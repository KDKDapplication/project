enum SourceType { ACCOUNT, CARD, ALL }

extension SourceTypeExtension on SourceType {
  String get value {
    switch (this) {
      case SourceType.ACCOUNT:
        return 'ACCOUNT';
      case SourceType.CARD:
        return 'CARD';
      case SourceType.ALL:
        return 'ALL';
    }
  }
}

class HistoryModel {
  final int totalCount;
  final List<HistoryItem> list;

  HistoryModel({
    required this.totalCount,
    required this.list,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      totalCount: json['totalCount'] ?? 0,
      list: (json['list'] as List<dynamic>?)?.map((item) => HistoryItem.fromJson(item)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCount': totalCount,
      'list': list.map((item) => item.toJson()).toList(),
    };
  }
}

class HistoryItem {
  final String date;
  final String time;
  final String description;
  final int amount;
  final String direction;
  final String source;

  HistoryItem({
    required this.date,
    required this.time,
    required this.description,
    required this.amount,
    required this.direction,
    required this.source,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      description: json['description'] ?? '',
      amount: json['amount'] ?? 0,
      direction: json['direction'] ?? '',
      source: json['source'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'time': time,
      'description': description,
      'amount': amount,
      'direction': direction,
      'source': source,
    };
  }
}
