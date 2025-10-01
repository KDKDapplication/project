package com.e106.kdkd.crypto;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.e106.kdkd.account.repository.AccountRepository;
import com.e106.kdkd.global.common.entity.Account;
import com.e106.kdkd.global.common.entity.QAccount;
import com.e106.kdkd.global.common.entity.User;
import com.e106.kdkd.global.common.enums.Provider;
import com.e106.kdkd.global.common.enums.Role;
import com.e106.kdkd.security.encryption.util.CryptoSupport;
import com.e106.kdkd.testsupport.TestCryptoBeans;
import com.e106.kdkd.users.repository.UserRepository;
import com.querydsl.jpa.impl.JPAQueryFactory;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.context.annotation.Import;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.transaction.TestTransaction;
import org.springframework.transaction.annotation.Transactional;

@DataJpaTest
@ActiveProfiles("test")
@Import({TestCryptoBeans.class, com.e106.kdkd.global.config.QueryDslConfig.class})
class CryptoJpaIntegrationTest {

    @Autowired
    AccountRepository accountRepo;
    @Autowired
    UserRepository userRepo;

    @PersistenceContext
    EntityManager em;
    JPAQueryFactory qf;

    @BeforeEach
    void setUp() {
        qf = new JPAQueryFactory(em);
    }

    private User persistUser(String uuid, String email, Provider provider, String providerId) {
        User u = User.builder()
            .userUuid(uuid)
            .name("Tester")
            .email(email)
            .role(Role.CHILD)
            .provider(provider)
            .providerId(providerId) // 컨버터가 암호화
            .build();
        return userRepo.saveAndFlush(u);
    }

    private Account persistAccount(User u, String accNo, String vcard, String cvc) {
        // 트랜잭션 리셋 등으로 비영속이 됐을 수 있으므로 방어적으로 재조회
        if (!em.contains(u)) {
            u = userRepo.findById(u.getUserUuid())
                .orElseThrow(
                    () -> new IllegalStateException("User must be persisted before Account"));
        }
        Account a = Account.builder()
            .user(u)
            .accountNumber(accNo) // 컨버터가 암호화
            .virtualCard(vcard)
            .virtualCardCvc(cvc)
            .build();
        return accountRepo.saveAndFlush(a);
    }

    /**
     * 중간에 트랜잭션을 롤백하고 새로 시작 (의도적 제약 위반 뒤 반드시 호출)
     */
    private static void resetTx() {
        TestTransaction.flagForRollback();
        TestTransaction.end();
        TestTransaction.start();
    }

    @Test
    @Transactional
    void roundTrip_and_repositoryQueries_work_with_plaintext() {
        // given
        User u = persistUser("uuid-1", "a@a.com", Provider.KAKAO, "kakao-123");
        Account a1 = persistAccount(u, "110-1234-567890", "4111-1111-1111-1111", "123");

        // when
        Optional<Account> byAcc = accountRepo.findByAccountNumber("110-1234-567890");
        Optional<Account> byVcard = accountRepo.findByVirtualCard("4111-1111-1111-1111");
        Optional<User> byProvider = userRepo.findByProviderAndProviderId(Provider.KAKAO,
            "kakao-123");

        // then
        assertThat(byAcc).isPresent();
        assertThat(byAcc.get().getVirtualCardCvc()).isEqualTo("123");

        assertThat(byVcard).isPresent();
        assertThat(byVcard.get().getAccountSeq()).isEqualTo(a1.getAccountSeq());

        // H2가 CHAR(36)에 공백 패딩을 붙일 수 있으므로 trim
        assertThat(byProvider).isPresent();
        assertThat(byProvider.get().getUserUuid().trim()).isEqualTo(u.getUserUuid());
    }

    @Test
    @Transactional
    void querydsl_eq_works_without_manual_encryption() {
        // given
        User u = persistUser("uuid-2", "b@b.com", Provider.GOOGLE, "google-xyz");
        Account a = persistAccount(u, "333-3333-333333", "4222-2222-2222-2222", "321");

        // when
        QAccount qa = QAccount.account;
        Account got = qf.selectFrom(qa)
            .where(qa.accountNumber.eq("333-3333-333333")) // 평문 그대로 바인딩
            .fetchOne();

        // then
        assertThat(got).isNotNull();
        assertThat(got.getAccountSeq()).isEqualTo(a.getAccountSeq());
    }

    @Test
    @Transactional
    void nativeQuery_requires_manual_encryption_bytes() {
        // given
        User u = persistUser("uuid-3", "c@c.com", Provider.KAKAO, "kakao-999");
        Account a = persistAccount(u, "777-7777-777777", "4333-3333-3333-3333", "999");

        // when: 네이티브 쿼리는 컨버터 미적용 → 직접 암호화
        byte[] encAcc = CryptoSupport.enc("777-7777-777777");
        Account got = (Account) em.createNativeQuery(
                "SELECT * FROM account WHERE account_number = :enc", Account.class)
            .setParameter("enc", encAcc)
            .getSingleResult();

        // then
        assertThat(got.getAccountSeq()).isEqualTo(a.getAccountSeq());
    }

