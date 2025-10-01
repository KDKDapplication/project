package com.e106.kdkd.account.service;

import com.e106.kdkd.account.dto.request.AutoTransferCreateRequest;
import com.e106.kdkd.account.dto.request.AutoTransferDeleteRequest;
import com.e106.kdkd.account.dto.request.AutoTransferUpdateRequest;
import com.e106.kdkd.account.dto.respoonse.AutoTransferListItemResponse;
import com.e106.kdkd.account.dto.respoonse.AutoTransferListResponse;
import com.e106.kdkd.account.repository.AccountParentRelationRepository;
import com.e106.kdkd.account.repository.AutoTransferQueryRepository;
import com.e106.kdkd.account.repository.AutoTransferRepository;
import com.e106.kdkd.account.repository.AutoTransferView;
import com.e106.kdkd.global.common.entity.AutoTransfer;
import com.e106.kdkd.global.common.entity.ParentRelation;
import com.e106.kdkd.global.exception.ResourceNotFoundException;
import jakarta.transaction.Transactional;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class AutoTransferServiceImpl implements AutoTransferService {

    private final AutoTransferRepository autoTransferRepository;
    private final AccountParentRelationRepository parentRelationRepository;
    private final AutoTransferQueryRepository autoTransferQueryRepository;
    private final AccountParentRelationRepository accountParentRelationRepository;

    private static final DateTimeFormatter TIME_FMT = DateTimeFormatter.ofPattern("HH:mm:ss");

    @Transactional
    @Override
    public void delete(String parentUuid, AutoTransferDeleteRequest request) {
        // 1) 관계 찾기
        var relation = accountParentRelationRepository
            .findByParent_UserUuidAndChild_UserUuid(parentUuid, request.getChildUuid())
            .orElseThrow(() -> new IllegalArgumentException("부모-자녀 관계가 없습니다."));

        // 2) 자동이체 찾기
        var at = autoTransferRepository
            .findByRelation_RelationUuid(relation.getRelationUuid())
            .orElseThrow(() -> new IllegalArgumentException("해당 자녀에 대한 자동이체 규칙이 없습니다."));

        // 3) 삭제
        autoTransferRepository.delete(at);
    }

    @Override
    public Long queryChildAutoTransferAmount(String childUuid) {
        ParentRelation relation = parentRelationRepository.findByChild_UserUuid(childUuid);
        if (relation == null) {
            throw new ResourceNotFoundException("해당 자녀와 연결된 부모가 없습니다.");
        }
        AutoTransfer autoTransfer = autoTransferRepository.findByRelation(relation);
        if (autoTransfer == null) {
            throw new ResourceNotFoundException("해당 자녀의 자동이체 데이터가 없습니다.");
        }
        return autoTransfer.getAmount();
    }

    @Transactional
    @Override
    public void update(String parentUuid, AutoTransferUpdateRequest request) {
        log.info("[DEBUG] parentUuid={}, childUuid={}", parentUuid, request.getChildUuid());

        // 1. parent_relation 테이블 전체 찍어보기
        var allRelations = accountParentRelationRepository.findAll();
        log.info("[DEBUG] total relations in DB={}", allRelations.size());
        for (var r : allRelations) {
            log.info("[DEBUG] relation_uuid={}, parent={}, child={}",
                r.getRelationUuid(),
                r.getParent() != null ? r.getParent().getUserUuid() : "null-parent",
                r.getChild() != null ? r.getChild().getUserUuid() : "null-child");
        }

        // 2. 쿼리 직접 실행
        var relationOpt = accountParentRelationRepository
            .findByParent_UserUuidAndChild_UserUuid(parentUuid, request.getChildUuid());

        if (relationOpt.isEmpty()) {
            log.warn("[DEBUG] No relation found for parentUuid={}, childUuid={}", parentUuid,
                request.getChildUuid());
            throw new IllegalArgumentException("parent-child 관계가 없습니다.");
        }

        var relation = relationOpt.get();
        log.info("[DEBUG] relation found: relationUuid={}", relation.getRelationUuid());

        // 3. auto_transfer 확인
        var autoTransferOpt = autoTransferRepository.findByRelation_RelationUuid(
            relation.getRelationUuid());
        if (autoTransferOpt.isEmpty()) {
            log.warn("[DEBUG] auto_transfer not found for relationUuid={}",
                relation.getRelationUuid());
            throw new IllegalArgumentException("자동이체 규칙이 존재하지 않습니다.");
        }

        var autoTransfer = autoTransferOpt.get();
        log.info("[DEBUG] auto_transfer before update: amount={}, day={}, time={}",
            autoTransfer.getAmount(),
            autoTransfer.getTransferDay(),
            autoTransfer.getTransferTime());

        // 값 업데이트
        autoTransfer.setAmount(request.getAmount());
        autoTransfer.setTransferDay(request.getDate());
        autoTransfer.setTransferTime(LocalTime.parse(request.getHour()));

        autoTransferRepository.save(autoTransfer);
        log.info("[DEBUG] auto_transfer updated: amount={}, day={}, time={}",
            autoTransfer.getAmount(),
            autoTransfer.getTransferDay(),
            autoTransfer.getTransferTime());
    }


    @Override
    public AutoTransferListResponse listForParent(String parentUuid) {
        List<AutoTransferView> rows = autoTransferQueryRepository.findAllForParent(parentUuid);

        List<AutoTransferListItemResponse> items = rows.stream()
            .map(r -> new AutoTransferListItemResponse(
                r.getChildName(),
                r.getAmount(),
                r.getTransferDay(),
                r.getTransferTime().format(TIME_FMT)
            ))
            .collect(Collectors.toList());

        return new AutoTransferListResponse(items);
    }

    @Transactional
    @Override
    public String create(String parentUuid, AutoTransferCreateRequest req) {
        if (req.getDate() < 1 || req.getDate() > 31) {
            throw new IllegalArgumentException("date는 1~31이어야 합니다.");
        }
        LocalTime time = LocalTime.parse(req.getHour()); // "HH:mm:ss"

        ParentRelation relation = parentRelationRepository
            .findByParent_UserUuidAndChild_UserUuid(parentUuid, req.getChildUuid())
            .orElseThrow(() -> new IllegalArgumentException("parent-child 관계가 없습니다."));

        // 커스텀 레포로 중복 체크 (DB 유니크와 이중 안전)
        if (autoTransferRepository.existsSameSchedule(relation.getRelationUuid(), req.getDate(),
            time)) {
            throw new IllegalStateException("이미 같은 시간대 규칙이 존재합니다.");
        }

        // relation 당 1개만 허용한다면 추가
        if (autoTransferRepository.findByRelation_RelationUuid(relation.getRelationUuid())
            .isPresent()) {
            throw new IllegalStateException("이미 이 자녀에 대한 자동이체 규칙이 등록되어 있습니다.");
        }

        AutoTransfer at = AutoTransfer.builder()
            .autoTransferUuid(UUID.randomUUID().toString())
            .relation(relation)
            .transferDay(req.getDate())
            .transferTime(time)
            .amount(req.getAmount() == null ? 0L : req.getAmount())
            .build();

        autoTransferRepository.save(at);
        return at.getAutoTransferUuid();
    }
}
