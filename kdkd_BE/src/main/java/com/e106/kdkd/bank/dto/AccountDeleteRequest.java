package com.e106.kdkd.bank.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AccountDeleteRequest {

    @NotBlank(message = "계좌번호는 필수입니다.")
    private String accountNumber;
}
