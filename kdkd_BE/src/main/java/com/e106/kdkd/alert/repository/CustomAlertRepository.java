package com.e106.kdkd.alert.repository;

import com.e106.kdkd.alert.dto.response.GetAlertResponseItem;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface CustomAlertRepository {

    Page<GetAlertResponseItem> findAllByUserUuid(String userUuid, Pageable pageable);

    void deleteAlertByUuidAndReceiver(String userUuid, String alertUuid);
}
