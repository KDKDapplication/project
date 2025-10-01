package com.e106.kdkd.fcm.dto.response;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class MultiFcmResponse {

    private String message;
    private List<String> failedTokens;
}
