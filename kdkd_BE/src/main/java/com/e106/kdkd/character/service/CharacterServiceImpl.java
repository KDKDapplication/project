package com.e106.kdkd.character.service;

import com.e106.kdkd.character.repository.UserCharacterRepository;
import com.e106.kdkd.global.common.entity.UserCharacter;
import com.e106.kdkd.global.common.enums.FileCategory;
import com.e106.kdkd.global.common.enums.RelatedType;
import com.e106.kdkd.s3.exception.FileUploadFailureException;
import com.e106.kdkd.s3.service.S3Service;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Service
@RequiredArgsConstructor
@Slf4j
public class CharacterServiceImpl implements CharacterService {

    private final UserCharacterRepository userCharacterRepository;
    private final S3Service s3Service;
    private final int MAX_EXPERIENCE = 10000; // 레벨당 상한은 10000

    @Transactional
    @Override
    public void giveExperience(String childUuid, int expAmount) {
        UserCharacter character = userCharacterRepository.findUserCharacterByUser_UserUuid(
            childUuid);

        if (expAmount <= 0) {
            throw new IllegalArgumentException("경험치는 양수여야 합니다.");
        }

        long currentExp = character.getExperience();
        long total = currentExp + expAmount;

        long levelsGained = Math.floorDiv(total, MAX_EXPERIENCE);

        int newExp = Math.floorMod(total, MAX_EXPERIENCE);
        int newLevel = character.getLevel() + (int) levelsGained;

        character.setExperience(newExp);
        character.setLevel(newLevel);

        log.info("[CharacterXP] user={} +{}xp -> level={}, xp={}/{} (gained={})",
            childUuid, expAmount, newLevel, newExp, MAX_EXPERIENCE, levelsGained);
    }

    @Override
    public void createCharacterImage(MultipartFile file, Long characterSeq) {
        log.debug("파일 업로드 시작");
        if (file != null && !file.isEmpty()) {
            try {
                s3Service.uploadFile(file, FileCategory.IMAGES, RelatedType.CHARACTER, characterSeq,
                    1);
            } catch (Exception e) {
                throw new FileUploadFailureException("스토리지에 파일 업로드 중 에러 발생");
            }
        }
    }
}
