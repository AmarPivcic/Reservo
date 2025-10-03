import 'package:json_annotation/json_annotation.dart';

part 'user_insert.g.dart';

@JsonSerializable()
class UserInsert {
  final String name;
  final String surname;
  final String email;
  final String phone;
  final String username;
  final String gender;
  final String password;
  final String passwordConfirm;
  final String city;
  final String? address;
  final String? postalCode;
  final String? image;

  UserInsert({
    required this.name,
    required this.surname,
    required this.email,
    required this.phone,
    required this.username,
    required this.gender,
    required this.password,
    required this.passwordConfirm,
    required this.city,
    this.address,
    this.postalCode,
    this.image,
  });
    factory UserInsert.fromJson(Map<String, dynamic> json) => _$UserInsertFromJson(json);
    Map<String, dynamic> toJson() => _$UserInsertToJson(this);
}