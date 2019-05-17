import 'package:dart_testable_forms/dart_testable_forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testable_forms/blocs/sign_up_bloc.dart';
import 'package:flutter_testable_forms/data/sign_up.dart';
import 'package:flutter_testable_forms/flutter_forms/form_widgets.dart';
import 'package:flutter_testable_forms/ui/sign_up.dart';
import 'package:mockito/mockito.dart';


class MockBloc extends Mock implements SignUpBloc {}
class MockGroup extends Mock implements FormGroup<SignUp> {}
class MockControl extends Mock implements FormControl<String> {}

void main() {

  MockBloc bloc;
  MockBuilder builder = MockBuilder();

  setUp(() {
    bloc = MockBloc();
    when(bloc.form).thenReturn(buildControls());
  });

  testWidgets('Email field bound to control', (WidgetTester tester) async {
    await pumpWithMaterial(tester, SignUpScreen(title: 'hello', bloc: bloc, builder: builder,));
    Finder fieldFinder = fieldWithLabel("Email Address");
    ControlledTextField field = tester.widget(fieldFinder);
    expect(field.control, bloc.form.controls[SignUpFields.EMAIL]);
  });

  testWidgets('Password field bound to control', (WidgetTester tester) async {
    await pumpWithMaterial(tester, SignUpScreen(title: 'hello', bloc: bloc, builder: builder,));
    Finder fieldFinder = fieldWithLabel("Password");
    ControlledTextField field = tester.widget(fieldFinder);
    expect(field.control, bloc.form.controls[SignUpFields.PASSWORD]);
  });
}

Future pumpWithMaterial(WidgetTester tester, Widget child) {
  return tester.pumpWidget(MaterialApp(
    home: Material(
      child: child,
    ),
  ));
}

Finder fieldWithLabel(String label) {
  final labelFinder = find.text(label);
  final fieldFinder = find.ancestor(of: labelFinder, matching: find.byType(ControlledTextField));
  return fieldFinder;
}

FormGroup<SignUp> buildControls() {
  final fb = FormBuilder();
  return fb.group(null, SignUp.fromJson, {
    SignUpFields.EMAIL: fb.control<String>(),
    SignUpFields.PASSWORD: fb.control<String>(),
    SignUpFields.CONFIRMATION: fb.control<String>(),
    SignUpFields.LIKE_BANANAS: fb.control<bool>(),
    SignUpFields.BANANA_TYPE: fb.control<int>()
  });
}

class MockBuilder implements FormWidgetBuilder {
  @override
  Widget build({Widget child}) {
    return Container();
  }

}