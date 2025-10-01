package com.e106.kdkd.parents.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class AccountItemWithSubcategory {

    private final String categoryName;
    private final Long paymentBalance;
    private final Long subcategoryId; // LifestyleMerchant.subcategory.id
}
