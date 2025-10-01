package com.e106.kdkd.parents.repository;

import com.e106.kdkd.global.common.entity.ParentRelation;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ParentRelationRepository extends JpaRepository<ParentRelation, String> {

    boolean existsByParent_UserUuidAndChild_UserUuid(String parentUuid, String childUuid);

    Long countByParent_UserUuidAndChild_UserUuid(String parentUuid, String childUuid);

    ParentRelation findByParent_UserUuidAndChild_UserUuid(String parentUuid, String childUuid);

    ParentRelation findByChild_UserUuid(String childUuid);

    List<ParentRelation> findAllByParent_UserUuid(String parentUuid);

    boolean existsByChild_UserUuid(String childUuid);

}
