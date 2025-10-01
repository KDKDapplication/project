package com.e106.kdkd.ssafy.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ResponseEnvelope<R> {

    @JsonProperty("Header")
    private ResponseHeader Header;

    @JsonProperty("REC")
    private R REC;
}
