package com.e106.kdkd.auth.dto.request;

import com.e106.kdkd.global.common.enums.Role;
import io.swagger.v3.oas.annotations.media.Schema;
import java.time.LocalDate;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OnboardRequest {

    @Schema(example = "signup-token-123")
    private String signupToken;   // TempSignupService가 발급한 token (client가 보관)

    @Schema(example = "CHILD")
    private Role role;

    @Schema(example = "홍길동")
    private String name;

    @Schema(example = "2010-01-01")
    private LocalDate birthdate;
}