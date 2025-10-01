package com.e106.kdkd.ssafy.jpa;

import com.e106.kdkd.global.common.entity.User;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface SsafyUserRepository extends JpaRepository<User, String> {

    Optional<User> findByUserUuid(String userUuid);

    @Query("select u.ssafyUserKey from User u where u.userUuid = :userUuid")
    Optional<String> findSsafyUserKeyByUserUuid(@Param("userUuid") String userUuid);
}
