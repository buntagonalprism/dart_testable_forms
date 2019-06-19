import 'package:dart_testable_forms/dart_testable_forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class FieldContainer extends StatefulWidget {
  final Widget child;
  final FieldCoordinator coordinator;
  FieldContainer({@required this.child, @required this.coordinator});

  @override
  _FieldContainerState createState() => _FieldContainerState();
}

class _FieldContainerState extends State<FieldContainer> {

  FieldCoordinator coordinator;

  @override
  void initState() {
    super.initState();
    coordinator = widget.coordinator;
    coordinator._clearFocus = () {
      FocusScope.of(context).requestFocus(FocusNode());
    };
  }

  @override
  Widget build(BuildContext context) {
    return FieldCoordinatorInherited(
      coordinator: coordinator,
      child: widget.child,
    );
  }
}

class FieldCoordinatorInherited extends InheritedWidget {
  final FieldCoordinator coordinator;

  FieldCoordinatorInherited({Key key, this.coordinator, Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(FieldCoordinatorInherited old) {
    return true;
  }
}

typedef PositionGetter = double Function();

class FieldCoordinatorFactory {
  FieldCoordinator build() => FieldCoordinator();
}

class FieldCoordinator {
  FieldCoordinator();

  VoidCallback _clearFocus;
  List<FieldReference> fields = [];

  static FieldCoordinator of(BuildContext context) {
    FieldCoordinatorInherited inherited =
        context.inheritFromWidgetOfExactType(FieldCoordinatorInherited);
    return inherited.coordinator;
  }

  void reattach(List<AbstractControl> oldControls, List<AbstractControl> newControls, PositionGetter getPosition, {VoidCallback reveal, VoidCallback focus}) {
    if (oldControls != null) {
      detach(oldControls);
    }
    fields.add(FieldReference(newControls, getPosition, reveal: reveal, focus: focus));
  }

  void detach(List<AbstractControl> currentControls) {
    fields.removeWhere(findReferencesByControls(currentControls));
  }

  bool Function(FieldReference ref) findReferencesByControls(List<AbstractControl> controls) {
    return (FieldReference field) {
      if (field.controls.length == controls.length) {
        for (var i = 0; i < field.controls.length; i++) {
          if (field.controls[i] != controls[i]) {
            return false;
          }
        }
        return true;
      } else {
        return false;
      }
    };
  }

  bool get valid {
    bool allValid = true;
    for (var ref in fields) {
      allValid = allValid && ref.valid;
    }
    return allValid;
  }

  void revealErrors() {
    final errorFields = fields.where((ref) => ref.valid == false);
    final first = getFirstControlAfterPosition(errorFields, -1.0);
    if (first != null) {
      first.reveal();
    }
  }

  FieldReference getFirstControlAfterPosition(List<FieldReference> refs, double startPosition) {
    FieldReference first;
    double firstPos = double.maxFinite;
    for (var ref in refs) {
      double refPos = ref.getPosition();
      if (refPos < firstPos && refPos > startPosition){
        first = ref;
        firstPos = refPos;
      }
    }
    return first;
  }

  void focusNext({@required List<AbstractControl> currentControls}) {
    FieldReference ref = fields.firstWhere(findReferencesByControls(currentControls));
    if (ref != null) {
      double currentPos = ref.getPosition();
      FieldReference next = getFirstControlAfterPosition(fields, currentPos);
      if (next != null) {
        if (next.focus != null) {
          next.focus();
        } else if (_clearFocus != null){
          _clearFocus();
        }
      }
    }
  }
}


class FieldReference {
  final List<AbstractControl> controls;
  final VoidCallback reveal;
  final VoidCallback focus;
  final PositionGetter getPosition;
  FieldReference(this.controls, this.getPosition, {this.reveal, this.focus});
  bool get valid  {
    for (var control in controls) {
      if (!control.valid) {
        return false;
      }
    }
    return true;
  }
}

class CoordinatedField extends StatefulWidget {

  final VoidCallback focus;
  final List<AbstractControl> controls;
  final Widget child;

  const CoordinatedField({Key key, @required this.controls, @required this.child, this.focus}) : super(key: key);

  @override
  _CoordinatedFieldState createState() => _CoordinatedFieldState();
}

class _CoordinatedFieldState extends State<CoordinatedField> {

  List<AbstractControl> controls;
  FieldCoordinator coordinator;


  @override
  Widget build(BuildContext context) {
    coordinator = FieldCoordinator.of(context);
    coordinator?.reattach(controls, widget.controls, position, reveal: reveal, focus: widget.focus);
    controls = widget.controls;
    return widget.child;
  }

  void reveal() {
    Scrollable.ensureVisible(context);
  }

  double position() {
    final RenderObject object = context.findRenderObject();
    final RenderAbstractViewport viewport = RenderAbstractViewport.of(object);
    return viewport.getOffsetToReveal(object, 0.0).offset;
  }

  @override
  void dispose() {
    super.dispose();
    coordinator?.detach(controls);
  }
}

