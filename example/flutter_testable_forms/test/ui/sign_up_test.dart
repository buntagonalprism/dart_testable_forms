import 'package:dart_testable_forms/dart_testable_forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testable_forms/blocs/sign_up_bloc.dart';
import 'package:flutter_testable_forms/data/sign_up.dart';
import 'package:flutter_testable_forms/flutter_forms/form_widgets.dart';
import 'package:flutter_testable_forms/ui/sign_up.dart';
import 'package:mockito/mockito.dart';


class BlocMock extends Mock implements SignUpBloc {}
class MockGroup extends Mock implements FormGroup<SignUp> {}
class MockControl extends Mock implements FormControl<String> {}

void main() {

  SignUpBloc bloc;

  setUp(() {
    bloc = SignUpBloc();
  });

  testWidgets('Email field bound to control', (WidgetTester tester) async {
    await pumpWithMaterial(tester, SignUpScreen(title: 'hello', bloc: bloc));
    Finder fieldFinder = fieldWithLabel("Email Address");
    ControlledTextField field = tester.widget(fieldFinder);
    expect(field.control, bloc.form.controls['email']);
  });

  testWidgets('Password field bound to control', (WidgetTester tester) async {
    await pumpWithMaterial(tester, SignUpScreen(title: 'hello', bloc: bloc));
    Finder fieldFinder = fieldWithLabel("Password");
    ControlledTextField field = tester.widget(fieldFinder);
    expect(field.control, bloc.form.controls['password']);
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
