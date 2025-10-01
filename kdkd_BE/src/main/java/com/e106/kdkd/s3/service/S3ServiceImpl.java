package com.e106.kdkd.s3.service;

import com.e106.kdkd.global.common.entity.FileMetadata;
import com.e106.kdkd.global.common.enums.FileCategory;
import com.e106.kdkd.global.common.enums.RelatedType;
import com.e106.kdkd.s3.exception.FileMetadataNotFoundException;
import com.e106.kdkd.s3.exception.FileUploadFailureException;
import com.e106.kdkd.s3.exception.StorageWriteException;
import com.e106.kdkd.s3.repository.FileMetadataRepository;
import com.e106.kdkd.s3.util.CustomFileUtil;
import java.io.IOException;
import java.time.Duration;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.services.s3.model.S3Exception;
import software.amazon.awssdk.services.s3.presigner.S3Presigner;
import software.amazon.awssdk.services.s3.presigner.model.GetObjectPresignRequest;

@Service
@RequiredArgsConstructor
@Slf4j
public class S3ServiceImpl implements S3Service {

    private final S3Client s3Client;
    private final FileMetadataRepository fileMetadataRepository;

    @Value("${s3.bucket}")
    private String bucket;

    @Value("${s3.access-key}")
    private String accessKey;

    @Value("${s3.secret-key}")
    private String secretKey;

    @Value("${s3.region}")
    private String region;

    @Value("${s3.presign.exp-min}")
    private Long ttl;

    @Override
    public void uploadFile(MultipartFile file, FileCategory category, RelatedType relatedType,
        String relatedId, Integer sequence) {
        log.debug("파일 업로드 매서드 진입");
        CustomFileUtil.validateFile(file, category, relatedType); // 파일 유효성 검사.
        FileMetadata fileMetadata = new FileMetadata(file, category, relatedType, relatedId,
            sequence); // 파일 개체 생성
        fileMetadataRepository.save(fileMetadata);
        String path = formPath(fileMetadata);
        writeObjectOnStorage(path, file);
    }

    @Override
    public void uploadFile(MultipartFile file, FileCategory category, RelatedType relatedType,
        Long relatedId, Integer sequence) {
        uploadFile(file, category, relatedType, String.valueOf(relatedId), sequence);
    }

    // 해당 파일 PresigedUrl 생성 후 반환
    @Override
    public String generatePresignedUrl(String path) {
        S3Presigner presigner = S3Presigner.builder()
            .region(Region.of(region))
            .credentialsProvider(
                StaticCredentialsProvider.create(AwsBasicCredentials.create(accessKey, secretKey))
            ).build();

        GetObjectRequest getObjectRequest = GetObjectRequest.builder()
            .bucket(bucket)
            .key(path).build();

        GetObjectPresignRequest presignRequest = GetObjectPresignRequest.builder()
            .signatureDuration(Duration.ofMinutes(ttl))
            .getObjectRequest(getObjectRequest)
            .build();

        return presigner.presignGetObject(presignRequest).url().toString();
    }

    @Override
    public String getPresignUrl(FileCategory category, RelatedType relatedType, String relatedId,
        Integer sequence) {
        log.debug("presignUrl 조회 매서드 진입");
        // DB에서 해당 파일 메타데이터 찾기
        FileMetadata metadata = fileMetadataRepository
            .findByConditions(category, relatedType, relatedId, sequence)
            .orElse(null); // 없으면 null

        if (metadata == null) {
            return null; // 호출자에게 "없음"을 null로 알림
        }

        String path = formPath(metadata);
        String presignedUrl = generatePresignedUrl(path);
        return presignedUrl;
    }

    @Override
    public String getPresignUrl(FileCategory category, RelatedType relatedType, Long relatedId,
        Integer sequence) {
        return getPresignUrl(category, relatedType, String.valueOf(relatedId), sequence);
    }

    @Override
    public String getPresignUrl(FileMetadata metadata) {
        log.debug("presignUrl 조회 매서드 진입");
        String path = formPath(metadata);
        String presignedUrl = generatePresignedUrl(path);
        return presignedUrl;
    }

    @Override
    public void deleteFile(FileCategory category, RelatedType relatedType, Long relatedId,
        Integer sequence) {
        deleteFile(category, relatedType, String.valueOf(relatedId), sequence);
    }

    @Override
    public void deleteFile(FileCategory category, RelatedType relatedType, String relatedId,
        Integer sequence) {
        log.debug("파일 삭제 매서드 진입");
        // 1. 메타데이터 조회
        FileMetadata metadata = fileMetadataRepository.findByConditions(category, relatedType,
                relatedId, sequence)
            .orElseThrow(() -> new FileMetadataNotFoundException("파일 존재하지 않습니다."));
        // 2. S3 Key 구성
        String path = formPath(metadata);
        // 3. S3에서 삭제
        deleteFromStorage(path);
        // 4. DB에서 메타데이터 삭제
        fileMetadataRepository.delete(metadata);
    }

    @Override
    public void deleteFile(FileMetadata metadata) {
        log.debug("파일 삭제 매서드 진입");
        String path = formPath(metadata);
        // 3. S3에서 삭제
        deleteFromStorage(path);
        // 4. DB에서 메타데이터 삭제
        fileMetadataRepository.delete(metadata);

    }

    @Override
    public void updateFile(MultipartFile file, FileCategory category, RelatedType relatedType,
        String relatedId, Integer sequence) {
        log.debug("파일 업데이트 매서드 진입");
        if (file != null && !file.isEmpty()) {
            try {
                deleteFile(category, relatedType, relatedId, sequence);
            } catch (Exception e) {
                log.debug("파일 삭제 중 예외 발생 {}", e.getMessage());
            }

            try {
                uploadFile(file, category, relatedType, relatedId, sequence);
            } catch (Exception e) {
                throw new FileUploadFailureException("스토리지에 파일 업로드 중 에러 발생");
            }
        }
    }

    @Override
    public void updateFile(MultipartFile file, FileCategory category, RelatedType relatedType,
        Long relatedId, Integer sequence) {
        updateFile(file, category, relatedType, String.valueOf(relatedId), sequence);
    }

    // S3 경로 구성
    private String formPath(FileMetadata metadata) {
        return String.format("%s/%s/%d.%s",
            metadata.getFileCategory().name().toLowerCase(),
            metadata.getRelatedType().name().toLowerCase(),
            metadata.getFileId(),
            metadata.getFileExtension()
        );
    }

    // S3에 파일을 쓰는 작업.
    private void writeObjectOnStorage(String path, MultipartFile file) {
        PutObjectRequest request = PutObjectRequest.builder()
            .bucket(bucket)
            .key(path)
            .contentType(file.getContentType())
            .build();

        try {
            s3Client.putObject(request,
                RequestBody.fromBytes(file.getBytes())); // 여기서 IOException 가능
        } catch (IOException e) {
            throw new StorageWriteException("S3 업로드 중 파일 읽기 실패");
        } catch (S3Exception | software.amazon.awssdk.core.exception.SdkClientException e) {
            throw new StorageWriteException("S3 업로드 실패");
        }
    }

    // S3에 파일을 삭제하는 작업
    private void deleteFromStorage(String path) {
        DeleteObjectRequest deleteRequest = DeleteObjectRequest.builder()
            .bucket(bucket)
            .key(path)
            .build();

        s3Client.deleteObject(deleteRequest);
    }
}
