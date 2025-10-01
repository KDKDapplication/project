package com.e106.kdkd.ssafy.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class SsafyMemberResponse {

    private String userId;
    private String userName;
    private String userKey;
}
