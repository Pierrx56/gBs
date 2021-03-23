// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/AppLocalizations.dart';
import 'package:gbsalternative/BluetoothManager.dart';
import 'package:gbsalternative/DatabaseHelper.dart';
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
  bool isTryingConnect = false;
  bool isTooHigh = false;
  bool isRunning = true;
  int bottomSelection = 0;
  int topSelection = 0;
  Timer timer;
  Timer timerConnexion;
  String macAdress;
  String data;
  User user;
  String inputMessage;
  AppLanguage appLanguage;

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
  double result = 0.0;
  String recording;
  String btData;
  bool isCorrect = false;
  bool isPush = false;
  Size screenSize;

  String backButtonText;
  DropdownButton<int> bottomPicker;
  DropdownButton<int> topPicker;
  int bottom;
  int top;

  List<int> bottomNumbers = [];
  List<int> topNumbers = [];

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
      isTryingConnect = false;
      isConnected = await btManage.getStatus();
      if (!isConnected) {
        btManage.connect(user.userMacAddress, user.userSerialNumber);
      }
      getConnectState();
    }
  }

  void getConnectState() async {
    timerConnexion =
        new Timer.periodic(Duration(milliseconds: 300), (timerConnexion) async {
      isConnected = await btManage.getStatus();
      if (!isConnected && !isTryingConnect) {
        show("Device disconnected ! Waiting for reconnexion...");
        btManage.connect(user.userMacAddress, user.userSerialNumber);
        setState(() {
          isTryingConnect = true;
        });
      } else if (isConnected && isTryingConnect) {
        setState(() {
          isTryingConnect = false;
        });
        show("Device connected !");
      }

      //Affiche le message pendant 3 secondes
      if (isTooHigh) {
        await Future.delayed(const Duration(seconds: 5), () {
          setState(() {
            isTooHigh = false;
            getData();
          });
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    btData = "0.0";
    bottom = 0;
    top = 1;

    for (int i = 0; i < 100; i++) {
      bottomNumbers.add(i);
    }
    for (int i = 1; i < 101; i++) {
      topNumbers.add(i);
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
    if (inputMessage == "fromRegister")
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Login(
                    appLanguage: appLanguage,
                    message: "",
                  )));
    else
      Navigator.pop(context);
  }

  void initializeNumberPicker() {
    bottomPicker = new DropdownButton<int>(
      items: bottomNumbers.map((int value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Container(
            width: 30.0,
            child: Text(value.toString()),
          ),
        );
      }).toList(),
      hint: Text(bottomSelection.toString()),
      onChanged: (int value) {
        bottomSelection = value;
        topNumbers = [];
        for (int i = 0; i < 100 - bottomSelection; i++) {
          topNumbers.add(bottomSelection + i + 1);
        }

        if (bottomSelection != 0 && topSelection != 1 ||
            double.parse(user.userInitialPush) == 0.0) {
          backButtonText = AppLocalizations.of(context).translate('valider');
        } else
          backButtonText = AppLocalizations.of(context).translate('retour');

        setState(() {
          if (bottomSelection > topSelection) topSelection = topNumbers[0];
        });
      },
    );
    topPicker = new DropdownButton<int>(
      items: topNumbers.map((int value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Container(
            width: 30.0,
            child: Text(value.toString()),
          ),
        );
      }).toList(),
      hint: Text(topSelection.toString()),
      onChanged: (int value) {
        topSelection = value;

        if (bottomSelection != 0 && topSelection != 1 ||
            double.parse(user.userInitialPush) == 0.0) {
          backButtonText = AppLocalizations.of(context).translate('valider');
        } else
          backButtonText = AppLocalizations.of(context).translate('retour');

        setState(() {
          if (topSelection < bottomSelection)
            bottomSelection = topSelection - 1;
        });
      },
    );
    /*topPicker = new NumberPicker.integer(
      initialValue: top,
      minValue: bottom + 1,
      maxValue: 101,
      onChanged: (topValue) => setState(() {
        top = topValue;
        if (top != 1) {
          backButtonText = AppLocalizations.of(context).translate('valider');
        } else
          backButtonText = AppLocalizations.of(context).translate('retour');
      }),
    );*/
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
          backgroundColor: backgroundColor,
          key: _scaffoldKey,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(20.0), // here the desired height
            child: AppBar(
              elevation: 0.0,
              //title: Text(AppLocalization.of(context).heyWorld),
              backgroundColor: backgroundColor,
              actions: <Widget>[
                Container(
                  width: (screenSize.width) * 0.1,
                  decoration: BoxDecoration(
                      color: splashIconColor.withAlpha(50),
                      shape: BoxShape.circle),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.keyboard_arrow_left,
                        size: 20.0, color: iconColor),
                  ),
                ),
                AutoSizeText(
                  AppLocalizations.of(context).translate('poussee_max'),
                  style: textStyleBG,
                ),
                Spacer(),
              ],
            ),
          ),
          body: SingleChildScrollView(
            child: Container(
              width: screenSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  !isCorrect
                      ? AutoSizeText(
                          AppLocalizations.of(context)
                              .translate('explications_mesure'),
                          style: textStyle,
                          textAlign: TextAlign.center,
                        )
                      : AutoSizeText(
                          AppLocalizations.of(context)
                              .translate('explications_hauteur'),
                          style: textStyle,
                          textAlign: TextAlign.center,
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
                                      AnimatedContainer(
                                        duration: Duration(milliseconds: 400),
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
                                        height: _start > 0.1
                                            ? double.parse(btData) < 40.0
                                                ? 40.0
                                                : double.parse(btData) > 100.0
                                                    ? screenSize.height / 2 - 10
                                                    //*1.7 pour remplir la progress bar à 100% lorsque le capteur renvoi 100
                                                    : double.parse(btData) * 1.7
                                            : result < 40.0
                                                ? 40.0
                                                : result * (1.7),
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
                                            //Affiche la mesure en live puis la moyenne à la fin
                                            child: _start <= 0.1
                                                ? AutoSizeText(
                                                    (result.toInt()).toString())
                                                : AutoSizeText(
                                                    (double.parse(btData)
                                                            .toInt())
                                                        .toString(),
                                                  ),
                                          ),
                                        ),
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
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  isCorrect
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Column(
                                              children: <Widget>[
                                                AutoSizeText(
                                                  AppLocalizations.of(context)
                                                      .translate('haut_min'),
                                                  style: textStyle,
                                                  textAlign: TextAlign.center,
                                                ),
                                                bottomPicker,
                                              ],
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(20.0),
                                            ),
                                            Column(
                                              children: <Widget>[
                                                AutoSizeText(
                                                  AppLocalizations.of(context)
                                                      .translate('haut_max'),
                                                  style: textStyle,
                                                  textAlign: TextAlign.center,
                                                ),
                                                topPicker,
                                              ],
                                            )
                                          ],
                                        )
                                      : Container(),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 20.0, 0, 0),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
