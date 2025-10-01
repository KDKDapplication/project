package com.e106.kdkd.account.repository;

import com.e106.kdkd.global.common.entity.Account;
import com.e106.kdkd.global.common.entity.User;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AccountRepository extends JpaRepository<Account, Long> {

    Optional<Account> findByAccountNumber(String accountNumber);

    Optional<Account> findByVirtualCard(String virtualCard);

    Account findByUser_UserUuid(String userUuid);

    Account findByUser(User userUuid);

    default Optional<Account> findPrimaryByUserUuid(String userUuid) {
        return Optional.ofNullable(findByUser_UserUuid(userUuid));
    }

    List<Account> findAllByUser_UserUuid(String userUuid);

}
