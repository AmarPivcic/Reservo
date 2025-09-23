import 'package:json_annotation/json_annotation.dart';

part 'user_order.g.dart';

@JsonSerializable()
class UserOrder{
  int orderId;
  String eventName;
  String? eventImage;
  String? state;

  UserOrder({
    required this.orderId,
    required this.eventName,
    this.eventImage,
    this.state,
  });

  factory UserOrder.fromJson(Map<String, dynamic> json) => _$UserOrderFromJson(json);

  Map<String, dynamic> toJson() => _$UserOrderToJson(this);
}