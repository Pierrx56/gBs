// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:gbsalternative/DrawCharts.dart';
import 'package:gbsalternative/LoadPage.dart';
import 'package:gbsalternative/MainTitle.dart';
import 'package:gbsalternative/Login.dart';

/*
* Classe pour gère la sélection de jeux à lancer
* Prend en paramètre un utilisateur, un message et la langue choisie
* */

class SelectStatistic extends StatefulWidget {
  User user;
  String inputMessage;
  AppLanguage appLanguage;

  SelectStatistic({
    @required this.user,
    @required this.inputMessage,
    @required this.appLanguage,
  });

  @override
  _SelectStatistic createState() =>
      new _SelectStatistic(user, inputMessage, appLanguage);
}

class _SelectStatistic extends State<SelectStatistic> {
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
  double widthCard, heightCard;
  List<Scores> dataSwim;
  List<Scores> dataPlane;
  List<Scores> dataTemp;

  Color colorMesureButton = Colors.black;

  //RoundedProgressBarTheme colorProgressBar = RoundedProgressBarTheme.yellow;
  Color colorProgressBar = Colors.red;
  Timer _timer;
  double _start = 10.0;
  int countdown = 5;
  static double _reset = 10.0;
  bool isCorrect = false;
  int numberOfCard = 6;
  Size screenSize;
  String game = "";

  //Initializing database
  DatabaseHelper db = new DatabaseHelper();

  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //Constructeur _SelectStatistic
  _SelectStatistic(User _user, String _inputMessage, AppLanguage _appLanguage) {
    user = _user;
    inputMessage = _inputMessage;
    appLanguage = _appLanguage;
  }

  @override
  void initState() {
    getScores(user.userId, ID_SWIMMER_ACTIVITY);
    getScores(user.userId, ID_PLANE_ACTIVITY);
    super.initState();
  }

  @override
  void dispose() {
    // Avoid memory leak
    super.dispose();
  }

  void getScores(int userId, int activityId) async {
    //Nageur
    if (activityId == ID_SWIMMER_ACTIVITY) {
      dataSwim = await db.getScore(userId, activityId);
      if (dataSwim == null) {
        getScores(userId, activityId);
      }
    }
    //Plane
    else if (activityId == ID_PLANE_ACTIVITY) {
      dataPlane = await db.getScore(userId, activityId);
      if (dataPlane == null) {
        getScores(userId, activityId);
      }
    }
    //Temp
    else if (activityId == ID_TEMP_ACTIVITY) {
      dataTemp = await db.getScore(userId, activityId);
      if (dataTemp == null) {
        getScores(userId, activityId);
      }
    }
    //Refresh la page pour afficher les charts
    if (mounted) setState(() {});
  }

/*  Widget swimStat() {
    var temp = AppLocalizations.of(context);
    return SizedBox(
      width: widthCard = screenSize.width / (numberOfCard / 2),
      height: screenSize.width / numberOfCard,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 8,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              temp != null
                  ? Text(
                      AppLocalizations.of(context).translate('stat_nageur'),
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )
                  : Text("Check Language file (en/fr.json)"),
              dataSwim == null
                  ? Container()
                  : Container(
                      child: DrawCharts(data: dataSwim),
                      height: heightCard,
                    ),
              Padding(
                padding: EdgeInsets.all(10),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: RaisedButton(
                  child: temp != null
                      ? Text(
                          AppLocalizations.of(context).translate('details'),
                        )
                      : Text("Check Language file (en/fr.json)"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoadPage(
                          appLanguage: appLanguage,
                          page: detailsCharts,
                          user: user,
                          messageIn: "$ID_SWIMMER_ACTIVITY",
                          scores: dataSwim,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }*/

