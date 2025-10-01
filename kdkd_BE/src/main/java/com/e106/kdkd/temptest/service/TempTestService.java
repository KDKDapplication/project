package com.e106.kdkd.temptest.service;

import com.e106.kdkd.global.common.entity.Account;
import com.e106.kdkd.global.common.entity.User;
import com.e106.kdkd.temptest.dto.RequestTestAccountInfo;
import com.e106.kdkd.temptest.dto.RequestTestUserInfo;

public interface TempTestService {

    User createTempTestUser(RequestTestUserInfo requestTestUserInfo);

    Account registerTempTestAccount(RequestTestAccountInfo requestTestAccountInfo);

}
