package com.e106.kdkd.bank.service;

import com.e106.kdkd.bank.dto.SourceType;
import com.e106.kdkd.bank.dto.UnifiedConsumptionItem;
import com.e106.kdkd.bank.dto.UnifiedConsumptionListRec;
import com.e106.kdkd.bank.repository.BankRepository;
import com.e106.kdkd.ssafy.dto.TransactionHistoryItem;
import com.e106.kdkd.ssafy.dto.TransactionHistoryRec;
import com.e106.kdkd.ssafy.dto.ResponseEnvelope;
import com.e106.kdkd.ssafy.dto.card.InquireCreditCardTransactionListRec;
import com.e106.kdkd.ssafy.dto.card.InquireCreditCardTransactionListRequest;
import com.e106.kdkd.ssafy.service.BankService;
import com.e106.kdkd.ssafy.service.CreditCardService;
import java.time.YearMonth;
import java.util.*;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class BankConsumptionServiceImpl implements BankConsumptionService {

    private final BankService bankService;
    private final CreditCardService creditCardService;
    private final BankRepository bankRepository;

    @Override
    public UnifiedConsumptionListRec queryMonthly(
            String userUuid,
            String month,
            String day,
            SourceType sourceType
    ) {
        // 기간 계산
        YearMonth ym = YearMonth.of(
                Integer.parseInt(month.substring(0, 4)),
                Integer.parseInt(month.substring(4, 6))
        );
        String startDate = month + "01";
        String endDate = month + String.format("%02d", ym.lengthOfMonth());

        if (day != null && !day.isBlank()) {
            String dd = String.format("%02d", Integer.parseInt(day));
            startDate = month + dd;
            endDate = month + dd;
        }

        List<UnifiedConsumptionItem> all = new ArrayList<>();

        // 1) 계좌
        if (sourceType == SourceType.ACCOUNT || sourceType == SourceType.ALL) {
            final String sDate = startDate;
            final String eDate = endDate;
            bankRepository.findPrimaryAccountNoByUserUuid(userUuid).ifPresent(accountNo -> {
                ResponseEnvelope<TransactionHistoryRec> resp =
                        bankService.inquireTransactionHistoryList(
                                accountNo, sDate, eDate, "A", "ASC", userUuid
                        );
                if (resp != null && resp.getREC() != null && resp.getREC().getList() != null) {
                    String myName = bankRepository.findUserNameByUserUuid(userUuid).orElse("나");
                    for (TransactionHistoryItem it : resp.getREC().getList()) {
                        String desc;
                        String direction;
                        String tName = safe(it.getTransactionTypeName());
                        if ("입금".equals(tName)) {
                            desc = myName;
                            direction = "증가";
                        } else if ("출금".equals(tName)) {
                            desc = myName;
                            direction = "감소";
                        } else if ("출금(이체)".equals(tName)) {
                            desc = bankRepository.findOwnerNameByAccountNo(safe(it.getTransactionAccountNo()))
                                    .orElse(maskAccount(safe(it.getTransactionAccountNo())));
                            direction = "감소";
                        } else if ("입금(이체)".equals(tName)) {
                            desc = bankRepository.findOwnerNameByAccountNo(safe(it.getTransactionAccountNo()))
                                    .orElse(maskAccount(safe(it.getTransactionAccountNo())));
                            direction = "증가";
                        } else {
                            desc = (tName == null || tName.isBlank()) ? "거래" : tName;
                            direction = "감소";
                        }

                        long amount = parseLongSafe(it.getTransactionBalance());
                        all.add(UnifiedConsumptionItem.builder()
                                .date(safe(it.getTransactionDate()))
                                .time(safe(it.getTransactionTime()))
                                .description(desc)
                                .amount(amount)
                                .direction(direction)
                                .source("ACCOUNT")
                                .build());
                    }
                }
            });
        }

        // 2) 카드
        if (sourceType == SourceType.CARD || sourceType == SourceType.ALL) {
            Optional<String> cardNoOpt = bankRepository.findPrimaryCardNoByUserUuid(userUuid);
            Optional<String> cvcOpt = bankRepository.findPrimaryCardCvcByUserUuid(userUuid);
            if (cardNoOpt.isPresent() && cvcOpt.isPresent()) {
                InquireCreditCardTransactionListRequest req = new InquireCreditCardTransactionListRequest();
                req.setCardNo(cardNoOpt.get());
                req.setCvc(cvcOpt.get());
                req.setStartDate(startDate);
                req.setEndDate(endDate);

                ResponseEnvelope<InquireCreditCardTransactionListRec> resp =
                        creditCardService.inquireCreditCardTransactionList(req, userUuid);

                if (resp != null && resp.getREC() != null && resp.getREC().getTransactionList() != null) {
                    for (var it : resp.getREC().getTransactionList()) {
                        String desc = (it.getMerchantName() != null && !it.getMerchantName().isBlank())
                                ? it.getMerchantName()
                                : (it.getCategoryName() != null && !it.getCategoryName().isBlank())
                                ? it.getCategoryName()
                                : "카드 결제";

                        long amount = parseLongSafe(it.getTransactionBalance());

                        all.add(UnifiedConsumptionItem.builder()
                                .date(safe(it.getTransactionDate()))
                                .time(safe(it.getTransactionTime()))
                                .description(desc)
                                .amount(amount)
                                .direction("감소")
                                .source("CARD")
                                .build());
                    }
                }
            }
        }

        // 정렬: 최신순
        List<UnifiedConsumptionItem> sorted = all.stream()
                .sorted(Comparator
                        .comparing(UnifiedConsumptionItem::getDate).reversed()
                        .thenComparing(UnifiedConsumptionItem::getTime, Comparator.nullsLast(Comparator.reverseOrder()))
                        .thenComparing(UnifiedConsumptionItem::getSource, Comparator.nullsLast(Comparator.naturalOrder()))
                        .thenComparing(UnifiedConsumptionItem::getDescription, Comparator.nullsLast(Comparator.naturalOrder()))
                        .thenComparingLong(UnifiedConsumptionItem::getAmount).reversed()
                )
                .collect(Collectors.toList());

        return UnifiedConsumptionListRec.builder()
                .totalCount(sorted.size())
                .list(sorted)
                .build();
    }

    private static String safe(String s) {
        return s == null ? "" : s;
    }

    private static String maskAccount(String acc) {
        if (acc == null || acc.isBlank()) return "이체";
        int n = acc.length();
        return (n <= 4) ? "****" : "****" + acc.substring(Math.max(0, n - 4));
    }

    private static long parseLongSafe(String s) {
        if (s == null) return 0L;
        try {
            return Long.parseLong(s.trim());
        } catch (NumberFormatException e) {
            return 0L;
        }
    }
}
