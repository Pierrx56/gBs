// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_rounded_progress_bar/flutter_rounded_progress_bar.dart';
import 'package:flutter_rounded_progress_bar/rounded_progress_bar_style.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/AppLocalizations.dart';
import 'package:gbsalternative/BluetoothManager.dart';
import 'package:gbsalternative/DatabaseHelper.dart';
import 'package:gbsalternative/LoadPage.dart';
import 'package:gbsalternative/MainTitle.dart';
import 'package:gbsalternative/Login.dart';

/*
* Classe pour gérer la première poussée de l'utilisateur
* Inaccessible une fois la première poussée enregistrée
* Prend en paramètre un utilisatuer, un message et la langue choisie
* */

class FirstPush extends StatefulWidget {
  User user;
  String inputMessage;
  AppLanguage appLanguage;

  FirstPush({
    @required this.user,
    @required this.inputMessage,
    @required this.appLanguage,
  });

  @override
  _FirstPush createState() => new _FirstPush(user, inputMessage, appLanguage);
}

class _FirstPush extends State<FirstPush> {
  //Initialisation de l'appel de fichiers externes
  //android: android/app/src/main/java/genourob/gbs_alternative/MainActivity.java
  //iOS: ios/Runner/AppDelegate.swift
  static const MethodChannel sensorChannel =
      MethodChannel('samples.flutter.io/sensor');

  //Déclaration de variables
  String _pairedDevices = 'No devices paired';
  bool isConnected = false;
  bool isRunning = true;
  Timer timer;
  Timer timerConnexion;
  String macAdress;
  String data;
  User user;
  String inputMessage;
  AppLanguage appLanguage;

  Color colorMesureButton = Colors.black;

  //RoundedProgressBarTheme colorProgressBar = RoundedProgressBarTheme.yellow;
  Color colorProgressBar = Colors.red;
  Timer _timer;
  double _start = 10.0;
  int countdown = 5;
  static double _reset = 10.0;
  int i = 100;
  List<double> average = new List(10 * _reset.toInt());
  static double delta = 102.0;
  double coefKg = 0.45359237;
  double result;
  String recording;
  String statusBT;
  String btData;
  bool isCorrect = false;
  Size screenSize;

  //Initializing database
  DatabaseHelper db = new DatabaseHelper();

  // Initializing Bluetooth
  BluetoothManager btManage =
      new BluetoothManager(user: null, inputMessage: null, appLanguage: null);

  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //Constructeur _BluetoothManager
  _FirstPush(User _user, String _inputMessage, AppLanguage _appLanguage) {
    user = _user;
    inputMessage = _inputMessage;
    appLanguage = _appLanguage;
  }

  @override
  void initState() {
    super.initState();
    btData = "0.0";
    connect();
  }

  @override
  void dispose() {
    // Avoid memory leak and disconnect
    if (isConnected) {
/*      isDisconnecting = true;
      connexion.dispose();
      connexion = null;*/
    }

    super.dispose();
  }

  void connect() async {
    //Tant que le bluetooth n'est pas activé, on demande son activation
    if(await btManage.enableBluetooth()){
      connect();

    } else {
      btManage.getPairedDevices("firstPush");
      btManage.connect(user.userMacAddress, user.userSerialNumber);
      isConnected = await btManage.getStatus();
      testConnect();
    }
  }

  testConnect() async {
    isConnected = await btManage.getStatus();
    if (!isConnected) {
      timerConnexion = new Timer.periodic(Duration(milliseconds: 1500),
          (timerConnexion) async {
        btManage.connect(user.userMacAddress, user.userSerialNumber);
        print("isConnected: $isConnected");
        isConnected = await btManage.getStatus();
        if (isConnected) {
          timerConnexion.cancel();
        }
      });
    }
  }

