package com.e106.kdkd.children.dto.request;

import java.util.List;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class AutoDistributionRequest {
    private List<AutoDistributionRequestItem> autoDistributions;
}