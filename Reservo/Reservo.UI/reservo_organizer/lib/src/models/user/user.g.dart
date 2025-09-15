// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      surname: json['surname'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      username: json['username'] as String,
      dateCreated: DateTime.parse(json['dateCreated'] as String),
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      postalCode: json['postalCode'] as String?,
      image: json['image'] as String?,
      role: json['role'] as String?,
      city: json['city'] as String?,
      active: json['active'] as bool?,
      cityId: json['cityId'] as int?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'surname': instance.surname,
      'email': instance.email,
      'phone': instance.phone,
      'username': instance.username,
      'dateCreated': instance.dateCreated.toIso8601String(),
      'gender': instance.gender,
      'address': instance.address,
      'postalCode': instance.postalCode,
      'image': instance.image,
      'role': instance.role,
      'city': instance.city,
      'cityId': instance.cityId,
      'active': instance.active,
    };
