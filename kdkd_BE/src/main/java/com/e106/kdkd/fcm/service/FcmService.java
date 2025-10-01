package com.e106.kdkd.fcm.service;

import com.e106.kdkd.fcm.dto.request.RegisterTokenRequest;
import com.e106.kdkd.fcm.dto.request.ToMultiRequest;
import com.e106.kdkd.fcm.dto.request.ToSingleRequest;
import com.e106.kdkd.fcm.dto.request.UnregisterTokenRequest;
import com.e106.kdkd.fcm.dto.response.MultiFcmResponse;
import com.e106.kdkd.fcm.dto.response.RegisterTokenResponse;
import com.e106.kdkd.fcm.dto.response.SingleFcmResponse;
import com.google.firebase.messaging.FirebaseMessagingException;

public interface FcmService {

    SingleFcmResponse sendSingleDevice(ToSingleRequest toSingleRequest)
        throws FirebaseMessagingException;

    MultiFcmResponse sendMultipleDevices(ToMultiRequest toMultiRequest)
        throws FirebaseMessagingException;

    RegisterTokenResponse registerToken(String userUuid, RegisterTokenRequest req);

    int unregisterToken(String userUuid, UnregisterTokenRequest req);

    MultiFcmResponse sendToUser(String userUuid, String title, String body)
        throws FirebaseMessagingException;
}
