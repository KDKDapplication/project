import 'package:kdkd_mobile/feature/parent_collection/models/spending_history_model.dart';

final Map<String, List<SpendingHistoryModel>> spendingHistoryData = {
  'child-uuid-1': [
    SpendingHistoryModel.fromMap({
      "accountItemSeq": "uuid-111",
      "merchantName": "과자가게",
      "paymentBalance": 10000,
      "transactionDate": "2025-07-20",
      "transactionTime": "142355",
    }),
    SpendingHistoryModel.fromMap({
      "accountItemSeq": "uuid-112",
      "merchantName": "편의점",
      "paymentBalance": 5500,
      "transactionDate": "2025-07-21",
      "transactionTime": "091010",
    }),
  ],
  'child-uuid-2': [
    SpendingHistoryModel.fromMap({
      "accountItemSeq": "uuid-221",
      "merchantName": "술집",
      "paymentBalance": 15000,
      "transactionDate": "2025-07-23",
      "transactionTime": "080245",
    }),
    SpendingHistoryModel.fromMap({
      "accountItemSeq": "uuid-222",
      "merchantName": "버거킹",
      "paymentBalance": 8900,
      "transactionDate": "2025-07-24",
      "transactionTime": "121500",
    }),
  ],
  'child-uuid-3': [
    SpendingHistoryModel.fromMap({
      "accountItemSeq": "uuid-331",
      "merchantName": "메가커피",
      "paymentBalance": 2500,
      "transactionDate": "2025-07-25",
      "transactionTime": "101230",
    }),
    SpendingHistoryModel.fromMap({
      "accountItemSeq": "uuid-332",
      "merchantName": "배달의민족",
      "paymentBalance": 21000,
      "transactionDate": "2025-07-25",
      "transactionTime": "192020",
    }),
  ],
};
