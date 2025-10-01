package com.e106.kdkd.global.common.entity;

import com.e106.kdkd.boxes.dto.request.RequestSaveBoxInfo;
import com.e106.kdkd.global.common.enums.BoxStatus;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.ForeignKey;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import java.util.UUID;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

@Entity
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Data
@Table(name = "save_box")
public class SaveBox {

    @Id
    @Column(name = "box_uuid", columnDefinition = "CHAR(36)")
    private String boxUuid;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "children_uuid", nullable = false,
        foreignKey = @ForeignKey(name = "fk_savebox_child"))
    private User children;

    @Column(name = "box_name", length = 255, nullable = false)
    private String boxName;

    @Builder.Default
    @Column(nullable = false)
    private Long saving = 0L;

    @Builder.Default
    @Column(nullable = false)
    private Long remain = 0L;

    @Builder.Default
    @Column(nullable = false)
    private Long target = 0L;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @Enumerated(EnumType.STRING)                  // DB에 문자열로 저장 (권장)
    @Column(name = "status", nullable = false)    // NOT NULL
    @Builder.Default
    private BoxStatus status = BoxStatus.IN_PROGRESS;  // 기본값

    public SaveBox(User child, RequestSaveBoxInfo boxInfo) {
        this.boxUuid = UUID.randomUUID().toString();
        this.children = child;
        this.boxName = boxInfo.getBoxName();
        this.saving = boxInfo.getSaving();
        this.remain = 0L;
        this.target = boxInfo.getTarget();
        this.createdAt = LocalDateTime.now();
        this.status = BoxStatus.IN_PROGRESS;
    }

    public void updateApply(RequestSaveBoxInfo boxInfo) {
        this.boxName = boxInfo.getBoxName();
        this.saving = boxInfo.getSaving();
        this.target = boxInfo.getTarget();
        this.updatedAt = LocalDateTime.now();
    }

    public void successUpdateAply(SaveBox saveBox) {
        this.status = BoxStatus.SUCCESS;
        this.saving = 0L;
        this.remain = 0L;
    }
}
