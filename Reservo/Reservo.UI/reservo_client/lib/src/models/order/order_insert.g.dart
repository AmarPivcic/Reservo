// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_insert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderInsert _$OrderInsertFromJson(Map<String, dynamic> json) => OrderInsert(
      userId: (json['userId'] as num?)?.toInt(),
      orderDetails: (json['orderDetails'] as List<dynamic>)
          .map((e) => OrderDetailsInsert.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OrderInsertToJson(OrderInsert instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'orderDetails': instance.orderDetails,
    };
