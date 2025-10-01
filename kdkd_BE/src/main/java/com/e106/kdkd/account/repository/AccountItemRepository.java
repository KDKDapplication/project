package com.e106.kdkd.account.repository;

import com.e106.kdkd.account.repository.custom.CustomAccountItemRepository;
import com.e106.kdkd.global.common.entity.Account;
import com.e106.kdkd.global.common.entity.AccountItem;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AccountItemRepository extends JpaRepository<AccountItem, Long>,
    CustomAccountItemRepository {

    List<AccountItem> findAllByAccount(Account account);

}
