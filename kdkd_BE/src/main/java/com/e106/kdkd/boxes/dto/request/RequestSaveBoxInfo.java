package com.e106.kdkd.boxes.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class RequestSaveBoxInfo {

    @NotBlank(message = "boxName은 필수 값입니다.")
    String boxName;

    @NotNull(message = " saving은 필수 값입니다.")
    @PositiveOrZero(message = "saving은 0 이상이어야 합니다.")
    Long saving;

    @NotNull(message = "target은(는) 필수 값입니다.")
    @Positive(message = "target은 0보다 커야 합니다.")
    Long target;

}
