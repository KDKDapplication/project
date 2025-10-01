package com.e106.kdkd.bank.dto;

import lombok.*;

@Getter @Setter @ToString
@AllArgsConstructor @NoArgsConstructor @Builder
public class UnifiedConsumptionItem {

    private String date;
    private String time;
    private String description;
    private long amount;
    private String direction;
    private String source;
}
