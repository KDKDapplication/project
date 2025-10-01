package com.e106.kdkd.global.common.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Data

@Table(name = "alert")
public class Alert {
    @Id
    @Column(name = "alert_uuid", length = 36)
    private String alertUuid;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "sender_uuid", nullable = false,
            foreignKey = @ForeignKey(name = "fk_alert_sender"))
    private User sender;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "receiver_uuid", nullable = false,
            foreignKey = @ForeignKey(name = "fk_alert_receiver"))
    private User receiver;

    @Column(nullable = false, length = 255)
    private String content;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
}
