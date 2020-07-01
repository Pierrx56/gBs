// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
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
  String _connectDevices;
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
  RoundedProgressBarTheme colorProgressBar = RoundedProgressBarTheme.yellow;
  Timer _timer;
  double _start = 10.0;
  static double _reset = 10.0;
  int i = 20;
  List<double> average = new List(2 * _reset.toInt());
  static double delta = 102.0;
  double coefKg = 0.45359237;
  double result;
  String recording;
  String statusBT;
  String btData;
  bool isCorrect = false;

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
    _connectDevices = "Disconnected";
    btData = "0.0";
    btManage.enableBluetooth();
  }

  @override
  void dispose() {
    // Avoid memory leak and disconnect
    if (isConnected) {
/*      isDisconnecting = true;
      connection.dispose();
      connection = null;*/
    }

    super.dispose();
  }

  void connect() async {
    btManage.enableBluetooth();
    btManage.getPairedDevices("firstPush");
    btManage.connect("firstPush");
    isConnected = await btManage.getStatus();
    testConnect();
  }

  testConnect() async {
    isConnected = await btManage.getStatus();
    if (!isConnected) {
      timerConnexion = new Timer.periodic(Duration(milliseconds: 1500),
          (timerConnexion) async {
        btManage.connect("firstPush");
        print("Status: $isConnected");
        isConnected = await btManage.getStatus();
        if (isConnected) {
          timerConnexion.cancel();
        }
      });
    }
  }

  void getData() async{
    btData = await btManage.getData();
  }

  @override
  Widget build(BuildContext context) {
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

          title: Text(
              AppLocalizations.of(context).translate('premiere_poussee')),
          backgroundColor: Colors.blue,
          actions: <Widget>[
            FlatButton.icon(
              icon: Icon(
                Icons.refresh,
                color: Colors.white,
              ),
              label: Text(
                "Refresh",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              splashColor: Colors.blue,
              onPressed: () async {
                // So, that when new devices are paired
                // while the app is running, user can refresh
                // the paired devices list.
                btManage.getPairedDevices("");
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    onPressed: statusBT !=
                            AppLocalizations.of(context)
                                .translate('status_connexion_bon')
                        ? () {
                            connect();

                            Timer.periodic(const Duration(seconds: 1), (timer) {
                              if (isConnected) {
                                timer.cancel();
                                setState(() {
                                  statusBT = AppLocalizations.of(context)
                                      .translate('status_connexion_bon');
                                });
                              } else {
                                setState(() {
                                  statusBT = AppLocalizations.of(context)
                                      .translate('connection_en_cours');
                                });
                              }
                            });
                          }
                        : null,
                    child: Text(statusBT),
                  ),
                  Column(
                    children: <Widget>[
                      Text(AppLocalizations.of(context)
                          .translate('explications_mesure')),
                      RaisedButton(
                          //child: Text("Démarrer l'enregistrement."),
                          onPressed: !isCorrect ? () async {
                            colorMesureButton = Colors.black;
                            const oneSec = const Duration(milliseconds: 500);
                            _timer = new Timer.periodic(
                              oneSec,
                              (Timer timer) => setState(
                                () {
                                  if (_start < 0.5) {
                                    timer.cancel();
                                    _start = _reset;
                                    result = double.parse(
                                        (average.reduce((a, b) => a + b) /
                                                average.length)
                                            .toStringAsFixed(2));
                                    print(result.toStringAsFixed(2));
                                    i = 20;
                                    if (result <= 5.0 || result >= 10.0) {
                                      //Mesure pas bonne, réajuster la toise
                                      setState(() {
                                        recording = AppLocalizations.of(context)
                                            .translate('status_mesure_mauvais');
                                        colorMesureButton = Colors.red;
                                      });
                                    } else{
                                      setState(() {
                                        colorMesureButton = Colors.green;
                                        recording = AppLocalizations.of(context)
                                            .translate('status_mesure_bon');
                                        isCorrect = true;
                                      });
                                      //update poussée
                                      User updatedUser = User(
                                        userId: user.userId,
                                        userName: user.userName,
                                        userMode: user.userMode,
                                        userPic: user.userPic,
                                        userHeightTop: user.userHeightBottom,
                                        userHeightBottom: user.userHeightBottom,
                                        userInitialPush: result.toStringAsFixed(2).toString(),
                                        userMacAddress: user.userMacAddress,
                                      );
                                      db.updateUser(updatedUser);
                                    }
                                  } else {
                                    recording = _start.toString();
                                    _start = _start - 0.5;
                                    i--;
                                    getData();
                                    average[i] = double.parse(btData);
                                    if (average[i] > 10.0) {
                                      setState(() {
                                        colorProgressBar =
                                            RoundedProgressBarTheme.red;
                                      });
                                    } else {
                                      setState(() {
                                        colorProgressBar =
                                            RoundedProgressBarTheme.yellow;
                                      });
                                    }
                                  }
                                },
                              ),
                            );
                            //_showDialog();
                          } : null,
                          textColor: colorMesureButton,
                          child: Text(recording)),
                      RoundedProgressBar(
                          percent: (double.parse(btData)) >= 0
                              ? (double.parse(btData) * 10)
                              : 0.0,
                          theme: colorProgressBar,
                          childCenter:
                              Text((double.parse(btData) * 10).toString())),
                    ],
                  ),

                  /*
                  RaisedButton(
                    onPressed: () {
                      isRunning = true;
                      startDataReceiver();
                    },
                    child: Text("Get Data"),
                  ),
                  RaisedButton(
                    onPressed: () {
                      isRunning = false;
                      disconnect();
                    },
                    child: Text("Disconnect"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: RaisedButton(
                      child: const Text('Refresh'),
                      onPressed: () {},
                    ),
                  ),*/
                ],
              ),
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

