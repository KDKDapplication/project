package com.e106.kdkd.tagging.service;

import com.e106.kdkd.account.repository.AccountRepository;
import com.e106.kdkd.alert.service.AlertService;
import com.e106.kdkd.fcm.service.FcmService;
import com.e106.kdkd.global.common.entity.Account;
import com.e106.kdkd.global.common.entity.User;
import com.e106.kdkd.global.exception.UserNotFoundException;
import com.e106.kdkd.ssafy.jpa.SsafyUserRepository;
import com.e106.kdkd.ssafy.service.backend.ApiAccountService;
import com.e106.kdkd.tagging.dto.request.TagTransferRequest;
import com.e106.kdkd.users.repository.UserRepository;
import com.google.firebase.messaging.FirebaseMessagingException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class TaggingServiceImpl implements TaggingService {

    private final ApiAccountService apiAccountService;
    private final AccountRepository accountRepository;
    private final SsafyUserRepository ssafyUserRepository;
    private final UserRepository userRepository;
    private final FcmService fcmService;
    private final AlertService alertService;

    @Transactional
    @Override
    public void tagTransfer(TagTransferRequest request, String parentUuid) {
        String childUuid = request.getChildUuid();
        Long amount = request.getAmount();

        Account parentAccount = accountRepository.findByUser_UserUuid(parentUuid);
        Account childAccount = accountRepository.findByUser_UserUuid(childUuid);

        String parentUserKey = ssafyUserRepository.findSsafyUserKeyByUserUuid(parentUuid)
            .orElseThrow(() -> new IllegalArgumentException("사용자의 user Key가 존재하지 않습니다."));

        String depositTransactionSummary = "태깅 입금(이체)";
        String withdrawalTransactionSummary = "태깅 송금(이체)";
        apiAccountService.customAccountTransfer(parentAccount, childAccount, amount, parentUserKey,
            depositTransactionSummary, withdrawalTransactionSummary);

        User child = userRepository.findById(childUuid).orElseThrow(
            () -> new UserNotFoundException("존재하지 않는 child userUuid입니다."));
        User parent = userRepository.findById(parentUuid).orElseThrow(
            () -> new UserNotFoundException("존재하지 않는 parent userUuid입니다."));

        log.debug("자녀 알림 전송");
        String message = String.format("부모 %s(이)가 태깅 용돈 이체를 하였습니다.", parent.getName());
        try {
            fcmService.sendToUser(childUuid, "태깅 용돈 이체",
                message);

        } catch (FirebaseMessagingException e) {
            log.warn("[FCM] 자녀 태깅 용돈 이체 알림 전송 실패: childUuid={}, err={}", childUuid, e.getMessage());
        }
        // 알림 DB에 저장
        alertService.createAlert(parentUuid, childUuid, message);

    }


}
