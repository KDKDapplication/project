package com.e106.kdkd.fcm.repository;

import com.e106.kdkd.fcm.entity.UserDeviceToken;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserDeviceTokenRepository extends JpaRepository<UserDeviceToken, Long> {

    Optional<UserDeviceToken> findByToken(String token);

    List<UserDeviceToken> findByUserUuid(String userUuid);

    Optional<UserDeviceToken> findUserDeviceTokenByUserUuid(String userUuid);

    void deleteByToken(String token);
}
