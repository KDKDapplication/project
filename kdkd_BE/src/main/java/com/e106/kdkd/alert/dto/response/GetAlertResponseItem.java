package com.e106.kdkd.alert.dto.response;

import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class GetAlertResponseItem {

    private String alertUuid;
    private String content;
    private LocalDateTime createdAt;
    private String senderName;
}
