package com.e106.kdkd.bank.service;

import com.e106.kdkd.account.repository.AccountRepository;
import com.e106.kdkd.bank.dto.*;
import com.e106.kdkd.boxes.repository.SaveBoxRepository;
import com.e106.kdkd.global.common.entity.Account;
import com.e106.kdkd.global.common.entity.SaveBox;
import com.e106.kdkd.global.common.entity.User;
import com.e106.kdkd.ssafy.dto.DemandDepositAccountBalance;
import com.e106.kdkd.ssafy.dto.ResponseEnvelope;
import com.e106.kdkd.ssafy.dto.card.CreateCreditCardRec;
import com.e106.kdkd.ssafy.dto.card.CreateCreditCardRequest;
import com.e106.kdkd.ssafy.service.BankService;
import com.e106.kdkd.ssafy.service.CreditCardService;
import com.e106.kdkd.users.repository.UserRepository;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class BankAccountServiceImpl implements BankAccountService {

    private final UserRepository userRepository;
    private final CreditCardService creditCardService;
    private final BankService bankService;
    private final AccountRepository accountRepository;
    private final SaveBoxRepository saveBoxRepository;


    @Value("${DEFAULT_CARD_UNIQUE_NO}")
    private String defaultCardUniqueNo;

    @Value("${DEFAULT_WITHDRAWAL_DATE}")
    private String defaultWithdrawalDate;

    @Transactional(readOnly = true)
    @Override
    public BalanceWithOffsetsResponse inquireDemandDepositAccountBalanceWithOffsets(String accountNo, String userUuid) {

        // 1) 외부 은행 API 호출 (기존 service 사용)
        ResponseEnvelope<DemandDepositAccountBalance> raw =
            bankService.inquireDemandDepositAccountBalance(accountNo, userUuid);

        // 2) 우리 DB 집계
        List<Account> accounts = accountRepository.findAllByUser_UserUuid(userUuid);
        int totalUsePayment = accounts.stream()
            .mapToInt(acc -> acc.getTotalUsePayment() != null ? acc.getTotalUsePayment() : 0)
            .sum();

        List<SaveBox> boxes = saveBoxRepository.findAllByChildren_UserUuid(userUuid);
        long totalRemain = boxes.stream()
            .mapToLong(SaveBox::getRemain)
            .sum();

        long diff = (long) totalUsePayment - totalRemain;

        log.info("[BalanceWithOffsets] userUuid={} totalUsePayment={} totalRemain={} diff={}",
            userUuid, totalUsePayment, totalRemain, diff);

        // 3) 조립 DTO 반환
        return BalanceWithOffsetsResponse.builder()
            .raw(raw)
            .totalUsePayment(totalUsePayment)
            .totalRemain(totalRemain)
            .diff(diff)
            .build();
    }


    @Override
    @Transactional(readOnly = true)
    public AccountInquiryResponse inquireMyAccount(String userUuid) {
        Account account = accountRepository.findByUser_UserUuid(userUuid);
        if (account == null) {
            throw new IllegalArgumentException("해당 사용자에 연결된 계좌가 없습니다.");
        }

        // SSAFY 실잔액 조회 (userUuid로 ssafy_user_key 내부에서 조회됨)
        ResponseEnvelope<DemandDepositAccountBalance> resp =
                bankService.inquireDemandDepositAccountBalance(account.getAccountNumber(), userUuid);

        long ssafyBalance = Long.parseLong(resp.getREC().getAccountBalance());
        long used = account.getTotalUsePayment() == null ? 0L : account.getTotalUsePayment().longValue();
        long adjusted = Math.max(ssafyBalance - used, 0L);

        return AccountInquiryResponse.builder()
                .ownerName(account.getUser().getName())
                .accountNumber(account.getAccountNumber())
                .balance(adjusted)
                .build();
    }

    @Override
    @Transactional
    public void delete(String userUuid, AccountDeleteRequest request) {
        // 1) 계좌 조회
        Account account = accountRepository.findByAccountNumber(request.getAccountNumber())
            .orElseThrow(() -> new IllegalArgumentException("계좌번호가 일치하는 계좌를 찾을 수 없습니다."));

        // 2) 소유자 검증
        if (account.getUser() == null || !userUuid.equals(account.getUser().getUserUuid())) {
            throw new IllegalArgumentException("해당 계좌의 소유자가 아닙니다.");
        }

        // 3) 하드 딜리트 (RESTRICT 정책: 참조 있으면 예외)
        try {
            accountRepository.delete(account);
            accountRepository.flush(); // FK 제약 빨리 감지
        } catch (DataIntegrityViolationException e) {
            throw new IllegalStateException("연관 데이터(거래내역/자동이체 등)로 인해 삭제할 수 없습니다. 먼저 관련 데이터를 정리하세요.", e);
        }
    }

    @Override
    @Transactional
    public CardIssueResponse issueCreditCardByAccountNumber(String accountNumber, String userUuid) {

        // 1) 계좌 조회
        Account account = accountRepository.findByAccountNumber(accountNumber)
            .orElseThrow(() -> new IllegalArgumentException("계좌번호가 일치하는 계좌를 찾을 수 없습니다."));

        // 소유자 검증
        if (account.getUser() == null || !userUuid.equals(account.getUser().getUserUuid())) {
            throw new IllegalArgumentException("해당 계좌의 소유자가 아닙니다.");
        }

        // 이미 발급됐다면 그대로 반환
        if (account.getVirtualCard() != null && !account.getVirtualCard().isEmpty()) {
            return CardIssueResponse.builder()
                .cardNo(account.getVirtualCard())
                .cvc(account.getVirtualCardCvc())
                .build();
        }

        // 외부 API 요청 바디
        CreateCreditCardRequest ssafyReq = CreateCreditCardRequest.builder()
            .cardUniqueNo(defaultCardUniqueNo)
            .withdrawalDate(defaultWithdrawalDate)
            .withdrawalAccountNo(account.getAccountNumber())
            .build();

        // userUuid를 넘긴다
        ResponseEnvelope<CreateCreditCardRec> ssafyResp =
            creditCardService.createCreditCard(ssafyReq, userUuid);

        CreateCreditCardRec rec = ssafyResp.getREC();

        // DB 업데이트
        account.setVirtualCard(rec.getCardNo());
        account.setVirtualCardCvc(rec.getCvc());
        accountRepository.save(account);

        // 응답
        return CardIssueResponse.builder()
            .cardNo(rec.getCardNo())
            .cvc(rec.getCvc())
            .build();
    }

    @Override
    @Transactional
    public AccountCreateResponse createAccount(AccountCreateRequest request) {
        // 1) user 조회
        User user = userRepository.findById(request.getUserUuid())
            .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 userUuid 입니다."));

        // 2) Account 생성
        Account account = Account.builder()
            .user(user)
            .accountNumber(request.getAccountNumber())
            .accountPassword(request.getAccountPassword())
            .bankName(request.getBankName())
            .totalUsePayment(0)
            .build();

        try {
            Account saved = accountRepository.save(account);

            return AccountCreateResponse.builder()
                .accountSeq(saved.getAccountSeq())
                .userUuid(user.getUserUuid())
                .bankName(saved.getBankName())
                .totalUsePayment(saved.getTotalUsePayment())
                .build();

        } catch (DataIntegrityViolationException e) {
            throw new IllegalStateException("이미 존재하는 계좌번호입니다.", e);
        }
    }
}
