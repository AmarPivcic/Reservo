import 'package:json_annotation/json_annotation.dart';

part 'user_update.g.dart';

@JsonSerializable()
class UserUpdate {
  final String? username;
  final String? name;
  final String? surname;
  final String? email;
  final String? phone;
  final String? gender;
  final String? address;
  final String? postalCode;
  final String? image;   // base64 string
  final int? cityId;

  UserUpdate({
    this.username,
    this.name,
    this.surname,
    this.email,
    this.phone,
    this.gender,
    this.address,
    this.postalCode,
    this.image,
    this.cityId,
  });

  factory UserUpdate.fromJson(Map<String, dynamic> json) => _$UserUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$UserUpdateToJson(this);
}