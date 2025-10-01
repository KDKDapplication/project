package com.e106.kdkd.character.controller;

import com.e106.kdkd.character.service.CharacterService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.constraints.NotNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@Tag(name = "캐릭터 도메인 API", description = "캐릭터 도메인 API 엔드포인트")
@RestController
@RequiredArgsConstructor
@RequestMapping("/characters")
@Slf4j
public class CharacterController {

    private final CharacterService characterService;

    @PostMapping("")
    @Operation(summary = "캐릭터 이미지 생성 API(개발자용)")
    public ResponseEntity<?> createCharacter(
        @RequestPart("file") @NotNull MultipartFile file,            // 업로드 파일
        @RequestPart("characterSeq") @NotNull Long characterSeq) {

        characterService.createCharacterImage(file, characterSeq);
        return ResponseEntity.ok("파일 데이터 및 s3 업로드 성공");
    }
}
