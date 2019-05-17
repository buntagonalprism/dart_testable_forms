import 'dart:convert';

import 'package:dart_testable_forms/dart_testable_forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_testable_forms/blocs/sign_up_bloc.dart';
import 'package:flutter_testable_forms/flutter_forms/form_widgets.dart';

final _scaffoldKey = GlobalKey<ScaffoldState>();

class SignUpScreen extends StatefulWidget {
  SignUpScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  SignUpBloc _bloc;

  List<DropdownMenuItem<String>> items;

  FormControl<String> ddControl;

  bool obscurePassword = true;
  bool obscureConfirmation = true;

  @override
  void initState() {
    super.initState();
    _bloc = SignUpBloc();
    items =  <String>['One', 'Two', 'Free', 'Four']
        .map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    FormControl<bool> likeBananas = _bloc.form.controls['likeBananas'];
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 48,
              ),
              Center(
                child: Text('How do you feel about curved yellow fruit/berry combos?'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ControlledRadioGroup<bool>(likeBananas, {
                  'Yes I like bananas': true,
                  'Bananas are disgusted': false,
                }),
              ),
              StreamBuilder(
                stream: likeBananas.valueUpdated,
                builder: (context, _) {
                  return Text(
                      (likeBananas.value ?? false) ? 'Good to hear. Want a smoothie?' : 'No cake for you then'
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ControlledDropDown(_bloc.form.controls['state'], {
                  'New South Wales': 0,
                  'Australian Capital Territory': 1,
                  'Queensland': 2,
                  'South Australia': 3,
                  'Victoria': 4,
                  'Tasmania': 5,
                  'Western Australia': 6,
                  'Northern Terriorty': 7
                }, decoration: InputDecoration(
                  labelText: 'What state are you from?',
                ),),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ControlledTextField(
                  _bloc.form.controls['email'],
                  decoration: InputDecoration(
                      labelText: 'Email Address'
                  ),
                  textInputType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ControlledTextField(
                  _bloc.form.controls['password'],
                  decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(obscurePassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => obscurePassword = !obscurePassword),
                      )
                  ),
                  obscureText: obscurePassword,
                  textInputAction: TextInputAction.next,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ControlledTextField(
                  _bloc.form.controls['confirmation'],
                  decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      suffixIcon: IconButton(
                        icon: Icon(obscureConfirmation ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => obscureConfirmation = !obscureConfirmation),
                      )
                  ),
                  obscureText: obscureConfirmation,
                ),
              ),
              RaisedButton(
                child: Text('SIGN UP'),
                onPressed: () {
                  _bloc.form.setSubmitRequested(true);
                  bool valid = _bloc.form.valid;
                  if (valid) {
                    showSnackBar('all fields valid');
                    print(_bloc.form.value);
                    print(json.encode(_bloc.form.value));
                  } else {
                    showSnackBar('there are invalid fields');
                  }
                },
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _bloc.post,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  void showSnackBar(String msg) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(msg)));
  }
}

