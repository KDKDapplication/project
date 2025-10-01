package com.e106.kdkd.ssafy.dto;

import lombok.Data;
import java.util.List;

@Data
public class TransactionHistoryRec {
    private String totalCount;                  // "3"
    private List<TransactionHistoryItem> list;  // 거래내역
}
