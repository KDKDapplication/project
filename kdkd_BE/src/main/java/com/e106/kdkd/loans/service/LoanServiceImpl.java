package com.e106.kdkd.loans.service;

import com.e106.kdkd.account.repository.AccountRepository;
import com.e106.kdkd.alert.service.AlertService;
import com.e106.kdkd.fcm.service.FcmService;
import com.e106.kdkd.global.common.entity.Account;
import com.e106.kdkd.global.common.entity.Loan;
import com.e106.kdkd.global.common.entity.ParentRelation;
import com.e106.kdkd.global.common.entity.User;
import com.e106.kdkd.global.common.enums.LoanStatus;
import com.e106.kdkd.global.exception.PermissionDeniedException;
import com.e106.kdkd.global.exception.ResourceNotFoundException;
import com.e106.kdkd.global.exception.UserNotFoundException;
import com.e106.kdkd.global.repository.LoanRepository;
import com.e106.kdkd.loans.dto.response.RequestLoanInfo;
import com.e106.kdkd.loans.dto.resquest.LoanInfo;
import com.e106.kdkd.parents.repository.ParentRelationRepository;
import com.e106.kdkd.s3.service.S3Service;
import com.e106.kdkd.ssafy.service.backend.ApiAccountService;
import com.e106.kdkd.users.repository.UserRepository;
import com.google.firebase.messaging.FirebaseMessagingException;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@RequiredArgsConstructor
@Service
@Slf4j
public class LoanServiceImpl implements LoanService {

    private final LoanRepository loanRepository;
    private final ParentRelationRepository parentRelationRepository;
    private final S3Service s3Service;
    private final ApiAccountService apiAccountService;
    private final UserRepository userRepository;
    private final AccountRepository accountRepository;
    private final FcmService fcmService;
    private final AlertService alertService;

    @Transactional
    @Override
    public void createLoan(String childUuid, RequestLoanInfo requestLoanInfo) {
        log.debug("부모 자녀 연결 관계 확인");
        ParentRelation parentRelation = parentRelationRepository.findByChild_UserUuid(childUuid);
        if (parentRelation == null) {
            throw new ResourceNotFoundException("부모와의 연결 관계가 없는 자녀입니다.");
        }

        log.debug("이미 존재하는 빌리기 유무 확인");
        if (loanRepository.existsByRelation(parentRelation)) {
            throw new IllegalArgumentException("이미 빌리기 승인 대기 중이거나 빌리기 중입니다.");
        }

        log.debug("빌리기 db 저장");
        Loan loan = new Loan(parentRelation, requestLoanInfo);
        loanRepository.save(loan);

        User child = userRepository.findById(childUuid).orElseThrow(
            () -> new UserNotFoundException("존재하지 않는 user입니다."));
        String parentUuid = parentRelation.getParent().getUserUuid();

        log.debug("알림 전송");
        String message = String.format("자녀 %s(이)가 빌리기 신청하였습니다.", child.getName());
        try {
            fcmService.sendToUser(parentUuid, "빌리기 신청",
                message);

        } catch (FirebaseMessagingException e) {
            log.warn("[FCM] 자녀 빌리기 알림 전송 실패: parentUuid={}, err={}", parentUuid, e.getMessage());
        }

        // 알림 DB에 저장
        alertService.createAlert(childUuid, parentUuid, message);

    }

    @Transactional
    @Override
    public void payBackLoan(String childUuid, String loanUuid) {
        Loan loan = loanRepository.findById(loanUuid).orElseThrow(
            () -> new ResourceNotFoundException("존재하지 않는 missionUuid 입니다."));

        Long totalPayBackAmount = loan.getLoanAmount() + calculateInterestAmount(loan);
        log.debug("갚을 총 금액 : {}", totalPayBackAmount);

        //loan 데이터 삭제
        loanRepository.deleteById(loanUuid);

        log.debug("부모와 자녀 User 엔티티 조회");
        User parent = loan.getRelation().getParent();
        User child = loan.getRelation().getChild();

        log.debug("부모와 자녀 Account 엔티티 조회");
        Account parentAccount = accountRepository.findByUser(parent);
        Account childAccount = accountRepository.findByUser(child);

        log.debug("대출금+이자 계좌 이체");
        apiAccountService.customChildAccountTransfer(childAccount, parentAccount,
            loan.getLoanAmount(),
            child, "(수시입출금) : 입금(원리금 이체)",
            "(수시입출금) : 출금(원리금 이체)");


    }

