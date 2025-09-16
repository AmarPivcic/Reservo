// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_update_password.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserUpdatePassword _$UserUpdatePasswordFromJson(Map<String, dynamic> json) =>
    UserUpdatePassword(
      oldPassword: json['oldPassword'] as String,
      newPassword: json['newPassword'] as String,
      confirmNewPassword: json['confirmNewPassword'] as String,
    );

Map<String, dynamic> _$UserUpdatePasswordToJson(UserUpdatePassword instance) =>
    <String, dynamic>{
      'oldPassword': instance.oldPassword,
      'newPassword': instance.newPassword,
      'confirmNewPassword': instance.confirmNewPassword,
    };
