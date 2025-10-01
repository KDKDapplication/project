package com.e106.kdkd.global.common.entity;

import com.e106.kdkd.global.common.enums.FileCategory;
import com.e106.kdkd.global.common.enums.RelatedType;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.apache.commons.io.FilenameUtils;
import org.hibernate.annotations.CreationTimestamp;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;

@Entity
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Data
@Table(name = "file_metadata",
        indexes = { @Index(name = "idx_file_related", columnList = "related_uuid") })
public class FileMetadata {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "file_id")
    private Long fileId;

    @Enumerated(EnumType.STRING)
    @Column(name = "file_category", nullable = false, length = 20)
    private FileCategory fileCategory;

    @Enumerated(EnumType.STRING)
    @Column(name = "related_type", nullable = false, length = 20)
    private RelatedType relatedType;

    @Column(name = "related_uuid", length = 36, nullable = false)
    private String relatedUuid;

    @Column(name = "file_name", length = 255, nullable = false)
    private String fileName;

    @Column(nullable = false)
    private Integer sequence = 1;

    @Column(name = "file_extension", length = 20, nullable = false)
    private String fileExtension;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    public FileMetadata(MultipartFile file, FileCategory category, RelatedType relatedType, String relatedId, Integer sequence) {
        this.fileName = file.getOriginalFilename();
        this.fileCategory = category;
        this.relatedType = relatedType;
        this.relatedUuid = relatedId;
        this.sequence = sequence;
        this.fileExtension = FilenameUtils.getExtension(file.getOriginalFilename());
        this.createdAt = LocalDateTime.now();
    }

}
