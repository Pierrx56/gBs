// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_rounded_progress_bar/flutter_rounded_progress_bar.dart';
import 'package:flutter_rounded_progress_bar/rounded_progress_bar_style.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/AppLocalizations.dart';
import 'package:gbsalternative/BluetoothManager.dart';
import 'package:gbsalternative/DatabaseHelper.dart';
import 'package:gbsalternative/LoadPage.dart';
import 'package:gbsalternative/MainTitle.dart';
import 'package:gbsalternative/Login.dart';
import 'package:sensors/sensors.dart';

/*
* Classe pour gérer la première poussée de l'utilisateur
* Inaccessible une fois la première poussée enregistrée
* Prend en paramètre un utilisatuer, un message et la langue choisie
* */

class MaxPush extends StatefulWidget {
  User user;
  String inputMessage;
  AppLanguage appLanguage;

  MaxPush({
    @required this.user,
    @required this.inputMessage,
    @required this.appLanguage,
  });

  @override
  _MaxPush createState() => new _MaxPush(user, inputMessage, appLanguage);
}

class _MaxPush extends State<MaxPush> {
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
  double x, y, z;

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
  String btData;
  bool isCorrect = false;
  bool isPush = false;
  Size screenSize;

  String backButtonText;
  NumberPicker bottomPicker;
  NumberPicker topPicker;
  int bottom;
  int top;

  //Initializing database
  DatabaseHelper db = new DatabaseHelper();

  // Initializing Bluetooth
  BluetoothManager btManage =
      new BluetoothManager(user: null, inputMessage: null, appLanguage: null);

  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //Constructeur _BluetoothManager
  _MaxPush(User _user, String _inputMessage, AppLanguage _appLanguage) {
    user = _user;
    inputMessage = _inputMessage;
    appLanguage = _appLanguage;
  }

  @override
  void dispose() {
    // Avoid memory leak and disconnect
    timerConnexion?.cancel();
    _timer?.cancel();

    super.dispose();
  }

