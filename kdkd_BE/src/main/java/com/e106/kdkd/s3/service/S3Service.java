package com.e106.kdkd.s3.service;


import com.e106.kdkd.global.common.entity.FileMetadata;
import com.e106.kdkd.global.common.enums.FileCategory;
import com.e106.kdkd.global.common.enums.RelatedType;
import com.e106.kdkd.s3.dto.response.ResponseFileInfo;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

public interface S3Service {
    // 파일 업로드
    void uploadFile(MultipartFile file, FileCategory category, RelatedType relatedType, String relatedId, Integer sequence);
    void uploadFile(MultipartFile file, FileCategory category, RelatedType relatedType, Long relatedId, Integer sequence);

    //presignedURL 생성
    String generatePresignedUrl(String path);

    //presignedURL 조회
    String getPresignUrl(FileCategory category, RelatedType relatedType, String relatedId, Integer sequence);
    String getPresignUrl(FileCategory category, RelatedType relatedType, Long relatedId, Integer sequence);
    String getPresignUrl(FileMetadata metadata);


    //s3의 파일과 file_metadat의 데이터 삭제
    void deleteFile(FileCategory category, RelatedType relatedType, String relatedId, Integer sequence);
    void deleteFile(FileCategory category, RelatedType relatedType, Long relatedId, Integer sequence);
    //s3의 파일과 file_metadat의 데이터 삭제
    void deleteFile(FileMetadata metadata);

    void updateFile(MultipartFile file, FileCategory category, RelatedType relatedType, String relatedId, Integer sequence);

    void updateFile(MultipartFile file, FileCategory category, RelatedType relatedType, Long relatedId, Integer sequence);


}
