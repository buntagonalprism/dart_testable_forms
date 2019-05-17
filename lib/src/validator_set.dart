part of '../dart_testable_forms.dart';

/// Base class for performing validation on an control.
abstract class Validator<T> extends Equatable {
  Validator(List props) : super(props);
  Map<String, dynamic> validate(AbstractControl<T> control);

  @override
  String toString() => props.isNotEmpty ? (runtimeType.toString() + ":" + props.toString()) : super.toString();
}

/// Interface for validators that only care about the value of the control.
abstract class ValueValidator<T> extends Validator<T> {
  ValueValidator(List props) : super(props);

  Map<String, dynamic> validate(AbstractControl<T> control) {
    return validateValue(control.value);
  }

  Map<String, dynamic> validateValue(T value);
}


class ValidatorSet<T> {
  List<Validator<T>> _validators;
  List<Validator<T>> get validators => _validators;

  static ValidatorSet<T> builder<T>(List<Validator<T>> validators) {
    return ValidatorSet(validators);
  }

  ValidatorSet(List<Validator<T>> validators) {
    validators.sort((a, b) => a.hashCode.compareTo(b.hashCode));
    this._validators = validators;
  }

  Map<String, dynamic> call(AbstractControl<T> control) {
    final errors = Map<String, dynamic>();
    for (var validator in _validators) {
      final validatorErrors = validator.validate(control);
      if (validatorErrors != null) {
        errors.addAll(validatorErrors);
      }
    }
    return errors;
  }

  @override
  String toString() {
    return "Validators: $_validators";
  }

  @override
  bool operator == (Object other) {
    return identical(this, other) ||
        (other is ValidatorSet &&
            runtimeType == other.runtimeType &&
            _validatorsEqual(other)
        );
  }

  bool _validatorsEqual(ValidatorSet other) {
    if (validators.length != other.validators.length) {
      return false;
    }
    for (int i = 0; i < validators.length; i++) {
      if (validators[i] != other.validators[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode {
    int hashCode = 0;
    validators.forEach((v) => hashCode = hashCode ^ v.hashCode);
    return hashCode;
  }
}