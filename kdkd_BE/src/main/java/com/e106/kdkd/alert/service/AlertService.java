package com.e106.kdkd.alert.service;

import com.e106.kdkd.alert.dto.response.GetAlertResponse;

public interface AlertService {

    void createAlert(String senderUuid, String receiverUuid, String content);

    GetAlertResponse getAlerts(String userUuid, int pageNum, int display);

    void deleteAlert(String userUuid, String alertUuid);

    int deleteAllAlert(String userUuid);
}
