package com.e106.kdkd.global.common.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
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
@Table(name = "lifestyle_subcategory") // 커넥션 DB가 kdkd면 schema 지정 불필요
public class LifestyleSubcategory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) // AUTO_INCREMENT
    @Column(name = "subcategory_id")
    private Long id;

    @Column(name = "subcategory_name", length = 50, nullable = false, unique = true)
    private String name;

}
