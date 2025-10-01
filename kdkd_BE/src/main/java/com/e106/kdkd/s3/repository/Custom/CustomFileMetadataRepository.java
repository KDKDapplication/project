package com.e106.kdkd.s3.repository.Custom;

import com.e106.kdkd.global.common.entity.FileMetadata;
import com.e106.kdkd.global.common.enums.FileCategory;
import com.e106.kdkd.global.common.enums.RelatedType;

import java.util.Optional;

public interface CustomFileMetadataRepository {
    Optional<FileMetadata> findByConditions(FileCategory category, RelatedType relatedType, String relatedId, Integer sequence);
}
