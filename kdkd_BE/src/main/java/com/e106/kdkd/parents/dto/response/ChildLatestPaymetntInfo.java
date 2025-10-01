package com.e106.kdkd.parents.dto.response;

import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ChildLatestPaymetntInfo {

    String childUuid;
    String childName;
    Long accountItemSeq;
    String merchantName;
    Long paymentBalance;
    LocalDateTime transactedAt;
}
