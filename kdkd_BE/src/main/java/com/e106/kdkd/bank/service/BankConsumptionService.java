package com.e106.kdkd.bank.service;

import com.e106.kdkd.bank.dto.SourceType;
import com.e106.kdkd.bank.dto.UnifiedConsumptionListRec;

public interface BankConsumptionService {
    UnifiedConsumptionListRec queryMonthly(
            String userUuid,
            String month,
            String day,
            SourceType sourceType
    );
}
