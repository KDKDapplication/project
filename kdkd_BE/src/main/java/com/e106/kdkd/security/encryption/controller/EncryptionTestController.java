package com.e106.kdkd.security.encryption.controller;
// src/main/java/com/e106/kdkd/dev/encryption/EncryptionTestController.java


import com.e106.kdkd.global.common.entity.Account;
import com.e106.kdkd.global.common.entity.User;
import com.e106.kdkd.global.common.enums.Provider;
import com.e106.kdkd.security.encryption.service.EncryptionTestService;
import io.swagger.v3.oas.annotations.Hidden;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Profile({"local", "test"})
@RequiredArgsConstructor
@RequestMapping("/api/dev/encryption")
@Validated
@Hidden
public class EncryptionTestController {

    private final EncryptionTestService service;

    // --- DTOs(간단히 컨트롤러 안에 배치) ---
    public record InsertReq(
        @NotBlank String accountNumber,
        @NotBlank String virtualCard,
        @NotBlank String virtualCardCvc,
        @NotNull Provider provider,
        String providerId // providerId는 NULL도 가능하도록
    ) {

    }

    public record AccountRes(Long accountSeq,
                             String accountNumber,
                             String virtualCard,
                             String virtualCardCvc,
                             String userUuid) {

        static AccountRes from(Account a) {
            return new AccountRes(
                a.getAccountSeq(),
                a.getAccountNumber(),     // 복호화된 평문
                a.getVirtualCard(),       // 복호화된 평문
                a.getVirtualCardCvc(),    // 복호화된 평문
                a.getUser().getUserUuid()
            );
        }
    }

    public record UserRes(String userUuid,
                          String email,
                          Provider provider,
                          String providerId) {

        static UserRes from(User u) {
            return new UserRes(
                u.getUserUuid(),
                u.getEmail(),
                u.getProvider(),
                u.getProviderId()  // 복호화된 평문
            );
        }
    }
    // ------------------------------------

    /**
     * 평문으로 들어온 4개 속성(계좌/가상카드/CVC/ProviderId)을 저장하고, 복호화된 평문을 포함한 요약을 반환한다.
     */
    @PostMapping("/seed")
    public ResponseEntity<AccountRes> seed(@RequestBody @Validated InsertReq req) {
        Account saved = service.createWithPlaintexts(
            req.accountNumber(),
            req.virtualCard(),
            req.virtualCardCvc(),
            req.provider(),
            req.providerId()
        );
        return ResponseEntity.ok(AccountRes.from(saved));
    }

    /**
     * 계좌번호(평문)로 조회
     */
    @GetMapping("/by-account-number")
    public ResponseEntity<AccountRes> byAccountNumber(@RequestParam("value") String value) {
        Optional<Account> found = service.findByAccountNumber(value);
        return found.map(a -> ResponseEntity.ok(AccountRes.from(a)))
            .orElseGet(() -> ResponseEntity.notFound().build());
    }

    /**
     * 가상카드번호(평문)로 조회
     */
    @GetMapping("/by-virtual-card")
    public ResponseEntity<AccountRes> byVirtualCard(@RequestParam("value") String value) {
        Optional<Account> found = service.findByVirtualCard(value);
        return found.map(a -> ResponseEntity.ok(AccountRes.from(a)))
            .orElseGet(() -> ResponseEntity.notFound().build());
    }

    /**
     * provider + providerId(평문)로 사용자 조회
     */
    @GetMapping("/by-provider-id")
    public ResponseEntity<UserRes> byProviderAndProviderId(
        @RequestParam("provider") Provider provider,
        @RequestParam("providerId") String providerId) {
        Optional<User> found = service.findUserByProviderAndProviderId(provider, providerId);
        return found.map(u -> ResponseEntity.ok(UserRes.from(u)))
            .orElseGet(() -> ResponseEntity.notFound().build());
    }
}

