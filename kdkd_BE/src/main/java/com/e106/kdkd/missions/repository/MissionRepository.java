package com.e106.kdkd.missions.repository;

import com.e106.kdkd.global.common.entity.Mission;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MissionRepository extends JpaRepository<Mission, String> {

    List<Mission> findAllByRelation_RelationUuid(String relationUuid);
}
