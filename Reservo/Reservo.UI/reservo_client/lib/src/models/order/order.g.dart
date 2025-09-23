// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
      id: (json['id'] as num).toInt(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      stripeClientSecret: json['stripeClientSecret'] as String,
    );

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'id': instance.id,
      'totalAmount': instance.totalAmount,
      'stripeClientSecret': instance.stripeClientSecret,
    };
