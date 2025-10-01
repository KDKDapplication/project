package com.e106.kdkd.tagging.service;

import com.e106.kdkd.tagging.dto.request.TagTransferRequest;

public interface TaggingService {

    void tagTransfer(TagTransferRequest request, String parentUuid);
}
