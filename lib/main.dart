import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'utils/Config.dart';
import 'views/Login.dart';

///
///
///
void main() {
  bool debug = false;

  assert(debug = true);

  Config config = Config();

  config.debug = debug;

  runApp(SimpleTagPackerClient());
}

///
///
///
class SimpleTagPackerClient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Tagpacker Client',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        accentColor: Colors.tealAccent,
        primaryColor: Colors.tealAccent,
        toggleableActiveColor: Colors.tealAccent,
        buttonTheme: ThemeData.dark().buttonTheme.copyWith(
              buttonColor: Colors.tealAccent,
              textTheme: ButtonTextTheme.primary,
            ),
      ),
      home: Login(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', 'US'),
      ],
    );
  }
}
