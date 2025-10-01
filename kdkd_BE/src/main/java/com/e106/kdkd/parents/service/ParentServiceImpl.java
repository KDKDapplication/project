package com.e106.kdkd.parents.service;

import com.e106.kdkd.account.repository.AccountItemRepository;
import com.e106.kdkd.account.repository.AccountRepository;
import com.e106.kdkd.account.repository.AutoTransferRepository;
import com.e106.kdkd.global.common.entity.Account;
import com.e106.kdkd.global.common.entity.AccountItem;
import com.e106.kdkd.global.common.entity.ParentRelation;
import com.e106.kdkd.global.common.entity.User;
import com.e106.kdkd.global.exception.EntityAlreadyExistsException;
import com.e106.kdkd.global.exception.ResourceNotFoundException;
import com.e106.kdkd.global.exception.UserNotFoundException;
import com.e106.kdkd.parents.dto.response.AutoTransferAmountResponse;
import com.e106.kdkd.parents.dto.response.ChildAccount;
import com.e106.kdkd.parents.dto.response.ChildPattern;
import com.e106.kdkd.parents.dto.response.ChildPaymentDetail;
import com.e106.kdkd.parents.dto.response.ChildPaymentinfo;
import com.e106.kdkd.parents.dto.response.TwoMonthPattern;
import com.e106.kdkd.parents.exception.RelationNotFoundException;
import com.e106.kdkd.parents.repository.ParentRelationRepository;
import com.e106.kdkd.parents.util.PatternAnalysisService;
import com.e106.kdkd.ssafy.service.backend.ApiAccountService;
import com.e106.kdkd.users.repository.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import jakarta.persistence.NonUniqueResultException;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class ParentServiceImpl implements ParentService {

    private final AutoTransferRepository autoTransferRepository;
    private final ParentRelationRepository parentRelationRepository;
    private final UserRepository userRepository;
    private final AccountRepository accountRepository;
    private final ApiAccountService apiAccountService;
    private final AccountItemRepository accountItemRepository;
    private final PatternAnalysisService patternAnalysisService;


    @Transactional
    @Override
    public void registerChild(String parentUuid, String childUuid) {
        log.debug("부모와 자식 uuid 비교");
        if (parentUuid.equals(childUuid)) {
            throw new IllegalArgumentException("부모와 자녀가 동일할 수 없습니다.");
        }

        log.debug("이미 존재하는 관계인지 확인");
        if (parentRelationRepository
            .existsByParent_UserUuidAndChild_UserUuid(parentUuid, childUuid)) {
            throw new EntityAlreadyExistsException("이미 존재하는 부모 자녀 관계입니다."); // 409
        }

        log.debug("부모와 자식 객체 로드");
        User parent = userRepository.findById(parentUuid)
            .orElseThrow(() -> new UserNotFoundException(parentUuid));
        User child = userRepository.findById(childUuid)
            .orElseThrow(() -> new UserNotFoundException(childUuid));

        log.debug("ParentRelation Entitiy 생성");
        ParentRelation relation = ParentRelation.builder()
            .relationUuid(UUID.randomUUID().toString()) // @GeneratedValue 없으니 직접 생성
            .parent(parent)
            .child(child)
            .build();

        log.debug("생성한 Entity db 저장");
        parentRelationRepository.save(relation);
    }

    @Override
    public List<ChildAccount> queryChildAccounts(String parentUuid) {
        log.debug("자녀 관계 조회");
        List<ParentRelation> parentRelations = parentRelationRepository.findAllByParent_UserUuid(
            parentUuid);

        List<ChildAccount> childAccounts = new ArrayList<>();

        for (ParentRelation relation : parentRelations) {
            log.debug("자녀의 account entity 조회");
            Account account = accountRepository.findByUser_UserUuid(
                relation.getChild().getUserUuid());

            ChildAccount childAccount = new ChildAccount();

            childAccount.setChildUuid(relation.getChild().getUserUuid());
            childAccount.setChildName(relation.getChild().getName());

            log.debug("자녀 account 설정");
            if (account != null) {
                childAccount.setChildAccountNumber(account.getAccountNumber());
                childAccount.setAccountSeq(account.getAccountSeq());

                //ssafy 계좌 잔액 조회
                String ssafyRemain = apiAccountService
                    .inquireDemandDepositAccountBalance(relation.getChild().getSsafyUserKey(),
                        account.getAccountNumber())
                    .getAccountBalance();

                //카드 사용료 제외한 잔액 설정
                childAccount.setChildRemain(
                    calculateRemainAmount(ssafyRemain, account.getTotalUsePayment()));
            }
            childAccounts.add(childAccount);
        }
        return childAccounts;
    }

    @Override
    public List<ChildPaymentinfo> queryChildPayments(String childUuid, LocalDate date) {
        List<ChildPaymentinfo> childPayments = new ArrayList<>();

        log.debug("자녀 계좌 조회");
        Account account = accountRepository.findByUser_UserUuid(childUuid);
        if (account == null) {
            throw new EntityNotFoundException("해당 자녀의 계좌는 존재하지 않습니다.");
        }

        log.debug("accountItems 조회");
        List<AccountItem> accountItems = accountItemRepository.findAllByAccountSeqAndDate(
            account.getAccountSeq(), date);

        for (AccountItem item : accountItems) {
            ChildPaymentinfo childPayment = new ChildPaymentinfo(item);
            childPayment.setChildUuid(childUuid);
            childPayments.add(childPayment);
        }
        return childPayments;
    }

    @Override
    public void isLinked(String parentUuid, String childUuid) {
        if (!parentRelationRepository.existsByParent_UserUuidAndChild_UserUuid(parentUuid,
            childUuid)) {
            throw new RelationNotFoundException("해당 자녀에 대한 접근 권한이 없는 부모입니다.");
        }
    }

    @Override
    public ChildPaymentDetail queryChildPaymentDetail(String childUuid, Long accountItemSeq) {
        log.debug("거래내역 조회");
        AccountItem accountItem = accountItemRepository.findById(accountItemSeq)
            .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 거래내역입니다."));

        ChildPaymentDetail childPaymentDetail = new ChildPaymentDetail(accountItem);
        return childPaymentDetail;
    }

    @Override
    public void checkRelation(String parentUuid, String childUuid) {
        Long count = parentRelationRepository.countByParent_UserUuidAndChild_UserUuid(parentUuid,
            childUuid);
        if (count == 0) {
            throw new RelationNotFoundException("연관되지 않은 자녀와 부모 입니다.");
        } else if (count > 1) {
            throw new NonUniqueResultException("연관 관계 결과가 유니크해야 하지만 여러 건이 반환되었습니다");
        }

    }

    @Override
    public TwoMonthPattern queryChildPattern(String childUuid, YearMonth yearMonth) {
        Account account = accountRepository.findByUser_UserUuid(childUuid);
        if (account == null) {
            throw new ResourceNotFoundException("해당 자녀의 계좌가 존재하지 않습니다.");
        }

        log.debug("ChildPattern 생성");
        ChildPattern thisPattern = patternAnalysisService.classifyCategory(account.getAccountSeq(),
            yearMonth);
        ChildPattern lastPattern = patternAnalysisService.classifyCategory(account.getAccountSeq(),
            yearMonth.minusMonths(1));

        log.debug("summary 생성");
        String summary = patternAnalysisService.classifyConsumptionTendency(thisPattern);

        TwoMonthPattern twoMonthPattern = new TwoMonthPattern(lastPattern, thisPattern, summary);
        return twoMonthPattern;
    }

    @Override
    public AutoTransferAmountResponse getAutoTransferAmount(String parentUuid) {
        List<ParentRelation> relations = parentRelationRepository.findAllByParent_UserUuid(
            parentUuid);

        Long total = autoTransferRepository.sumByParentUuid(parentUuid);

        return AutoTransferAmountResponse.builder()
            .totalAmount(total)
            .build();
    }

    public Integer calculateRemainAmount(String strNumber, Integer value) {
        if (strNumber == null || value == null) {
            return null; // 안전 처리
        }

        try {
            // String → int 변환
            int num = Integer.parseInt(strNumber);
            // 연산 후 결과를 Integer로 반환 (자동 박싱)
            return num - value;
        } catch (NumberFormatException e) {
            // strNumber가 정수 형태가 아닐 경우
            throw new IllegalArgumentException("입력 문자열이 정수가 아닙니다: " + strNumber, e);
        }
    }

}
