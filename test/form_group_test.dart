import 'dart:convert';

import 'package:dart_testable_forms/dart_testable_forms.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class ControlMock extends Mock implements FormControl {}



void main() {

  final vsb = ValidatorSet.builder;

  FormControl<String> firstField;
  FormControl<String> secondField;
  FormControl<String> thirdField;
  FormControl<NestedData> nestedField;
  Map<String, AbstractControl> controls;

  setUp(() {
    firstField = FormControl<String>();
    secondField = FormControl<String>();
    thirdField = FormControl<String>();
    nestedField = FormControl<NestedData>();
    controls = {
      FIRST_KEY: firstField,
      SECOND_KEY: secondField,
      THIRD_KEY: thirdField,
      NESTED_KEY: nestedField,
    };
  });

  test('Get controller by key', () {
    final group = FormGroup<DummyData>(controls, DummyData.fromJson);
    expect(group.controls[FIRST_KEY], firstField);
    expect(group.controls[SECOND_KEY], secondField);
    expect(group.controls[THIRD_KEY], thirdField);
  });

  group('Initialisation passes down', () {

    test('value when supplied', () {
      final data = DummyData.fromJson({FIRST_KEY: 'abc', SECOND_KEY: 'qwe', THIRD_KEY: '123'});
      FormGroup<DummyData>(controls, DummyData.fromJson, initialValue: data);
      expect(firstField.value, 'abc');
      expect(secondField.value, 'qwe');
      expect(thirdField.value, '123');
    });

    test('no value when not supplied', () {
      FormGroup<DummyData>(controls, DummyData.fromJson);
      expect(firstField.value, isNull);
      expect(secondField.value, isNull);
      expect(thirdField.value, isNull);
    });

    test('enabled status when supplied', () {
      FormGroup<DummyData>(controls, DummyData.fromJson, enabled: false);
      expect(firstField.enabled, isFalse);
      expect(secondField.enabled, isFalse);
      expect(thirdField.enabled, isFalse);
    });

    test('no enabled status when not supplied', () {
      FormGroup<DummyData>(controls, DummyData.fromJson);
      expect(firstField.enabled, isTrue);
      expect(secondField.enabled, isTrue);
      expect(thirdField.enabled, isTrue);
    });
  });



  group('Get value:', () {
    test('Collects data from all children', () {
      final group = FormGroup<DummyData>(controls, DummyData.fromJson);
      firstField.setValue('a');
      secondField.setValue('b');
      thirdField.setValue('c');
      nestedField.setValue(NestedData()..innerFirst = '1'..innerSecond = '2');
      DummyData data = group.value;
      expect(data.first, 'a'); 
      expect(data.second, 'b');
      expect(data.third, 'c');
      expect(data.nested.innerFirst, '1');
      expect(data.nested.innerSecond, '2');
    });

    test('Disabled children have null value', () {
      final group = FormGroup<DummyData>(controls, DummyData.fromJson);
      firstField.setValue('a');
      secondField.setEnabled(false);
      secondField.setValue('b');
      thirdField.setValue('c');
      nestedField.setEnabled(false);
      nestedField.setValue(NestedData()..innerFirst = '1'..innerSecond = '2');
      DummyData data = group.value;
      expect(data.first, 'a'); 
      expect(data.second, isNull);
      expect(data.third, 'c');
      expect(data.nested, isNull);
    });

    test('Values for fields without controls are preserved', () {
      final group = FormGroup<DummyData>({
        FIRST_KEY: firstField,
      }, DummyData.fromJson);
      group.setValue(DummyData()..first = 'a'..second='no control');
      DummyData data = group.value;
      expect(data.first, 'a');
      expect(data.second, 'no control');
    });

  });

  group('Updates are passed down to all children', () {

    test('Value', () {
      final group = FormGroup<DummyData>(controls, DummyData.fromJson);
      final data = DummyData.fromJson({FIRST_KEY: 'tyu', SECOND_KEY: 'ikm', THIRD_KEY: 'dfg'});
      group.setValue(data);
      expect(firstField.value, 'tyu');
      expect(secondField.value, 'ikm');
      expect(thirdField.value, 'dfg');
    });

    test('submitRequest status', () {
      final group = FormGroup<DummyData>(controls, DummyData.fromJson);
      expect(firstField.submitRequested, isFalse);
      group.setSubmitRequested(true);
      expect(firstField.submitRequested, isTrue);
      expect(secondField.submitRequested, isTrue);
      expect(thirdField.submitRequested, isTrue);
    });

    test('enabled status', () {
      final group = FormGroup<DummyData>(controls, DummyData.fromJson);
      expect(firstField.enabled, isTrue);
      group.setEnabled(false);
      expect(firstField.enabled, isFalse);
      expect(secondField.enabled, isFalse);
      expect(thirdField.enabled, isFalse);
    });
  });

  group('Validation', () {
    test('Default empty validator set', () {
      final emptyValidatorSet = ValidatorSet<DummyData>([]);
      final group = FormGroup<DummyData>(controls, DummyData.fromJson);
      expect(group.validators, emptyValidatorSet);
    });

    test('Initial validators stored', () {
      final validators = vsb([MockValidator<DummyData>({'oops':'an error'})]);
      final group = FormGroup<DummyData>(controls, DummyData.fromJson, validators: validators);
      expect(group.validators, validators);
    });

    test('Updated validators are stored', () {
      final group = FormGroup<DummyData>(controls, DummyData.fromJson);
      final validators = vsb([MockValidator<DummyData>({'oops':'an error'})]);
      group.setValidators(validators);
      expect(group.validators, validators);
    });

    test('Getting errors runs group validator', () {
      final validator = MockValidator<DummyData>({'oops':'an error'});
      final group = FormGroup<DummyData>(controls, DummyData.fromJson, validators: vsb([validator]));
      expect(validator.calledWithValues, isEmpty);
      firstField.setValue('123');
      secondField.setValue('456');
      thirdField.setValue('789');
      final errors = group.errors;
      expect(errors, {'oops':'an error'});
      expect(validator.calledWithValues[0].first, '123');
      expect(validator.calledWithValues[0].second, '456');
      expect(validator.calledWithValues[0].third, '789');
    });

    test('Getting errors combines all enabled child errors keyed by their control Id', () {
      final validator = MockValidator<DummyData>({'oops':'This is a group error'});
      final group = FormGroup<DummyData>(controls, DummyData.fromJson, validators: vsb([validator]));
      secondField.setEnabled(false); // Should not be present in group error - disabled
      secondField.setValidators(vsb([MockValidator({'secondErr':'yes'})]));
      thirdField.setValidators(vsb([MockValidator({'thirdErrOne': 'also', 'thirdErrTwo':'another'})]));
      nestedField.setValidators(vsb([MockValidator({'nested':'so error, wow'})]));
      final errors = group.errors;
      expect(errors, {
        'oops': 'This is a group error',
        'controlErrors': {
          THIRD_KEY: {
            'thirdErrOne': 'also',
            'thirdErrTwo': 'another'
          },
          NESTED_KEY: {
            'nested': 'so error, wow',
          },
        },
      });
    });
  });
}

