package com.e106.kdkd.global.common.entity;

import com.e106.kdkd.ssafy.dto.card.CreateCreditCardTransactionRec;
import jakarta.persistence.Column;
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
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(
    name = "account_item",
    uniqueConstraints = {
        @UniqueConstraint(
            name = "uq_accountitem_account_txno",
            columnNames = {"account_seq", "transaction_unique_no"}
        )
    }
)
@ToString(exclude = "account") // LAZY 순환 방지
public class AccountItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "account_item_seq")
    private Long accountItemSeq;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
        name = "account_seq",
        nullable = false,
        foreignKey = @ForeignKey(name = "fk_accountitem_account")
    )
    private Account account;

    private Double latitude;
    private Double longitude;

    @Column(name = "transaction_unique_no", nullable = false)
    private Long transactionUniqueNo;

    @Column(name = "category_id", length = 20, nullable = false)
    private String categoryId;

    @Column(name = "category_name", length = 255, nullable = false)
    private String categoryName;

    @Column(name = "merchant_id", nullable = false)
    private Long merchantId;

    @Column(name = "merchant_name", length = 100, nullable = false)
    private String merchantName;

    @Column(name = "transacted_at", nullable = false)
    private LocalDateTime transactedAt;

    @Column(name = "payment_balance", nullable = false)
    private Long paymentBalance;

    public AccountItem(CreateCreditCardTransactionRec rec) {
        this.transactionUniqueNo = Long.valueOf(rec.getTransactionUniqueNo());
        this.categoryId = rec.getCategoryId();
        this.categoryName = rec.getCategoryName();
        this.merchantId = Long.valueOf(rec.getMerchantId());
        this.merchantName = rec.getMerchantName();
        this.transactedAt = LocalDateTime.now();
        this.paymentBalance = Long.valueOf(rec.getPaymentBalance());
    }
}
