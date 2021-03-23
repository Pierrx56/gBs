import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/AppLocalizations.dart';
import 'package:provider/provider.dart';
import 'Login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Détection de la langue du portable
  AppLanguage appLanguage = AppLanguage();
  Locale langue = await appLanguage.fetchLocale();

  //Changement de la langue
  //Anglais si autre que fr ou en
  appLanguage.changeLanguage(langue);

  //Lancement de la page Login
  runApp(
    ChangeNotifierProvider.value(
      value: appLanguage,
      child: Consumer<AppLanguage>(builder: (context, model, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: model.appLocal != null ? model.appLocal : "",
          supportedLocales: [
            Locale('en', 'US'),
            Locale('fr', 'FR'),
          ],
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: SplashScreen(
            appLanguage: appLanguage,
          ),
          routes: <String, WidgetBuilder>{
            '/Login': (BuildContext context) =>
                new Login(appLanguage: appLanguage, message: "fromMain"),
          },
        );
      }),
    ),
  );
}

class SplashScreen extends StatefulWidget {
  final AppLanguage appLanguage;

  SplashScreen({@required this.appLanguage});

  @override
  _SplashScreenState createState() =>
      new _SplashScreenState(appLanguage: appLanguage);
}

class _SplashScreenState extends State<SplashScreen> {
  AppLanguage appLanguage;

  _SplashScreenState({
    @required this.appLanguage,
  });

  startTime() async {
    var _duration = new Duration(seconds: 2);
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Navigator.of(context).pushReplacementNamed('/Login');
  }

  @override
  void initState() {
    //Lock rotation
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: backgroundColor,
      body: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: new Image.asset(
          'assets/spineo.png',
          alignment: Alignment.center,
        ),
      ),
    );
  }
}
