package com.e106.kdkd.alert.service;

import com.e106.kdkd.alert.dto.response.GetAlertResponse;
import com.e106.kdkd.alert.dto.response.GetAlertResponseItem;
import com.e106.kdkd.alert.repository.AlertRepository;
import com.e106.kdkd.global.common.entity.Alert;
import com.e106.kdkd.global.common.entity.User;
import com.e106.kdkd.users.repository.UserRepository;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class AlertServiceImpl implements AlertService {

    private final AlertRepository alertRepository;
    private final UserRepository userRepository;

    @Override
    public void createAlert(String senderUuid, String receiverUuid, String content) {
        User senderRef = userRepository.getReferenceById(senderUuid);
        User receiverRef = userRepository.getReferenceById(receiverUuid);

        Alert alert = Alert.builder()
            .alertUuid(UUID.randomUUID().toString())
            .sender(senderRef)
            .receiver(receiverRef)
            .content(content)
            .build();

        alertRepository.save(alert);
    }

    @Override
    public GetAlertResponse getAlerts(String userUuid, int pageNum, int display) {
        Pageable pageable = PageRequest.of(pageNum, display);

        Page<GetAlertResponseItem> page = alertRepository.findAllByUserUuid(userUuid, pageable);

        return GetAlertResponse.builder()
            .totalPages(page.getTotalPages())
            .alerts(page.getContent())
            .build();
    }

    @Transactional
    @Override
    public void deleteAlert(String userUuid, String alertUuid) {
        alertRepository.deleteAlertByUuidAndReceiver(alertUuid, userUuid);
    }

    @Transactional
    @Override
    public int deleteAllAlert(String userUuid) {
        return alertRepository.deleteAlertsByReceiver_UserUuid(userUuid);
    }
}
