class CityConfig {
  final String id;
  final String name;
  final double pensionBase;
  final double pensionBaseMax;
  final double pensionRate;
  final double medicalRate;
  final double unemploymentRate;
  final double housingFundRate;
  final double housingFundBase;
  final double housingFundBaseMax;

  CityConfig({
    required this.id,
    required this.name,
    required this.pensionBase,
    required this.pensionBaseMax,
    required this.pensionRate,
    required this.medicalRate,
    required this.unemploymentRate,
    required this.housingFundRate,
    required this.housingFundBase,
    required this.housingFundBaseMax,
  });

  CityConfig copyWith({
    String? id,
    String? name,
    double? pensionBase,
    double? pensionBaseMax,
    double? pensionRate,
    double? medicalRate,
    double? unemploymentRate,
    double? housingFundRate,
    double? housingFundBase,
    double? housingFundBaseMax,
  }) {
    return CityConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      pensionBase: pensionBase ?? this.pensionBase,
      pensionBaseMax: pensionBaseMax ?? this.pensionBaseMax,
      pensionRate: pensionRate ?? this.pensionRate,
      medicalRate: medicalRate ?? this.medicalRate,
      unemploymentRate: unemploymentRate ?? this.unemploymentRate,
      housingFundRate: housingFundRate ?? this.housingFundRate,
      housingFundBase: housingFundBase ?? this.housingFundBase,
      housingFundBaseMax: housingFundBaseMax ?? this.housingFundBaseMax,
    );
  }
}
