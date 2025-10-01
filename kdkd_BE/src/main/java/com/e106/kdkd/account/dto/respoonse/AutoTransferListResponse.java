package com.e106.kdkd.account.dto.respoonse;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class AutoTransferListResponse {

    private List<AutoTransferListItemResponse> autoTransfers;
}