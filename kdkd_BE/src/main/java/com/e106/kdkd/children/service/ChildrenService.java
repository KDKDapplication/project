package com.e106.kdkd.children.service;

import com.e106.kdkd.children.dto.request.ChildrenRegisterRequest;
import com.e106.kdkd.children.dto.response.CharactersResponse;
import com.e106.kdkd.children.dto.response.ChildrenRegisterResponse;
import com.e106.kdkd.children.dto.response.PaymentResponse;
import java.time.LocalDate;

public interface ChildrenService {

    ChildrenRegisterResponse registerChild(String childrenUuid, ChildrenRegisterRequest request);

    CharactersResponse getCharacters(String childrenUuid);

    PaymentResponse getPayments(String childUuid, LocalDate month, int pageNum,
        int display);
}
