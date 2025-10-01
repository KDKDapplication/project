package com.e106.kdkd.parents.service;

import com.e106.kdkd.parents.dto.response.AutoTransferAmountResponse;
import com.e106.kdkd.parents.dto.response.ChildAccount;
import com.e106.kdkd.parents.dto.response.ChildPaymentDetail;
import com.e106.kdkd.parents.dto.response.ChildPaymentinfo;
import com.e106.kdkd.parents.dto.response.TwoMonthPattern;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.List;

public interface ParentService {

    void registerChild(String parentUuid, String childUuid);

    List<ChildAccount> queryChildAccounts(String parentUuid);

    List<ChildPaymentinfo> queryChildPayments(String childUuid, LocalDate date);

    void isLinked(String parentUuid, String childUuid);

    ChildPaymentDetail queryChildPaymentDetail(String childUuid, Long accountItemSeq);

    void checkRelation(String parentUuid, String childUuid);

    TwoMonthPattern queryChildPattern(String childUuid, YearMonth yearMonth);

    AutoTransferAmountResponse getAutoTransferAmount(String parentUuid);


}
