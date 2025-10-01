package com.e106.kdkd.parents.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class TwoMonthPattern {

    private String summary;
    private ChildPattern lastData;
    private ChildPattern thisData;

    public TwoMonthPattern(ChildPattern lastData, ChildPattern thisData, String summary) {
        this.lastData = lastData;
        this.thisData = thisData;
        this.summary = summary;
    }
}
