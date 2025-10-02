import 'package:json_annotation/json_annotation.dart';

part 'report_models.g.dart';

@JsonSerializable()
class ProfitByCategory {
  final String category;
  final double profit;

  ProfitByCategory({
    required this.category, 
    required this.profit
  });

  factory ProfitByCategory.fromJson(Map<String, dynamic> json) => _$ProfitByCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$ProfitByCategoryToJson(this);
}

@JsonSerializable()
class ProfitByMonth{
  final int month;
  final double profit;

  ProfitByMonth({
    required this.month,
    required this.profit
  });

  factory ProfitByMonth.fromJson(Map<String, dynamic> json) => _$ProfitByMonthFromJson(json);

  Map<String, dynamic> toJson() => _$ProfitByMonthToJson(this);
}

@JsonSerializable()
class ProfitByDay{
  final int day;
  final double profit;

  ProfitByDay({
    required this.day,
    required this.profit
  });

  factory ProfitByDay.fromJson(Map<String, dynamic> json) => _$ProfitByDayFromJson(json);

  Map<String, dynamic> toJson() => _$ProfitByDayToJson(this);
}