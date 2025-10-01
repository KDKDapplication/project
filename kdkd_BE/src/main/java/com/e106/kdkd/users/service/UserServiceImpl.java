package com.e106.kdkd.users.service;

import com.e106.kdkd.character.repository.CharacterListRepository;
import com.e106.kdkd.character.repository.UserCharacterRepository;
import com.e106.kdkd.global.common.entity.CharacterList;
import com.e106.kdkd.global.common.entity.User;
import com.e106.kdkd.global.common.entity.UserCharacter;
import com.e106.kdkd.global.common.enums.FileCategory;
import com.e106.kdkd.global.common.enums.Provider;
import com.e106.kdkd.global.common.enums.RelatedType;
import com.e106.kdkd.global.common.enums.Role;
import com.e106.kdkd.global.util.RefreshTokenService;
import com.e106.kdkd.parents.repository.ParentRelationRepository;
import com.e106.kdkd.s3.repository.FileMetadataRepository;
import com.e106.kdkd.s3.service.S3Service;
import com.e106.kdkd.ssafy.dto.SsafyMemberResponse;
import com.e106.kdkd.ssafy.service.SsafyApiService;
import com.e106.kdkd.users.dto.request.UserUpdateRequest;
import com.e106.kdkd.users.dto.response.UserResponse;
import com.e106.kdkd.users.repository.UserRepository;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.Period;
import java.util.Objects;
import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final UserCharacterRepository userCharacterRepository;
    private final CharacterListRepository characterListRepository;

    private final FileMetadataRepository fileMetadataRepository;
    private final S3Service s3Service;

    private final RefreshTokenService refreshTokenService;
    private final SsafyApiService ssafyApiService;
    private final ParentRelationRepository parentRelationRepository;

    @Override
    @Transactional
    public User findOrCreateForGoogleAnonymize(String googleSub, String email, String name,
        boolean emailVerified) {
        if (email == null || email.isBlank()) {
            throw new IllegalArgumentException("email required");
        }
        if (!emailVerified) {
            throw new IllegalArgumentException("Google email not verified");
        }

        // 1) provider+providerId 로 활성 사용자 먼저 조회
        Optional<User> byProviderActive = userRepository.findByProviderAndProviderIdAndDeletedAtIsNull(
            Provider.GOOGLE, googleSub);
        if (byProviderActive.isPresent()) {
            return byProviderActive.get();
        }

        // 2) provider+providerId 로 soft-deleted 포함 조회 (익명화 대상 확인)
        Optional<User> byProviderAny = userRepository.findByProviderAndProviderId(Provider.GOOGLE,
            googleSub);
        if (byProviderAny.isPresent()) {
            User existing = byProviderAny.get();
            if (existing.getDeletedAt() != null) {
                anonymizeUserForRecreate(existing);
                return createNewGoogleUser(googleSub, email, name);
            } else {
                // 논리적으로 위에 active 조회에서 이미 잡혀야 하므로 보수적으로 기존 반환
                return existing;
            }
        }

        // 3) 이메일로 활성 사용자 조회 (충돌 방지)
        Optional<User> byEmailActive = userRepository.findByEmailAndDeletedAtIsNull(email);
        if (byEmailActive.isPresent()) {
            throw new IllegalStateException("Email already in use");
        }

        // 4) 이메일로 soft-deleted 계정이 있는지 확인 -> 익명화 후 신규 생성
        Optional<User> byEmailAny = userRepository.findByEmail(email);
        if (byEmailAny.isPresent() && byEmailAny.get().getDeletedAt() != null) {
            anonymizeUserForRecreate(byEmailAny.get());
            return createNewGoogleUser(googleSub, email, name);
        }

        // 5) 신규 생성
        return createNewGoogleUser(googleSub, email, name);
    }

    @Override
    @Transactional
    public User createUserForGoogleOnboarding(String googleSub,
        String email,
        String name,
        LocalDate birthdate,
        Role role
    ) {
        if (email == null || email.isBlank()) {
            throw new IllegalArgumentException("email required");
        }

        // 1) 동일 provider+sub 활성 사용자 이미 있으면 에러(온보딩은 '신규' 흐름)
        Optional<User> byProviderActive = userRepository.findByProviderAndProviderIdAndDeletedAtIsNull(
            Provider.GOOGLE, googleSub);
        if (byProviderActive.isPresent()) {
            // 이미 활성 계정이 있으면 온보딩이 아니라 로그인 흐름이어야 함
            return byProviderActive.get();
        }

        // 2) provider+sub 로 soft-deleted 포함 존재하면 익명화 후 진행
        userRepository.findByProviderAndProviderId(Provider.GOOGLE, googleSub)
            .filter(u -> u.getDeletedAt() != null)
            .ifPresent(this::anonymizeUserForRecreate);

        // 3) 이메일 충돌 체크 (활성 사용자)
        userRepository.findByEmailAndDeletedAtIsNull(email)
            .ifPresent(u -> {
                throw new IllegalStateException("Email already in use");
            });

        // 4) 이메일로 soft-deleted 기록이 있으면 익명화 후 생성
        userRepository.findByEmail(email)
            .filter(u -> u.getDeletedAt() != null)
            .ifPresent(this::anonymizeUserForRecreate);

        String ssafyUserKey = ssafyApiService.searchMemberOnboard(email)
            .map(SsafyMemberResponse::getUserKey)
            .orElse(null); // 실패해도 가입 진행 (정책에 따라 orElseThrow)

        User saved;
        try {
            saved = userRepository.save(User.builder()
                .userUuid(UUID.randomUUID().toString())
                .provider(Provider.GOOGLE)
                .providerId(googleSub)
                .email(email)
                .name(name)
                .birthdate(birthdate)
                .role(role)
                .ssafyUserKey(ssafyUserKey)
                .build());
        } catch (DataIntegrityViolationException ex) {
            // ❌ 여기서 재조회 금지(autoflush 유발) → 바로 래핑해서 던진다
            throw new IllegalStateException("Failed to create user (integrity violation)", ex);
        }
        CharacterList character = getOrCreateDefaultCharacter(1L);

        try {
            userCharacterRepository.save(UserCharacter.builder()
                .user(saved)
                .character(character)
                .experience(0)
                .level(1)
                .build());
        } catch (DataIntegrityViolationException ex) {
            // FK/제약 위반 등은 400 성격으로 내려도 됨
            throw new IllegalStateException("Failed to attach default character", ex);
        }

        return saved;
    }

    /**
     * 기본 캐릭터(id=1)를 보장한다. 없으면 생성하고, 동시 생성 경합 시 재조회로 폴백.
     */
    private CharacterList getOrCreateDefaultCharacter(Long id) {
        return characterListRepository.findById(id).orElseGet(() -> {
            try {
                CharacterList created = CharacterList.builder()
                    .characterSeq(id)            // PK 컬럼명에 맞게
                    .characterName("Default Character")   // 프로젝트에 맞는 필드 세팅
                    .build();
                return characterListRepository.save(created);
            } catch (DataIntegrityViolationException race) {
                // 다른 트랜잭션이 먼저 만들었을 수 있음 → 재조회
                return characterListRepository.findById(id)
                    .orElseThrow(() -> new IllegalStateException("기본 캐릭터를 찾을 수 없습니다."));
            }
        });
    }


    /**
     * 기존 user 레코드를 익명화(비식별화) - email, name 등 PII를 대체 - provider 정보 제거 - deletedAt 기록 - refresh
     * token (Redis) 전부 삭제
     */
    @Transactional
    protected void anonymizeUserForRecreate(User old) {
        if (old == null) {
            return;
        }

        String origUuid = old.getUserUuid();
        String anonEmail = "deleted+" + origUuid + "@deleted.example";
        String anonName =
            "deleted_user_" + (origUuid.length() >= 8 ? origUuid.substring(0, 8) : origUuid);

        old.setEmail(anonEmail);
        old.setName(anonName);

        try {
            old.setBirthdate(null);
        } catch (Exception ignored) {
        }

        old.setProvider(null);
        old.setProviderId(null);

        old.setDeletedAt(LocalDateTime.now());
        old.setUpdatedAt(LocalDateTime.now());

        userRepository.save(old);

        // Redis에 저장된 refresh token 전체 삭제(운영에서는 실패 시 재시도/모니터링 고려)
        try {
            refreshTokenService.deleteAllByUser(origUuid);
        } catch (Exception ignored) {
        }
    }

    /**
     * 내부 헬퍼: 구글용 신규 사용자 생성
     */
    @Transactional
    protected User createNewGoogleUser(String googleSub, String email, String name) {
        User u = User.builder()
            .userUuid(UUID.randomUUID().toString())
            .provider(Provider.GOOGLE)
            .providerId(googleSub)
            .email(email)
            .name(name)
            .build();
        try {
            return userRepository.save(u);
        } catch (DataIntegrityViolationException ex) {
            // 경쟁 상황: 누군가가 거의 동시에 동일한 레코드를 만들었을 수 있음 -> 재조회 시도
            Optional<User> maybeByProvider = userRepository.findByProviderAndProviderId(
                Provider.GOOGLE, googleSub);
            if (maybeByProvider.isPresent()) {
                return maybeByProvider.get();
            }

            Optional<User> maybeByEmail = userRepository.findByEmail(email);
            if (maybeByEmail.isPresent()) {
                return maybeByEmail.get();
            }

            // 재시도에도 실패하면 예외로 전파
            throw new IllegalStateException("Failed to create user due to integrity violation", ex);
        }
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<User> findActiveByProviderSub(Provider provider, String providerId) {
        return userRepository.findByProviderAndProviderIdAndDeletedAtIsNull(provider, providerId);
    }

    @Override
    @Transactional(readOnly = true)
    public UserResponse getMyProfile(String userUuid) {
        User user = userRepository.findById(userUuid)
            .orElseThrow(() -> new IllegalStateException("User not found"));

        //isConnected 설정
        Boolean isConnected = null;
        if (user.getRole() == Role.CHILD) {
            if (parentRelationRepository.existsByChild_UserUuid(userUuid)) {
                isConnected = true;
            } else {
                isConnected = false;
            }
        }

        // 나이 계산
        Integer age = null;
        LocalDate birthdate = user.getBirthdate();
        if (birthdate != null) {
            age = Period.between(birthdate, LocalDate.now()).getYears();
        }

        // 프로필 presigned URL (한 사람당 1건 가정)
        String profileUrl = fileMetadataRepository
            .findByRelatedTypeAndRelatedUuid(RelatedType.USER_PROFILE, user.getUserUuid())
            .map(s3Service::getPresignUrl)
            .orElse(null);

        return new UserResponse(
            user.getRole(),
            user.getUserUuid(),
            user.getName(),
            profileUrl,
            age == null ? 0 : age,
            birthdate,
            isConnected,
            user.getEmail()
        );
    }

    @Transactional
    @Override
    public UserResponse updateMyProfile(String userUuid, UserUpdateRequest req) {
        User user = userRepository.findById(userUuid)
            .orElseThrow(() -> new IllegalStateException("User not found"));

        Boolean isConnected = null;
        if (user.getRole() == Role.CHILD) {
            if (parentRelationRepository.existsByChild_UserUuid(userUuid)) {
                isConnected = true;
            } else {
                isConnected = false;
            }
        }

        boolean changed = false;

        // 1) 이름
        if (req.getName() != null && !Objects.equals(user.getName(), req.getName())) {
            user.setName(req.getName());
            changed = true;
        }

        // 2) 생일
        if (req.getBirthdate() != null) {
            LocalDate newBirth = LocalDate.parse(req.getBirthdate());
            if (!Objects.equals(user.getBirthdate(), newBirth)) {
                user.setBirthdate(newBirth);
                changed = true;
            }
        }

        if (changed) {
            userRepository.save(user);
        }

        Integer age = null;
        LocalDate birthdate = user.getBirthdate();
        if (birthdate != null) {
            age = Period.between(birthdate, LocalDate.now()).getYears();
        }

        String profileUrl = fileMetadataRepository
            .findByRelatedTypeAndRelatedUuid(
                com.e106.kdkd.global.common.enums.RelatedType.USER_PROFILE, user.getUserUuid())
            .map(s3Service::getPresignUrl)
            .orElse(null);

        return new UserResponse(
            user.getRole(),
            user.getUserUuid(),
            user.getName(),
            profileUrl,
            age == null ? 0 : age,
            birthdate,
            isConnected,
            user.getEmail()
        );
    }

    @Override
    @Transactional
    public String updateMyProfileImage(String userUuid, MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("empty file");
        }
        String ct = file.getContentType();
        if (ct == null || !ct.startsWith("image/")) {
            throw new IllegalArgumentException("invalid content type");
        }
        // 필요 시 용량 제한
        if (file.getSize() > 5 * 1024 * 1024) {
            throw new IllegalArgumentException("file too large (<=5MB)");
        }

        s3Service.updateFile(
            file,
            FileCategory.IMAGES,
            RelatedType.USER_PROFILE,
            userUuid,
            1
        );

        // 최신 메타로 presigned URL 반환
        return fileMetadataRepository
            .findByRelatedTypeAndRelatedUuid(RelatedType.USER_PROFILE, userUuid)
            .map(s3Service::getPresignUrl)
            .orElse(null);
    }

    @Override
    @Transactional
    public void deleteMyAccount(String userUuid, String providerName, String providerAccessToken) {
        User user = userRepository.findById(userUuid)
            .orElseThrow(() -> new IllegalStateException("User not found"));

        // 1) 소셜 연결 해제
        try {
            if (user.getProvider() != null) {
//                switch (user.getProvider()) {
//                    case GOOGLE -> unlinkGoogle(providerAccessToken);
//                    case KAKAO -> unlinkKakao(providerAccessToken, user.getProviderId());
//                    default -> {
//                    }
//                }
            }
        } catch (Exception e) {
            log.warn("Social unlink failed (ignored): {}", e.toString());
        }

        // 2) 프로필 파일 삭제
        try {
            s3Service.deleteFile(
                FileCategory.IMAGES,
                RelatedType.USER_PROFILE,
                userUuid,
                1
            );
        } catch (Exception e) {
            log.debug("profile delete best-effort (ignored): {}", e.getMessage());
        }

        // 3) refresh token 전부 삭제 (세션 폐기)
        try {
            refreshTokenService.deleteAllByUser(userUuid);
        } catch (Exception ignore) {
        }
        // 5) 계정 비식별 + soft delete
        anonymizeUserForRecreate(user);
    }

}
