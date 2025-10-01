package com.e106.kdkd.ssafy.util;

import com.e106.kdkd.ssafy.dto.RequestHeader;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.concurrent.ThreadLocalRandom;

public class HeaderFactory {

    private static final String INSTITUTION_CODE = "00100";
    private static final String FINTECH_APP_NO = "001";
    private static final DateTimeFormatter DATE_FMT  = DateTimeFormatter.ofPattern("yyyyMMdd");
    private static final DateTimeFormatter TIME_FMT  = DateTimeFormatter.ofPattern("HHmmss");
    private static final DateTimeFormatter UNIQUE_FMT= DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

    private static String uniqueNo() {
        String ts = LocalDateTime.now().format(UNIQUE_FMT);
        int rand = ThreadLocalRandom.current().nextInt(0, 1_000_000);
        return ts + String.format("%06d", rand);
    }

    /** userKey 없는 경우 (조회 API) */
    public static RequestHeader of(String apiName, String apiKey) {
        LocalDateTime now = LocalDateTime.now();
        return RequestHeader.builder()
                .apiName(apiName)
                .transmissionDate(now.format(DATE_FMT))
                .transmissionTime(now.format(TIME_FMT))
                .institutionCode(INSTITUTION_CODE)
                .fintechAppNo(FINTECH_APP_NO)
                .apiServiceCode(apiName)
                .institutionTransactionUniqueNo(uniqueNo())
                .apiKey(apiKey)
                .build();
    }

    /** userKey 포함 (이체 API 등) */
    public static RequestHeader of(String apiName, String apiKey, String userKey) {
        return of(apiName, apiKey).toBuilder()
                .userKey(userKey)
                .build();
    }
}
