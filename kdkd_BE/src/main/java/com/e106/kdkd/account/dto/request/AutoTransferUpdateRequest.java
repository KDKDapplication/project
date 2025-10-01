package com.e106.kdkd.account.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class AutoTransferUpdateRequest {

    @NotNull
    private String childUuid;

    @NotNull
    private Integer date;

    @NotNull
    private String hour;

    @NotNull
    private Long amount;
}
