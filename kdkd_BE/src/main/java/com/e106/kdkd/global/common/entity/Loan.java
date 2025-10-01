package com.e106.kdkd.global.common.entity;

import com.e106.kdkd.loans.dto.response.RequestLoanInfo;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.ForeignKey;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.LocalDate;
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
@Table(name = "loan")
public class Loan {

    @Id
    @Column(name = "loan_uuid", length = 36)
    private String loanUuid;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "relation_uuid", nullable = false,
        foreignKey = @ForeignKey(name = "fk_loan_relation_uuid"))
    private ParentRelation relation;

    @Column(name = "loan_amount", nullable = false)
    private Long loanAmount;

    @Column(name = "loan_date")
    private LocalDate loanDate;

    @Column(name = "loan_due", nullable = false)
    private LocalDate loanDue;

    @Builder.Default
    @Column(name = "loan_interest", nullable = false, columnDefinition = "int not null default 0")
    private Integer loanInterest = 0;

    @Column(name = "loan_content", length = 1000)
    private String loanContent;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @Column(name = "is_loaned", nullable = false)
    private boolean loaned; // TINYINT(1) ↔ boolean

    public Loan(ParentRelation relation, RequestLoanInfo info) {
        this.loanUuid = UUID.randomUUID().toString();
        this.relation = relation;
        this.loanAmount = info.getLoanAmount();
        this.loanDue = info.getLoanDue();
        this.loanInterest = info.getLoanInterest();
        this.loanContent = info.getLoanContent();
        this.createdAt = LocalDateTime.now();
        this.loaned = false;
    }
}
