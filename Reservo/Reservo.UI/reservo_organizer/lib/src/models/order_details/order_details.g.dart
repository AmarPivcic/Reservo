// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderDetails _$OrderDetailsFromJson(Map<String, dynamic> json) => OrderDetails(
      orderId: (json['orderId'] as num).toInt(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      state: json['state'] as String,
      orderedBy: json['orderedBy'] as String,
      tickets: (json['tickets'] as List<dynamic>)
          .map((e) => OrderTicket.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OrderDetailsToJson(OrderDetails instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'totalAmount': instance.totalAmount,
      'state': instance.state,
      'orderedBy': instance.orderedBy,
      'tickets': instance.tickets.map((e) => e.toJson()).toList(),
    };
