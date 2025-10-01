package com.e106.kdkd.auth.dto.internal;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class TempSignupData {

    private final String tokenId;
    private final String googleSub;
    private final String email;
}