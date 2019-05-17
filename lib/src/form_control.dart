part of '../dart_testable_forms.dart';

class FormControl<T> extends AbstractControl<T> {
  T _value;
  final _valueController = StreamController<T>.broadcast();
  Stream<T> get valueUpdated => _valueController.stream;

  FormControl({T initialValue, ValidatorSet<T> validators, bool enabled = true}) {
    if (initialValue != null) {
      _value = initialValue;
    }
    if (validators != null) {
      _validators = validators;
    }
    _enabled = enabled == true;
    _updateErrors();
  }

  @override
  T get value => _value;


  @override
  setValidators(ValidatorSet<T> validators) {
    _validators = validators;
    _updateErrors();
    _notifyView();
  }

  @override
  setSubmitRequested(bool submitRequested) {
    _submitRequested = submitRequested;
    _notifyView();
  }

  @override
  setEnabled(bool enabled) {
    _enabled = enabled;
    _notifyView();
  }

  /// Update the view with a new value. Results in the [ViewNotifier] informing the view that it
  /// needs to rebuild with the new value.
  @override
  setValue(T newValue) {
    _value = newValue;
    _updateErrors();
    _notifyView();
    _notifyValueListeners();
  }

  /// Notify the a bound input view field of changes
  _notifyView() {
    _modelUpdated.add(null);
  }

  void _notifyValueListeners() {
    _valueController.add(_value);
  }

  void setTouched(bool touched) {
    _touched = touched;
    _notifyView();
  }


  String combineErrors(ErrorCombiner<T> combiner) => combiner.combine(this);
}

abstract class ErrorCombiner<T> extends Equatable {
  ErrorCombiner(List props) : super(props);
  String combine(FormControl<T> control);
}

/// A helper for getting a combined error message to display. Returns:
/// - null if the field is disabled
/// - null if the field is enabled, but not touched or submitRequested
/// - All error values combined with a newline separator if enabled, and either touched or submitRequested
class NewlineErrorCombiner extends ErrorCombiner<String> {
  final newlineSeparator;
  NewlineErrorCombiner([this.newlineSeparator = '\n']) : super([newlineSeparator]);

  String combine(FormControl<String> control) {
    if ((control.touched || control.submitRequested) && control.enabled) {
      return control.errors.length > 0
          ? control.errors.values.map((error) => error.toString()).join('\n')
          : null;
    } else {
      return null;
    }
  }

}