  void getData() async {
    btData = await btManage.getData();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;

    if (recording == null)
      recording =
          AppLocalizations.of(context).translate('demarrer_enregistrement');

    if (statusBT == null)
      statusBT = AppLocalizations.of(context).translate('connecter_app');

    return MaterialApp(
      supportedLocales: [
        Locale('en', 'US'),
        Locale('fr', 'FR'),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          //title: Text(AppLocalization.of(context).heyWorld),

          title:
              Text(AppLocalizations.of(context).translate('premiere_poussee')),
          backgroundColor: Colors.blue,
          actions: <Widget>[],
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                AppLocalizations.of(context).translate('explications_mesure'),
                style: textStyle,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  //Progress bar maison
                  //Rotate 9.4 pour retourner les container de 180°
                  Transform.rotate(
                    angle: 9.4,
                    child: Stack(
                      children: <Widget>[
                        //Container de fond
                        Container(
                          decoration: new BoxDecoration(
                              color: Colors.blue,
                              //new Color.fromRGBO(255, 0, 0, 0.0),
                              borderRadius: new BorderRadius.only(
                                  topLeft: const Radius.circular(20.0),
                                  topRight: const Radius.circular(20.0),
                                  bottomLeft: const Radius.circular(20.0),
                                  bottomRight: const Radius.circular(20.0))),
                          width: 100,
                          height: screenSize.height / 2 - 10,
                        ),
                        //Container progress bar
                        //Passe à vert au dessus de 50 et en dessous de 100
                        //sinon rouge
                        Container(
                          decoration: new BoxDecoration(
                              color: colorProgressBar,
                              //new Color.fromRGBO(255, 0, 0, 0.0),
                              borderRadius: new BorderRadius.only(
                                  topLeft: const Radius.circular(20.0),
                                  topRight: const Radius.circular(20.0),
                                  bottomLeft: const Radius.circular(20.0),
                                  bottomRight: const Radius.circular(20.0))),
                          //40.0 pour éviter des bugs d'affichage
                          height: double.parse(btData) < 40.0
                              ? 40.0
                              : double.parse(btData) > 100.0
                                  ? screenSize.height / 2 - 10
                                  //*1.7 pour remplir la progress bar à 100% lorsque le capteur renvoi 100
                                  : double.parse(btData) * 1.7,
                          width: 100,
                        ),
                        //Container d'affichage de la valeur du capteur
                        Container(
                          color: Colors.transparent,
                          //new Color.fromRGBO(255, 0, 0, 0.0),
                          child: Center(
                              child: Transform.rotate(
                                  angle: 9.4,
                                  child: Text(
                                    (double.parse(btData)).toString(),
                                    style: textStyle,
                                  ))),
                          width: 100,
                          height: screenSize.height / 2,
                        ),
                      ],
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(10.0)),
                  Container(
                    width: screenSize.width / 1.5,
                    child: Column(
                      children: <Widget>[
                        RaisedButton(
                          //child: Text("Démarrer l'enregistrement."),
                          onPressed: !isCorrect || user.userInitialPush != "0.0"
                              ? () async {
                                  colorMesureButton = Colors.black;
                                  const oneSec =
                                      const Duration(milliseconds: 100);
                                  _timer = new Timer.periodic(
                                    oneSec,
                                    (Timer timer) => setState(
                                      () {
                                        if (_start < 0.1) {
                                          timer.cancel();
                                          _start = _reset;
                                          result = double.parse(
                                              (average.reduce((a, b) => a + b) /
                                                      average.length)
                                                  .toStringAsFixed(2));
                                          print(result.toStringAsFixed(2));
                                          i = 100;
                                          if (result <= 50.0 ||
                                              result >= 100.0) {
                                            //Mesure pas bonne, réajuster la toise
                                            setState(() {
                                              recording = AppLocalizations.of(
                                                      context)
                                                  .translate(
                                                      'status_mesure_mauvais');
                                              colorMesureButton = Colors.red;
                                            });
                                          } else {
                                            setState(() {
                                              colorMesureButton = Colors.green;
                                              recording =
                                                  AppLocalizations.of(context)
                                                      .translate(
                                                          'status_mesure_bon');
                                            });
                                            isCorrect = true;
                                            //update poussée
                                            User updatedUser = User(
                                              userId: user.userId,
                                              userName: user.userName,
                                              userMode: user.userMode,
                                              userPic: user.userPic,
                                              userHeightTop: user.userHeightTop,
                                              userHeightBottom:
                                                  user.userHeightBottom,
                                              userInitialPush: result
                                                  .toStringAsFixed(2)
                                                  .toString(),
                                              userMacAddress:
                                                  user.userMacAddress,
                                              userSerialNumber:
                                                  user.userSerialNumber,
                                            );

                                            db.updateUser(updatedUser);

                                            const time = const Duration(
                                                milliseconds: 1000);
                                            _timer = new Timer.periodic(
                                              time,
                                              (Timer timer) {
                                                if (countdown < 1) {
                                                  //TODO Display menu ?
                                                  timer.cancel();
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          MainTitle(
                                                              userIn:
                                                                  updatedUser,
                                                              appLanguage:
                                                                  appLanguage,
                                                              messageIn: 0),
                                                    ),
                                                  );
                                                } else {
                                                  setState(() {
                                                    countdown = countdown - 1;
                                                  });
                                                }
                                              },
                                            );
/*
                                                Future.delayed(
                                                    const Duration(
                                                        milliseconds: 5000), () {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => MainTitle(
                                                          userIn: updatedUser,
                                                          appLanguage: appLanguage,
                                                          messageIn: 0),
                                                    ),
                                                  );
                                                });*/
                                          }
                                        } else {
                                          recording = _start.toStringAsFixed(1);
                                          _start = _start - 0.1;
                                          i--;
                                          getData();
                                          average[i] = double.parse(btData);
                                          if (average[i] > 100.0 ||
                                              average[i] < 50.0) {
                                            setState(() {
                                              colorMesureButton = Colors.red;
                                              colorProgressBar = Colors.red;
                                            });
                                          } else {
                                            setState(() {
                                              colorMesureButton = Colors.green;
                                              colorProgressBar = Colors.green;
                                            });
                                          }
                                        }
                                      },
                                    ),
                                  );
                                  //_showDialog();
                                }
                              : null,
                          textColor: colorMesureButton,
                          child: Text(recording),
                        ),
                        isCorrect
                            ? Text(
                                AppLocalizations.of(context)
                                        .translate('redirection') +
                                    " $countdown " +
                                    AppLocalizations.of(context)
                                        .translate('secondes'),
                                style: textStyle,
                              )
                            : Text(""),
                        inputMessage == "fromMain"
                            ? RaisedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoadPage(
                                        appLanguage: appLanguage,
                                        page: mainTitle,
                                        user: user,
                                        messageIn: "0",
                                      ),
                                    ),
                                  );
                                },
                                child: Text(AppLocalizations.of(context)
                                    .translate('retour')),
                              )
                            : Text(""),
                      ],
                    ),
                  ),
                ],
              ),
              /*RoundedProgressBar(
                          percent: (double.parse(btData)) >= 0
                              ? (double.parse(btData))
                              : 0.0,
                          theme: colorProgressBar,
                          childCenter: Text((double.parse(btData)).toString())),
                      */
            ],
          ),
        ),
      ),
    );
  }

  // Method to show a Snackbar,
  // taking message as the text
  Future show(
    String message, {
    Duration duration: const Duration(seconds: 3),
  }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: new Text(
          message,
        ),
        duration: duration,
      ),
    );
  }
}
