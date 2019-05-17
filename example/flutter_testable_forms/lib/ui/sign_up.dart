import 'dart:convert';

import 'package:dart_testable_forms/dart_testable_forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_testable_forms/blocs/sign_up_bloc.dart';
import 'package:flutter_testable_forms/flutter_forms/form_widgets.dart';

final _scaffoldKey = GlobalKey<ScaffoldState>();

class SignUpScreen extends StatefulWidget {
  final String title;
  final SignUpBloc bloc;
  SignUpScreen({Key key, this.title, this.bloc}) : super(key: key);
  

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  SignUpBloc bloc;

  List<DropdownMenuItem<String>> items;

  FormControl<String> ddControl;

  bool obscurePassword = true;
  bool obscureConfirmation = true;

  @override
  void initState() {
    super.initState();
    bloc = widget.bloc;
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
    FormControl<bool> likeBananas = bloc.form.controls['likeBananas'];
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
                child: ControlledDropDown(bloc.form.controls['state'], {
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
                  bloc.form.controls['email'],
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
                  bloc.form.controls['password'],
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
                  bloc.form.controls['confirmation'],
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
                  bloc.form.setSubmitRequested(true);
                  bool valid = bloc.form.valid;
                  if (valid) {
                    showSnackBar('all fields valid');
                    print(bloc.form.value);
                    print(json.encode(bloc.form.value));
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
        onPressed: bloc.post,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  void showSnackBar(String msg) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(msg)));
  }
}

