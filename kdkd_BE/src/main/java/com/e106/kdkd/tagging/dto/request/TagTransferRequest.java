package com.e106.kdkd.tagging.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class TagTransferRequest {

    @NotBlank(message = "받는 이(자녀)의 userUuid는 필수입니다.")
    private String childUuid;

    @NotNull(message = "송금하는 금액은 필수입니다.")
    @Positive
    private Long amount;
}
