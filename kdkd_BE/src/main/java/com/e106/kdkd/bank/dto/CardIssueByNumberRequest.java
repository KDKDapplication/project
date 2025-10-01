package com.e106.kdkd.bank.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CardIssueByNumberRequest {

    @NotBlank
    private String accountNumber; // 평문 계좌번호 (엔티티에 결정적 암호화 컨버터가 있어야 equality 조회 가능)
}
