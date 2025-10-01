package com.e106.kdkd.children.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class ChildrenRegisterRequest {

    @NotBlank(message = "등록 코드는 필수입니다.")
    @Schema(description = "부모가 발급한 자녀 등록 코드", example = "abcd1234abcd1234")
    private String code;
}