package com.e106.kdkd.users.dto.request;

import jakarta.validation.constraints.Pattern;
import lombok.Getter;

@Getter
public class UserUpdateRequest {

    private String name;

    @Pattern(regexp = "^\\d{4}-\\d{2}-\\d{2}$",
        message = "YYYY-MM-DD 형식")
    private String birthdate;
}
