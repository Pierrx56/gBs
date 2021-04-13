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
import 'package:syncfusion_flutter_gauges/gauges.dart';

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
  String explications;
  String btData;
  bool isCorrect = false;
  bool isPush = false;
  bool hasPushed = false;
  bool hasShowDialog = false;
  Size screenSize;

  String backButtonText;
  DropdownButton<int> bottomPicker;
  DropdownButton<int> topPicker;
  ElevatedButton recordButton;
  ElevatedButton backButton;
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
      explanationDialog();
    }
  }

  void getConnectState() async {
    timerConnexion =
        new Timer.periodic(Duration(milliseconds: 300), (timerConnexion) async {
      isConnected = await btManage.getStatus();
      if (!isConnected && !isTryingConnect) {
        show("Device disconnected ! Waiting for reconnexion...");
        btManage.connect(user.userMacAddress, user.userSerialNumber);
        if (mounted)
          setState(() {
            isTryingConnect = true;
          });
      } else if (isConnected && isTryingConnect) {
        if (mounted)
          setState(() {
            isTryingConnect = false;
          });
        show("Device connected !");
      }

      //Affiche le message pendant 3 secondes
      /*if (isTooHigh) {
        await Future.delayed(const Duration(seconds: 5), () {
          setState(() {
            isTooHigh = false;
            getData();
          });
        });
      }*/
    });
  }

  void explanationDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            actions: <Widget>[
              Container(
                  width: screenSize.width * 0.8,
                  height: screenSize.height * 0.7,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: AutoSizeText(
                          explications,
                          style: textStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: AutoSizeText(
                          "*Image d'explication*",
                          style: textStyle,
                        ),
                      ),
                      Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            children: [
                              Spacer(),
                              backButton,
                              Spacer(),
                              recordButton,
                              Spacer(),
                            ],
                          )),
                      //Align(alignment: Alignment.bottomLeft, child: backButton),
                    ],
                  )),
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    btData = "0.0";
    bottom = 0;
    top = 1;
    isCorrect = false;
    hasPushed = false;

    btManage.sendData("WU");
    hasShowDialog = false;

    for (int i = 0; i < 100; i++) {
      bottomNumbers.add(i);
    }
    for (int i = 1; i < 101; i++) {
      topNumbers.add(i);
    }

    connect();
  }

  @override
  void dispose() {
    // Avoid memory leak and disconnect
    timerConnexion?.cancel();
    _timer?.cancel();

    super.dispose();
  }


  void getData() async {
    btData = await btManage.getData("F");
  }

  Future<bool> _onBackPressed() {
    _timer?.cancel();
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
          recording = AppLocalizations.of(context).translate('valider');
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
          recording = AppLocalizations.of(context).translate('valider');
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

    explications =
        AppLocalizations.of(this.context).translate('explications_mesure');

    if (backButtonText == null)
      backButtonText = AppLocalizations.of(context).translate('retour');

    recordButton = ElevatedButton(
      style: ButtonStyle(
        backgroundColor: !isTryingConnect && !isCorrect && !isPush ||
                bottomSelection != 0 && topSelection != 1
            ? colorButton
            : colorPushedButton,
      ),
      onPressed: !isTryingConnect && !isCorrect && !isPush ||
              bottomSelection != 0 && topSelection != 1
          ? () async {
              Navigator.of(context).pop();
              //Initialisation du timer
              _start = _reset;
              isTooHigh = false;
              result = 60.0;
              for (int i = 0; i < average.length; i++) average[i] = 0;

              if (!isPush) {
                isPush = true;
                const oneSec = const Duration(milliseconds: 100);
                _timer = new Timer.periodic(
                  oneSec,
                  (Timer timer) => setState(
                    () {
                      getData();
                      //While user didn't push until 50, reset counter and arrays
                      if (double.parse(btData) < 50.0 && _start >= _reset) {
                        hasPushed = false;
                      } else {
                        _start -= 0.01;
                        hasPushed = true;
                      }
                      //Si déco pendant une mesure
                      if (isTryingConnect) {
                        _timer.cancel();
                        isPush = false;
                        _start = _reset;
                        isTooHigh = false;
                        i = 100;
                        setState(() {
                          recording = AppLocalizations.of(context)
                              .translate('demarrer_enregistrement');
                        });
                      } else if (_start < 0.1) {
                        _timer.cancel();
                        print(average);
                        result = double.parse(
                            (average.reduce((a, b) => a + b) / average.length)
                                .toStringAsFixed(2));
                        print(result.toStringAsFixed(2));
                        i = 100;
                        if (result <= 50.0) {
                          //Mesure pas bonne, réajuster la toise
                          setState(() {
                            /*recording = AppLocalizations
                                                          .of(context)
                                                      .translate(
                                                          'status_mesure_mauvais');*/
                            isPush = false;
                          });
                        } else {
                          setState(() {
                            /*
                                                  recording = AppLocalizations
                                                          .of(context)
                                                      .translate(
                                                          'status_mesure_bon');*/
                          });
                          isCorrect = true;
                          if (mounted)
                            setState(() {
                              recording = AppLocalizations.of(context)
                                  .translate('valider');
                            });
                          //update poussée
                          updatedUser = User(
                            userId: user.userId,
                            userName: user.userName,
                            userMode: user.userMode,
                            userPic: user.userPic,
                            userHeightTop: user.userHeightTop,
                            userHeightBottom: user.userHeightBottom,
                            userInitialPush:
                                result.toStringAsFixed(2).toString(),
                            userMacAddress: user.userMacAddress,
                            userSerialNumber: user.userSerialNumber,
                            userNotifEvent: user.userNotifEvent,
                            userLastLogin: user.userLastLogin,
                          );

                          db.updateUser(updatedUser);

                          const time = const Duration(milliseconds: 1000);
                        }
                      } else if (hasPushed) {
                        /*recording =
                                                  _start.toStringAsFixed(1);*/
                        _start = _start - 0.1;

                        getData();
                        //Affiche la valeur en live
                        if (_start >= 0.0) {
                          if (i == 100) {
                            i--;
                            btData = "50.0";
                          }
                          average[i] = double.parse(btData);
                          //Dépasse la valeur max, réajuster la toise
                          if (average[i] > 100.0) {
                            for (int i = 0; i < average.length; i++)
                              average[i] = 0;
                            _start = _reset;
                            i = 100;
                            /*
                                                  average[i] =
                                                      double.parse(btData);*/
                            isPush = false;
                            isTooHigh = true;
                            recording = AppLocalizations.of(context)
                                .translate('demarrer_enregistrement');

                            _timer.cancel();
                          } else if (average[i] < 50.0) {
                            setState(() {
                              colorProgressBar = Colors.red;
                            });
                          } else {
                            i--;
                            setState(() {
                              colorProgressBar = Colors.green;
                            });
                          }
                        }
                        //Affiche la moyenne après la mesure
                        else {
                          if (result > 100.0 || result < 50.0) {
                            setState(() {
                              colorProgressBar = Colors.red;
                            });
                          } else {
                            setState(() {
                              colorProgressBar = Colors.green;
                            });
                          }
                        }
                      }
                    },
                  ),
                );
                //_showDialog();
              } else if (isCorrect) {
                if (inputMessage != "fromRegister") {
                  if (bottomSelection == 0)
                    bottomSelection = int.parse(user.userHeightBottom);

                  if (topSelection == 1)
                    topSelection = int.parse(user.userHeightTop);
                }

                if (result == null || (result <= 50.0 || result >= 100.0))
                  result = double.parse(user.userInitialPush);

                //update poussée
                updatedUser = User(
                  userId: user.userId,
                  userName: user.userName,
                  userMode: user.userMode,
                  userPic: user.userPic,
                  userHeightTop: topSelection.toString(),
                  userHeightBottom: bottomSelection.toString(),
                  userInitialPush: result.toStringAsFixed(2).toString(),
                  userMacAddress: user.userMacAddress,
                  userSerialNumber: user.userSerialNumber,
                  userNotifEvent: user.userNotifEvent,
                  userLastLogin: user.userLastLogin,
                );

                db.updateUser(updatedUser);

                if (inputMessage == "fromMain") {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainTitle(
                        appLanguage: appLanguage,
                        userIn: updatedUser,
                        messageIn: "",
                      ),
                    ),
                  );
                } else
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainTitle(
                        appLanguage: appLanguage,
                        userIn: updatedUser,
                        messageIn: "fromRegister",
                      ),
                    ),
                  );
              }
              /**/
            }
          : null,
      child: AutoSizeText(
        recording,
        maxLines: 1,
        style: textStyle,
      ),
    );

    backButton =
        //Back button
        inputMessage == "fromMain" ||
                (inputMessage == "fromRegister" && isCorrect)
            ? ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: bottomSelection != 0 &&
                              (topSelection != 0 || topSelection != 1) ||
                          inputMessage == "fromMain"
                      ? colorButton
                      : colorPushedButton,
                ),
                onPressed: bottomSelection != 0 &&
                            (topSelection != 0 || topSelection != 1) ||
                        inputMessage == "fromMain"
                    ? () {
                        if (!isCorrect)
                          ;
                        else {
                          if (inputMessage != "fromRegister") {
                            if (bottomSelection == 0)
                              bottomSelection =
                                  int.parse(user.userHeightBottom);

                            if (topSelection == 1)
                              topSelection = int.parse(user.userHeightTop);
                          }

                          if (result == null ||
                              (result <= 50.0 || result >= 100.0))
                            result = double.parse(user.userInitialPush);

                          //update poussée
                          updatedUser = User(
                            userId: user.userId,
                            userName: user.userName,
                            userMode: user.userMode,
                            userPic: user.userPic,
                            userHeightTop: topSelection.toString(),
                            userHeightBottom: bottomSelection.toString(),
                            userInitialPush:
                                result.toStringAsFixed(2).toString(),
                            userMacAddress: user.userMacAddress,
                            userSerialNumber: user.userSerialNumber,
                            userNotifEvent: user.userNotifEvent,
                            userLastLogin: user.userLastLogin,
                          );

                          db.updateUser(updatedUser);
                        }
                        if (inputMessage == "fromMain") {
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
                              builder: (context) => MainTitle(
                                appLanguage: appLanguage,
                                userIn: updatedUser,
                                messageIn: "",
                              ),
                            ),
                          );
                        } else
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MainTitle(
                                appLanguage: appLanguage,
                                userIn: updatedUser,
                                messageIn: "fromRegister",
                              ),
                            ),
                          );
                      }
                    : null,
                child: AutoSizeText(
                  backButtonText,
                  style: textStyle,
                ))
            : Text("");

    if (result < 50 && _start < 0.1 || isTooHigh) {
      print("reset");
      explications =
          AppLocalizations.of(context).translate('status_mesure_mauvais');
      //Delay to avoid flutter error (?)
      Future.delayed(Duration.zero, () async {
        explanationDialog();
      });
      _start = 10;
    }

    return MaterialApp(
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
              height: screenSize.height * 0.9,
              padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
              child: Stack(
                children: <Widget>[
                  //Progress bar/gauge & messages
                  !isCorrect
                      ? Stack(
                          children: <Widget>[
                            //Gauge
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                height: screenSize.height * 0.9,
                                width: screenSize.width * 0.5,
                                child: SfRadialGauge(
                                  enableLoadingAnimation: true,
                                  axes: <RadialAxis>[
                                    RadialAxis(
                                      interval: 10,
                                      minimum: 40,
                                      maximum: 110,
                                      ranges: <GaugeRange>[
                                        GaugeRange(
                                            startValue: 0,
                                            endValue: 50,
                                            color: Colors.red),
                                        GaugeRange(
                                            startValue: 50,
                                            endValue: 100,
                                            color: Colors.green),
                                        GaugeRange(
                                            startValue: 100,
                                            endValue: 150,
                                            color: Colors.red)
                                      ],
                                      pointers: <GaugePointer>[
                                        NeedlePointer(
                                          value: double.parse(btData),
                                          enableAnimation: true,
                                        ),
                                        //RangePointer(value: double.parse(btData),enableAnimation: true),
                                      ],
                                      annotations: <GaugeAnnotation>[
                                        GaugeAnnotation(
                                            widget: Container(
                                                child: Text(
                                                    _start.toStringAsFixed(0),
                                                    style: TextStyle(
                                                        fontSize: 25,
                                                        fontWeight:
                                                            FontWeight.bold))),
                                            angle: 90,
                                            positionFactor: 0.5),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            /*
                            result < 50 && _start < 0.1 || isTooHigh
                                ? Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      width: screenSize.width * 0.25,
                                      child: AutoSizeText(
                                        AppLocalizations.of(context)
                                            .translate('status_mesure_mauvais'),
                                        style: textStyle,
                                      ),
                                    ),
                                  )
                                : result >= 50 && _start < 0.1
                                    ? Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          width: screenSize.width * 0.25,
                                          child: AutoSizeText(
                                            AppLocalizations.of(context)
                                                .translate('status_mesure_bon'),
                                            style: textStyle,
                                          ),
                                        ),
                                      )
                                    : Container(),
                                    */
                          ],
                        )
                      : Align(alignment: Alignment.center, child: Container()),
                  //Hauteur min/max
                  isCorrect
                      ? Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Column(
                                children: [
                                  Container(
                                    width: screenSize.width * 0.6,
                                    child: AutoSizeText(
                                      AppLocalizations.of(context)
                                          .translate('explications_hauteur'),
                                      style: textStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(5.0),
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
                                      Padding(
                                        padding: EdgeInsets.all(20.0),
                                      ),
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
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        )
                      : Container(),
                  isCorrect
                      ? Align(
                          alignment: Alignment.bottomCenter,
                          child: recordButton)
                      : Container(),
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
