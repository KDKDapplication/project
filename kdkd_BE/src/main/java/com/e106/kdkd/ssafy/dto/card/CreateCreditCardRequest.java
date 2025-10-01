// src/main/java/com/e106/kdkd/ssafy/dto/card/CreateCreditCardRequest.java
package com.e106.kdkd.ssafy.dto.card;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateCreditCardRequest {

    private String cardUniqueNo;
    private String withdrawalAccountNo;
    private String withdrawalDate; // "4" 등 문자열 규격 유지
}
