// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserOrder _$UserOrderFromJson(Map<String, dynamic> json) => UserOrder(
      orderId: (json['orderId'] as num).toInt(),
      eventName: json['eventName'] as String,
      eventImage: json['eventImage'] as String?,
      state: json['state'] as String?,
    );

Map<String, dynamic> _$UserOrderToJson(UserOrder instance) => <String, dynamic>{
      'orderId': instance.orderId,
      'eventName': instance.eventName,
      'eventImage': instance.eventImage,
      'state': instance.state,
    };
