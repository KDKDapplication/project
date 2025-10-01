package com.e106.kdkd.global.common.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.ForeignKey;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import java.time.LocalDateTime;
import java.util.UUID;
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
@Table(
    name = "parent_relation",
    uniqueConstraints = @UniqueConstraint(name = "uq_child_unique", columnNames = "child_uuid")
)
public class ParentRelation {

    @Id
    @Column(name = "relation_uuid", columnDefinition = "CHAR(36)")
    private String relationUuid;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "parent_uuid", nullable = false,
        foreignKey = @ForeignKey(name = "fk_pc_parent_uuid"))
    private User parent;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "child_uuid", nullable = false,
        foreignKey = @ForeignKey(name = "fk_pc_child_uuid"), unique = true)
    private User child;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    public ParentRelation(User parent, User child) {
        this.relationUuid = UUID.randomUUID().toString();
        this.parent = parent;
        this.child = child;
    }
}
