package com.e106.kdkd.character.service;

import org.springframework.web.multipart.MultipartFile;

public interface CharacterService {

    void giveExperience(String childUuid, int amount);

    void createCharacterImage(MultipartFile file, Long characterSeq);
}
