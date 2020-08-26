import 'package:dart_testable_forms/dart_testable_forms.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class ControlMock extends Mock implements FormControl<String> {}

void main() {
  final vsb = ValidatorSet.builder;

  ControlMock firstMock;
  ControlMock secondMock;
  ControlMock thirdMock;

  FormControl<String> builder(String value, int index) {
    return FormControl<String>(initialValue: value);
  }

  FormControl<String> mockBuilder(String value, int index) {
    final ControlMock c = [firstMock, secondMock, thirdMock][index];
    c.setValue(value);
    when(c.value).thenReturn(value);
    return c;
  }

  setUp(() {
    firstMock = ControlMock();
    when(firstMock.enabled).thenReturn(true);
    when(firstMock.errors).thenReturn({});
    secondMock = ControlMock();
    when(secondMock.enabled).thenReturn(true);
    when(secondMock.errors).thenReturn({});
    thirdMock = ControlMock();
    when(thirdMock.enabled).thenReturn(true);
    when(thirdMock.errors).thenReturn({});
  });

  group('Initialisations', () {
    test('Builds controls when value supplied', () {
      final array = FormArray<String>(builder, initialValue: ['a', 'b', 'qwerty']);
      expect(array.controls[0].value, 'a');
      expect(array.controls[1].value, 'b');
      expect(array.controls[2].value, 'qwerty');
    });

    test('Does nothing when value when not supplied', () {
      final array = FormArray<String>(builder);
      expect(array.controls, isEmpty);
    });
  });

  group('Get value', () {
    test('Value combines child values', () {
      final array = FormArray<String>(builder, initialValue: ['a', 'b', 'c']);
      expect(array.value, ['a', 'b', 'c']);
      array.controls[0].setValue('1');
      array.controls[1].setValue('2');
      array.controls[2].setValue('3');
      expect(array.value, ['1', '2', '3']);
    });

    test('Disabled children are not added to value', () {
      final array = FormArray<String>(builder, initialValue: ['1', '2', '3']);
      array.controls[1].setEnabled(false);
      expect(array.value, ['1', '3']);
    });
  });

  group('Updates are passed', () {
    test('Value creates new controls', () {
      final array = FormArray<String>(builder);
      expect(array.controls, isEmpty);
      final data = ['tyu', 'ikm', 'dfg'];
      array.setValue(data);
      expect(array.controls.length, 3);
      expect(array.controls[0].value, 'tyu');
      expect(array.controls[1].value, 'ikm');
      expect(array.controls[2].value, 'dfg');
    });

    test('submitRequest status', () {
      final array = FormArray<String>(builder, initialValue: [null, null]);
      expect(array.controls[0].submitRequested, isFalse);
      array.setSubmitRequested(true);
      expect(array.controls[0].submitRequested, isTrue);
      expect(array.controls[1].submitRequested, isTrue);
    });

    test('enabled status', () {
      final array = FormArray<String>(builder, initialValue: [null, null]);
      expect(array.controls[0].enabled, isTrue);
      array.setEnabled(false);
      expect(array.controls[0].enabled, isFalse);
      expect(array.controls[1].enabled, isFalse);
    });
  });

  group('Validation', () {
    test('Default empty validator set', () {
      final emptyValidatorSet = ValidatorSet<List<String>>([]);
      final array = FormArray<String>(mockBuilder);
      expect(array.validators, emptyValidatorSet);
    });

    test('Initial validators stored', () {
      final validators = vsb([
        MockValidator({'oops': 'an error'})
      ]);
      final array = FormArray<String>(mockBuilder, validators: validators);
      expect(array.validators, validators);
    });

    test('Updated validators are stored', () {
      final array = FormArray<String>(mockBuilder);
      final validators = vsb([
        MockValidator({'oops': 'an error'})
      ]);
      array.setValidators(validators);
      expect(array.validators, validators);
    });

    test('Getting errors runs group validator', () {
      final validator = MockValidator({'oops': 'an error'});
      final array = FormArray<String>(builder,
          initialValue: ['123', '456', '789'], validators: vsb([validator]));
      expect(validator.calledWithValues, isEmpty);
      final errors = array.errors;
      expect(errors, {'oops': 'an error'});
      expect(validator.calledWithValues[0][0], '123');
      expect(validator.calledWithValues[0][1], '456');
      expect(validator.calledWithValues[0][2], '789');
    });

    test('Getting errors combines all enabled child errors keyed by their index', () {
      final validator = MockValidator({'oops': 'This is a group error'});
      final array = FormArray<String>(mockBuilder,
          initialValue: [null, null, null], validators: vsb([validator]));
      expect(validator.calledWithValues, isEmpty);
      when(firstMock.errors).thenReturn({}); // Should not be present in group error - no errors
      when(secondMock.enabled).thenReturn(false); // Should not be present in group error - disabled
      when(secondMock.errors).thenReturn({'secondErr': 'yes'});
      when(thirdMock.errors).thenReturn({'thirdErrOne': 'also', 'thirdErrTwo': 'another'});
      final errors = array.errors;
      expect(errors, {
        'oops': 'This is a group error',
        'controlErrors': {
          '2': {'thirdErrOne': 'also', 'thirdErrTwo': 'another'}
        }
      });
    });
  });

  group('Modifying controls', () {
    test('Setting a new value notifies observers', () async {
      final array = FormArray<String>(builder, initialValue: [null, null, null]);
      bool didChange = false;
      array.modelUpdated.listen((_) {
        expect(array.controls.length, 2);
        didChange = true;
      });
      expect(
          array.valueUpdated,
          emitsInOrder([
            ['q', 'x']
          ]));
      array.setValue(['q', 'x']);
      await Future.delayed(Duration());
      expect(didChange, true);
    });

    test('No action from setting a null list value', () async {
      final array = FormArray<String>(builder, initialValue: ['1', '2', '3']);
      bool didChange = false;
      array.modelUpdated.listen((_) {
        didChange = true;
      });
      array.setValue(null);
      await Future.delayed(Duration());
      expect(didChange, isFalse);
      expect(array.controls.length, 3);
    });

    test('Appending a value notifies observers', () async {
      final array = FormArray<String>(builder, initialValue: [null, null, null]);
      bool didChange = false;
      array.modelUpdated.listen((_) {
        expect(array.controls.length, 4);
        didChange = true;
      });
      expect(
          array.valueUpdated,
          emitsInOrder([
            [null, null, null, 'a']
          ]));
      array.append('a');
      await Future.delayed(Duration());
      expect(didChange, true);
    });

    test('Inserting a value notifies observers', () async {
      final array = FormArray<String>(builder, initialValue: [null, null, null]);
      bool didChange = false;
      array.modelUpdated.listen((_) {
        expect(array.controls.length, 4);
        didChange = true;
      });
      expect(
          array.valueUpdated,
          emitsInOrder([
            [null, 'b', null, null]
          ]));
      array.insertAt('b', 1);
      await Future.delayed(Duration());
      expect(didChange, true);
    });

    test('Removing a value notifies observers', () async {
      final array = FormArray<String>(builder, initialValue: ['1', '2', '3']);
      bool didChange = false;
      array.modelUpdated.listen((_) {
        expect(array.controls.length, 2);
        didChange = true;
      });
      expect(
          array.valueUpdated,
          emitsInOrder([
            ['1', '3']
          ]));
      array.removeAt(1);
      await Future.delayed(Duration());
      expect(didChange, true);
    });
  });

  test('Enabled status change emitted to listeners', () {
    final array = FormArray<String>(mockBuilder);
    expect(array.enabledUpdated, emitsInOrder([false, true]));
    array.setEnabled(false);
    array.setEnabled(true);
  });
}

class MockValidator extends Validator<List<String>> {
  final Map<String, dynamic> returnErrors;
  MockValidator([this.returnErrors]);

  final List<List<String>> calledWithValues = List<List<String>>();

  @override
  Map<String, dynamic> validate(AbstractControl<List<String>> control) {
    calledWithValues.add(control.value);
    return returnErrors;
  }

  @override
  List<Object> get props => [returnErrors];
}
