import 'dart:async';

import 'package:dart_testable_forms/dart_testable_forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ControlledTextField extends StatefulWidget {
  final bool obscureText;
  final TextInputType textInputType;
  final InputDecoration decoration;
  final TextInputAction textInputAction;
  final FormControl<String> control;
  ControlledTextField(
    this.control, {
    this.decoration,
    this.textInputType,
    this.obscureText,
    this.textInputAction,
  });

  String get errorText {
    if ((control.touched || control.submitRequested) && control.enabled) {
      return control.errors.length > 0
          ? control.errors.values.map((error) => error.toString()).join('\n')
          : null;
    } else {
      return null;
    }
  }

  @override
  _ControlledTextFieldState createState() => new _ControlledTextFieldState();
}

class _ControlledTextFieldState extends State<ControlledTextField> {
  final controller = TextEditingController();
  final focus = FocusNode();
  bool focused = false;

  StreamSubscription sub;

  @override
  void initState() {
    super.initState();
    controller.text = widget.control.value;
    sub = widget.control.modelUpdated.listen((_) {
      if (controller.text != widget.control.value) {
        controller.text = widget.control.value;
      }
      setState(() {});
    });
    focus.addListener(() {
      // Mark field as touched and trigger a rebuild when focus is lost
      if (focused && !focus.hasFocus) {
        widget.control.setTouched(true);
      }
      focused = focus.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: widget.obscureText ?? false,
      keyboardType: widget.textInputType,
      focusNode: focus,
      controller: controller,
      enabled: widget.control.enabled,
      textInputAction: widget.textInputAction,
      onChanged: (value) => widget.control.setValue(value),
      decoration: (widget.decoration ?? InputDecoration()).copyWith(
        errorText: widget.control.combineErrors(newlineErrorCombiner),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    sub.cancel();
  }
}

class ControlledRadioGroup<T> extends StatelessWidget {
  final FormControl<T> control;
  final Map<String, T> options;
  ControlledRadioGroup(this.control, this.options);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: control.modelUpdated,
      builder: (context, _) {
        final children = List<Widget>();
        options.forEach((label, T value) {
          children.add(RadioListTile(
            title: Text(label),
            value: value,
            groupValue: control.value,
            onChanged: (value) {
              control.setValue(value);
              control.setTouched(true);
            },
          ));
        });
        return Column(children: children);
      },
    );
  }
}

class ControlledDropDown<T> extends StatelessWidget {
  final InputDecoration decoration;
  final FormControl<T> control;
  final Map<String, T> options;
  ControlledDropDown(this.control, this.options, {this.decoration});

  String get errorText {
    if ((control.touched || control.submitRequested) && control.enabled) {
      return control.errors.length > 0
          ? control.errors.values.map((error) => error.toString()).join('\n')
          : null;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: control.modelUpdated,
      builder: (context, _) {
        final items = List<DropdownMenuItem<T>>();
        options.forEach((label, T value) {
          items.add(DropdownMenuItem<T>(
            child: Text(label),
            value: value,
          ));
        });
        return InputDecorator(
          decoration: (decoration ?? InputDecoration()).copyWith(errorText: errorText),
          isEmpty: false,
          child: DropdownButton<T>(
            isDense: true,
            value: control.value,
            items: items,
            onChanged: (value) {
              control.setValue(value);
              control.setTouched(true);
            },
          ),
        );
      },
    );
  }
}
