part of '../dart_testable_forms.dart';

typedef Deserializer<T> = T Function(Map<String, dynamic> source);

class FormGroup<T> extends AbstractControl<T> {
  Map<String, dynamic> _values = {};
  final _controls = Map<String, AbstractControl>();
  final Deserializer<T> deserializer;
  FormGroup(Map<String, AbstractControl> controls, this.deserializer, {
    T initialValue,
    bool enabled,
    ValidatorSet<T> validators,
  }) {
    if (controls != null) {
      _controls.addAll(controls);
    }
    if (initialValue != null) {
      setValue(initialValue);
    }
    if (enabled != null) {
      setEnabled(enabled);
    }
    _validators = validators ?? ValidatorSet<T>([]);
  }

  Map<String, AbstractControl> get controls => _controls;


  @override
  T get value {
    return deserializer(jsonValue);
  }

  @override 
  dynamic get jsonValue {
    controls.forEach((key, control) {
      if (control.enabled) {
        _values[key] = control.jsonValue;
      } else {
        _values[key] = null;
      }
    });
    return _values;
  }

  @override
  setSubmitRequested(bool submitRequested) {
    _submitRequested = submitRequested;
    controls.forEach((_, control) {
      control.setSubmitRequested(submitRequested);
    });
  }

  @override
  setEnabled(bool enabled) {
    _enabled = enabled;
    controls.forEach((_, control) {
      control.setEnabled(enabled);
    });
  }

  @override
  setValue(T value) {
    if (value != null) {
      _values = _serialize(value);
      controls.forEach((key, control) {
        if (!_values.containsKey(key)) {
          throw "Control with key '$key' does not have a corresponding field in class ${value.runtimeType.toString()}";
        }
        controls[key].setValue(_values[key]);
      });
    }
  }

  @override
  setValidators(ValidatorSet<T> validators) {
    _validators = validators;
  }

  Map<String, dynamic> _serialize(value) {
    try {
      Map<String, dynamic> values = value.toJson();
      return values;
    } on NoSuchMethodError catch(_) {
      throw "Class ${value.runtimeType} must have a toJson() method returning Map<String, dynamic> to be used with FormGroup";
    }
  }

  @override
  Map<String, dynamic> get errors {
    final allControlErrors = Map<String, dynamic>();
    controls.forEach((key, control) {
      if (control.enabled) {
        final controlErrors = control.errors;
        if (controlErrors.length > 0) {
          allControlErrors[key] = controlErrors;
        }
      }
    });
    final groupErrors = _validators(this);
    if (allControlErrors.length > 0) {
      groupErrors['controlErrors'] = allControlErrors;
    }
    return groupErrors;
  }



  @override
  bool get valid => errors.length == 0;
}

