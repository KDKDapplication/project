package com.e106.kdkd.account.repository;

import java.time.LocalTime;

// 인터페이스 기반 프로젝션
public interface AutoTransferView {
    String getChildName();
    Long getAmount();
    Integer getTransferDay();
    LocalTime getTransferTime();
}