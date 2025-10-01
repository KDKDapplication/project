// com.e106.kdkd.account.repository.AccountParentRelationRepository
package com.e106.kdkd.account.repository;

import com.e106.kdkd.global.common.entity.ParentRelation;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AccountParentRelationRepository extends JpaRepository<ParentRelation, String> {

    // ParentRelation.parent.userUuid, ParentRelation.child.userUuid 로 탐색
    Optional<ParentRelation> findByParent_UserUuidAndChild_UserUuid(String parentUuid,
        String childUuid);

    ParentRelation findByChild_UserUuid(String childUuid);
}
