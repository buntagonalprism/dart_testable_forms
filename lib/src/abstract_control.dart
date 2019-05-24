part of '../dart_testable_forms.dart';

typedef ViewNotifier();


abstract class AbstractControl<T> {

  final _errors = Map<String, dynamic>();

  final _modelUpdated = StreamController<void>.broadcast();

  bool _enabled = true;
  bool _submitRequested = false;
  bool _touched = false;
  ValidatorSet<T> _validators = ValidatorSet<T>([]);


  /// Stream notified when any change to this control occurs. These changes include changes to value
  /// and errors, as well as updates to enabled, touched or submitRequested status. Once this event is
  /// emitted, all changes have already been made to the control, so it is safe to rebuild any UI 
  /// components using the current properties of the control. 
  Stream<void> get modelUpdated => _modelUpdated.stream;

  /// The current errors related to the value in this control, as determined by the [validators]
  Map<String, dynamic> get errors => _errors;

  /// Whether this control is enabled. When enabled, users should be able to interact with the view
  /// and make changes to the value of this control. When disabled, users should not be able to
  /// interact with the view bound to this control. This behaviour must be enforced within the view.
  bool get enabled => _enabled;

  /// Whether the user has attempted to submit the data for this control. This is useful as an
  /// indication that error messages should be displayed regardless of [touched] status - e.g. an
  /// untouched required field still needs to show errors before being submitted.
  bool get submitRequested => _submitRequested;

  /// Check whether this control is valid, that is - whether this control or any child control
  /// has any errors
  bool get valid => _errors.length == 0;

  /// Check whether this control is touched, that is, whether the user has interacted with this
  /// control or any child controls. Typically used to control whether error messages are displayed,
  /// allowing the user a chance to input into the field before showing errors.
  bool get touched => _touched;

  /// The current set of validators used to validate the value in this control.
  ValidatorSet<T> get validators => _validators;

  /// Get the value of the control. If this control is disabled, the value will be returned as null
  /// within parent groups. 
  T get value;

  dynamic get jsonValue {
    T current = value;
    return _convertToJson(current);
  }

  dynamic _convertToJson(dynamic val) {
    if (val is String || val is int || val is double || val is bool || val == null) {
      return val;
    }
    else if (val is Iterable) {
      return val.map((item) => _convertToJson(item)).toList();
    } else {
      try {
        Map<String, dynamic> values = val.toJson();
        return values;
      } on NoSuchMethodError catch(_) {
        throw "Class ${val.runtimeType} must have a toJson() method returning Map<String, dynamic> to be used with dart_testable_forms";
      }
    }
  }

  /// Update the value of this control
  setValue(T value);

  /// Update the validators that should be run when this control is validated. Validators are run
  /// on every value change and so should be fast to execute and synchronous. To run asynchronous
  /// validators subscribe to valueUpdated stream, perform asynchronous work in the background,
  /// then add a StaticErrorValidator to the control with the result of the error. 
  setValidators(ValidatorSet<T> validators);

  /// Whether this input field bound to this control is displaying its errors. Typically enabled
  /// either on blur of input fields, or on a form submit button press.
  setSubmitRequested(bool submitRequested);

  /// Whether this control should be enabled: i.e. whether the view input field bound to this
  /// control should accept user input. It is up to the view to decide how disabled state should
  /// be presented. Typical options include greying out the field, or hiding it altogether.
  setEnabled(bool enabled);


  /// Run the validators and calculate errors for this control
  void _updateErrors() {
    final errors = _validators(this);
    _errors.clear();
    _errors.addAll(errors);
  }

}
