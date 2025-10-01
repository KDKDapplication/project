package com.e106.kdkd.children.dto.response;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class PaymentResponse {

    int totalPages;
    String childUuid;
    List<PaymentResponseItem> payments;
}
