package com.e106.kdkd.global.security;

import com.e106.kdkd.global.common.enums.Role;

public record CustomPrincipal(String userUuid, String email, Role role) {

}