    @Override
    public LoanInfo queryLoan(String childUuid) {
        log.debug("부모 자녀 연결 관계 확인");
        ParentRelation parentRelation = parentRelationRepository.findByChild_UserUuid(childUuid);
        if (parentRelation == null) {
            throw new ResourceNotFoundException("부모와의 연결 관계가 없는 자녀입니다.");
        }

        LoanInfo loanInfo = new LoanInfo();
        Loan loan = loanRepository.findByRelation(parentRelation);

        log.debug("NOT_APPLIED의 경우 데이터 적용");
        if (loan == null) {
            loanInfo.setLoanStatus(LoanStatus.NOT_APPLIED);
            return loanInfo;
        }

        log.debug("WAITING_APPROVAL, ACTIVE 중복 loanInfo 데이터 설정");
        loanInfo.applyLoanInfo(loan);

        log.debug("WAITING_APPROVAL, ACTIVE 구별 데이터 적용");
        if (loan.isLoaned()) {
            loanInfo.setLoanStatus(LoanStatus.ACTIVE);
            loanInfo.setCurrentInterestAmount(calculateInterestAmount(loan));
        } else {
            loanInfo.setLoanStatus(LoanStatus.WAITING_APPROVAL);
        }

        return loanInfo;
    }

    @Transactional
    @Override
    public void acceptLoan(String parentUuid, String loanUuid) {
        log.debug("빌리기 조회");
        Loan loan = loanRepository.findById(loanUuid).orElseThrow(
            () -> new ResourceNotFoundException("해당 loanUuid에 해당하는 빌리기는 존재하지 않습니다."));

        log.debug("해당 부모의 해당 빌리기 권한 검증");
        if (!loan.getRelation().getParent().getUserUuid().equals(parentUuid)) {
            throw new PermissionDeniedException("해당 부모 유저가 해당 빌리기를 수락할 권한이 없습니다.");
        }

        log.debug("더티체크 업데이트");
        loan.setLoaned(true);
        loan.setLoanDate(LocalDate.now());

        log.debug("부모와 자녀 User 엔티티 조회");
        User parent = loan.getRelation().getParent();
        User child = loan.getRelation().getChild();

        log.debug("부모와 자녀 Account 엔티티 조회");
        Account parentAccount = accountRepository.findByUser(parent);
        Account childAccount = accountRepository.findByUser(child);

        log.debug("대출금 계좌 이체");
        apiAccountService.customAccountTransfer(parentAccount, childAccount, loan.getLoanAmount(),
            parent.getSsafyUserKey(), "(수시입출금) : 입금(대출 금액 이체)",
            "(수시입출금) : 출금(대출 금액 이체)");

    }

    @Transactional
    @Override
    public void rejectLoan(String parentUuid, String loanUuid) {
        log.debug("빌리기 조회");
        Loan loan = loanRepository.findById(loanUuid).orElseThrow(
            () -> new ResourceNotFoundException("해당 loanUuid에 해당하는 빌리기는 존재하지 않습니다."));

        log.debug("해당 부모의 해당 빌리기 권한 검증");
        if (!loan.getRelation().getParent().getUserUuid().equals(parentUuid)) {
            throw new PermissionDeniedException("해당 부모 유저가 해당 빌리기를 거절할 권한이 없습니다.");
        }

        log.debug("빌리기 삭제");
        loanRepository.deleteById(loanUuid);

    }

    @Transactional
    @Override
    public void deleteLoan(String parentUuid, String loanUuid) {
        log.debug("빌리기 조회");
        Loan loan = loanRepository.findById(loanUuid).orElseThrow(
            () -> new ResourceNotFoundException("해당 loanUuid에 해당하는 빌리기는 존재하지 않습니다."));

        log.debug("해당 부모의 해당 빌리기 권한 검증");
        if (!loan.getRelation().getParent().getUserUuid().equals(parentUuid)) {
            throw new PermissionDeniedException("해당 부모 유저가 해당 빌리기를 삭제할 권한이 없습니다.");
        }

        log.debug("빌리기 삭제");
        loanRepository.deleteById(loanUuid);
    }

    private Long calculateInterestAmount(Loan loan) {
        double rate = loan.getLoanInterest() / 100.0; // 2 -> 0.02
        long days = ChronoUnit.DAYS.between(loan.getLoanDate(), LocalDate.now());

        double interest = loan.getLoanAmount() * rate * (days / 365.0);
        long currentInterestAmount = Math.round(interest); // 반올림 정책에 맞게 변경
        return currentInterestAmount;
    }
}
