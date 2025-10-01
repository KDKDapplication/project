package com.e106.kdkd.users.dto.response;

import com.e106.kdkd.global.common.enums.Role;
import java.time.LocalDate;

public record UserResponse(
    Role role,
    String uuid,
    String name,
    String profileImageUrl,   // presigned URL (없으면 null)
    Integer age,              // birthdate 없으면 null
    LocalDate birthdate,
    Boolean isConnected,
    String email
) {

}