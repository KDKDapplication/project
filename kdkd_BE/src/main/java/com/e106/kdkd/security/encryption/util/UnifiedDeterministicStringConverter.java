package com.e106.kdkd.security.encryption.util;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;

/**
 * 하나의 AD로 통일해 쓰는 컨버터
 */
@Converter(autoApply = false)
public class UnifiedDeterministicStringConverter
    implements AttributeConverter<String, byte[]> {

    @Override
    public byte[] convertToDatabaseColumn(String attribute) {
        return CryptoSupport.enc(attribute);
    }

    @Override
    public String convertToEntityAttribute(byte[] dbData) {
        return CryptoSupport.dec(dbData);
    }
}
