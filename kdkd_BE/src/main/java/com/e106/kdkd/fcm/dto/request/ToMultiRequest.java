package com.e106.kdkd.fcm.dto.request;

import jakarta.validation.constraints.NotNull;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ToMultiRequest {

    @NotNull(message = "기기 등록 토큰들을 입력해 주세요.")
    private List<String> registrationToken;

    @NotNull(message = "알림 제목을 입력해 주세요.")
    private String title;

    @NotNull(message = "알림 내용을 입력해 주세요.")
    private String body;
}
