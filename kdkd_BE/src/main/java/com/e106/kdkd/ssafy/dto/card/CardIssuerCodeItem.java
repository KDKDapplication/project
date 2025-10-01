package com.e106.kdkd.ssafy.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
public class CardIssuerCodeItem {

    @JsonProperty("cardIssuerCode")
    private String cardIssuerCode;

    @JsonProperty("cardIssuerName")
    private String cardIssuerName;
}
