package com.e106.kdkd.missions.service;

import com.e106.kdkd.missions.dto.request.RequestMissionInfo;
import com.e106.kdkd.missions.dto.response.MissionInfo;
import java.util.List;

public interface MissionService {

    void createMission(String parentUuid, RequestMissionInfo requestMissionInfo);

    List<MissionInfo> queryMissionInfoList(String childUuid);

    void successMission(String missionUuid);

    void deleteMission(String missionUuid);

    void updateMission(String missionUuid, RequestMissionInfo requestMissionInfo);
}
