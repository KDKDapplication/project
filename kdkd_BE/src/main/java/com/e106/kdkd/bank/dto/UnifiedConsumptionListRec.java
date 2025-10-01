package com.e106.kdkd.bank.dto;

import java.util.List;
import lombok.*;

@Getter @Setter @ToString
@AllArgsConstructor @NoArgsConstructor @Builder
public class UnifiedConsumptionListRec {
    private int totalCount;
    private List<UnifiedConsumptionItem> list;
}
