package com.e106.kdkd.s3.repository;

import com.e106.kdkd.global.common.entity.FileMetadata;
import com.e106.kdkd.global.common.enums.RelatedType;
import com.e106.kdkd.s3.repository.Custom.CustomFileMetadataRepository;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FileMetadataRepository extends JpaRepository<FileMetadata, Long>,
    CustomFileMetadataRepository {

    Optional<FileMetadata> findByRelatedTypeAndRelatedUuid(RelatedType relatedType,
        String relatedUuid);
}
