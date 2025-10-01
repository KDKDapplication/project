package com.e106.kdkd.bank.dto;

import com.e106.kdkd.ssafy.dto.DemandDepositAccountBalance;
import com.e106.kdkd.ssafy.dto.ResponseEnvelope;
import lombok.*;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class BalanceWithOffsetsResponse {
    private ResponseEnvelope<DemandDepositAccountBalance> raw; // SSAFY 원본 응답
    private Integer totalUsePayment;  // sum(account.total_use_payment)
    private Long totalRemain;         // sum(save_box.remain)
    private Long diff;                // totalUsePayment - totalRemain
}
