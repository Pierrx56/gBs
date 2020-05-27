import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'Login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Détection de la langue du portable
  AppLanguage appLanguage = AppLanguage();
  await appLanguage.fetchLocale();

  runApp(new MaterialApp(
    color: Colors.white,
    home: new SplashScreen(),
    routes: <String, WidgetBuilder>{
      '/Login': (BuildContext context) => new MyApp(
        appLanguage: appLanguage,
          ),
    },
  ));
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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
    return new MaterialApp(
      home: new Image.asset(
        'assets/ABSeat.png',
      ),
    );
  }
}