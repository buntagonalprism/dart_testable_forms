part of '../dart_testable_forms.dart';

typedef ControlBuilder<T> = AbstractControl<T> Function(T value, int index);

class FormArray<T> extends AbstractControl<List<T>> {


  final _valueController = StreamController<List<T>>.broadcast();
  final _enabledController = StreamController<bool>.broadcast();
  final _controls = List<AbstractControl<T>>();

  Stream<List<T>> get valueUpdated => _valueController.stream;
  Stream<bool> get enabledUpdated => _enabledController.stream;

  final ControlBuilder<T> builder;
  FormArray(this.builder, {List<T> initialValue, ValidatorSet<List<T>> validators}) {
    if (initialValue != null) {
      setValue(initialValue);
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
  setValue(List<T> values)  {
    if (values != null) {
      _controls.clear();
      for (var i = 0; i < values.length; i++) {
        _controls.add(builder(values[i], i));
      }
      _notifyValue();
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

  void append(T value) {
    _controls.add(builder(value, _controls.length));
    _notifyValue();
  }

  void insertAt(T value, int index) {
    _controls.insert(index, builder(value, index));
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
