package com.e106.kdkd.boxes.controller;

import com.e106.kdkd.boxes.dto.response.SaveBoxDetail;
import com.e106.kdkd.boxes.dto.response.SaveBoxInfo;
import com.e106.kdkd.boxes.service.SaveBoxService;
import com.e106.kdkd.global.common.enums.BoxStatus;
import com.e106.kdkd.global.security.CustomPrincipal;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "모으기 상자(부모) API", description = "모으기 상자(부모) API 엔드포인트")
@RestController
@RequiredArgsConstructor
@RequestMapping("/parents/boxes")
@Slf4j
public class ParentsSaveBoxController {

    private final SaveBoxService saveBoxService;

    @GetMapping("/list")
    @Operation(summary = "모으기 상자 목록 조회(부모 입장) API")
    public ResponseEntity<List<SaveBoxInfo>> getSaveBoxInfoListByParents(
        @RequestParam String childUuid,
        @RequestParam BoxStatus boxStatus,
        @AuthenticationPrincipal CustomPrincipal principal) {

        String parentUuid = principal.userUuid();
        log.debug("parentUuid : {}", parentUuid);

        List<SaveBoxInfo> saveBoxInfoList = saveBoxService.querySaveBoxInfoList(childUuid,
            boxStatus);
        return ResponseEntity.ok(saveBoxInfoList);
    }

    @GetMapping("/{boxUuid}")
    @Operation(summary = "모으기 상자 상세 조회 API")
    public ResponseEntity<SaveBoxDetail> getSaveBoxDetail(
        @PathVariable String boxUuid,
        @AuthenticationPrincipal CustomPrincipal principal) {

        String userUuid = principal.userUuid();
        log.debug("childUuid : {}", userUuid);

        SaveBoxDetail saveBoxDetail = saveBoxService.querySaveBoxDetail(boxUuid);
        return ResponseEntity.ok(saveBoxDetail);
    }


}
