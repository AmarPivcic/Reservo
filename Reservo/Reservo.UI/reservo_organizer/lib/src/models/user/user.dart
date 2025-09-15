import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  String name;
  String surname;
  String? email;
  String? phone;
  String username;
  final DateTime dateCreated;
  String? gender;
  String? address;
  String? postalCode;
  String? image;
  String? role;
  String? city;
  int? cityId;
  bool? active;

  User({
    required this.id,
    required this.name,
    required this.surname,
    this.email,
    this.phone,
    required this.username,
    required this.dateCreated,
    this.gender,
    this.address,
    this.postalCode,
    this.image,
    this.role,
    this.city,
    this.active,
    this.cityId
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}