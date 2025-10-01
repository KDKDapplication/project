package com.e106.kdkd.missions.service;

import com.e106.kdkd.account.repository.AccountRepository;
import com.e106.kdkd.alert.repository.AlertRepository;
import com.e106.kdkd.alert.service.AlertService;
import com.e106.kdkd.character.service.CharacterService;
import com.e106.kdkd.fcm.service.FcmService;
import com.e106.kdkd.global.common.entity.Account;
import com.e106.kdkd.global.common.entity.Mission;
import com.e106.kdkd.global.common.entity.ParentRelation;
import com.e106.kdkd.global.common.entity.User;
import com.e106.kdkd.global.common.enums.MissionStatus;
import com.e106.kdkd.global.exception.ResourceNotFoundException;
import com.e106.kdkd.global.exception.UserNotFoundException;
import com.e106.kdkd.missions.dto.request.RequestMissionInfo;
import com.e106.kdkd.missions.dto.response.MissionInfo;
import com.e106.kdkd.missions.repository.MissionRepository;
import com.e106.kdkd.parents.repository.ParentRelationRepository;
import com.e106.kdkd.ssafy.service.backend.ApiAccountService;
import com.e106.kdkd.users.repository.UserRepository;
import com.google.firebase.messaging.FirebaseMessagingException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class MissionServiceImpl implements MissionService {

    private final CharacterService characterService;
    private final ParentRelationRepository parentRelationRepository;
    private final MissionRepository missionRepository;
    private final UserRepository userRepository;
    private final AlertRepository alertRepository;
    private final ApiAccountService apiAccountService;
    private final AccountRepository accountRepository;
    private final FcmService fcmService;
    private final AlertService alertService;


    @Transactional
    @Override
    public void createMission(String parentUuid, RequestMissionInfo requestMissionInfo) {
        log.debug("연결된 관계 조회");
        ParentRelation parentRelation = parentRelationRepository.findByParent_UserUuidAndChild_UserUuid(
            parentUuid, requestMissionInfo.getChildUuid());
        if (parentRelation == null) {
            throw new IllegalArgumentException("연결된 자녀가 아닙니다.");
        }

        log.debug("mission 객체 초기화");
        Mission mission = Mission.builder()
            .missionUuid(UUID.randomUUID().toString())
            .relation(parentRelation)
            .missionTitle(requestMissionInfo.getMissionTitle())
            .missionContent(requestMissionInfo.getMissionContent())
            .reward(requestMissionInfo.getReward())
            .status(MissionStatus.IN_PROGRESS)
            .createdAt(LocalDateTime.now())
            .endAt(requestMissionInfo.getEndAt())
            .build();
        log.debug("생성한 객체 db 저장");
        missionRepository.save(mission);

        User child = userRepository.findById(requestMissionInfo.getChildUuid()).orElseThrow(
            () -> new UserNotFoundException("존재하지 않는 child userUuid입니다."));
        User parent = userRepository.findById(parentUuid).orElseThrow(
            () -> new UserNotFoundException("존재하지 않는 parent userUuid입니다."));

        log.debug("알림 전송");
        String message = String.format("부모 %s(이)가 미션을 생성하였습니다.", parent.getName());
        try {
            fcmService.sendToUser(child.getUserUuid(), "미션 생성",
                message);

        } catch (FirebaseMessagingException e) {
            log.warn("[FCM] 부모 미션 생성 알림 전송 실패: childUuid={}, err={}", child.getUserUuid(),
                e.getMessage());
        }

        // 알림 DB에 저장
        alertService.createAlert(parentUuid, child.getUserUuid(), message);
    }

    @Transactional
    @Override
    public List<MissionInfo> queryMissionInfoList(String childUuid) {
        log.debug("{}을 통해 ParentRelation 조회", childUuid);
        ParentRelation parentRelation = parentRelationRepository.findByChild_UserUuid(childUuid);
        if (parentRelation == null) {
            throw new IllegalArgumentException("연결된 관계가 없습니다. childUuid=" + childUuid);
        }

        log.debug("mission 리스트 조회");
        List<Mission> missions = missionRepository.findAllByRelation_RelationUuid(
            parentRelation.getRelationUuid());

        int changed = 0;

        log.debug("Mission Status 갱신 및 MissionInfo 리스트 생성");
        List<MissionInfo> missionInfoList = new ArrayList<>();
        for (Mission m : missions) {
            if (m.getEndAt() != null
                && m.getEndAt().isBefore(LocalDateTime.now())
                && (m.getStatus() == MissionStatus.IN_PROGRESS)) {
                m.setStatus(MissionStatus.FAILED);
            }
            MissionInfo missionInfo = new MissionInfo(m);
            missionInfoList.add(missionInfo);
        }
        log.debug("만료로 전환된 미션 수: {}", changed);

        return missionInfoList;
    }

    @Transactional
    @Override
    public void successMission(String missionUuid) {
        Mission mission = missionRepository.findById(missionUuid).orElseThrow(
            () -> new ResourceNotFoundException("존재하지 않는 missionUuid입니다."));

        if (mission.getStatus() != MissionStatus.IN_PROGRESS) {
            throw new IllegalArgumentException("IN_PROGRESS가 아닌 미션은 성공처리 할 수 없습니다.");
        }
        mission.setStatus(MissionStatus.SUCCESS);
        /*
        계좌이체 설정 (잔액이 해당금액보다 없을때는 오류반환)
         */
        User parent = mission.getRelation().getParent();
        User child = mission.getRelation().getChild();
        log.debug("parentUuid : {}, childUuid : {}", parent.getUserUuid(), child.getUserUuid());

        Account parentAccount = accountRepository.findByUser(parent);
        Account childAccount = accountRepository.findByUser(child);

        log.debug("미션 보상 금액 이체");
        apiAccountService.customAccountTransfer(parentAccount, childAccount, mission.getReward(),
            parent.getSsafyUserKey(), "(수시입출금) : 입금(미션 보상 금액 이체)"
            , "(수시입출금) : 출금(미션 보상 금액 이체)");

        log.debug("경험치 부여");
        double scale = 10.0;
        int expAmount = (int) Math.floor(scale * Math.sqrt(mission.getReward())); // 경험치 계산
        if (expAmount < 100) {
            expAmount = 100;
        } else if (expAmount > 2000) {
            expAmount = 2000;
        }

        characterService.giveExperience(child.getUserUuid(), expAmount);

        log.debug("알림 전송");
        String message = String.format("부모 %s(이)가 미션을 성공 처리하였습니다.", parent.getName());
        try {
            fcmService.sendToUser(child.getUserUuid(), "미션 성공 처리",
                message);

        } catch (FirebaseMessagingException e) {
            log.warn("[FCM] 부모 미션 성공 처리 알림 전송 실패: childUuid={}, err={}", child.getUserUuid(),
                e.getMessage());
        }

        // 알림 DB에 저장
        alertService.createAlert(parent.getUserUuid(), child.getUserUuid(), message);
    }

    @Transactional
    @Override
    public void deleteMission(String missionUuid) {
        if (!missionRepository.existsById(missionUuid)) {
            throw new IllegalArgumentException("존재하지 않는 mission 입니다.");
        }
        missionRepository.deleteById(missionUuid);
    }

    @Transactional
    @Override
    public void updateMission(String missionUuid, RequestMissionInfo requestMissionInfo) {
        Mission mission = missionRepository.findById(missionUuid).orElseThrow(
            () -> new IllegalArgumentException("업데이트 할 mission이 존재하지 않습니다."));
        if (mission.getStatus() != MissionStatus.IN_PROGRESS) {
            throw new IllegalArgumentException("IN_PROGRESS 상태가 아닌 미션은 수정할 수 없습니다.");
        }
        // 더티 체킹 업데이트
        mission.updateApply(requestMissionInfo);
    }
}
