package com.e106.kdkd.users.service;

import com.e106.kdkd.global.common.entity.User;
import com.e106.kdkd.global.common.enums.Provider;
import com.e106.kdkd.global.common.enums.Role;
import com.e106.kdkd.users.dto.request.UserUpdateRequest;
import com.e106.kdkd.users.dto.response.UserResponse;
import java.time.LocalDate;
import java.util.Optional;
import org.springframework.web.multipart.MultipartFile;

public interface UserService {

    User findOrCreateForGoogleAnonymize(String googleSub, String email, String name,
        boolean emailVerified);

    Optional<User> findActiveByProviderSub(Provider provider, String providerId);

    // [추가] 온보딩 단계용: 충돌/익명화 체크 후 최종 생성(역할/생일 포함)
    User createUserForGoogleOnboarding(String googleSub,
        String email,
        String name,
        LocalDate birthdate,
        Role role);

    UserResponse getMyProfile(String userUuid);

    UserResponse updateMyProfile(String userUuid, UserUpdateRequest req);

    String updateMyProfileImage(String userUuid, MultipartFile file);

    void deleteMyAccount(String userUuid, String providerName, String providerAccessToken);

}