const FIRST_KEY = 'first';
const SECOND_KEY = 'second';
const THIRD_KEY = 'third';
const NESTED_KEY = 'nested';

class DummyData {
  String first;
  String second;
  String third;
  NestedData nested;
  Map<String, dynamic> toJson() {
    return {
      'first': first,
      'second': second,
      'third': third,
      'nested': nested, 
    };
  }
  static DummyData fromJson(Map<String, dynamic> json) {
    return DummyData()
        ..first = json['first']
        ..second = json['second']
        ..third = json['third']
        ..nested = json['nested'] != null ? NestedData.fromJson(json['nested']) : null;
  }
}

class NestedData {
  String innerFirst;
  String innerSecond;
  Map<String, dynamic> toJson() {
    return {
      'innerFirst': innerFirst,
      'innerSecond': innerSecond,
    };
  }
  static NestedData fromJson(Map<String, dynamic> json) {
    return NestedData()
        ..innerFirst = json['innerFirst']
        ..innerSecond = json['innerSecond'];
  }
}

class MockValidator<T> extends Validator<T> {
  final Map<String, dynamic> returnErrors;
  MockValidator([this.returnErrors]): super([returnErrors]);

  final List<T> calledWithValues = List<T>();

  @override
  Map<String, dynamic> validate(AbstractControl<T> control) {
    calledWithValues.add(control.value);
    return returnErrors;
  }
}
