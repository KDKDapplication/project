package com.e106.kdkd.global.common.entity;

import com.e106.kdkd.global.common.enums.MissionStatus;
import com.e106.kdkd.missions.dto.request.RequestMissionInfo;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.ForeignKey;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

@Entity
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Data
@Table(name = "mission")
public class Mission {

    @Id
    @Column(name = "mission_uuid", length = 36)
    private String missionUuid;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "relation_uuid", nullable = false,
        foreignKey = @ForeignKey(name = "fk_mission_relation_uuid"))
    private ParentRelation relation;

    @Column(name = "mission_title", length = 20, nullable = false)
    private String missionTitle;

    @Column(name = "mission_content", length = 255, nullable = false)
    private String missionContent;

    @Column(nullable = false)
    private Long reward = 0L;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private MissionStatus status;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Column(name = "end_at")
    private LocalDateTime endAt;

    @PrePersist
    void prePersist() {
        if (status == null) {
            status = MissionStatus.IN_PROGRESS;
        }
    }


    public void updateApply(RequestMissionInfo dto) {
        this.missionTitle = dto.getMissionTitle();
        this.missionContent = dto.getMissionContent();
        this.reward = dto.getReward();
        this.endAt = dto.getEndAt();
        this.updatedAt = LocalDateTime.now();
    }
}
