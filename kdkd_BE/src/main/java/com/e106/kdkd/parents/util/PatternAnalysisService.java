package com.e106.kdkd.parents.util;

import static java.lang.Math.abs;

import com.e106.kdkd.account.repository.AccountItemRepository;
import com.e106.kdkd.parents.dto.AccountItemWithSubcategory;
import com.e106.kdkd.parents.dto.response.ChildPattern;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class PatternAnalysisService {

    private final AccountItemRepository accountItemRepository;

    public ChildPattern classifyCategory(Long accountSeq, YearMonth yearMonth) {
        Long totalAmount = 0L;
        Long etcAmount = 0L;
        Long transportationAmount = 0L;
        Long stationaryStoreAmount = 0L;
        Long convenienceStoreAmount = 0L;
        Long restaurantAmount = 0L;
        Long cultureAmount = 0L;
        Long cafeAmount = 0L;

        List<AccountItemWithSubcategory> items = accountItemRepository.findAccountItemsWithSubcategory(
            accountSeq, yearMonth);

        for (AccountItemWithSubcategory item : items) {
            if (item.getCategoryName().equals("교통")) {
                transportationAmount += item.getPaymentBalance();
            } else if (item.getCategoryName().equals("생활")) {
                switch (item.getSubcategoryId().toString()) {
                    case "1":
                        convenienceStoreAmount += item.getPaymentBalance();
                        break;
                    case "2":
                        cafeAmount += item.getPaymentBalance();
                        break;
                    case "3":
                        restaurantAmount += item.getPaymentBalance();
                        break;
                    case "4":
                        stationaryStoreAmount += item.getPaymentBalance();
                        break;
                    case "5":
                        cultureAmount += item.getPaymentBalance();
                        break;
                }
            } else {
                etcAmount += item.getPaymentBalance();
            }
            totalAmount += item.getPaymentBalance();
        }

        ChildPattern childPattern = ChildPattern.builder()
            .totalDays(calcTotalDays(yearMonth))
            .cafeAmount(cafeAmount)
            .convenienceStoreAmount(convenienceStoreAmount)
            .restaurantAmount(restaurantAmount)
            .stationaryStoreAmount(stationaryStoreAmount)
            .etcAmount(etcAmount)
            .transportationAmount(transportationAmount)
            .totalAmount(totalAmount)
            .cultureAmount(cultureAmount)
            .build();
        return childPattern;
    }

    public int calcTotalDays(YearMonth ym) {
        LocalDate today = LocalDate.now();           // 시스템 기본 타임존 기준
        YearMonth thisMonth = YearMonth.from(today);

        if (ym.equals(thisMonth)) {
            // 이번 달: 1일 ~ 오늘(포함)
            return (int) ChronoUnit.DAYS.between(ym.atDay(1), today) + 1;
        } else {
            // 다른 달: 그 달의 총 일수
            return ym.lengthOfMonth();
        }
    }

    private static long nz(Long v) {
        return v == null ? 0L : v;
    }

    /**
     * ChildPattern의 카테고리별 지출을 비교해 소비 성향 단어를 반환한다. 규칙: - 총지출 0원이면 "지출 없음" - 1위와 2위 비율 차이가 5%p 이내면
     * "혼합형 (A/B)" - 그 외엔 1위 카테고리의 성향 단어(A)를 반환 성향 매핑: 기타→즉흥형, 편의점→간편추구형, 카페→힐링형, 음식점→외식중심형,
     * 문구/서점→학습지향형, 문화→경험중시형, 교통→활동가형
     */
    public String classifyConsumptionTendency(ChildPattern p) {
        long etc = nz(p.getEtcAmount());
        long convenience = nz(p.getConvenienceStoreAmount());
        long cafe = nz(p.getCafeAmount());
        long restaurant = nz(p.getRestaurantAmount());
        long stationery = nz(p.getStationaryStoreAmount());
        long culture = nz(p.getCultureAmount());
        long transport = nz(p.getTransportationAmount());

        long total = etc + convenience + cafe + restaurant + stationery + culture + transport;
        if (total <= 0) {
            return "지출 없음";
        }

        record Item(String category, String persona, long amount) {

        }

        List<Item> items = List.of(
            new Item("기타", "즉흥형", etc),
            new Item("편의점", "간편추구형", convenience),
            new Item("카페", "힐링형", cafe),
            new Item("음식점", "외식중심형", restaurant),
            new Item("문구/서점", "학습지향형", stationery),
            new Item("문화", "경험중시형", culture),
            new Item("교통", "활동가형", transport)
        );

        List<Item> sorted = new ArrayList<>(items);
        sorted.sort(Comparator.comparingLong(Item::amount).reversed());

        Item top1 = sorted.get(0);
        if (top1.amount == 0) {
            return "지출 없음"; // 모든 금액이 0인 경우
        }

        Item top2 = sorted.get(1);
        double s1 = top1.amount / (double) total;
        double s2 = top2.amount / (double) total;

        final double MIXED_DELTA = 0.05; // 5%p 이내면 혼합형으로 간주

        if (abs(s1 - s2) <= MIXED_DELTA) {
            return "혼합형 (" + top1.persona + "/" + top2.persona + ")";
        }
        return top1.persona;
    }
}
