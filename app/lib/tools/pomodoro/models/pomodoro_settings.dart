import 'dart:convert';

enum DisplayStyle { timer, independent, mixed }

enum CompleteAction { autoProceed, waitConfirm }

class PomodoroSettings {
  final int workDuration;
  final bool shortBreakEnabled;
  final int shortBreakDuration;
  final bool longBreakEnabled;
  final int longBreakDuration;
  final int longBreakInterval;
  final DisplayStyle displayStyle;
  final CompleteAction completeAction;
  final bool vibrationEnabled;
  final bool soundEnabled;

  const PomodoroSettings({
    this.workDuration = 25,
    this.shortBreakEnabled = true,
    this.shortBreakDuration = 5,
    this.longBreakEnabled = true,
    this.longBreakDuration = 15,
    this.longBreakInterval = 4,
    this.displayStyle = DisplayStyle.mixed,
    this.completeAction = CompleteAction.waitConfirm,
    this.vibrationEnabled = true,
    this.soundEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'workDuration': workDuration,
      'shortBreakEnabled': shortBreakEnabled,
      'shortBreakDuration': shortBreakDuration,
      'longBreakEnabled': longBreakEnabled,
      'longBreakDuration': longBreakDuration,
      'longBreakInterval': longBreakInterval,
      'displayStyle': displayStyle.name,
      'completeAction': completeAction.name,
      'vibrationEnabled': vibrationEnabled,
      'soundEnabled': soundEnabled,
    };
  }

  factory PomodoroSettings.fromMap(Map<String, dynamic> map) {
    return PomodoroSettings(
      workDuration: map['workDuration'] as int? ?? 25,
      shortBreakEnabled: map['shortBreakEnabled'] as bool? ?? true,
      shortBreakDuration: map['shortBreakDuration'] as int? ?? 5,
      longBreakEnabled: map['longBreakEnabled'] as bool? ?? true,
      longBreakDuration: map['longBreakDuration'] as int? ?? 15,
      longBreakInterval: map['longBreakInterval'] as int? ?? 4,
      displayStyle: map['displayStyle'] != null
          ? DisplayStyle.values.firstWhere((e) => e.name == map['displayStyle'])
          : DisplayStyle.mixed,
      completeAction: map['completeAction'] != null
          ? CompleteAction.values.firstWhere((e) => e.name == map['completeAction'])
          : CompleteAction.waitConfirm,
      vibrationEnabled: map['vibrationEnabled'] as bool? ?? true,
      soundEnabled: map['soundEnabled'] as bool? ?? true,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory PomodoroSettings.fromJson(String source) {
    return PomodoroSettings.fromMap(jsonDecode(source) as Map<String, dynamic>);
  }

  PomodoroSettings copyWith({
    int? workDuration,
    bool? shortBreakEnabled,
    int? shortBreakDuration,
    bool? longBreakEnabled,
    int? longBreakDuration,
    int? longBreakInterval,
    DisplayStyle? displayStyle,
    CompleteAction? completeAction,
    bool? vibrationEnabled,
    bool? soundEnabled,
  }) {
    return PomodoroSettings(
      workDuration: workDuration ?? this.workDuration,
      shortBreakEnabled: shortBreakEnabled ?? this.shortBreakEnabled,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakEnabled: longBreakEnabled ?? this.longBreakEnabled,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      longBreakInterval: longBreakInterval ?? this.longBreakInterval,
      displayStyle: displayStyle ?? this.displayStyle,
      completeAction: completeAction ?? this.completeAction,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }
}