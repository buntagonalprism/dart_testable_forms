part of '../dart_testable_forms.dart';

class FormBuilder {

  ValidatorSet<T> v<T>(List<Validator<T>> validators) {
    return this.validators(validators);
  }
  ValidatorSet<T> validators<T>(List<Validator<T>> validators) {
    return ValidatorSet<T>(validators);
  }

  FormGroup<T> g<T>(T initialValue, Deserializer<T> deserializer, Map<String, AbstractControl> controls, [ValidatorSet<T> validators]) {
    return group<T>(initialValue, deserializer, controls, validators);
  }
  FormGroup<T> group<T>(T initialValue, Deserializer<T> deserializer, Map<String, AbstractControl> controls, [ValidatorSet<T> validators]) {
    return FormGroup<T>(controls, deserializer, initialValue: initialValue, validators: validators);
  }

  FormControl<T> c<T>([ValidatorSet<T> validators]) {
    return control<T>(validators);
  }
  FormControl<T> control<T>([ValidatorSet<T> validators]) {
    return FormControl<T>(validators: validators);
  }

  FormArray<T> a<T>(List<T> initialValue, List<AbstractControl<T>> controls, [ValidatorSet<List<T>> validators]) {
    return array<T>(initialValue, controls, validators);
  }
  FormArray<T> array<T>(List<T> initialValue, List<AbstractControl<T>> controls, [ValidatorSet<List<T>> validators]) {
    return FormArray<T>(controls, initialValue: initialValue, validators: validators);
  }
}