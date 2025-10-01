package com.e106.kdkd.boxes.service;

import com.e106.kdkd.account.repository.AccountRepository;
import com.e106.kdkd.boxes.dto.request.RequestSaveBoxInfo;
import com.e106.kdkd.boxes.dto.response.SaveBoxDetail;
import com.e106.kdkd.boxes.dto.response.SaveBoxInfo;
import com.e106.kdkd.boxes.dto.response.SaveBoxItemInfo;
import com.e106.kdkd.boxes.repository.SaveBoxItemRepository;
import com.e106.kdkd.boxes.repository.SaveBoxRepository;
import com.e106.kdkd.character.service.CharacterService;
import com.e106.kdkd.children.dto.request.AutoDistributionRequest;
import com.e106.kdkd.children.dto.request.AutoDistributionRequestItem;
import com.e106.kdkd.global.common.entity.Account;
import com.e106.kdkd.global.common.entity.SaveBox;
import com.e106.kdkd.global.common.entity.SaveBoxItem;
import com.e106.kdkd.global.common.entity.User;
import com.e106.kdkd.global.common.enums.BoxStatus;
import com.e106.kdkd.global.common.enums.FileCategory;
import com.e106.kdkd.global.common.enums.RelatedType;
import com.e106.kdkd.global.exception.PermissionDeniedException;
import com.e106.kdkd.global.exception.ResourceNotFoundException;
import com.e106.kdkd.global.exception.UserNotFoundException;
import com.e106.kdkd.s3.exception.FileUploadFailureException;
import com.e106.kdkd.s3.service.S3Service;
import com.e106.kdkd.ssafy.service.backend.ApiAccountService;
import com.e106.kdkd.users.repository.UserRepository;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Service
@RequiredArgsConstructor
@Slf4j
public class SaveBoxServiceImpl implements SaveBoxService {

    private final CharacterService characterService;
    private final UserRepository userRepository;
    private final SaveBoxRepository saveBoxRepository;
    private final S3Service s3Service;
    private final SaveBoxItemRepository saveBoxItemRepository;
    private final ApiAccountService apiAccountService;
    private final AccountRepository accountRepository;

    @Transactional
    @Override
    public void createSaveBox(String childUuid, RequestSaveBoxInfo requestSaveBoxInfo,
        MultipartFile file) {
        User child = userRepository.findById(childUuid).orElseThrow(
            () -> new UserNotFoundException("존재하지 않는 child입니다."));

        //자동 저축 금액과 목표 금액 검증
        checkSavingExceedTarget(requestSaveBoxInfo.getSaving(), requestSaveBoxInfo.getTarget());

        SaveBox saveBox = new SaveBox(child, requestSaveBoxInfo);
        saveBoxRepository.save(saveBox);

        log.debug("파일 업로드 시작");
        if (file != null && !file.isEmpty()) {
            try {
                s3Service.uploadFile(file, FileCategory.IMAGES, RelatedType.BOX,
                    saveBox.getBoxUuid(), 1);
            } catch (Exception e) {
                throw new FileUploadFailureException("스토리지에 파일 업로드 중 에러 발생");
            }
        }

    }

    @Transactional
    @Override
    public void updateSaveBox(String childUuid, String boxUuid,
        RequestSaveBoxInfo requestSaveBoxInfo, MultipartFile file) {
        SaveBox saveBox = saveBoxRepository.findById(boxUuid).orElseThrow(
            () -> new ResourceNotFoundException("존재하지 않는 boxUuid입니다."));

        //해당 save box의 child인지 확인
        checkSaveBoxAuthorizationByChildUuid(saveBox, childUuid);

        //자동 저축 금액과 목표 금액 검증
        checkSavingExceedTarget(requestSaveBoxInfo.getSaving(), requestSaveBoxInfo.getTarget());

        //saveBox Status가 IN_PROGRESS인지 체크
        checkSaveBoxStatusInProgress(saveBox);

        log.debug("더티 체크 업데이트");
        saveBox.updateApply(requestSaveBoxInfo);

        log.debug("파일 수정 시작");
        s3Service.updateFile(file, FileCategory.IMAGES, RelatedType.BOX, saveBox.getBoxUuid(), 1);
    }

