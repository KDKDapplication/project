package com.e106.kdkd.account.repository;

import java.util.Optional;

public interface SsafyUserRepository {
    Optional<String> findSsafyUserKeyByUserUuid(String userUuid);
}
