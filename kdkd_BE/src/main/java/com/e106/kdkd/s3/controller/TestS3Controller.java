package com.e106.kdkd.s3.controller;


import com.e106.kdkd.global.common.enums.FileCategory;
import com.e106.kdkd.global.common.enums.RelatedType;
import com.e106.kdkd.s3.service.S3Service;
import io.swagger.v3.oas.annotations.Hidden;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequiredArgsConstructor
@RequestMapping("/files")
@Hidden
public class TestS3Controller {
    private final S3Service s3Service;

    // ========= UPLOAD =========
    // String relatedId
    @PostMapping(value = "/upload/string", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<String> uploadString(
            @RequestPart("file") MultipartFile file,
            @RequestParam FileCategory category,
            @RequestParam RelatedType relatedType,
            @RequestParam String relatedId,
            @RequestParam Integer sequence
    ) {
        s3Service.uploadFile(file, category, relatedType, relatedId, sequence);
        return ResponseEntity.ok("upload(string) OK");
    }

    // Long relatedId
    @PostMapping(value = "/upload/long", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<String> uploadLong(
            @RequestPart("file") MultipartFile file,
            @RequestParam FileCategory category,
            @RequestParam RelatedType relatedType,
            @RequestParam Long relatedId,
            @RequestParam Integer sequence
    ) {
        s3Service.uploadFile(file, category, relatedType, relatedId, sequence);
        return ResponseEntity.ok("upload(long) OK");
    }

    // ========= PRESIGNED URL (GET) =========
    // String relatedId
    @GetMapping("/presign/string")
    public ResponseEntity<String> presignString(
            @RequestParam FileCategory category,
            @RequestParam RelatedType relatedType,
            @RequestParam String relatedId,
            @RequestParam Integer sequence
    ) {
        String url = s3Service.getPresignUrl(category, relatedType, relatedId, sequence);
        return ResponseEntity.ok(url);
    }

    // Long relatedId
    @GetMapping("/presign/long")
    public ResponseEntity<String> presignLong(
            @RequestParam FileCategory category,
            @RequestParam RelatedType relatedType,
            @RequestParam Long relatedId,
            @RequestParam Integer sequence
    ) {
        String url = s3Service.getPresignUrl(category, relatedType, relatedId, sequence);
        return ResponseEntity.ok(url);
    }

    // ========= DELETE =========
    // String relatedId
    @DeleteMapping("/delete/string")
    public ResponseEntity<String> deleteString(
            @RequestParam FileCategory category,
            @RequestParam RelatedType relatedType,
            @RequestParam String relatedId,
            @RequestParam Integer sequence
    ) {
        s3Service.deleteFile(category, relatedType, relatedId, sequence);
        return ResponseEntity.ok("delete(string) OK");
    }

    // Long relatedId
    @DeleteMapping("/delete/long")
    public ResponseEntity<String> deleteLong(
            @RequestParam FileCategory category,
            @RequestParam RelatedType relatedType,
            @RequestParam Long relatedId,
            @RequestParam Integer sequence
    ) {
        s3Service.deleteFile(category, relatedType, relatedId, sequence);
        return ResponseEntity.ok("delete(long) OK");
    }

    // ========= UPDATE =========
    // String relatedId
    @PutMapping(value = "/update/string", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<String> updateString(
            @RequestPart(value = "file", required = false) MultipartFile file,
            @RequestParam FileCategory category,
            @RequestParam RelatedType relatedType,
            @RequestParam String relatedId,
            @RequestParam Integer sequence
    ) {
        s3Service.updateFile(file, category, relatedType, relatedId, sequence);
        return ResponseEntity.ok("update(string) OK");
    }

    // Long relatedId
    @PutMapping(value = "/update/long", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<String> updateLong(
            @RequestPart(value = "file", required = false) MultipartFile file,
            @RequestParam FileCategory category,
            @RequestParam RelatedType relatedType,
            @RequestParam Long relatedId,
            @RequestParam Integer sequence
    ) {
        s3Service.updateFile(file, category, relatedType, relatedId, sequence);
        return ResponseEntity.ok("update(long) OK");
    }

}
