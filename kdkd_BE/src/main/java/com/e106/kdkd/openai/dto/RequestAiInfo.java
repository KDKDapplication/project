package com.e106.kdkd.openai.dto;

import java.time.YearMonth;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class RequestAiInfo {

    String childUuid;

    @com.fasterxml.jackson.annotation.JsonFormat(shape = com.fasterxml.jackson.annotation.JsonFormat.Shape.STRING, pattern = "yyyy-MM")
    @io.swagger.v3.oas.annotations.media.Schema(type = "string", pattern = "^[0-9]{4}-(0[1-9]|1[0-2])$", example = "2025-09", description = "YYYY-MM 형식")
    YearMonth yearMonth;
}
