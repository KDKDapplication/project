package com.e106.kdkd.s3.repository.Custom;

import com.e106.kdkd.global.common.entity.FileMetadata;
import com.e106.kdkd.global.common.entity.QFileMetadata;
import com.e106.kdkd.global.common.enums.FileCategory;
import com.e106.kdkd.global.common.enums.RelatedType;
import com.querydsl.jpa.impl.JPAQueryFactory;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class CustomFileMetadataRepositoryImpl implements CustomFileMetadataRepository{
    private final JPAQueryFactory queryFactory;

    private final QFileMetadata fileMetadata = QFileMetadata.fileMetadata;


    @Override
    public Optional<FileMetadata> findByConditions(
            FileCategory category,
            RelatedType relatedType,
            String relatedId,
            Integer sequence
    ) {
        FileMetadata result = queryFactory
                .selectFrom(fileMetadata)
                .where(
                        fileMetadata.fileCategory.eq(category),
                        fileMetadata.relatedType.eq(relatedType),
                        fileMetadata.relatedUuid.eq(relatedId),
                        fileMetadata.sequence.eq(sequence)
                )
                .fetchOne();

        return Optional.ofNullable(result);
    }
}
