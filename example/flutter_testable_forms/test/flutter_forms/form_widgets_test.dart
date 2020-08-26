import 'dart:async';

import 'package:dart_testable_forms/dart_testable_forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testable_forms/flutter_forms/form_widgets.dart';
import 'package:mockito/mockito.dart';

class ControlMock extends Mock implements FormControl<String> {}

void main() {
  ControlMock mock;
  StreamController<void> streamController; // ignore: close_sinks
  setUp(() {
    mock = ControlMock();
    streamController = StreamController<void>.broadcast();
    when(mock.enabled).thenReturn(true);
    when(mock.touched).thenReturn(false);
    when(mock.submitRequested).thenReturn(false);
    when(mock.modelUpdated).thenAnswer((_) => streamController.stream);
    when(mock.errors).thenReturn({});
  });

  testWidgets('Registers a view notifier with control', (WidgetTester tester) async {
    await pumpWithMaterial(tester, ControlledTextField(mock));
    expect(streamController.hasListener, true);
  });

  group('Text field value', () {
    testWidgets('displays initial control value', (WidgetTester tester) async {
      final control = FormControl<String>(initialValue: 'hi');
      await pumpWithMaterial(tester, ControlledTextField(control));
      expect(find.text('hi'), findsOneWidget);
    });

    testWidgets('recieves updates from control', (WidgetTester tester) async {
      final control = FormControl<String>(initialValue: 'hi');
      await pumpWithMaterial(tester, ControlledTextField(control));
      control.setValue('gh');
      await tester.pump();
      expect(find.text('gh'), findsOneWidget);
    });
  });

  testWidgets('User input updates control', (WidgetTester tester) async {
    when(mock.enabled).thenReturn(true);
    await pumpWithMaterial(tester, ControlledTextField(mock));
    final textFinder = find.byType(TextField);
    verifyNever(mock.setValue(any));
    await tester.enterText(textFinder, 'cd');
    verify(mock.setValue('cd')).called(1);
  });

  group('Enabled status', () {
    group('Internal text field is:', () {
      testWidgets('enabled when control enabled', (WidgetTester tester) async {
        when(mock.enabled).thenReturn(true);
        await pumpWithMaterial(tester, ControlledTextField(mock));
        TextField field = tester.widget(find.byType(TextField));
        expect(field.enabled, true);
      });

      testWidgets('disabled when control disabled', (WidgetTester tester) async {
        when(mock.enabled).thenReturn(false);
        await pumpWithMaterial(tester, ControlledTextField(mock));
        TextField field = tester.widget(find.byType(TextField));
        expect(field.enabled, false);
      });
    });

    testWidgets('Changing enabled status updates field', (WidgetTester tester) async {
      final control = FormControl<String>(enabled: true);
      await pumpWithMaterial(tester, ControlledTextField(control));
      TextField field = tester.widget(find.byType(TextField));
      expect(field.enabled, true);
      control.setEnabled(false);
      await doublePump(tester);
      field = tester.widget(find.byType(TextField));
      expect(field.enabled, false);
    });
  });

  group('Error message calculation:', () {
    testWidgets('Error message uses newline combiner', (WidgetTester tester) async {
      await pumpWithMaterial(tester, ControlledTextField(mock));
      verify(mock.combineErrors(NewlineErrorCombiner())).called(1);
    });

    testWidgets('Draws combined error message', (WidgetTester tester) async {
      final msg = 'hello\nworld';
      await pumpWithMaterial(tester, ControlledTextField(mock));
      expect(find.text(msg), findsNothing);
      when(mock.combineErrors(any)).thenReturn(msg);
      streamController.add(null);
      await doublePump(tester);
      expect(find.text(msg), findsOneWidget);
    });
  });

  testWidgets('touched is set on field blur', (WidgetTester tester) async {
    await pumpWithMaterial(tester, Column(children: [ControlledTextField(mock), TextFormField()]));
    await tester.tap(find.byType(ControlledTextField));
    verifyNever(mock.setSubmitRequested(any));
    // Change focus to another text field
    await tester.tap(find.byType(TextFormField));
    verify(mock.setTouched(true)).called(1);
  });
}

Future pumpWithMaterial(WidgetTester tester, Widget child) {
  return tester.pumpWidget(MaterialApp(
    home: Material(
      child: child,
    ),
  ));
}

/// When building a UI off a stream, two pumps are almost always required for the UI to update.
/// Since values are not delivered to stream listeners synchronously, the first pump triggers the
/// dart microtask where the listeners are notified of the new stream data. UI components will then
/// request a redraw using setState(). The redraw itself then runs during the second pump.
Future doublePump(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}

void setMockStates(ControlMock mock, {bool enabled, bool touched, bool submitted}) {
  when(mock.enabled).thenReturn(enabled);
  when(mock.submitRequested).thenReturn(touched);
  when(mock.touched).thenReturn(submitted);
}

class MockValidator extends Validator<String> {
  final Map<String, dynamic> returnErrors;
  MockValidator([this.returnErrors]);

  final List<String> calledWithValues = List<String>();

  @override
  Map<String, dynamic> validate(AbstractControl<String> control) {
    calledWithValues.add(control.value);
    return returnErrors;
  }

  @override
  List<Object> get props => [returnErrors];
}