    @Override
    public List<SaveBoxInfo> querySaveBoxInfoList(String childUuid, BoxStatus boxStatus) {
        List<SaveBox> saveBoxes = saveBoxRepository.findAllByChildren_UserUuidAndStatusOrderByCreatedAtDesc(
            childUuid, boxStatus);
        List<SaveBoxInfo> saveBoxInfoList = new ArrayList<>();

        for (SaveBox saveBox : saveBoxes) {
            SaveBoxInfo saveBoxInfo = new SaveBoxInfo(saveBox);

            log.debug("파일 조회");
            try {
                String imageUrl = s3Service.getPresignUrl(
                    FileCategory.IMAGES, RelatedType.BOX, saveBox.getBoxUuid(), 1);
                saveBoxInfo.setImageUrl(imageUrl);
            } catch (Exception e) {
                log.debug("파일 조회 중 예외 발생 {}", e.getMessage());
            }
            saveBoxInfoList.add(saveBoxInfo);
        }

        return saveBoxInfoList;
    }

    @Override
    public SaveBoxDetail querySaveBoxDetail(String boxUuid) {
        SaveBox saveBox = saveBoxRepository.findById(boxUuid).orElseThrow(
            () -> new IllegalArgumentException("존재하지 않는 boxUuid입니다."));

        SaveBoxDetail saveBoxDetail = new SaveBoxDetail(saveBox);

        log.debug("파일 조회");
        try {
            String imageUrl = s3Service.getPresignUrl(
                FileCategory.IMAGES, RelatedType.BOX, saveBox.getBoxUuid(), 1);
            saveBoxDetail.setImageUrl(imageUrl);
        } catch (Exception e) {
            log.debug("파일 조회 중 예외 발생 {}", e.getMessage());
        }

        List<SaveBoxItemInfo> saveBoxItemInfoList = new ArrayList<>();

        log.debug("saveBoxItems 조회");
        List<SaveBoxItem> saveBoxItems = saveBoxItemRepository
            .findAllByBox_BoxUuidOrderByBoxTransferDateDesc(boxUuid);

        for (SaveBoxItem item : saveBoxItems) {
            SaveBoxItemInfo saveBoxItemInfo = new SaveBoxItemInfo(item);
            saveBoxItemInfoList.add(saveBoxItemInfo);
        }
        saveBoxDetail.setSaveBoxItemInfoList(saveBoxItemInfoList);

        return saveBoxDetail;
    }

    @Transactional
    @Override
    public void createAutoDistribution(String childrenUuid, AutoDistributionRequest request) {
        for (AutoDistributionRequestItem item : request.getAutoDistributions()) {
            log.info("버킷 {}에 {}원 자동 분배 설정", item.getBoxUuid(), item.getSaving());

            SaveBox saveBox = saveBoxRepository.findById(item.getBoxUuid())
                .orElseThrow(() -> new IllegalArgumentException("모으기 통장을 찾을 수 없습니다."));

            //자동 저축 금액과 목표 금액 검증
            checkSavingExceedTarget((long) item.getSaving(), saveBox.getTarget());

            saveBox.setSaving((long) item.getSaving());

            saveBoxRepository.save(saveBox);
        }

        log.info("자동 분배 설정 완료");
    }

    @Transactional
    @Override
    public void successSaveBox(String childUuid, String boxUuid) {
        SaveBox saveBox = saveBoxRepository.findById(boxUuid).orElseThrow(
            () -> new ResourceNotFoundException("존재하지 않는 boxUuid입니다."));

        //saveBox Status가 IN_PROGRESS인지 체크
        checkSaveBoxStatusInProgress(saveBox);

        //해당 save box의 child인지 확인
        checkSaveBoxAuthorizationByChildUuid(saveBox, childUuid);

        //saveBox success처리 더티체크 업데이트
        saveBox.successUpdateAply(saveBox);

        log.debug("경험치 부여");
        double scale = 15.0;
        int expAmount = (int) Math.floor(scale * Math.sqrt(saveBox.getTarget())); // 경험치 계산
        if (expAmount < 150) {
            expAmount = 150;
        } else if (expAmount > 5000) {
            expAmount = 5000;
        }

        characterService.giveExperience(childUuid, expAmount);
    }

    @Transactional
    @Override
    public void deleteSaveBox(String childUuid, String boxUuid) {
        SaveBox saveBox = saveBoxRepository.findById(boxUuid).orElseThrow(
            () -> new ResourceNotFoundException("존재하지 않는 boxUuid입니다."));

        //해당 save box의 child인지 확인
        checkSaveBoxAuthorizationByChildUuid(saveBox, childUuid);

        saveBoxItemRepository.deleteAllByBox_BoxUuid(boxUuid);
        saveBoxRepository.deleteById(boxUuid);
    }

