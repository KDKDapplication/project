package com.e106.kdkd.global.common.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Data
@Table(name = "character_list")
public class CharacterList {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "character_seq")
    private Long characterSeq;

    @Column(name = "character_name", length = 20, nullable = false)
    private String characterName;
}
