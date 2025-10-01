package com.e106.kdkd.auth.dto.internal;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class KakaoUserInfo {

    private String id;            // kakao user id (문자열로 보관)
    private String email;         // null 가능
    private Boolean emailVerified; // null 가능(카카오는 미제공일 수 있음)

}
