package com.e106.kdkd.qr.service;

import com.e106.kdkd.account.repository.AccountItemRepository;
import com.e106.kdkd.account.repository.AccountRepository;
import com.e106.kdkd.alert.service.AlertService;
import com.e106.kdkd.fcm.service.FcmService;
import com.e106.kdkd.global.common.entity.Account;
import com.e106.kdkd.global.common.entity.AccountItem;
import com.e106.kdkd.global.common.entity.ParentRelation;
import com.e106.kdkd.global.common.entity.User;
import com.e106.kdkd.global.exception.ResourceNotFoundException;
import com.e106.kdkd.global.exception.UserNotFoundException;
import com.e106.kdkd.parents.repository.ParentRelationRepository;
import com.e106.kdkd.qr.dto.request.RequestPayInfo;
import com.e106.kdkd.ssafy.dto.card.CreateCreditCardTransactionRec;
import com.e106.kdkd.ssafy.service.backend.ApiAccountService;
import com.e106.kdkd.ssafy.service.backend.ApiCardService;
import com.e106.kdkd.users.repository.UserRepository;
import com.google.firebase.messaging.FirebaseMessagingException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class QrServiceImpl implements QrService {

    private final UserRepository userRepository;
    private final AccountRepository accountRepository;
    private final ApiAccountService apiAccountService;
    private final ApiCardService apiCardService;
    private final AccountItemRepository accountItemRepository;
    private final ParentRelationRepository parentRelationRepository;
    private final FcmService fcmService;
    private final AlertService alertService;

    @Transactional
    @Override
    public void processQrPayment(Long merchantId, RequestPayInfo requestPayInfo) {
        User user = userRepository.findById(requestPayInfo.getUserUuid()).orElseThrow(
            () -> new UserNotFoundException("존재하지 않는 userUuid 입니다."));

        Account account = accountRepository.findByUser(user);
        if (account == null) {
            throw new ResourceNotFoundException("해당 user의 계좌가 존재하지 않습니다.");
        }

        log.debug("거래 가능한지 계좌 잔액 조회");
        apiAccountService.checkUserCanTransfer(user,
            account, requestPayInfo.getPayAmount());

        log.debug("카드 결제");
        CreateCreditCardTransactionRec rec = apiCardService.createCreditCardTransaction(
            user.getSsafyUserKey(), account.getVirtualCard(),
            account.getVirtualCardCvc(), merchantId.toString(),
            requestPayInfo.getPayAmount().toString());

        log.debug("accountItem 생성");
        AccountItem accountItem = new AccountItem(rec);
        accountItem.setAccount(account);
        accountItem.setLatitude(requestPayInfo.getLatitude());
        accountItem.setLongitude(requestPayInfo.getLongitude());
        accountItemRepository.save(accountItem);

        account.setTotalUsePayment(account.getTotalUsePayment() +
            requestPayInfo.getPayAmount().intValue());

        ParentRelation relation = parentRelationRepository.findByChild_UserUuid(user.getUserUuid());
        User parent = relation.getParent();

        log.debug("부모에게 알림 전송");
        String message = String.format("자녀 %s(이)가 결제하였습니다.", user.getName());
        try {
            fcmService.sendToUser(parent.getUserUuid(), "결제 완료",
                message);

        } catch (FirebaseMessagingException e) {
            log.warn("[FCM] 부모에게 자녀 결제 알림 전송 실패: parentUuid={}, err={}", parent.getUserUuid(),
                e.getMessage());
        }

        // 알림 DB에 저장
        alertService.createAlert(user.getUserUuid(), parent.getUserUuid(), message);

        log.debug("자녀에게 알림 전송");
        String messageToChild = String.format(" %s(이)님의 결제가 완료되었습니다.", user.getName());
        try {
            fcmService.sendToUser(user.getUserUuid(), "결제 완료",
                message);

        } catch (FirebaseMessagingException e) {
            log.warn("[FCM] 자녀에게 자신에게 결제 알림 전송 실패: childUuid={}, err={}", user.getUserUuid(),
                e.getMessage());
        }

        // 알림 DB에 저장
        alertService.createAlert(user.getUserUuid(), user.getUserUuid(), message);
    }
}
