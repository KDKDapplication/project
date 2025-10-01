package com.e106.kdkd.children.service;

import com.e106.kdkd.account.repository.AccountItemRepository;
import com.e106.kdkd.account.repository.AccountRepository;
import com.e106.kdkd.alert.service.AlertService;
import com.e106.kdkd.character.repository.CharacterListRepository;
import com.e106.kdkd.character.repository.UserCharacterRepository;
import com.e106.kdkd.children.dto.request.ChildrenRegisterRequest;
import com.e106.kdkd.children.dto.response.CharactersResponse;
import com.e106.kdkd.children.dto.response.ChildrenRegisterResponse;
import com.e106.kdkd.children.dto.response.PaymentResponse;
import com.e106.kdkd.children.dto.response.PaymentResponseItem;
import com.e106.kdkd.fcm.service.FcmService;
import com.e106.kdkd.global.common.entity.Account;
import com.e106.kdkd.global.common.entity.CharacterList;
import com.e106.kdkd.global.common.entity.ParentRelation;
import com.e106.kdkd.global.common.entity.User;
import com.e106.kdkd.global.common.entity.UserCharacter;
import com.e106.kdkd.global.common.enums.FileCategory;
import com.e106.kdkd.global.common.enums.RelatedType;
import com.e106.kdkd.global.exception.ResourceNotFoundException;
import com.e106.kdkd.parents.repository.ParentRelationRepository;
import com.e106.kdkd.s3.service.S3Service;
import com.e106.kdkd.users.repository.UserRepository;
import com.google.firebase.messaging.FirebaseMessagingException;
import jakarta.persistence.EntityNotFoundException;
import java.time.LocalDate;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class ChildrenServiceImpl implements ChildrenService {

    private final S3Service s3Service;
    private final FcmService fcmService;
    private final AlertService alertService;

    private final StringRedisTemplate redisTemplate;
    private final UserRepository userRepository;
    private final UserCharacterRepository userCharacterRepository;
    private final CharacterListRepository characterListRepository;
    private final ParentRelationRepository parentRelationRepository;
    private final AccountRepository accountRepository;

    private final AccountItemRepository accountItemRepository;

    @Override
    public ChildrenRegisterResponse registerChild(String childrenUuid,
        ChildrenRegisterRequest request) {
        String code = request.getCode();
        String parentUuid = redisTemplate.opsForValue().get(code);

        if (parentUuid == null) {
            throw new IllegalArgumentException("유효하지 않은 등록 코드입니다.");
        }

        User parent = userRepository.findById(parentUuid)
            .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다."));

        User child = userRepository.findById(childrenUuid)
            .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다."));

        String parentName = parent.getName();

        ParentRelation relation = ParentRelation.builder()
            .parent(parent)
            .child(child)
            .build();

        parentRelationRepository.save(relation);

        // 알림 전송
        String message = String.format("자녀 %s(이)가 등록되었습니다.", child.getName());
        try {
            fcmService.sendToUser(parentUuid, "자녀 등록",
                message);

        } catch (FirebaseMessagingException e) {
            log.warn("[FCM] 자녀 등록 알림 전송 실패: parentUuid={}, err={}", parentUuid, e.getMessage());
        }

        // 알림 DB에 저장
        alertService.createAlert(childrenUuid, parentUuid, message);

        redisTemplate.delete(code);

        return ChildrenRegisterResponse.builder()
            .parentName(parentName)
            .build();
    }

    @Override
    public CharactersResponse getCharacters(String childUuid) {
        UserCharacter userCharacter = userCharacterRepository.findUserCharacterByUser_UserUuid(
            childUuid);
        if (userCharacter == null) {
            throw new ResourceNotFoundException("해당 사용자의 캐릭터가 존재하지 않습니다.");
        }
        CharacterList characterList = userCharacter.getCharacter();

        log.debug("파일 조회 시작");
        String characterImageUrl = null;
        try {
            characterImageUrl = s3Service.getPresignUrl(
                FileCategory.IMAGES,
                RelatedType.CHARACTER,
                characterList.getCharacterSeq(),
                1);
        } catch (Exception e) {
            log.debug("파일 조회 중 예외 발생 {}", e.getMessage());
        }

        return CharactersResponse.builder()
            .characterName(characterList.getCharacterName())
            .experience(userCharacter.getExperience())
            .level(userCharacter.getLevel())
            .characterImage(characterImageUrl)
            .build();
    }

    @Override
    public PaymentResponse getPayments(String childUuid, LocalDate month, int pageNum,
        int display) {
        Account account = accountRepository.findByUser_UserUuid(childUuid);
        if (account == null) {
            throw new EntityNotFoundException("해당 계좌는 존재하지 않습니다.");
        }

        Pageable pageable = PageRequest.of(pageNum, display);

        Page<PaymentResponseItem> page =
            accountItemRepository.findAllByAccountSeqAndMonth(account.getAccountSeq(), month,
                pageable);

        return PaymentResponse.builder()
            .totalPages(page.getTotalPages())
            .childUuid(childUuid)
            .payments(page.getContent())
            .build();
    }
}