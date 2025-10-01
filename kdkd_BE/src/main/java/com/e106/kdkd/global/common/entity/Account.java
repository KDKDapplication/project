package com.e106.kdkd.global.common.entity;

import com.e106.kdkd.security.encryption.util.UnifiedDeterministicStringConverter;
import jakarta.persistence.Column;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.ForeignKey;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;


@Entity
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Data
@Table(
    name = "account",
    uniqueConstraints = {
        @UniqueConstraint(name = "uq_account_number", columnNames = "account_number"),
        @UniqueConstraint(name = "uq_account_virtual_card", columnNames = "virtual_card")
        // ← UNIQUE 추가
    }
)
public class Account {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "account_seq")
    private Long accountSeq;

    @Convert(converter = UnifiedDeterministicStringConverter.class)
    @Column(name = "account_number", nullable = false, columnDefinition = "VARBINARY(512)")
    private String accountNumber;

    @Convert(converter = UnifiedDeterministicStringConverter.class)
    @Column(name = "virtual_card", columnDefinition = "VARBINARY(512)")
    private String virtualCard;

    @Convert(converter = UnifiedDeterministicStringConverter.class)
    @Column(name = "virtual_card_cvc", columnDefinition = "VARBINARY(512)")
    private String virtualCardCvc;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_uuid", nullable = false,
        foreignKey = @ForeignKey(name = "fk_account_user"))
    private User user;

    @Convert(converter = UnifiedDeterministicStringConverter.class)
    @Column(name = "account_password", columnDefinition = "VARBINARY(512)", nullable = false)
    private String accountPassword;

    @Column(name = "total_use_payment", columnDefinition = "INT", nullable = true)
    private Integer totalUsePayment;

    @Column(name = "bank_name", columnDefinition = "VARCHAR(10)", nullable = false)
    private String bankName;

}
