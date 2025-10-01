package com.e106.kdkd.parents.dto.response;

import com.e106.kdkd.global.common.entity.AccountItem;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ChildPaymentinfo {

    String childUuid;
    Long accountItemSeq;
    String merchantName;
    Long paymentBalance;
    LocalDateTime transactedAt;

    public ChildPaymentinfo(AccountItem item) {
        this.accountItemSeq = item.getAccountItemSeq();
        this.merchantName = item.getMerchantName();
        this.paymentBalance = item.getPaymentBalance();
        this.transactedAt = item.getTransactedAt();
    }
}