    @Test
    @Transactional
    void ciphertext_is_deterministic_and_equals_to_enc_result() {
        // given
        User u = persistUser("uuid-4", "d@d.com", Provider.KAKAO, "kakao-000");
        Account a = persistAccount(u, "110-0000-000000", "4444-4444-4444-4444", "000");

        // when: 저장된 암호문 직접 조회
        byte[] stored = (byte[]) em.createNativeQuery(
                "SELECT account_number FROM account WHERE account_seq = :id")
            .setParameter("id", a.getAccountSeq())
            .getSingleResult();

        byte[] reenc = CryptoSupport.enc("110-0000-000000");

        // then: 결정적 암호화 → 동일 평문 == 동일 암호문
        assertThat(stored).isEqualTo(reenc);
    }

    @Test
    @Transactional
    void unique_constraints_duplicate_plaintext_should_violate() {
        // ===== 1) account_number UNIQUE 위반 =====
        User u1 = persistUser("uuid-5", "e@e.com", Provider.KAKAO, "kakao-dup");

        persistAccount(u1, "555-5555-555555", null, null);

        Account dup1 = Account.builder()
            .user(u1)
            .accountNumber("555-5555-555555") // 같은 평문 → UNIQUE 위반
            .build();

        assertThatThrownBy(() -> accountRepo.saveAndFlush(dup1))
            .isInstanceOf(DataIntegrityViolationException.class);

        // 예외 후 트랜잭션 리셋
        resetTx();

        // ===== 2) virtual_card = NULL 여러 건 허용 =====
        User u2 = persistUser("uuid-5b", "e2@e.com", Provider.KAKAO, "kakao-dup-2");
        persistAccount(u2, "666-6666-666666", null, null);

        Account nullAgain = Account.builder()
            .user(u2)
            .accountNumber("666-6666-666667")
            .virtualCard(null) // 또 NULL
            .build();

        assertThatCode(() -> accountRepo.saveAndFlush(nullAgain))
            .doesNotThrowAnyException();

        // ===== 3) virtual_card 중복 평문 → UNIQUE 위반 =====
        persistAccount(u2, "888-8888-888888", "4999-9999-9999-9999", null);

        Account dupV = Account.builder()
            .user(u2)
            .accountNumber("888-8888-888889")
            .virtualCard("4999-9999-9999-9999")
            .build();

        assertThatThrownBy(() -> accountRepo.saveAndFlush(dupV))
            .isInstanceOf(DataIntegrityViolationException.class);
    }

    @Test
    @Transactional
    void composite_unique_on_user_provider_and_providerId() {
        // ========== 1) 같은 provider + 같은 providerId → UNIQUE 위반 ==========
        persistUser("uuid-6", "f@f.com", Provider.KAKAO, "pid-123");

        User dup = User.builder()
            .userUuid("uuid-7")
            .name("Dup")
            .email("g@g.com")
            .role(Role.CHILD)
            .provider(Provider.KAKAO)
            .providerId("pid-123") // 같은 평문 → 같은 암호문
            .build();

        assertThatThrownBy(() -> userRepo.saveAndFlush(dup))
            .isInstanceOf(DataIntegrityViolationException.class);

        // ★ 중요: 위에서 예외가 발생했으므로 트랜잭션 리셋
        resetTx();

        // ========== 2) provider 다르면 같은 providerId 허용 ==========
        User ok = User.builder()
            .userUuid("uuid-8")
            .name("Ok")
            .email("h@h.com")
            .role(Role.CHILD)
            .provider(Provider.GOOGLE)  // 다른 provider
            .providerId("pid-123")      // 동일 평문(=동일 암호문)이어도 허용
            .build();

        assertThatCode(() -> userRepo.saveAndFlush(ok))
            .doesNotThrowAnyException();

        // ========== 3) providerId = NULL 은 여러 건 허용 ==========
        User n1 = User.builder()
            .userUuid("uuid-9")
            .name("Null1")
            .email("i@i.com")
            .role(Role.CHILD)
            .provider(Provider.KAKAO)
            .providerId(null)
            .build();
        userRepo.saveAndFlush(n1);

        User n2 = User.builder()
            .userUuid("uuid-10")
            .name("Null2")
            .email("j@j.com")
            .role(Role.CHILD)
            .provider(Provider.KAKAO)
            .providerId(null)
            .build();

        assertThatCode(() -> userRepo.saveAndFlush(n2))
            .doesNotThrowAnyException();
    }
}