/*                                      user.userHeightBottom != ""
                                          ? AutoSizeText(
                                              "Hmin: ${user.userHeightBottom} | "
                                              "HMAX: ${user.userHeightTop}",
                                              style: textStyle,
                                            )
                                          : Container(),*/
                                      isTooHigh
                                          ? Container(
                                              width: screenSize.width * 0.6,
                                              child: AutoSizeText(
                                                AppLocalizations.of(context)
                                                    .translate(
                                                        'status_mesure_mauvais'),
                                                textAlign: TextAlign.center,
                                                style: textStyle,
                                              ),
                                            )
                                          : Container(),
                                      Container(
                                        width: screenSize.width * 0.3,
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                            !isCorrect ? MaterialStateProperty.all<
                                                    Color>(Colors.grey[350]) : MaterialStateProperty.all<
                                                Color>(Colors.grey[600]),
                                          ),
                                          //child: Text("Démarrer l'enregistrement."),
                                          onPressed: !isTryingConnect &&
                                                  !isTooHigh &&
                                                  !isCorrect &&
                                                  !isPush
                                              ? () async {
                                                  //Initialisation du timer
                                                  _start = _reset;
                                                  if (!isPush) {
                                                    isPush = true;
                                                    const oneSec =
                                                        const Duration(
                                                            milliseconds: 100);
                                                    _timer = new Timer.periodic(
                                                      oneSec,
                                                      (Timer timer) => setState(
                                                        () {
                                                          //Si déco pendant une mesure
                                                          if (isTryingConnect) {
                                                            timer.cancel();
                                                            isPush = false;
                                                            _start = _reset;
                                                            i = 100;
                                                            setState(() {
                                                              recording = AppLocalizations
                                                                      .of(
                                                                          context)
                                                                  .translate(
                                                                      'demarrer_enregistrement');
                                                            });
                                                          } else if (_start <
                                                              0.1) {
                                                            timer.cancel();
                                                            print(average);
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
                                                                50.0) {
                                                              //Mesure pas bonne, réajuster la toise
                                                              setState(() {
                                                                recording = AppLocalizations.of(
                                                                        context)
                                                                    .translate(
                                                                        'status_mesure_mauvais');
                                                                isPush = false;
                                                              });
                                                            } else {
                                                              setState(() {
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
                                                                userNotifEvent:
                                                                    user.userNotifEvent,
                                                                userLastLogin: user
                                                                    .userLastLogin,
                                                              );

                                                              db.updateUser(
                                                                  updatedUser);

                                                              const time =
                                                                  const Duration(
                                                                      milliseconds:
                                                                          1000);
                                                            }
                                                          } else {
                                                            recording = _start
                                                                .toStringAsFixed(
                                                                    1);
                                                            _start =
                                                                _start - 0.1;
                                                            i--;
                                                            getData();
                                                            //Affiche la valeur en live
                                                            if (_start >= 0.0) {
                                                              average[i] =
                                                                  double.parse(
                                                                      btData);
                                                              //Dépasse la valeur max, réajuster la toise
                                                              if (average[i] >
                                                                  100.0) {
                                                                for (int i = 0;
                                                                    i <
                                                                        average.length -
                                                                            1;
                                                                    i++)
                                                                  average[i] =
                                                                      0;
                                                                _start = 0.0;
                                                                i = 99;
                                                                average[i] =
                                                                    double.parse(
                                                                        btData);
                                                                isPush = false;
                                                                isTooHigh =
                                                                    true;
                                                                recording = AppLocalizations.of(
                                                                        context)
                                                                    .translate(
                                                                        'demarrer_enregistrement');
                                                                timer.cancel();
                                                              } else if (average[
                                                                      i] <
                                                                  50.0) {
                                                                setState(() {
                                                                  colorProgressBar =
                                                                      Colors
                                                                          .red;
                                                                });
                                                              } else {
                                                                setState(() {
                                                                  colorProgressBar =
                                                                      Colors
                                                                          .green;
                                                                });
                                                              }
                                                            }
                                                            //Affiche la moyenne après la mesure
                                                            else {
                                                              if (result >
                                                                      100.0 ||
                                                                  result <
                                                                      50.0) {
                                                                setState(() {
                                                                  colorProgressBar =
                                                                      Colors
                                                                          .red;
                                                                });
                                                              } else {
                                                                setState(() {
                                                                  colorProgressBar =
                                                                      Colors
                                                                          .green;
                                                                });
                                                              }
                                                            }
                                                          }
                                                        },
                                                      ),
                                                    );
                                                    //_showDialog();
                                                  }
                                                }
                                              : null,
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
                                          ? ElevatedButton(
                                              style: ButtonStyle(
                                                backgroundColor:
                                                bottomSelection != 0 &&
                                                    (topSelection != 0 ||
                                                        topSelection !=
                                                            1) ||
                                                    inputMessage == "fromMain" ? MaterialStateProperty.all<
                                                            Color>(
                                                        Colors.grey[350]) : MaterialStateProperty.all<
                                                            Color>(
                                                        Colors.grey[600]),
                                              ),
                                              onPressed: bottomSelection != 0 &&
                                                          (topSelection != 0 ||
                                                              topSelection !=
                                                                  1) ||
                                                      inputMessage == "fromMain"
                                                  ? () {
                                                      if (!isCorrect)
                                                        ;
                                                      else {
                                                        if (inputMessage !=
                                                            "fromRegister") {
                                                          if (bottomSelection ==
                                                              0)
                                                            bottomSelection =
                                                                int.parse(user
                                                                    .userHeightBottom);

                                                          if (topSelection == 1)
                                                            topSelection =
                                                                int.parse(user
                                                                    .userHeightTop);
                                                        }

                                                        if (result == null ||
                                                            (result <= 50.0 ||
                                                                result >=
                                                                    100.0))
                                                          result = double.parse(
                                                              user.userInitialPush);

                                                        //update poussée
                                                        updatedUser = User(
                                                          userId: user.userId,
                                                          userName:
                                                              user.userName,
                                                          userMode:
                                                              user.userMode,
                                                          userPic: user.userPic,
                                                          userHeightTop:
                                                              topSelection
                                                                  .toString(),
                                                          userHeightBottom:
                                                              bottomSelection
                                                                  .toString(),
                                                          userInitialPush: result
                                                              .toStringAsFixed(
                                                                  2)
                                                              .toString(),
                                                          userMacAddress: user
                                                              .userMacAddress,
                                                          userSerialNumber: user
                                                              .userSerialNumber,
                                                          userNotifEvent: user
                                                              .userNotifEvent,
                                                          userLastLogin: user
                                                              .userLastLogin,
                                                        );

                                                        db.updateUser(
                                                            updatedUser);
                                                      }
                                                      if (inputMessage ==
                                                          "fromMain") {
                                                        /*
                                                        MainTitle(
                                                          appLanguage:
                                                              appLanguage,
                                                          userIn: updatedUser,
                                                          messageIn: "",
                                                        )
                                                            .createState()
                                                            .updateUser(
                                                                updatedUser);*/
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    MainTitle(
                                                              appLanguage:
                                                                  appLanguage,
                                                              userIn:
                                                                  updatedUser,
                                                              messageIn: "",
                                                            ),
                                                          ),
                                                        );
                                                      } else
                                                        Navigator
                                                            .pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    MainTitle(
                                                              appLanguage:
                                                                  appLanguage,
                                                              userIn:
                                                                  updatedUser,
                                                              messageIn:
                                                                  "fromRegister",
                                                            ),
                                                          ),
                                                        );
                                                    }
                                                  : null,
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
