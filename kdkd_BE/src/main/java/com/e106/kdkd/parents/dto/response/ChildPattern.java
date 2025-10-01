package com.e106.kdkd.parents.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@AllArgsConstructor
@Builder
public class ChildPattern {

    Integer totalDays;
    Long totalAmount;
    Long etcAmount;
    Long transportationAmount;
    Long stationaryStoreAmount;
    Long convenienceStoreAmount;
    Long restaurantAmount;
    Long cultureAmount;
    Long cafeAmount;

    public ChildPattern() {
        this.totalDays = 0;
        this.totalAmount = 0L;
        this.etcAmount = 0L;
        this.cafeAmount = 0L;
        this.transportationAmount = 0L;
        this.stationaryStoreAmount = 0L;
        this.convenienceStoreAmount = 0L;
        this.restaurantAmount = 0L;
        this.cultureAmount = 0L;
    }
}