  Widget swimStat() {
    var temp = AppLocalizations.of(context);
    return SizedBox(
      width: widthCard = screenSize.width / (numberOfCard / 2),
      height: heightCard = screenSize.height / (numberOfCard / 2.5),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 8,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              temp != null
                  ? AutoSizeText(
                      AppLocalizations.of(context).translate('stat_nageur'),
                      maxLines: 1,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )
                  : Text("Check Language file (en/fr.json)"),
              dataSwim == null
                  ? Container()
                  : Container(
                      child: DrawCharts(data: dataSwim),
                      height: heightCard,
                    ),
              Padding(
                padding: EdgeInsets.all(10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget planeStat() {
    var temp = AppLocalizations.of(context);
    return SizedBox(
      width: widthCard = screenSize.width / (numberOfCard / 2),
      height: heightCard = screenSize.height / (numberOfCard / 2.5),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 8,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              temp != null
                  ? AutoSizeText(
                      AppLocalizations.of(context).translate('stat_avion'),
                      maxLines: 1,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )
                  : Text("Check Language file (en/fr.json)"),
              dataPlane == null
                  ? Container()
                  : Container(
                      child: DrawCharts(data: dataPlane),
                      height: heightCard,
                    ),
              Padding(
                padding: EdgeInsets.all(10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget tempStat() {
    var temp = AppLocalizations.of(context);
    return SizedBox(
      width: widthCard = screenSize.width / (numberOfCard / 2),
      height: heightCard = screenSize.height / (numberOfCard / 2.5),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 8,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              temp != null
                  ? AutoSizeText(
                      AppLocalizations.of(context).translate('statistiques') +
                          AppLocalizations.of(context).translate('temp'),
                      maxLines: 1,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )
                  : Text("Check Language file (en/fr.json)"),
              dataTemp == null
                  ? Container()
                  : Container(
                      child: DrawCharts(data: dataTemp),
                      height: heightCard,
                    ),
              Padding(
                padding: EdgeInsets.all(10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget backCard() {
    var temp = AppLocalizations.of(context);
    return SizedBox(
      width: widthCard = screenSize.width / (numberOfCard / 2),
      height: heightCard = (screenSize.width / numberOfCard),
      child: GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoadPage(
                user: user,
                appLanguage: appLanguage,
                messageIn: "0",
                page: mainTitle,
              ),
            ),
          );
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 8,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Icon(
                  Icons.exit_to_app,
                  size: heightCard / 2,
                ),
                temp != null
                    ? Text(
                        AppLocalizations.of(context).translate('retour'),
                        style: textStyle,
                      )
                    : Text("Check Language file (en/fr.json)"),
                Container()
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var temp = AppLocalizations.of(context);
    screenSize = MediaQuery.of(context).size;
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

          title: Text(AppLocalizations.of(context).translate('statistiques')),
          backgroundColor: Colors.blue,
          actions: <Widget>[],
        ),
        body: Container(
          height: screenSize.height,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        swimStat(),
                        Container(
                          width: screenSize.width / numberOfCard,
                          height: screenSize.width / numberOfCard,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoadPage(
                                    appLanguage: appLanguage,
                                    page: detailsCharts,
                                    user: user,
                                    messageIn: "$ID_SWIMMER_ACTIVITY",
                                    scores: dataSwim,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Stack(
                      children: <Widget>[
                        planeStat(),
                        Container(
                          width: screenSize.width / numberOfCard,
                          height: screenSize.width / numberOfCard,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoadPage(
                                    appLanguage: appLanguage,
                                    page: detailsCharts,
                                    user: user,
                                    messageIn: "$ID_PLANE_ACTIVITY",
                                    scores: dataPlane,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Stack(
                      children: <Widget>[
                        tempStat(),
                        Container(
                          width: screenSize.width / numberOfCard,
                          height: screenSize.width / numberOfCard,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoadPage(
                                    appLanguage: appLanguage,
                                    page: detailsCharts,
                                    user: user,
                                    messageIn: "$ID_TEMP_ACTIVITY",
                                    scores: dataTemp,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    //swimmerGame(),
                    backCard(),
                  ],
                ),
              ],
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
