package com.e106.kdkd.children.dto.response;

import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class PaymentResponseItem {

    Long accountItemSeq;
    String merchantName;
    int paymentBalance;
    LocalDateTime transactedAt;
}
