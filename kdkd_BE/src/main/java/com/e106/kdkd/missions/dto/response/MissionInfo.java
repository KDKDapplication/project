package com.e106.kdkd.missions.dto.response;

import com.e106.kdkd.global.common.entity.Mission;
import com.e106.kdkd.global.common.enums.MissionStatus;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class MissionInfo {

    private String missionUuid;
    private String missionTitle;
    private String missionContent;
    private Long reward;
    private MissionStatus missionStatus;
    private LocalDateTime createdAt;
    private LocalDateTime endAt;

    public MissionInfo(Mission m) {
        this.missionUuid = m.getMissionUuid();
        this.missionTitle = m.getMissionTitle();
        this.missionContent = m.getMissionContent();
        this.reward = m.getReward();
        this.missionStatus = m.getStatus();
        this.createdAt = m.getCreatedAt();
        this.endAt = m.getEndAt();
    }
}
