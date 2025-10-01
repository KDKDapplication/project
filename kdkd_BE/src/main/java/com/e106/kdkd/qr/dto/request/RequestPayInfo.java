package com.e106.kdkd.qr.dto.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class RequestPayInfo {

    private String userUuid;
    private Long payAmount;
    private Double latitude;
    private Double longitude;
}
