package com.e106.kdkd.missions.controller;

import com.e106.kdkd.global.security.CustomPrincipal;
import com.e106.kdkd.missions.dto.response.MissionInfo;
import com.e106.kdkd.missions.service.MissionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "미션(자녀) API", description = "미션(자녀) API 엔드포인트")
@RestController
@RequiredArgsConstructor
@RequestMapping("/children/missions")
@Slf4j
public class ChildrenMissionController {

    private final MissionService missionService;

    @GetMapping("/list")
    @Operation(summary = "자녀 자신의 미션 목록 조회 API")
    public ResponseEntity<List<MissionInfo>> getMissionsFromChild(
        @AuthenticationPrincipal CustomPrincipal principal
    ) {
        String childUuid = principal.userUuid();

        log.debug("미션 리스트 조회 수행");
        List<MissionInfo> missionInfoList = missionService.queryMissionInfoList(childUuid);
        return ResponseEntity.ok(missionInfoList);
    }

}