    @Transactional
    @Override
    public void saveAmount(String childUuid, String boxUuid, Long savingAmount) {
        SaveBox saveBox = saveBoxRepository.findById(boxUuid).orElseThrow(
            () -> new ResourceNotFoundException("해당 boxUuid가 존재하지 않습니다."));

        if (!saveBox.getChildren().getUserUuid().equals(childUuid)) {
            throw new PermissionDeniedException("요청 사용자는 해당 모으기 상자에 대한 권한이 없습니다.");
        }

        User child = userRepository.findById(childUuid).orElseThrow(
            () -> new UserNotFoundException("존재하지 않는 childUuid 입니다."));

        Account account = accountRepository.findByUser_UserUuid(childUuid);

        if (account == null) {
            throw new ResourceNotFoundException("해당 자녀의 계좌가 존재하지 않습니다.");
        }

        log.debug("계좌에서 저축할 금액이 있는지 확인 및 계좌이체");
        apiAccountService.checkUserCanTransfer(child, account,
            savingAmount);

        log.debug("더티 체크 업데이트");
        saveBox.setSaving(saveBox.getSaving() + savingAmount);

        log.debug("SaveBoxItem 생성 및 저장");
        SaveBoxItem saveBoxItem = SaveBoxItem.builder()
            .box(saveBox)
            .boxPayName("자유적금")
            .boxTransferDate(LocalDateTime.now())
            .boxAmount(savingAmount)
            .build();

        saveBoxItemRepository.save(saveBoxItem);
    }

    private void checkSaveBoxStatusInProgress(SaveBox saveBox) {
        if (saveBox.getStatus() != BoxStatus.IN_PROGRESS) {
            throw new IllegalArgumentException("박스의 상태가 IN_PROGRESS일 때만 수정할 수 있습니다.");
        }
    }

    private void checkSaveBoxAuthorizationByChildUuid(SaveBox saveBox, String childUuid) {
        if (!saveBox.getChildren().getUserUuid().equals(childUuid)) {
            throw new PermissionDeniedException("해당 save box에 접근할 수 없는 사용자입니다.");
        }
    }

    private void checkSavingExceedTarget(Long saving, Long target) {
        if (saving > target) {
            throw new IllegalArgumentException("자동 저축 금액이 목표금액보다 클 수 없습니다.");
        }
    }

    /**
     * 자녀의 모든 진행중 상자(IN_PROGRESS)에 대해 각 상자의 'saving'만큼 자동 적립하고 save_box_item 내역을 한 건씩 생성한다.
     * <p>
     * 규칙: - toAdd = min(saving, target - remain) (목표 초과 금지) - toAdd <= 0 이면 스킵 - remain 업데이트 후 목표
     * 도달 시 status = SUCCESS
     * <p>
     * 트랜잭션을 분리(REQUIRES_NEW)하여 은행 이체 성공과 분리 보장.
     */
    @Override
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void applyAutoSavingForChild(String childUuid, String payName) {
        // 진행중 상자들에 쓰기 락
        List<SaveBox> boxes = saveBoxRepository.findAllInProgressForChildForUpdate(childUuid);
        if (boxes.isEmpty()) {
            log.info("[SaveBox] no in-progress boxes for child={}", childUuid);
            return;
        }

        LocalDateTime now = LocalDateTime.now(java.time.ZoneId.of("Asia/Seoul"));

        for (SaveBox box : boxes) {
            long remain = nz(box.getRemain());
            long target = nz(box.getTarget());
            long saving = Math.max(0, nz(box.getSaving()));

            long capacity =
                target > 0 ? Math.max(0, target - remain) : saving; // target=0이면 제한 없음으로 간주
            long toAdd = Math.min(saving, capacity);

            if (toAdd <= 0) {
                continue;
            }

            // remain 업데이트 (더티체킹)
            long newRemain = remain + toAdd;
            box.setRemain(newRemain);

            if (target > 0 && newRemain >= target) {
                box.setStatus(BoxStatus.SUCCESS);
            }

            // 적립 내역 생성
            SaveBoxItem item = new SaveBoxItem();
            item.setBox(box);                    // 연관관계: SaveBox 엔티티 자체 설정
            item.setBoxPayName(payName);
            item.setBoxTransferDate(now);
            item.setBoxAmount(toAdd);

            saveBoxItemRepository.save(item);
        }

        log.info("[SaveBox] applied auto saving for child={}, boxes={}", childUuid, boxes.size());
    }

    private long nz(Long v) {
        return v == null ? 0L : v;
    }


}
