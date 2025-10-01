package com.e106.kdkd.account.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class AutoTransferDeleteRequest {

    @NotBlank
    private String childUuid;
}
