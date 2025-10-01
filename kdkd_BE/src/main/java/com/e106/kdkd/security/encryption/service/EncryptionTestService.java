package com.e106.kdkd.security.encryption.service;

// src/main/java/com/e106/kdkd/dev/encryption/EncryptionTestService.java


import com.e106.kdkd.account.repository.AccountRepository;
import com.e106.kdkd.global.common.entity.Account;
import com.e106.kdkd.global.common.entity.User;
import com.e106.kdkd.global.common.enums.Provider;
import com.e106.kdkd.global.common.enums.Role;
import com.e106.kdkd.users.repository.UserRepository;
import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Profile({"local", "test"})
@RequiredArgsConstructor
public class EncryptionTestService {

    private final AccountRepository accountRepository;
    private final UserRepository userRepository;

    @Transactional
    public Account createWithPlaintexts(String accountNumber,
        String virtualCard,
        String virtualCardCvc,
        Provider provider,
        String providerId) {
        // 1) 목 유저 생성 (providerId는 암호화 컬럼)
        User user = User.builder()
            .userUuid(UUID.randomUUID().toString())
            .name("Mock User")
            .email("mock+" + System.currentTimeMillis() + "@kdkd.test")
            .role(Role.CHILD)
            .provider(provider)
            .providerId(providerId)   // <-- 컨버터가 암호화
            .birthdate(LocalDate.of(2010, 1, 1)) // 필요시 엔티티에 맞춰 조정
            .build();
        user = userRepository.save(user);

        // 2) 목 계좌 생성 (세 컬럼은 암호화)
        Account account = Account.builder()
            .user(user)
            .accountNumber(accountNumber) // <-- 암호화
            .virtualCard(virtualCard)     // <-- 암호화(UNIQUE)
            .virtualCardCvc(virtualCardCvc) // <-- 암호화
            .build();

        return accountRepository.save(account);
    }

    @Transactional(readOnly = true)
    public Optional<Account> findByAccountNumber(String accountNumberPlain) {
        // 평문 그대로 조회 (컨버터가 암/복호 처리)
        return accountRepository.findByAccountNumber(accountNumberPlain);
    }

    @Transactional(readOnly = true)
    public Optional<Account> findByVirtualCard(String virtualCardPlain) {
        return accountRepository.findByVirtualCard(virtualCardPlain);
    }

    @Transactional(readOnly = true)
    public Optional<User> findUserByProviderAndProviderId(Provider provider,
        String providerIdPlain) {
        return userRepository.findByProviderAndProviderId(provider, providerIdPlain);
    }
}

