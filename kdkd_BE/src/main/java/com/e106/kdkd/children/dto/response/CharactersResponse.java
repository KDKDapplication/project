package com.e106.kdkd.children.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class CharactersResponse {
    String characterName;
    int experience;
    int level;
    String characterImage;
}
