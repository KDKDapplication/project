package com.e106.kdkd.boxes.controller;

import com.e106.kdkd.boxes.dto.request.RequestSaveBoxInfo;
import com.e106.kdkd.boxes.dto.response.SaveBoxDetail;
import com.e106.kdkd.boxes.dto.response.SaveBoxInfo;
import com.e106.kdkd.boxes.service.SaveBoxService;
import com.e106.kdkd.children.dto.request.AutoDistributionRequest;
import com.e106.kdkd.global.common.enums.BoxStatus;
import com.e106.kdkd.global.security.CustomPrincipal;
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
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@Tag(name = "모으기 상자(자녀) API", description = "모으기 상자(자녀) API 엔드포인트")
@RestController
@RequiredArgsConstructor
@RequestMapping("/children/boxes")
@Slf4j
public class ChildrenSaveBoxController {

    private final SaveBoxService saveBoxService;

    @PostMapping("")
    @Operation(summary = "모으기 상자 추가 API")
    public ResponseEntity<String> createSaveBox(
        @Valid @RequestPart RequestSaveBoxInfo requestSaveBoxInfo,
        @RequestPart("file") MultipartFile file,
        @AuthenticationPrincipal CustomPrincipal principal) {

        String childUuid = principal.userUuid();
        log.debug("childUuid : {}", childUuid);
        saveBoxService.createSaveBox(childUuid, requestSaveBoxInfo, file);

        return ResponseEntity.ok("save box 생성 성공");
    }

    @PutMapping("/{boxUuid}")
    @Operation(summary = "모으기 상자 수정 API")
    public ResponseEntity<String> updateSaveBox(
        @PathVariable String boxUuid,
        @RequestPart("file") MultipartFile file,
        @Valid @RequestPart RequestSaveBoxInfo requestSaveBoxInfo,
        @AuthenticationPrincipal CustomPrincipal principal) {

        String childUuid = principal.userUuid();
        log.debug("childUuid : {}", childUuid);

        saveBoxService.updateSaveBox(childUuid, boxUuid, requestSaveBoxInfo, file);

        return ResponseEntity.ok("save box 수정 성공");
    }

    @GetMapping("/list")
    @Operation(summary = "모으기 상자 목록 조회(자녀 입장) API")
    public ResponseEntity<List<SaveBoxInfo>> getSaveBoxInfoListByChildren(
        @RequestParam BoxStatus boxStatus,
        @AuthenticationPrincipal CustomPrincipal principal) {

        String childUuid = principal.userUuid();
        log.debug("childUuid : {}", childUuid);

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

    @PostMapping("/auto-distributions")
    @Operation(summary = "용돈 자동분배 설정 API")
    public ResponseEntity<String> createAutoDistribution(
        @RequestBody AutoDistributionRequest request,
        @AuthenticationPrincipal CustomPrincipal principal) {

        String currentUserUuid = principal.userUuid();
        saveBoxService.createAutoDistribution(currentUserUuid, request);
        return ResponseEntity.ok("용돈 자동 분배 설정 완료");
    }

    @PostMapping("/{boxUuid}/success")
    @Operation(summary = "모으기 상자 성공 처리 API")
    public ResponseEntity<String> successSaveBox(
        @PathVariable String boxUuid,
        @AuthenticationPrincipal CustomPrincipal principal) {

        String childUuid = principal.userUuid();
        log.debug("childUuid : {}", childUuid);

        saveBoxService.successSaveBox(childUuid, boxUuid);
        return ResponseEntity.ok("모으기 상자 성공 처리 완료");
    }

    @DeleteMapping("/{boxUuid}")
    @Operation(summary = "모으기 상자 삭제 API")
    public ResponseEntity<String> deleteSaveBox(
        @PathVariable String boxUuid,
        @AuthenticationPrincipal CustomPrincipal principal) {

        String childUuid = principal.userUuid();
        log.debug("childUuid : {}", childUuid);

        saveBoxService.deleteSaveBox(childUuid, boxUuid);
        return ResponseEntity.ok("모으기 상자 삭제 성공");
    }

    @PostMapping("/{boxUuid}/saving")
    @Operation(summary = "모으기 상자 저축 API")
    public ResponseEntity<String> saveAmount(
        @PathVariable String boxUuid,
        @RequestParam Long savingAmount,
        @AuthenticationPrincipal CustomPrincipal principal) {

        String childUuid = principal.userUuid();
        log.debug("childUuid : {}", childUuid);

        saveBoxService.saveAmount(childUuid, boxUuid, savingAmount);
        return ResponseEntity.ok("모으기 상자 저축 성공");
    }

}
