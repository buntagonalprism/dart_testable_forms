// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_up.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignUp _$SignUpFromJson(Map<String, dynamic> json) {
  return SignUp()
    ..email = json['email'] as String
    ..password = json['password'] as String
    ..confirmation = json['confirmation'] as String
    ..likeBananas = json['likeBananas'] as bool
    ..state = json['state'] as int;
}

Map<String, dynamic> _$SignUpToJson(SignUp instance) => <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'confirmation': instance.confirmation,
      'likeBananas': instance.likeBananas,
      'state': instance.state
    };
