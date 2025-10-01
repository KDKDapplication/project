package com.e106.kdkd.ssafy.util;

import com.e106.kdkd.ssafy.dto.ResponseEnvelope;

public class BankApiException extends RuntimeException {
    private final ResponseEnvelope<?> errorResponse;

    public BankApiException(ResponseEnvelope<?> errorResponse) {
        super("Bank API Error: " + errorResponse.getHeader().getResponseMessage());
        this.errorResponse = errorResponse;
    }

    public ResponseEnvelope<?> getErrorResponse() {
        return errorResponse;
    }
}
