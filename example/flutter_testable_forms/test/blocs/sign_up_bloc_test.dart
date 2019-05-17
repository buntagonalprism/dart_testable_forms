import 'package:dart_testable_forms/dart_testable_forms.dart';
import 'package:flutter_testable_forms/blocs/sign_up_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testable_forms/data/sign_up.dart';

void main() {

  final vsb = ValidatorSet.builder;

  SignUpBloc bloc;
  setUp(() {
    bloc = SignUpBloc();
  });

  /// This test will only fail if one of the field keys is not found in the SignUp class. It relies
  /// on the setValue method checking all the control keys against the serialized value.
  test('Bloc field keys match data model', () {
    bloc.form.setValue(SignUp());
  });

  test('Email address validators', () {
    expect(bloc.form.controls[SignUpFields.EMAIL].validators, vsb([
      EmailAddressValidator('Invalid email address'),
      RequiredValidator('put an email in here'),
    ]));
  });

  test('Password validators', () {
    expect(bloc.form.controls[SignUpFields.PASSWORD].validators, vsb([
      MinLengthValidator(6, 'Password must be at least 6 characters'),
      RequiredValidator('Yeah you gotta have a password'),
    ]));
  });

  test('Initial confirm validator', () {
    expect(bloc.form.controls[SignUpFields.CONFIRMATION].validators, vsb([
      RequiredValidator('This is where the confirmation goes'),
    ]));
  });

  test('Updating password changes confirm validators', () async {
    (bloc.form.controls[SignUpFields.PASSWORD] as FormControl).setValue('abc123');
    await Future.delayed(Duration());
    expect(bloc.form.controls[SignUpFields.CONFIRMATION].validators, vsb([
      RegexValidator(RegExp('abc123'), 'Does not match'),
      RequiredValidator('This is where the confirmation goes'),
    ]));
  });

}

