import 'package:json_annotation/json_annotation.dart';

part 'order.g.dart';

@JsonSerializable()
class Order{
  int id;
  double totalAmount;
  String stripeClientSecret;

  Order({
    required this.id,
    required this.totalAmount,
    required this.stripeClientSecret,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  Map<String, dynamic> toJson() => _$OrderToJson(this);
}