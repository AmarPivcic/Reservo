// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserUpdate _$UserUpdateFromJson(Map<String, dynamic> json) =>
    UserUpdate(
      username: json['username'] as String?,
      name: json['name'] as String?,
      surname: json['surname'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      postalCode: json['postalCode'] as String?,
      image: json['image'] as String?,
      cityId: (json['cityId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UserUpdateToJson(UserUpdate instance) =>
    <String, dynamic>{
      'username': instance.username,
      'name': instance.name,
      'surname': instance.surname,
      'email': instance.email,
      'phone': instance.phone,
      'gender': instance.gender,
      'address': instance.address,
      'postalCode': instance.postalCode,
      'image': instance.image,
      'cityId': instance.cityId,
    };
