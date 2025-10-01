package com.e106.kdkd.auth.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SignupTokenResponse {

    private boolean onboardingRequired;
    private String signupToken;
    private boolean isNewUser;
}