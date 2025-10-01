package com.e106.kdkd.alert.repository;

import com.e106.kdkd.global.common.entity.Alert;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.stereotype.Repository;

@Repository
public interface AlertRepository extends JpaRepository<Alert, String>, CustomAlertRepository {


    @Modifying(clearAutomatically = true, flushAutomatically = true)
    int deleteAlertsByReceiver_UserUuid(String userUuid);
}
