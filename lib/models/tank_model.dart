class TankModel {
  final double level;
  final bool pump;
  final double flow;
  final double dailyUsage;
  final double monthlyUsage;
  final bool overflowAlert;
  final bool lowLevelAlert;

  const TankModel({
    required this.level,
    required this.pump,
    required this.flow,
    required this.dailyUsage,
    required this.monthlyUsage,
    required this.overflowAlert,
    required this.lowLevelAlert,
  });

  String get status {
    if (level >= 80) {
      return 'Tank Full';
    }
    if (level <= 30) {
      return 'Low Level';
    }
    if (pump) {
      return 'Filling';
    }
    return 'Normal';
  }

  factory TankModel.fromMap(Map<dynamic, dynamic> map) {
    double toDouble(dynamic value, {double fallback = 0}) {
      if (value is num) {
        return value.toDouble();
      }
      if (value is String) {
        return double.tryParse(value) ?? fallback;
      }
      return fallback;
    }

    bool toBool(dynamic value, {bool fallback = false}) {
      if (value is bool) {
        return value;
      }
      if (value is num) {
        return value != 0;
      }
      if (value is String) {
        return value.toLowerCase() == 'true';
      }
      return fallback;
    }

    final level = toDouble(map['level']);
    final pump = toBool(map['pump']);

    return TankModel(
      level: level,
      pump: pump,
      flow: toDouble(map['flow']),
      dailyUsage: toDouble(map['dailyUsage']),
      monthlyUsage: toDouble(map['monthlyUsage']),
      overflowAlert: toBool(map['overflowAlert'], fallback: level >= 95),
      lowLevelAlert: toBool(map['lowLevelAlert'], fallback: level <= 20),
    );
  }

  TankModel copyWith({
    double? level,
    bool? pump,
    double? flow,
    double? dailyUsage,
    double? monthlyUsage,
    bool? overflowAlert,
    bool? lowLevelAlert,
  }) {
    return TankModel(
      level: level ?? this.level,
      pump: pump ?? this.pump,
      flow: flow ?? this.flow,
      dailyUsage: dailyUsage ?? this.dailyUsage,
      monthlyUsage: monthlyUsage ?? this.monthlyUsage,
      overflowAlert: overflowAlert ?? this.overflowAlert,
      lowLevelAlert: lowLevelAlert ?? this.lowLevelAlert,
    );
  }
}

