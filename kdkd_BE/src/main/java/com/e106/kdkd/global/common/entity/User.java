package com.e106.kdkd.global.common.entity;


import com.e106.kdkd.global.common.enums.Provider;
import com.e106.kdkd.global.common.enums.Role;
import com.e106.kdkd.security.encryption.util.UnifiedDeterministicStringConverter;
import jakarta.persistence.Column;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import java.time.LocalDate;
import java.time.LocalDateTime;
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
@Table(
    name = "`user`",
    uniqueConstraints = {
        @UniqueConstraint(name = "uq_user_email", columnNames = "email"),
        @UniqueConstraint(name = "uq_user_provider", columnNames = {"provider", "provider_id"})
    }
)
public class User {

    @Id
    @Column(name = "user_uuid", columnDefinition = "CHAR(36)", nullable = false)
    private String userUuid;

    @Column(length = 100, nullable = false)
    private String name;

    private LocalDate birthdate;

    @Column(length = 255, nullable = false)
    private String email;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private Role role; // DB default 'CHILD' (앱에서 기본값 세팅 권장)

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    private Provider provider; // nullable

    @Convert(converter = UnifiedDeterministicStringConverter.class)
    @Column(name = "provider_id", columnDefinition = "VARBINARY(512)")
    private String providerId;

    @Convert(converter = UnifiedDeterministicStringConverter.class)
    @Column(name = "ssafy_user_key", columnDefinition = "VARBINARY(512)")
    private String ssafyUserKey;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false, nullable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;

    @PrePersist
    void prePersist() {
        if (role == null) {
            role = Role.CHILD;
        }
    }
}
