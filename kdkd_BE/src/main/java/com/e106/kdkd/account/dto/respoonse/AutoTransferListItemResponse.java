package com.e106.kdkd.account.dto.respoonse;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class AutoTransferListItemResponse {

    private String childName;
    private Long amount;
    private Integer date;
    private String hour; // "HH:mm:ss"
}