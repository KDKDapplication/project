package com.e106.kdkd.account.service;

import com.e106.kdkd.account.dto.request.AutoTransferCreateRequest;
import com.e106.kdkd.account.dto.request.AutoTransferDeleteRequest;
import com.e106.kdkd.account.dto.request.AutoTransferUpdateRequest;
import com.e106.kdkd.account.dto.respoonse.AutoTransferListResponse;

public interface AutoTransferService {

    String create(String parentUuid, AutoTransferCreateRequest req);

    AutoTransferListResponse listForParent(String parentUuid);

    void update(String parentUuid, AutoTransferUpdateRequest request);

    void delete(String parentUuid, AutoTransferDeleteRequest request);

    Long queryChildAutoTransferAmount(String childUuid);
}
