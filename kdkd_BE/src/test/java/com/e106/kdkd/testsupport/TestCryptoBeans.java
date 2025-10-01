package com.e106.kdkd.testsupport;

import com.e106.kdkd.security.encryption.util.CryptoSupport;
import com.google.crypto.tink.DeterministicAead;
import com.google.crypto.tink.KeyTemplates;
import com.google.crypto.tink.KeysetHandle;
import com.google.crypto.tink.config.TinkConfig;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Profile;

@TestConfiguration
@Profile("test")
public class TestCryptoBeans {

    @Bean
    public DeterministicAead testDaead() throws Exception {
        TinkConfig.register();
        KeysetHandle handle = KeysetHandle.generateNew(
            KeyTemplates.get("AES256_SIV"));  // <- 문자열로 템플릿 조회
        DeterministicAead daead = handle.getPrimitive(DeterministicAead.class);
        CryptoSupport.init(daead); // 컨버터가 사용
        return daead;
    }
}
