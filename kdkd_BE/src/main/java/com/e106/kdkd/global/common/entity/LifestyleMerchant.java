package com.e106.kdkd.global.common.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.ForeignKey;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
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
    name = "lifestyle_merchant",
    indexes = {
        @Index(name = "idx_lm_subcategory", columnList = "subcategory_id")
    }
)
public class LifestyleMerchant {

    @Id
    @Column(name = "merchant_id") // AUTO_INCREMENT 아님 → 값을 직접 채워야 함
    private Long id;

    @Column(name = "merchant_name", length = 255, nullable = false)
    private String name;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
        name = "subcategory_id",
        nullable = false,
        foreignKey = @ForeignKey(name = "fk_lm_subcategory")
    )
    private LifestyleSubcategory subcategory;
}
