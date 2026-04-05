class LifeGridSettings {
  bool showWeekMonth;
  bool showYear;
  bool showLife;
  bool showCustom;
  List<String> tabOrder;
  DateTime? birthDate;
  int targetAge;
  int activeTabIndex;

  LifeGridSettings({
    this.showWeekMonth = true,
    this.showYear = true,
    this.showLife = true,
    this.showCustom = true,
    this.tabOrder = const ['week_month', 'year', 'life', 'custom'],
    this.birthDate,
    this.targetAge = 80,
    this.activeTabIndex = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'showWeekMonth': showWeekMonth,
      'showYear': showYear,
      'showLife': showLife,
      'showCustom': showCustom,
      'tabOrder': tabOrder,
      'birthDate': birthDate?.toIso8601String(),
      'targetAge': targetAge,
      'activeTabIndex': activeTabIndex,
    };
  }

  factory LifeGridSettings.fromJson(Map<String, dynamic> json) {
    return LifeGridSettings(
      showWeekMonth: json['showWeekMonth'] ?? true,
      showYear: json['showYear'] ?? true,
      showLife: json['showLife'] ?? true,
      showCustom: json['showCustom'] ?? true,
      tabOrder: (json['tabOrder'] as List<dynamic>?)?.cast<String>() ??
                ['week_month', 'year', 'life', 'custom'],
      birthDate: json['birthDate'] != null
          ? DateTime.tryParse(json['birthDate'] as String)
          : null,
      targetAge: json['targetAge'] ?? 80,
      activeTabIndex: json['activeTabIndex'] ?? 0,
    );
  }

  LifeGridSettings copyWith({
    bool? showWeekMonth,
    bool? showYear,
    bool? showLife,
    bool? showCustom,
    List<String>? tabOrder,
    DateTime? birthDate,
    int? targetAge,
    int? activeTabIndex,
  }) {
    return LifeGridSettings(
      showWeekMonth: showWeekMonth ?? this.showWeekMonth,
      showYear: showYear ?? this.showYear,
      showLife: showLife ?? this.showLife,
      showCustom: showCustom ?? this.showCustom,
      tabOrder: tabOrder ?? this.tabOrder,
      birthDate: birthDate ?? this.birthDate,
      targetAge: targetAge ?? this.targetAge,
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
    );
  }
}
