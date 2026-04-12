class HistoryItem {
  final String id;
  final DateTime timestamp;
  final double preTaxSalary;
  final String cityName;
  final double afterTaxSalary;
  final String? label;

  HistoryItem({
    required this.id,
    required this.timestamp,
    required this.preTaxSalary,
    required this.cityName,
    required this.afterTaxSalary,
    this.label,
  });

  HistoryItem copyWith({
    String? id,
    DateTime? timestamp,
    double? preTaxSalary,
    String? cityName,
    double? afterTaxSalary,
    String? label,
  }) {
    return HistoryItem(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      preTaxSalary: preTaxSalary ?? this.preTaxSalary,
      cityName: cityName ?? this.cityName,
      afterTaxSalary: afterTaxSalary ?? this.afterTaxSalary,
      label: label ?? this.label,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'preTaxSalary': preTaxSalary,
      'cityName': cityName,
      'afterTaxSalary': afterTaxSalary,
      'label': label,
    };
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      preTaxSalary: json['preTaxSalary'] as double,
      cityName: json['cityName'] as String,
      afterTaxSalary: json['afterTaxSalary'] as double,
      label: json['label'] as String?,
    );
  }
}
