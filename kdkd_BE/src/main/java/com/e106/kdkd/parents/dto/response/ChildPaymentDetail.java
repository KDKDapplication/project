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
public class ChildPaymentDetail {

    Double latitude;
    Double longitude;
    String categoryName;
    String merchantName;
    LocalDateTime transactedAt;
    Long paymentBalance;

    public ChildPaymentDetail(AccountItem item) {
        this.latitude = item.getLatitude();
        this.longitude = item.getLongitude();
        this.categoryName = item.getCategoryName();
        this.merchantName = item.getMerchantName();
        this.transactedAt = item.getTransactedAt();
        this.paymentBalance = item.getPaymentBalance();
    }
}
