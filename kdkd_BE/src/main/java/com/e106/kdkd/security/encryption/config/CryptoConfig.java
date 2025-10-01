package com.e106.kdkd.security.encryption.config;

import com.e106.kdkd.security.encryption.util.CryptoSupport;
import com.google.crypto.tink.CleartextKeysetHandle;
import com.google.crypto.tink.DeterministicAead;
import com.google.crypto.tink.JsonKeysetReader;
import com.google.crypto.tink.KeysetHandle;
import com.google.crypto.tink.config.TinkConfig;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

@Configuration
@Profile("!test")
@Slf4j
public class CryptoConfig {

    // Base64 로 인코딩된 키셋(JSON)만 사용
    @Value("${CRYPTO_TINK_KEYSET_B64}")
    private String keysetB64;

    @Bean
    public DeterministicAead deterministicAead() throws Exception {
        log.debug("[TINK] 키셋 로딩 (Base64 from properties/env)");
        TinkConfig.register();

        if (keysetB64 == null || keysetB64.isBlank()) {
            throw new IllegalStateException(
                "CRYPTO_TINK_KEYSET_B64 (crypto.tink.keyset-b64)가 비어있습니다. " +
                    "환경변수나 프로퍼티로 Base64 키셋을 주입하세요.");
        }

        String json = new String(Base64.getDecoder().decode(keysetB64), StandardCharsets.UTF_8);
        KeysetHandle handle = CleartextKeysetHandle.read(JsonKeysetReader.withString(json));
        DeterministicAead daead = handle.getPrimitive(DeterministicAead.class);
        CryptoSupport.init(daead);
        log.info("[TINK] keyset loaded from Base64 (length: {} chars)", keysetB64.length());
        return daead;
    }
}
