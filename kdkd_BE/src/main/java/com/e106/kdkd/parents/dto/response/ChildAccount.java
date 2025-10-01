package com.e106.kdkd.parents.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ChildAccount {

    String childUuid;
    Long accountSeq;
    String childName;
    String childAccountNumber;
    Integer childRemain;
}
