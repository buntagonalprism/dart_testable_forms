import 'package:json_annotation/json_annotation.dart';

part 'sign_up.g.dart';

@JsonSerializable()
class SignUp {

  SignUp();

  String email;
  String password;
  String confirmation;
  bool likeBananas;
  int bananaType;

  Map<String, dynamic> toJson() => _$SignUpToJson(this);
  static SignUp fromJson(Map<String, dynamic> json) => _$SignUpFromJson(json);

}

class SignUpFields {
  static const String EMAIL = 'email';
  static const String PASSWORD = 'password';
  static const String CONFIRMATION = 'confirmation';
  static const String LIKE_BANANAS = 'likeBananas';
  static const String BANANA_TYPE = 'bananaType';
}