package com.e106.kdkd.ssafy.service;

import com.e106.kdkd.ssafy.dto.SsafyMemberResponse;
import java.util.Map;
import java.util.Optional;

public interface SsafyApiService {

    // Api Key 최초 발급
    Map<String, Object> issueApiKey();

    // Api Key 재발급
    Map<String, Object> reIssueApiKey();

    // 회원 등록
    Map<String, Object> enrollMember(String userEmail);

    // 회원 조회
    Optional<SsafyMemberResponse> searchMember(String userEmail);

    Optional<SsafyMemberResponse> searchMemberOnboard(String userEmail);
}
