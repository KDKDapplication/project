package com.e106.kdkd.missions.controller;

import com.e106.kdkd.global.security.CustomPrincipal;
import com.e106.kdkd.missions.dto.request.RequestMissionInfo;
import com.e106.kdkd.missions.dto.response.MissionInfo;
import com.e106.kdkd.missions.service.MissionService;
import com.e106.kdkd.parents.service.ParentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "미션(부모) API", description = "미션(부모) API 엔드포인트")
@RestController
@RequiredArgsConstructor
@RequestMapping("/parents/missions")
@Slf4j
public class ParentsMissionController {

    private final MissionService missionService;
    private final ParentService parentService;


    @PostMapping("")
    @Operation(summary = "미션 등록 API")
    public ResponseEntity<String> createMission(
        @Valid @RequestBody RequestMissionInfo requestMissionInfo,
        @AuthenticationPrincipal CustomPrincipal principal
    ) {
        String parentUuid = principal.userUuid();

        log.debug("미션 등록 수행");
        missionService.createMission(parentUuid, requestMissionInfo);
        return ResponseEntity.ok("미션 등록에 성공했습니다.");
    }

    @GetMapping("/list")
    @Operation(summary = "부모가 자녀의 미션 목록 조회 API")
    public ResponseEntity<List<MissionInfo>> getMissionsFromParent(
        @RequestParam String childUuid,
        @AuthenticationPrincipal CustomPrincipal principal
    ) {
        String parentUuid = principal.userUuid();

        log.debug("부모 자녀 연결 관계 확인");
        parentService.checkRelation(parentUuid, childUuid);

        log.debug("미션 리스트 조회 수행");
        List<MissionInfo> missionInfoList = missionService.queryMissionInfoList(childUuid);
        return ResponseEntity.ok(missionInfoList);
    }


    @PostMapping("/{missionUuid}/success")
    @Operation(summary = "미션 성공 처리 API")
    public ResponseEntity<String> successMission(
        @PathVariable String missionUuid
    ) {
        log.debug("미션 성공 처리 수행");
        missionService.successMission(missionUuid);
        return ResponseEntity.ok("미션 성공 처리 완료");
    }

    @DeleteMapping("/{missionUuid}")
    @Operation(summary = "미션 삭제 API")
    public ResponseEntity<String> deleteMission(
        @PathVariable String missionUuid
    ) {
        log.debug("미션 삭제 수행");
        missionService.deleteMission(missionUuid);
        return ResponseEntity.ok("미션 삭제 성공");
    }

    @PutMapping("/{missionUuid}")
    @Operation(summary = "미션 수정 API")
    public ResponseEntity<String> updateMission(
        @PathVariable String missionUuid,
        @RequestBody RequestMissionInfo requestMissionInfo
    ) {
        log.debug("미션 수정 수행");
        missionService.updateMission(missionUuid, requestMissionInfo);
        return ResponseEntity.ok("미션 수정 성공");
    }
}
