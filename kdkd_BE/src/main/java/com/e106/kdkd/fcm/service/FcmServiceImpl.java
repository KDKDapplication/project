package com.e106.kdkd.fcm.service;

import com.e106.kdkd.fcm.dto.request.RegisterTokenRequest;
import com.e106.kdkd.fcm.dto.request.ToMultiRequest;
import com.e106.kdkd.fcm.dto.request.ToSingleRequest;
import com.e106.kdkd.fcm.dto.request.UnregisterTokenRequest;
import com.e106.kdkd.fcm.dto.response.MultiFcmResponse;
import com.e106.kdkd.fcm.dto.response.RegisterTokenResponse;
import com.e106.kdkd.fcm.dto.response.SingleFcmResponse;
import com.e106.kdkd.fcm.entity.UserDeviceToken;
import com.e106.kdkd.fcm.repository.UserDeviceTokenRepository;
import com.google.firebase.messaging.AndroidConfig;
import com.google.firebase.messaging.AndroidNotification;
import com.google.firebase.messaging.ApnsConfig;
import com.google.firebase.messaging.Aps;
import com.google.firebase.messaging.BatchResponse;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.MessagingErrorCode;
import com.google.firebase.messaging.MulticastMessage;
import com.google.firebase.messaging.Notification;
import com.google.firebase.messaging.SendResponse;
import java.util.ArrayList;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class FcmServiceImpl implements FcmService {

    private static final String ANDROID_CHANNEL_ID = "high_importance_channel";

    private final FirebaseMessaging firebaseMessaging;
    private final UserDeviceTokenRepository userDeviceTokenRepository;

    @Override
    public SingleFcmResponse sendSingleDevice(ToSingleRequest req)
        throws FirebaseMessagingException {

        Notification notification = Notification.builder()
            .setTitle(req.getTitle())
            .setBody(req.getBody())
            .build();

        AndroidConfig android = AndroidConfig.builder()
            .setPriority(AndroidConfig.Priority.HIGH)
            .setNotification(AndroidNotification.builder()
                .setChannelId(ANDROID_CHANNEL_ID)
                .build())
            .build();

        ApnsConfig apns = ApnsConfig.builder()
            .putHeader("apns-priority", "10")
            .setAps(Aps.builder().build())
            .build();

        Message message = Message.builder()
            .setToken(req.getRegistrationToken())
            .setNotification(notification)
            .setAndroidConfig(android)
            .setApnsConfig(apns)
            .build();

        String messageId = firebaseMessaging.send(message);
        return new SingleFcmResponse(messageId);
    }

    @Transactional
    @Override
    public MultiFcmResponse sendMultipleDevices(ToMultiRequest req)
        throws FirebaseMessagingException {

        Notification notification = Notification.builder()
            .setTitle(req.getTitle())
            .setBody(req.getBody())
            .build();

        AndroidConfig android = AndroidConfig.builder()
            .setPriority(AndroidConfig.Priority.HIGH)
            .setNotification(AndroidNotification.builder()
                .setChannelId(ANDROID_CHANNEL_ID)
                .build())
            .build();

        ApnsConfig apns = ApnsConfig.builder()
            .putHeader("apns-priority", "10")
            .setAps(Aps.builder().build())
            .build();

        MulticastMessage message = MulticastMessage.builder()
            .addAllTokens(req.getRegistrationToken())
            .setNotification(notification)
            .setAndroidConfig(android)
            .setApnsConfig(apns)
            .build();

        BatchResponse response = firebaseMessaging.sendEachForMulticast(message);

        List<String> failed = new ArrayList<>();
        if (response.getFailureCount() > 0) {
            List<SendResponse> rs = response.getResponses();
            for (int i = 0; i < rs.size(); i++) {
                if (!rs.get(i).isSuccessful()) {
                    String badToken = req.getRegistrationToken().get(i);
                    failed.add(badToken);

                    // 무효 토큰 제거
                    Exception ex = rs.get(i).getException();
                    if (ex instanceof FirebaseMessagingException fme) {
                        MessagingErrorCode code = fme.getMessagingErrorCode();
                        if (code == MessagingErrorCode.UNREGISTERED
                            || code == MessagingErrorCode.INVALID_ARGUMENT
                            || code == MessagingErrorCode.SENDER_ID_MISMATCH) {
                            try {
                                userDeviceTokenRepository.deleteByToken(badToken);
                                log.info("[FCM] invalid token removed: {}", badToken);
                            } catch (Exception ignore) {
                                log.warn("[FCM] failed to remove token: {}", badToken);
                            }
                        } else {
                            log.warn("[FCM] send fail ({}): {} - {}", code, badToken,
                                fme.getMessage());
                        }
                    } else {
                        log.warn("[FCM] send fail: {} - {}", badToken,
                            ex != null ? ex.getMessage() : "unknown");
                    }
                }
            }
        }

        String msg = String.format("%d개의 메시지가 성공적으로 전송되었습니다.", response.getSuccessCount());
        return new MultiFcmResponse(msg, failed);
    }

    // 클라이언트 발급 코드 등록, 삭제

    @Transactional
    @Override
    public RegisterTokenResponse registerToken(String userUuid, RegisterTokenRequest req) {
        // 같은 토큰이 이미 있으면 사용자/플랫폼만 업데이트
        var existing = userDeviceTokenRepository.findByToken(req.token()).orElse(null);
        if (existing != null) {
            existing.setUserUuid(userUuid);
            return new RegisterTokenResponse(existing.getId());
        }
        // 신규 저장
        var saved = userDeviceTokenRepository.save(UserDeviceToken.builder()
            .userUuid(userUuid)
            .token(req.token())
            .build());
        return new RegisterTokenResponse(saved.getId());
    }

    @Transactional
    @Override
    public int unregisterToken(String userUuid, UnregisterTokenRequest req) {
        var row = userDeviceTokenRepository.findByToken(req.token()).orElse(null);
        if (row != null && row.getUserUuid().equals(userUuid)) {
            userDeviceTokenRepository.delete(row);
            return 1;
        }
        return 0;
    }

    // 특정 유저에게 전송
    @Transactional
    @Override
    public MultiFcmResponse sendToUser(String userUuid, String title, String body)
        throws FirebaseMessagingException {
        var tokens = userDeviceTokenRepository.findByUserUuid(userUuid)
            .stream().map(UserDeviceToken::getToken).toList();
        if (tokens.isEmpty()) {
            return new MultiFcmResponse("전송 대상 토큰이 없습니다.", List.of());
        }
        return sendMultipleDevices(new ToMultiRequest(tokens, title, body));
    }
}
