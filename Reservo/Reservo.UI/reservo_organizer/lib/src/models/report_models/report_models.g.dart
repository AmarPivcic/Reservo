// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfitByCategory _$ProfitByCategoryFromJson(Map<String, dynamic> json) =>
    ProfitByCategory(
      category: json['category'] as String,
      profit: (json['profit'] as num).toDouble(),
    );

Map<String, dynamic> _$ProfitByCategoryToJson(ProfitByCategory instance) =>
    <String, dynamic>{
      'category': instance.category,
      'profit': instance.profit,
    };

ProfitByMonth _$ProfitByMonthFromJson(Map<String, dynamic> json) =>
    ProfitByMonth(
      month: (json['month'] as num).toInt(),
      profit: (json['profit'] as num).toDouble(),
    );

Map<String, dynamic> _$ProfitByMonthToJson(ProfitByMonth instance) =>
    <String, dynamic>{
      'month': instance.month,
      'profit': instance.profit,
    };

ProfitByDay _$ProfitByDayFromJson(Map<String, dynamic> json) => ProfitByDay(
      day: (json['day'] as num).toInt(),
      profit: (json['profit'] as num).toDouble(),
    );

Map<String, dynamic> _$ProfitByDayToJson(ProfitByDay instance) =>
    <String, dynamic>{
      'day': instance.day,
      'profit': instance.profit,
    };
