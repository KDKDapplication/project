package com.e106.kdkd.security.encryption.util;

import com.google.crypto.tink.DeterministicAead;
import jakarta.persistence.PersistenceException;
import java.nio.charset.StandardCharsets;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public final class CryptoSupport {

    private static DeterministicAead D;

    private CryptoSupport() {
    }

    public static void init(DeterministicAead d) {
        D = d;
        log.debug("DeterministicAead initialized: type={}, adLen={}",
            (d != null ? d.getClass().getSimpleName() : "null"),
            (UnifiedAd.AD != null ? UnifiedAd.AD.length() : -1));
    }

    public static byte[] enc(String plaintext) {
        log.debug("enc 매서드 시작");
        if (plaintext == null) {
            log.debug("enc() | plaintext is null → return null");
            return null;
        }
        try {
            return D.encryptDeterministically(
                plaintext.getBytes(StandardCharsets.UTF_8),
                UnifiedAd.AD.getBytes(StandardCharsets.UTF_8));
        } catch (Exception e) {
            throw new PersistenceException("Deterministic encryption failed", e);
        }
    }

    public static String dec(byte[] ciphertext) {
        log.debug("dec 매서드 시작");
        if (ciphertext == null) {
            return null;
        }
        try {
            byte[] p = D.decryptDeterministically(
                ciphertext,
                UnifiedAd.AD.getBytes(StandardCharsets.UTF_8));
            return new String(p, StandardCharsets.UTF_8);
        } catch (Exception e) {
            throw new PersistenceException("Deterministic decryption failed", e);
        }
    }
}