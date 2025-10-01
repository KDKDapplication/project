package com.e106.kdkd.missions.dto.request;


import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class RequestMissionInfo {

    @NotBlank(message = "childUuid는 필수이며 공백일 수 없습니다.")
    private String childUuid;

    @NotBlank(message = "missionTitle은 필수이며 공백일 수 없습니다.")
    @Size(max = 20, message = "missionTitle은 최대 20자까지 가능합니다.")
    private String missionTitle;

    @NotBlank(message = "missionContent는 필수이며 공백일 수 없습니다.")
    @Size(max = 255, message = "missionContent는 최대 255자까지 가능합니다.")
    private String missionContent;

    @NotNull(message = "reward는 필수 값입니다.")
    @Positive(message = "reward는 0보다 큰 값이어야 합니다.")
    private Long reward;

    @NotNull(message = "endAt은(는) 필수 값입니다.")
    @Future(message = "endAt은 현재 시각 이후여야 합니다.")
    private LocalDateTime endAt;
}
