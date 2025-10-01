package com.e106.kdkd.temptest.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class RequestTestAccountInfo {

    @NotBlank
    String accountNumber;
    @NotBlank
    String virtualCard;
    @NotBlank
    String virtualCardCvc;
    @NotBlank
    String userUuid;
    @NotBlank
    String accountPassord;
    @NotBlank
    String bankName;
}
