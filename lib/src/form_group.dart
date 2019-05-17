part of '../dart_testable_forms.dart';

typedef Deserializer<T> = T Function(Map<String, dynamic> source);

class FormGroup<T> extends AbstractControl<T> {
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
    final values = Map<String, dynamic>();
    controls.forEach((key, control) {
      if (control.enabled) {
        values[key] = control.value;
      } else {
        values[key] = null;
      }
    });
    return deserializer(values);
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
    final initialValues = _serialize(value);
    initialValues.forEach((key, value) {
      if (controls.containsKey(key)) {
        controls[key].setValue(initialValues[key]);
      }
    });
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

