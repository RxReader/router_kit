// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
    code: json['code'] as int,
    msg: json['msg'] as String,
  )..name = json['nickname'] as String;
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'nickname': instance.name,
    };
