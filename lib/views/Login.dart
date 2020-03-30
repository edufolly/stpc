import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stpc/utils/MetricHttpClient.dart';
import '../utils/Config.dart';
import '../utils/WaitingMessage.dart';
import 'Home.dart';

///
///
///
enum Status {
  loading,
  form,
  success,
}

///
///
///
class Login extends StatefulWidget {
  final String message;

  ///
  ///
  ///
  const Login({Key key, this.message}) : super(key: key);

  ///
  ///
  ///
  @override
  _LoginState createState() => _LoginState();
}

///
///
///
class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//  final TextEditingController _apiController = TextEditingController();
  final TextEditingController _userController = TextEditingController();

//  final FocusNode _apiFocusNode = FocusNode();
  final FocusNode _userFocusNode = FocusNode();
  final StreamController<Status> _streamController = StreamController();
  String _error;
  final Config _config = Config();

  ///
  ///
  ///
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  ///
  ///
  ///
  void _loadData() async {
    _streamController.add(Status.loading);
    if (widget.message != null && widget.message.isNotEmpty) {
      _error = widget.message;
      _streamController.add(Status.form);
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();

//      _config.apiKey = prefs.getString('apiKey');
      _config.userName = prefs.getString('userName');

//      if (_config.apiKey == null ||
//          _config.apiKey.isEmpty ||
//          _config.userName == null ||
//          _config.userName.isEmpty) {

      if (_config.userName == null || _config.userName.isEmpty) {
        _streamController.add(Status.form);
      } else {
        _signIn();
      }
    }
  }

  ///
  ///
  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 600,
          width: 350,
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.all(
              const Radius.circular(8.0),
            ),
          ),
          child: StreamBuilder<Status>(
              stream: _streamController.stream,
              initialData: Status.loading,
              builder: (context, snapshot) {
                switch (snapshot.data) {
                  case Status.loading:
                    return WaitingMessage('Aguarde...');
                  case Status.form:
                    return Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            /// Image
                            Image.asset('assets/logo-small.png'),

                            /// Title
                            Text(
                              'Simple Tagpacker Client',
                              style: Theme.of(context).textTheme.headline4,
                              textAlign: TextAlign.center,
                            ),

                            /// Message
                            _error == null || _error.isEmpty
                                ? Container()
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Container(
                                      padding: EdgeInsets.all(8.0),
                                      color: Theme.of(context).accentColor,
                                      child: Center(
                                        child: Text(
                                          _error,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

//                            /// Api
//                            TextFormField(
//                              key: Key('apiTextFormField'),
//                              controller: _apiController,
//                              focusNode: _apiFocusNode,
//                              keyboardType: TextInputType.text,
//                              autocorrect: false,
//                              enableSuggestions: false,
//                              textCapitalization: TextCapitalization.none,
//                              decoration: InputDecoration(
//                                filled: true,
//                                labelText: 'API Key*',
//                              ),
//                              validator: (value) {
//                                if (value.isEmpty) {
//                                  return 'API Key is necessary.';
//                                }
//                                return null;
//                              },
//                              textInputAction: TextInputAction.next,
//                              onFieldSubmitted: (_) {
//                                _apiFocusNode.unfocus();
//                                FocusScope.of(context)
//                                    .requestFocus(_userFocusNode);
//                              },
//                            ),

                            /// User
                            TextFormField(
                              key: Key('userTextFormField'),
                              controller: _userController,
                              focusNode: _userFocusNode,
                              keyboardType: TextInputType.text,
                              autocorrect: false,
                              enableSuggestions: false,
                              textCapitalization: TextCapitalization.none,
                              decoration: InputDecoration(
                                filled: true,
                                labelText: 'User*',
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'User is necessary.';
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) {
                                _userFocusNode.unfocus();
//                                _config.apiKey = _apiController.text;
                                _config.userName = _userController.text;
                                _signIn();
                              },
                            ),

                            /// Signin
                            RaisedButton(
                              key: Key('signInBtn'),
                              child: Text(
                                'Sign in',
                              ),
                              onPressed: _signIn,
                            ),
                          ],
                        ),
                      ),
                    );
                  case Status.success:
                    return WaitingMessage('Redirecionando...');
                }
                return WaitingMessage('Aguarde...');
              }),
        ),
      ),
    );
  }

  ///
  ///
  ///
  void _signIn() async {
    _streamController.add(Status.loading);

    // TODO - Save name, userId, and PhotoUrl to don't
    //  do the request every time.
    try {
      Map<String, dynamic> data = await MetricHttpClient.doCall(
        endpoint: 'users?username=${_config.userName}',
        log: false,
      );

      if (data['code'] != 200) {
        throw Exception('Sign in error.');
      }

      String body = data['body'];

      List newData = json.decode(body);

      Map<String, dynamic> user = newData.first;

      _config.name = user['name'];
      _config.userId = user['id'];
      _config.photoUrl = user['photoUrl'];

      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString('userName', _config.userName);

      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => Home(),
        ),
        (_) => false,
      );
    } catch (exception, stack) {
      print(exception);
      print(stack);
      _error = exception;
      _streamController.add(Status.form);
    }
  }

  ///
  ///
  ///
  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }
}
