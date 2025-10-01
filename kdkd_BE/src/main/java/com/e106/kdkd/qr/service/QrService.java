package com.e106.kdkd.qr.service;

import com.e106.kdkd.qr.dto.request.RequestPayInfo;

public interface QrService {

    void processQrPayment(Long merchantId, RequestPayInfo requestPayInfo);

}
