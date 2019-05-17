part of '../dart_testable_forms.dart';

class FormBuilder {
  group<T>(T initialValue, Deserializer<T> deserializer, Map<String, AbstractControl> controls, [ValidatorSet<T> validators]) {
    return FormGroup<T>(controls, deserializer, initialValue: initialValue, validators: validators);
  }
  control<T>([ValidatorSet<T> validators]) {
    return FormControl<T>(validators: validators);
  }
}