  void connect() async {
    //Tant que le bluetooth n'est pas activé, on demande son activation
    if (await btManage.enableBluetooth()) {
      connect();
    } else {
      isConnected = await btManage.getStatus();
      if (!isConnected) {
        btManage.connect(user.userMacAddress, user.userSerialNumber);
        //testConnect();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    btData = "0.0";
    bottom = 0;
    top = 1;

    if (gyroscopeEvents.isEmpty != null) {
      gyroscopeEvents.listen((GyroscopeEvent event) {
        setState(() {
          x = event.x;
          y = event.y;
          z = event.z;
        });
      }); //get the sensor data and set then to the data types
    }
    connect();
  }

  testConnect() async {
    isConnected = await btManage.getStatus();
    if (!isConnected) {
      timerConnexion = new Timer.periodic(
        Duration(milliseconds: 3000),
        (timerConnexion) async {
          btManage.connect(user.userMacAddress, user.userSerialNumber);
          print("Status: $isConnected");

          isConnected = await btManage.getStatus();
          if (isConnected) {
            timerConnexion.cancel();
          }
        },
      );
    }
  }

  void getData() async {
    btData = await btManage.getData();
  }

  Future<bool> _onBackPressed() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => LoadPage(
                  user: user,
                  appLanguage: appLanguage,
                  messageIn: "0",
                  page: login,
                )));
  }

  void initializeNumberPicker() {
    bottomPicker = new NumberPicker.integer(
      initialValue: bottom,
      minValue: 0,
      maxValue: 99,
      onChanged: (bottomValue) => setState(() {
        bottom = bottomValue;
        top = bottom + 1;
        if (bottom != 0) {
          backButtonText = AppLocalizations.of(context).translate('valider');
        } else
          backButtonText = AppLocalizations.of(context).translate('retour');
      }),
    );
    topPicker = new NumberPicker.integer(
      initialValue: top,
      minValue: bottom + 1,
      maxValue: 100,
      onChanged: (topValue) => setState(() {
        top = topValue;
        if (top != 1) {
          backButtonText = AppLocalizations.of(context).translate('valider');
        } else
          backButtonText = AppLocalizations.of(context).translate('retour');
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    User updatedUser = user;

    initializeNumberPicker();

    if (recording == null)
      recording =
          AppLocalizations.of(context).translate('demarrer_enregistrement');

    if (backButtonText == null)
      backButtonText = AppLocalizations.of(context).translate('retour');

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
      home: WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            //title: Text(AppLocalization.of(context).heyWorld),
            title: AutoSizeText(
                AppLocalizations.of(context).translate('poussee_max')),
            backgroundColor: Colors.blue,
            actions: <Widget>[],
          ),
          body: SingleChildScrollView(
            child: Container(
              width: screenSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  AutoSizeText(
                    AppLocalizations.of(context)
                        .translate('explications_mesure'),
                    style: textStyle,
                    textAlign: TextAlign.center,
                  ),
                  Table(
                    border: TableBorder.all(
                        width: 2.0,
                        color: Colors.blueAccent,
                        style: BorderStyle.solid),
                    children: [
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "X Asis : ",
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("${x?.toStringAsFixed(2)}",
                                //trim the asis value to 2 digit after decimal point
                                style: TextStyle(fontSize: 20.0)),
                          )
                        ],
                      ),
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Y Asis : ",
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("${y?.toStringAsFixed(2)}",
                                //trim the asis value to 2 digit after decimal point
                                style: TextStyle(fontSize: 20.0)),
                          )
                        ],
                      ),
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Z Asis : ",
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("${z?.toStringAsFixed(2)}",
                                //trim the asis value to 2 digit after decimal point
                                style: TextStyle(fontSize: 20.0)),
                          )
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        //Progress bar maison
                        //Rotate -math.pi pour retourner les container de 180°
                        !isCorrect
                            ? Container(
                                width: screenSize.width * 0.2,
                                alignment: Alignment.center,
                                child: Transform.rotate(
                                  angle: -math.pi,
                                  child: Stack(
                                    children: <Widget>[
                                      //Container de fond
                                      Container(
                                        decoration: new BoxDecoration(
                                            color: Colors.blue,
                                            //new Color.fromRGBO(255, 0, 0, 0.0),
                                            borderRadius: new BorderRadius.only(
                                                topLeft:
                                                    const Radius.circular(20.0),
                                                topRight:
                                                    const Radius.circular(20.0),
                                                bottomLeft:
                                                    const Radius.circular(20.0),
                                                bottomRight:
                                                    const Radius.circular(
                                                        20.0))),
                                        width: screenSize.width * 0.15,
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
                                            topLeft:
                                                const Radius.circular(20.0),
                                            topRight:
                                                const Radius.circular(20.0),
                                            bottomLeft:
                                                const Radius.circular(20.0),
                                            bottomRight:
                                                const Radius.circular(20.0),
                                          ),
                                        ),
                                        //40.0 pour éviter des bugs d'affichage
                                        height: double.parse(btData) < 40.0
                                            ? 40.0
                                            : double.parse(btData) > 100.0
                                                ? screenSize.height / 2 - 10
                                                //*1.7 pour remplir la progress bar à 100% lorsque le capteur renvoi 100
                                                : double.parse(btData) * 1.7,
                                        width: screenSize.width * 0.15,
                                      ),
                                      //Container d'affichage de la valeur du capteur
                                      //-math.pi = 180°
                                      Container(
                                        color: Colors.transparent,
                                        //new Color.fromRGBO(255, 0, 0, 0.0),
                                        child: Center(
                                            child: Transform.rotate(
                                                angle: -math.pi,
                                                child: AutoSizeText(
                                                  (double.parse(btData))
                                                      .toString(),
                                                  style: textStyle,
                                                ))),
                                        width: screenSize.width * 0.15,
                                        height: screenSize.height / 2,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Container(),
                        Container(
                          width: isCorrect
                              ? screenSize.width * 0.9
                              : screenSize.width * 0.7,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  isCorrect
                                      ? Column(
                                          children: <Widget>[
                                            Text(" "),
                                            bottomPicker,
                                            AutoSizeText(
                                              AppLocalizations.of(context)
                                                  .translate('haut_min'),
                                              style: textStyle,
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        )
                                      : Container(),
                                  isCorrect
                                      ? Column(
                                          children: <Widget>[
                                            AutoSizeText(
                                              AppLocalizations.of(context)
                                                  .translate('haut_max'),
                                              style: textStyle,
                                              textAlign: TextAlign.center,
                                            ),
                                            topPicker,
                                            Text(" "),
                                            Text(" "),
                                          ],
                                        )
                                      : Container(),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      user.userHeightBottom != ""
                                          ? AutoSizeText(
                                              "Hmin: ${user.userHeightBottom} | "
                                              "HMAX: ${user.userHeightTop}",
                                              style: textStyle,
                                            )
                                          : Container(),
                                      Container(
                                        width: screenSize.width * 0.3,
                                        child: RaisedButton(
                                          //child: Text("Démarrer l'enregistrement."),
                                          onPressed: !isCorrect || _start < 0.1
                                              ? () async {
                                                  if (!isPush) {
                                                    isPush = true;
                                                    colorMesureButton =
                                                        Colors.black;
                                                    const oneSec =
                                                        const Duration(
                                                            milliseconds: 100);
                                                    _timer = new Timer.periodic(
                                                      oneSec,
                                                      (Timer timer) => setState(
                                                        () {
                                                          if (_start < 0.1) {
                                                            timer.cancel();
                                                            _start = _reset;
                                                            result = double.parse(
                                                                (average.reduce((a,
                                                                                b) =>
                                                                            a +
                                                                            b) /
                                                                        average
                                                                            .length)
                                                                    .toStringAsFixed(
                                                                        2));
                                                            print(result
                                                                .toStringAsFixed(
                                                                    2));
                                                            i = 100;
                                                            if (result <=
                                                                    50.0 ||
                                                                result >=
                                                                    100.0) {
                                                              //Mesure pas bonne, réajuster la toise
                                                              setState(() {
                                                                recording = AppLocalizations.of(
                                                                        context)
                                                                    .translate(
                                                                        'status_mesure_mauvais');
                                                                colorMesureButton =
                                                                    Colors.red;
                                                                isPush = false;
                                                              });
                                                            } else {
                                                              setState(() {
                                                                colorMesureButton =
                                                                    Colors
                                                                        .green;
                                                                recording = AppLocalizations.of(
                                                                        context)
                                                                    .translate(
                                                                        'status_mesure_bon');
                                                              });
                                                              isCorrect = true;
                                                              //update poussée
                                                              updatedUser =
                                                                  User(
                                                                userId:
                                                                    user.userId,
                                                                userName: user
                                                                    .userName,
                                                                userMode: user
                                                                    .userMode,
                                                                userPic: user
                                                                    .userPic,
                                                                userHeightTop: user
                                                                    .userHeightTop,
                                                                userHeightBottom:
                                                                    user.userHeightBottom,
                                                                userInitialPush: result
                                                                    .toStringAsFixed(
                                                                        2)
                                                                    .toString(),
                                                                userMacAddress:
                                                                    user.userMacAddress,
                                                                userSerialNumber:
                                                                    user.userSerialNumber,
                                                              );

                                                              db.updateUser(
                                                                  updatedUser);

                                                              const time =
                                                                  const Duration(
                                                                      milliseconds:
                                                                          1000);
                                                              /*_timer = new Timer.periodic(
                                                      time,
                                                      (Timer timer) {
                                                        if (countdown < 1) {
                                                          timer.cancel();
                                                          if (inputMessage !=
                                                              "fromRegister")
                                                            inputMessage = "0";

                                                          Navigator.pushReplacement(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  MainTitle(
                                                                      userIn:
                                                                          updatedUser,
                                                                      appLanguage:
                                                                          appLanguage,
                                                                      messageIn:
                                                                          inputMessage),
                                                              //inputMessage == "fromRegister" ? "fromRegister" :
                                                            ),
                                                          );
                                                        } else {
                                                          setState(() {
                                                            countdown = countdown - 1;
                                                          });
                                                        }
                                                      },
                                                    );*/
                                                            }
                                                          } else {
                                                            recording = _start
                                                                .toStringAsFixed(
                                                                    1);
                                                            _start =
                                                                _start - 0.1;
                                                            i--;
                                                            getData();
                                                            average[i] =
                                                                double.parse(
                                                                    btData);
                                                            if (average[i] >
                                                                    100.0 ||
                                                                average[i] <
                                                                    50.0) {
                                                              setState(() {
                                                                colorMesureButton =
                                                                    Colors.red;
                                                                colorProgressBar =
                                                                    Colors.red;
                                                              });
                                                            } else {
                                                              setState(() {
                                                                colorMesureButton =
                                                                    Colors
                                                                        .green;
                                                                colorProgressBar =
                                                                    Colors
                                                                        .green;
                                                              });
                                                            }
                                                          }
                                                        },
                                                      ),
                                                    );
                                                    //_showDialog();
                                                  }
                                                }
                                              : null,
                                          textColor: colorMesureButton,
                                          child: AutoSizeText(
                                            recording,
                                            maxLines: 1,
                                            style: textStyle,
                                          ),
                                        ),
                                      ),
                                      inputMessage == "fromMain" ||
                                              (inputMessage == "fromRegister" &&
                                                  isCorrect)
                                          ? RaisedButton(
                                              onPressed: () {
                                                if (bottom == 0)
                                                  bottom = int.parse(
                                                      user.userHeightBottom);

                                                if (top == 1)
                                                  top = int.parse(
                                                      user.userHeightTop);

                                                if (result == null ||
                                                    (result <= 50.0 ||
                                                        result >= 100.0))
                                                  result = double.parse(
                                                      user.userInitialPush);

                                                //update poussée
                                                updatedUser = User(
                                                  userId: user.userId,
                                                  userName: user.userName,
                                                  userMode: user.userMode,
                                                  userPic: user.userPic,
                                                  userHeightTop: top.toString(),
                                                  userHeightBottom:
                                                      bottom.toString(),
                                                  userInitialPush: result
                                                      .toStringAsFixed(2)
                                                      .toString(),
                                                  userMacAddress:
                                                      user.userMacAddress,
                                                  userSerialNumber:
                                                      user.userSerialNumber,
                                                );

                                                db.updateUser(updatedUser);

                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        LoadPage(
                                                      appLanguage: appLanguage,
                                                      page: mainTitle,
                                                      user: updatedUser,
                                                      messageIn: "0",
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: AutoSizeText(
                                                backButtonText,
                                                style: textStyle,
                                              ))
                                          : Text(""),
                                    ],
                                  )
                                ],
                              ),
                              /*isCorrect
                                  ? Text(
                                      AppLocalizations.of(context)
                                              .translate('redirection') +
                                          " $countdown " +
                                          AppLocalizations.of(context)
                                              .translate('secondes'),
                                      style: textStyle,
                                    )
                                  : Text(""),*/
                            ],
                          ),
                        ),
                      ],
                    ),
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
