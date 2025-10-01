package com.e106.kdkd.temptest.dto;

import com.e106.kdkd.global.common.enums.Provider;
import com.e106.kdkd.global.common.enums.Role;
import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Past;
import jakarta.validation.constraints.Size;
import java.time.LocalDate;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class RequestTestUserInfo {

    @NotBlank(message = "이름은 필수입니다.")
    @Size(max = 100, message = "이름은 100자 이하로 입력하세요.")
    private String name;

    @NotNull(message = "생년월일은 필수입니다.")
    @Past(message = "생년월일은 오늘보다 이전이어야 합니다.")
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
    @Schema(type = "string", format = "date", example = "2012-03-15")
    private LocalDate birthday;

    @NotBlank(message = "이메일은 필수입니다.")
    @Size(max = 255)
    private String email;

    @NotNull(message = "역할(role)은 필수입니다.")
    private Role role;

    @NotNull(message = "provider는 필수입니다.")
    private Provider provider;

    @NotBlank(message = "providerId는 필수입니다.")
    private String providerId;

    @NotBlank(message = "ssafyUserKey는 필수입니다.")
    @Schema(description = "SSAFY API에서 발급된 사용자 키")
    private String ssafyUserKey;
}

