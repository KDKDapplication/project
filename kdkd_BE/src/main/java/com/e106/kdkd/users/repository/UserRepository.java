package com.e106.kdkd.users.repository;

import com.e106.kdkd.global.common.entity.User;
import com.e106.kdkd.global.common.enums.Provider;
import io.lettuce.core.dynamic.annotation.Param;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepository extends JpaRepository<User, String> {

    // 활성(삭제되지 않은) 조회
    Optional<User> findByProviderAndProviderIdAndDeletedAtIsNull(Provider provider,
        String providerId);

    Optional<User> findByEmailAndDeletedAtIsNull(String email);

    boolean existsByEmailAndDeletedAtIsNull(String email);

    // soft-deleted 포함한 조회 (서비스에서 익명화 대상 탐지/처리를 위해 필요)
    @Override
    Optional<User> findById(String userUuid);

    Optional<User> findByProviderAndProviderId(Provider provider, String providerId);

    Optional<User> findByEmail(String email);

    Boolean existsByUserUuid(String userUuid);

    @Query("select u.ssafyUserKey from User u where u.userUuid = :userUuid")
    Optional<String> findUserKeyByUserUuid(@Param("userUuid") String userUuid);

    @Query("select u from User u where u.userUuid = :userUuid and u.deletedAt is null")
    Optional<User> findActiveById(@Param("userUuid") String userUuid);
}
