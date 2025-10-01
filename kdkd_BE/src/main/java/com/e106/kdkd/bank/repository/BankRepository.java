package com.e106.kdkd.bank.repository;

import java.util.Optional;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

@Repository
@RequiredArgsConstructor
public class BankRepository {

    private final EntityManager em;

    /** userUuid → 사용자 이름 */
    public Optional<String> findUserNameByUserUuid(String userUuid) {
        try {
            String name = em.createQuery(
                            "select u.name from User u where u.userUuid = :uuid",
                            String.class
                    )
                    .setParameter("uuid", userUuid)
                    .setMaxResults(1)
                    .getSingleResult();
            return Optional.ofNullable(name);
        } catch (NoResultException e) {
            return Optional.empty();
        }
    }

    /** accountNumber → 소유자 이름 (Account.user.name) */
    public Optional<String> findOwnerNameByAccountNo(String rawAccountNo) {
        if (rawAccountNo == null || rawAccountNo.isBlank()) return Optional.empty();
        String normalized = normalizeAccountNo(rawAccountNo);

        try {
            String name = em.createQuery(
                            "select u.name " +
                                    "from Account a join a.user u " +
                                    "where a.accountNumber = :acc",
                            String.class
                    )
                    .setParameter("acc", normalized)   // UnifiedDeterministicStringConverter가 파라미터에도 적용됨
                    .setMaxResults(1)
                    .getSingleResult();
            return Optional.ofNullable(name);
        } catch (NoResultException e) {
            return Optional.empty();
        }
    }

    /** userUuid → 최신 계좌번호 */
    public Optional<String> findPrimaryAccountNoByUserUuid(String userUuid) {
        try {
            String acc = em.createQuery(
                            "select a.accountNumber from Account a " +
                                    "where a.user.userUuid = :uuid " +
                                    "order by a.accountSeq desc",   // PK로 최신 정렬
                            String.class
                    )
                    .setParameter("uuid", userUuid)
                    .setMaxResults(1)
                    .getSingleResult();
            return Optional.ofNullable(acc);
        } catch (NoResultException e) {
            return Optional.empty();
        }
    }

    /** userUuid → 기본 가상카드 번호 */
    public Optional<String> findPrimaryCardNoByUserUuid(String userUuid) {
        try {
            String cardNo = em.createQuery(
                            "select a.virtualCard from Account a " +
                                    "where a.user.userUuid = :uuid and a.virtualCard is not null " +
                                    "order by a.accountSeq desc",
                            String.class
                    )
                    .setParameter("uuid", userUuid)
                    .setMaxResults(1)
                    .getSingleResult();
            return Optional.ofNullable(cardNo);
        } catch (NoResultException e) {
            return Optional.empty();
        }
    }

    /** userUuid → 기본 가상카드 CVC */
    public Optional<String> findPrimaryCardCvcByUserUuid(String userUuid) {
        try {
            String cvc = em.createQuery(
                            "select a.virtualCardCvc from Account a " +
                                    "where a.user.userUuid = :uuid and a.virtualCardCvc is not null " +
                                    "order by a.accountSeq desc",
                            String.class
                    )
                    .setParameter("uuid", userUuid)
                    .setMaxResults(1)
                    .getSingleResult();
            return Optional.ofNullable(cvc);
        } catch (NoResultException e) {
            return Optional.empty();
        }
    }

    /** 하이픈/공백 제거 등: 숫자만 남기기 */
    private static String normalizeAccountNo(String s) {
        return s.replaceAll("[^0-9]", "");
    }
}
