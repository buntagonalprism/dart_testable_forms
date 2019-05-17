import 'package:dart_testable_forms/dart_testable_forms.dart';
import 'package:test/test.dart';

void main() {
  final vb = ValidatorSet.builder;
  MockValidator withErrorValidator;
  MockValidator noErrorValidator;
  Map<String, dynamic> error;

  setUp(() {
    error = {'ohNo':'an error occured'};
    withErrorValidator = MockValidator(error);
    noErrorValidator = MockValidator(null);
  });

  group('Initialisation', () {
    test('Value and validators stored in control', () {
      final control = FormControl(initialValue: 'surprise', validators: vb([noErrorValidator]));
      expect(control.value, 'surprise');
      expect(control.validators, vb([noErrorValidator]));
    });
    test('Validators run against initial value', () {
      final control = FormControl(initialValue: 'abc', validators: vb([withErrorValidator]));
      expect(withErrorValidator.calledWithValues, ['abc']);
      expect(control.errors, error);
    });
    test('Error output defaults to empty map', () {
      final control = FormControl(initialValue: 'abc');
      expect(control.errors, {});
    });
  });

  group('Setting value', () {
    test('Updates control value', () {
      final control = FormControl<String>();
      expect(control.value, null);
      control.setValue('updated');
      expect(control.value, 'updated');
    });

    test('runs validation', () {
      final control = FormControl<String>(validators: vb([noErrorValidator]));
      control.setValue('foobar');
      expect(noErrorValidator.calledWithValues, [null, 'foobar']);
    });

    test('updates value listeners', () {
      final control = FormControl<String>(initialValue: 'initialNotEmitted');
      expect(control.valueUpdated, emitsInOrder([
        '123'
      ]));
      control.setValue('123');
    });

    test('updates view with value and errors', () async {
      final control = FormControl<String>(validators: vb([withErrorValidator]));
      bool didChange = false;
      control.modelUpdated.listen((_) {
        expect(control.value, 'abc');
        expect(control.errors, error);
        didChange = true;
      });
      control.setValue('abc');
      await Future.delayed(Duration());
      expect(didChange, true);
    });
  });


  group('updating validators', () {
    test('Updates control validators', () {
      final control = FormControl<String>(initialValue: '678', validators: vb([noErrorValidator]));
      control.setValidators(vb([withErrorValidator]));
      expect(control.validators, vb([withErrorValidator]));
    });

    test('runs validation and sets error', () {
      final control = FormControl<String>(initialValue: '678', validators: vb([noErrorValidator]));
      expect(noErrorValidator.calledWithValues, ['678']);
      expect(control.errors, {});
      control.setValidators(vb([withErrorValidator]));
      expect(withErrorValidator.calledWithValues, ['678']);
      expect(control.errors, error);
    });

    test('updates view with errors', () async {
      final control = FormControl<String>(validators: vb([noErrorValidator]));
      bool didChange = false;
      control.modelUpdated.listen((_) {
        expect(control.errors, error);
        didChange = true;
      });
      control.setValidators(vb([withErrorValidator]));
      await Future.delayed(Duration());
      expect(didChange, true);
    });
  });

  test('changing submit requested updates view ', () async {
    final control = FormControl<String>();
    expect(control.submitRequested, false);

    bool didChange = false;
    control.modelUpdated.listen((_) {
      expect(control.submitRequested, true);
      didChange = true;
    });
    control.setSubmitRequested(true);
    await Future.delayed(Duration());
    expect(didChange, true);
  });

  test('changing enabled status updates view', () async {
    final control = FormControl<String>(enabled: true);
    expect(control.enabled, true);

    bool didChange = false;
    control.modelUpdated.listen((_) {
      expect(control.enabled, false);
      didChange = true;
    });
    control.setEnabled(false);
    await Future.delayed(Duration());
    expect(didChange, true);
  });

  test('changing touched status updates view', () async {
    final control = FormControl<String>();
    expect(control.touched, false);

    bool didChange = false;
    control.modelUpdated.listen((_) {
      expect(control.touched, true);
      didChange = true;
    });
    control.setTouched(true);
    await Future.delayed(Duration());
    expect(didChange, true);
  });

  group('Newline error combiner output', () {

    FormControl<String> control;
    setUp(() {
      control = FormControl<String>();
      control.setValidators(vb([MockValidator({'er1': 'hello', 'er2': 'foobar'})]));
    });

    test('null when control not enabled', () {
      setMockStates(control, enabled: false, submitted: false, touched: false);
      expect(control.combineErrors(NewlineErrorCombiner()), null);

      setMockStates(control, enabled: false, submitted: false, touched: true);
      expect(control.combineErrors(NewlineErrorCombiner()), null);

      setMockStates(control, enabled: false, submitted: true, touched: false);
      expect(control.combineErrors(NewlineErrorCombiner()), null);

      setMockStates(control, enabled: false, submitted: true, touched: true);
      expect(control.combineErrors(NewlineErrorCombiner()), null);
    });

    test('null when control enabled but not touched or submitted', () {
      setMockStates(control, enabled: true, submitted: false, touched: false);
      expect(control.combineErrors(NewlineErrorCombiner()), null);
    });

    test('Combine errors with separator when enabled and either touched or submitted', () {
      setMockStates(control, enabled: true, submitted: false, touched: true);
      expect(control.combineErrors(NewlineErrorCombiner()), 'hello\nfoobar');

      setMockStates(control, enabled: true, submitted: true, touched: false);
      expect(control.combineErrors(NewlineErrorCombiner()), 'hello\nfoobar');

      setMockStates(control, enabled: true, submitted: true, touched: true);
      expect(control.combineErrors(NewlineErrorCombiner()), 'hello\nfoobar');
    });
  });

}

class MockValidator extends Validator<String> {
  final Map<String, dynamic> returnErrors;
  MockValidator([this.returnErrors]): super([returnErrors]);

  final List<String> calledWithValues = List<String>();

  @override
  Map<String, dynamic> validate(AbstractControl<String> control) {
    calledWithValues.add(control.value);
    return returnErrors;
  }
}

void setMockStates(FormControl<String> control, {bool enabled, bool touched, bool submitted}) {
  control.setEnabled(enabled);
  control.setTouched(touched);
  control.setSubmitRequested(submitted);
}