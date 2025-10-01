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
@Table(name = "user_character")
public class UserCharacter {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_character_seq")
    private Integer userCharacterSeq;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_uuid", nullable = false,
            foreignKey = @ForeignKey(name = "fk_character_user"))
    private User user;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "character_seq", nullable = false,
            foreignKey = @ForeignKey(name = "fk_character_list"))
    private CharacterList character;

    @Column(nullable = false)
    private Integer experience = 0;

    @Column(nullable = false)
    private Integer level = 1;
}
