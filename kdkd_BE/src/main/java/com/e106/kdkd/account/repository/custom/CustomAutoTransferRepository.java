package com.e106.kdkd.account.repository.custom;

import com.e106.kdkd.global.common.entity.AutoTransfer;
import java.util.List;

public interface CustomAutoTransferRepository {

    boolean existsSameSchedule(String relationUuid, int transferDay,
        java.time.LocalTime transferTime);

    List<AutoTransfer> findAllByRelationUuidOrderByTime(String relationUuid);

    Long sumByParentUuid(String parentUuid);
}
