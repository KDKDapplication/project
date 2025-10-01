package com.e106.kdkd.account.dto.request;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import lombok.Data;

@Data
public class AutoTransferCreateRequest {

    @NotBlank
    private String childUuid;

    @Min(1)
    @Max(31)
    private int date;

    @NotBlank
    private String hour;

    @NotNull
    @PositiveOrZero
    private Long amount;
}
