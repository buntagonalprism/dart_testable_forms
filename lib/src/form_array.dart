part of '../dart_testable_forms.dart';

class FormArray<T> extends AbstractControl<List<T>> {

  final _valueController = StreamController<List<T>>.broadcast();
  final _enabledController = StreamController<bool>.broadcast();

  Stream<List<T>> get valueUpdated => _valueController.stream;
  Stream<bool> get enabledUpdated => _enabledController.stream;

  final  _controls = List<AbstractControl<T>>();
  FormArray(List<AbstractControl<T>> controls, {List<T> initialValue, ValidatorSet<List<T>> validators}) {
    _controls.addAll(controls);
    if (initialValue != null) {
      setValue(initialValue);
    }
    if (enabled != null) {
      setEnabled(enabled);
    }
    _validators = validators ?? ValidatorSet<List<T>>([]);
  }

  List<AbstractControl<T>> get controls => _controls;

  @override
  setSubmitRequested(bool submitRequested) {
    _submitRequested = submitRequested;
    for (var control in _controls){
      control.setSubmitRequested(submitRequested);
    }
  }

  @override
  setEnabled(bool enabled) {
    _enabled = enabled;
    _enabledController.add(_enabled);
    for (var control in _controls){
      control.setEnabled(enabled);
    }
  }

  @override
  setValidators(ValidatorSet<List<T>> validators) {
    _validators = validators;
  }

  @override
  setValue(List<T> value)  {
    if (value != null) {
      if (value.length != _controls.length) {
        throw 'Attempting to set FormArray value with a list of length ${value.length}, but FormArray contains ${_controls.length} controls';
      }
      for (int i = 0; i < _controls.length; i++) {
        _controls[i].setValue(value[i]);
      }

    }
  }

  @override
  List<T> get value {
    final values = List<T>();
    for (var control in _controls) {
      if (control.enabled) {
        values.add(control.value);
      }
    }
    return values;
  }

  @override
  Map<String, dynamic> get errors {
    final allControlErrors = Map<String, Map<String, dynamic>>();
    for (int i = 0; i < _controls.length; i++) {
      final control = _controls[i];
      if (control.enabled) {
        final controlErrors = control.errors;
        if (controlErrors.length > 0) {
          allControlErrors[i.toString()] = controlErrors;
        }
      }
    }
    final groupErrors = _validators(this);
    if (allControlErrors.length > 0) {
      groupErrors['controlErrors'] = allControlErrors;
    }
    return groupErrors;
  }

  void append(AbstractControl<T> control) {
    _controls.add(control);
    _notifyValue();
  }

  void insertAt(AbstractControl<T> control, int index) {
    _controls.insert(index, control);
    _notifyValue();
  }

  void removeAt(int index) {
    _controls.removeAt(index);
    _notifyValue();
  }

  _notifyValue() {
    if (_valueController.hasListener) {
      _valueController.add(value);
    }
    _modelUpdated.add(null);
  }

}
