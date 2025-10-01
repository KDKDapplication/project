package com.e106.kdkd.bank.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AccountCreateRequest {

    @NotBlank(message = "userUuid는 필수입니다.")
    private String userUuid;

    @NotBlank(message = "accountNumber는 필수입니다.")
    private String accountNumber;

    @NotBlank(message = "accountPassword는 필수입니다.")
    @Pattern(regexp = "^\\d{4}$", message = "accountPassword는 4자리 숫자여야 합니다.")
    private String accountPassword;

    @NotBlank(message = "bankName은 필수입니다.")
    private String bankName;
}
