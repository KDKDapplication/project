package com.e106.kdkd.s3.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder

public class ResponseFileInfo {
    private String presignedUrl;
    private String fileName;
    private Integer sequence;

}
