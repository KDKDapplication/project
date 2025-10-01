package com.e106.kdkd.global.common.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.ForeignKey;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import java.time.LocalTime;
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
@Table(name = "auto_transfer")
public class AutoTransfer {

    @Id
    @Column(name = "auto_transfer_uuid", columnDefinition = "CHAR(36)", nullable = false)
    private String autoTransferUuid;

    // parent_relation FK
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
        name = "relation_uuid",
        nullable = false,
        referencedColumnName = "relation_uuid",
        foreignKey = @ForeignKey(name = "FK_AUTO_TRANSFER_RELATION")
    )
    private ParentRelation relation;

    /**
     * 매월 실행 일자 (1~31)
     */
    @Column(name = "transfer_day", nullable = false)
    private Integer transferDay;

    /**
     * 실행 시각 HH:MM:SS
     */
    @Column(name = "transfer_time", nullable = false, columnDefinition = "TIME")
    private LocalTime transferTime;

    /**
     * 이체 금액 (원)
     */
    @Column(name = "amount", nullable = false, columnDefinition = "BIGINT DEFAULT 0")
    private Long amount;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false, nullable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    void prePersist() {
        if (amount == null) {
            amount = 0L;
        }
    }
}
