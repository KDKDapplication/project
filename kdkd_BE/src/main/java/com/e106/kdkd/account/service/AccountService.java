package com.e106.kdkd.account.service;

import com.e106.kdkd.parents.dto.response.ChildLatestPaymetntInfo;

public interface AccountService {

    ChildLatestPaymetntInfo queryLatestPaymentByParent(String parentUuid);

    ChildLatestPaymetntInfo queryLatestPaymentByChild(String childUuid);

}
