package com.e106.kdkd.bank.dto;

import lombok.*;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AccountInquiryResponse {
    private String ownerName;      // 소유자명
    private String accountNumber;  // 계좌번호(복호화 컨버터 적용됨)
    private Long balance;          // 잔액(SSAFY 잔액 - total_use_payment)
}
