package com.e106.kdkd.auth.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AuthResponse {
    private String accessToken;
    private String refreshToken;
    private String userUuid;
    /** 만료까지 남은 초 (클라이언트 편의) */
    private long expiresIn;
}