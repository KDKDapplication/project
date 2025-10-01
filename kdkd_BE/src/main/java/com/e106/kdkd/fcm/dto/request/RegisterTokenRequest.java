package com.e106.kdkd.fcm.dto.request;

import jakarta.validation.constraints.NotBlank;

public record RegisterTokenRequest(
    @NotBlank String token
) {

}