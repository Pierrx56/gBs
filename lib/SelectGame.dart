// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

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

class SelectGame extends StatefulWidget {
  User user;
  String inputMessage;
  AppLanguage appLanguage;

  SelectGame({
    @required this.user,
    @required this.inputMessage,
    @required this.appLanguage,
  });

  @override
  _SelectGame createState() => new _SelectGame(user, inputMessage, appLanguage);
}

class _SelectGame extends State<SelectGame> {
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
  ScrollController _controller;

  bool visible_swim;
  bool visible_plane;
  bool visible_temp;
  Color colorCard_swim;
  Color colorCard_plane;
  Color colorCard_temp;
  List<Scores> data_swim;
  List<Scores> data_plane;
  List<Scores> data_temp;
  int level;
  Star dataStar;
  Star dataSwimmer;
  Star dataPlane;
  Star dataTemp;
  bool isEmpty;
  List<double> totalStar = [];

  Color colorMesureButton = Colors.black;

  //RoundedProgressBarTheme colorProgressBar = RoundedProgressBarTheme.yellow;
  Color colorProgressBar = Colors.red;
  Timer _timer;
  double _start = 10.0;
  int countdown = 5;
  static double _reset = 10.0;
  bool isCorrect = false;
  int numberOfCard = 3;
  Size screenSize;
  double firstPosition;
  bool hasMoved;

  //Initializing database
  DatabaseHelper db = new DatabaseHelper();

  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //Constructeur _SelectGame
  _SelectGame(User _user, String _inputMessage, AppLanguage _appLanguage) {
    user = _user;
    inputMessage = _inputMessage;
    appLanguage = _appLanguage;
  }

  @override
  void initState() {
    visible_swim = true;
    visible_plane = true;
    visible_temp = true;
    isEmpty = true;
    colorCard_swim = Colors.white;
    colorCard_plane = Colors.white;
    colorCard_temp = Colors.white;
    _controller = ScrollController();
    firstPosition = 0.0;
    hasMoved = false;
    level = 1;
    totalStar = [];

    super.initState();
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

  Future<Star> getStar(int idGame, int level) async {
    if (idGame == ID_SWIMMER_ACTIVITY)
      return dataSwimmer = await db.getStar(user.userId, idGame, level);
    else if (idGame == ID_PLANE_ACTIVITY)
      return dataPlane = await db.getStar(user.userId, idGame, level);
    else if (idGame == ID_TEMP_ACTIVITY)
      return dataTemp = await db.getStar(user.userId, idGame, level);
  }

  //Retourne un widget de 5 etoiles en lignes
  Widget numberOfStars(int idGame, int level) {
    return FutureBuilder(
        future: getStar(idGame, level),
        builder: (context, AsyncSnapshot<Star> snapshot) {
          List<Widget> starArray = List<Widget>();
          if (!snapshot.hasData) {
            for (int i = 0; i < 5; i++)
              starArray.add(Icon(Icons.star_border));
            return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: starArray);
          }
          else {
            getStar(idGame, level);
            double stars = snapshot.data.starValue;

            for (int i = 0; i < 5; i++) {
              if (stars - 1.0 >= 0.0) {
                starArray.add(Icon(Icons.star));
                stars -= 1.0;
              } else if (stars - 0.5 >= 0.0) {
                starArray.add(Icon(Icons.star_half));
                stars -= 0.5;
              } else if (stars - 0.5 < 0.0) {
                starArray.add(Icon(Icons.star_border));
              }
            }
            return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: starArray);
          }
        });
  }

  Widget swimmerGame(int _level) {
    var temp = AppLocalizations.of(context);
    return SizedBox(
      width: widthCard = screenSize.width / (numberOfCard / 1),
      height: heightCard = screenSize.height / (numberOfCard / 1.3),
      child: new GestureDetector(
        onTap: () async {
          data_swim = await db.getScore(user.userId, ID_SWIMMER_ACTIVITY);

          if (data_swim.length > 0) {
            lauchGame(ID_SWIMMER_ACTIVITY);
          } else {
            launcherDialog(ID_SWIMMER_ACTIVITY);
          }
        },
        child: new Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 8,
          color: colorCard_swim,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Stack(
                children: <Widget>[
                  AnimatedOpacity(
                    duration: Duration(milliseconds: 1000),
                    opacity: visible_swim ? 1.0 : 1.0,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: <Widget>[
                        Container(
                          width: widthCard,
                          height: heightCard - 20,
                          child: Column(
                            children: <Widget>[
                              Image.asset(
                                'assets/swim.png',
                                width: widthCard * 0.5,
                                height: heightCard * 0.5,
                              ),
                              numberOfStars(ID_SWIMMER_ACTIVITY, 100 + _level * 10 + ID_SWIMMER_ACTIVITY),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (mounted)
                              setState(() {
                                launcherDialog(ID_SWIMMER_ACTIVITY);
                              });
                          },
                          child: Container(
                            width: widthCard,
                            height: heightCard * 0.25,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.info_outline,
                                  size: 30.0,
                                ),
                                temp != null
                                    ? AutoSizeText(
                                        AppLocalizations.of(context)
                                            .translate('nageur'),
                                        minFontSize: 20,
                                        maxFontSize: 35,
                                        style: TextStyle(
                                          fontSize: 50,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : AutoSizeText(
                                        "Check Language file (en/fr.json)"),
                              ],
                            ),
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

  Widget planeGame(int _level) {
    var temp = AppLocalizations.of(context);
    return SizedBox(
      width: widthCard = screenSize.width / (numberOfCard / 1),
      height: heightCard = screenSize.height / (numberOfCard / 1.3),
      child: new GestureDetector(
        onTap: () async {
          data_plane = await db.getScore(user.userId, ID_PLANE_ACTIVITY);

          if (data_plane.length > 0) {
            lauchGame(ID_PLANE_ACTIVITY);
          } else {
            launcherDialog(ID_PLANE_ACTIVITY);
          }
        },
        child: new Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 8,
          color: colorCard_plane,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Stack(
                children: <Widget>[
                  AnimatedOpacity(
                    duration: Duration(milliseconds: 1000),
                    opacity: !visible_plane ? 1.0 : 1.0,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: <Widget>[
                        Container(
                          width: widthCard,
                          height: heightCard - 20,
                          child: Column(
                            children: <Widget>[
                              Image.asset(
                                'assets/plane.png',
                                width: widthCard * 0.7,
                                height: heightCard * 0.5,
                              ),
                              numberOfStars(ID_PLANE_ACTIVITY, 100 + _level * 10 + ID_PLANE_ACTIVITY),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (mounted)
                              setState(() {
                                launcherDialog(ID_PLANE_ACTIVITY);
                              });
                          },
                          child: Container(
                            width: widthCard,
                            height: heightCard * 0.25,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.info_outline,
                                  size: 30.0,
                                ),
                                temp != null
                                    ? AutoSizeText(
                                        AppLocalizations.of(context)
                                            .translate('avion'),
                                        minFontSize: 20,
                                        maxFontSize: 35,
                                        style: TextStyle(
                                          fontSize: 50,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : AutoSizeText(
                                        "Check Language file (en/fr.json)"),
                              ],
                            ),
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

  Widget tempGame(int _level) {
    var temp = AppLocalizations.of(context);
    return SizedBox(
      width: widthCard = screenSize.width / (numberOfCard / 1),
      height: heightCard = screenSize.height / (numberOfCard / 1.3),
      child: new GestureDetector(
        onTap: () async {
          if (visible_temp) {
            data_temp = await db.getScore(user.userId, ID_TEMP_ACTIVITY);

            if (data_temp.length > 0) {
              lauchGame(ID_TEMP_ACTIVITY);
            } else {
              launcherDialog(ID_TEMP_ACTIVITY);
            }
          }
        },
        child: new Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 8,
          color: colorCard_temp,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Stack(
                children: <Widget>[
                  AnimatedOpacity(
                    duration: Duration(milliseconds: 1000),
                    opacity: visible_temp ? 1.0 : 0.0,
                    child: visible_temp
                        ? Stack(
                            alignment: Alignment.bottomCenter,
                            children: <Widget>[
                              Container(
                                width: widthCard,
                                height: heightCard - 20,
                                child: Column(
                                  children: <Widget>[
                                    Image.asset(
                                      'assets/temp.png',
                                      width: widthCard * 0.7,
                                      height: heightCard * 0.5,
                                    ),
                                    numberOfStars(ID_TEMP_ACTIVITY, 100 + _level * 10 + ID_TEMP_ACTIVITY),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (mounted)
                                    setState(() {
                                      launcherDialog(ID_TEMP_ACTIVITY);
                                    });
                                },
                                child: Container(
                                  width: widthCard,
                                  height: heightCard * 0.25,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.info_outline,
                                        size: 30.0,
                                      ),
                                      AutoSizeText(
                                        AppLocalizations.of(context)
                                            .translate('temp'),
                                        minFontSize: 20,
                                        maxFontSize: 35,
                                        style: TextStyle(
                                          fontSize: 50,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              /*Container(
                                alignment: Alignment.bottomCenter,
                                width: widthCard,
                                child: FlatButton.icon(
                                  label: temp != null
                                      ? AutoSizeText(
                                          AppLocalizations.of(context)
                                              .translate('temp'),
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                          minFontSize: 20,
                                        )
                                      : AutoSizeText(
                                          "Check Language file (en/fr.json)"),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  icon: Icon(
                                    Icons.info_outline,
                                    color: Colors.black,
                                  ),
                                  splashColor: Colors.blue,
                                  onPressed: () {
                                    if (mounted)
                                      setState(
                                        () {
                                          launcherDialog(ID_TEMP_ACTIVITY);
                                          */ /*visible_plane = !visible_plane;
                                          !visible_plane
                                              ? colorCard_plane = Colors.white70
                                              : colorCard_plane = Colors.white;*/ /*
                                        },
                                      );
                                  },
                                ),
                              ),*/
                            ],
                          )
                        : Container(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void launcherDialog(int idGame) async {
    //appLanguage = AppLanguage();
    //await appLanguage.fetchLocale();

    showDialog(
      context: this.context,
      builder: (BuildContext context) {
        var temp = AppLocalizations.of(this.context);
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Builder(builder: (context) {
                return Container(
                  width: screenSize.width * 0.8,
                  height: screenSize.height * 0.9,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SingleChildScrollView(
                        child: Container(
                          width: screenSize.width * 0.7,
                          height: screenSize.height * 0.8,
                          child: Column(
                            children: <Widget>[
                              AutoSizeText(
                                temp != null
                                    ? idGame == ID_PLANE_ACTIVITY
                                        ? AppLocalizations.of(this.context)
                                            .translate('avion')
                                        : idGame == ID_SWIMMER_ACTIVITY
                                            ? AppLocalizations.of(this.context)
                                                .translate('nageur')
                                            : idGame == ID_TEMP_ACTIVITY
                                                ? AppLocalizations.of(
                                                        this.context)
                                                    .translate('temp')
                                                : "non renseigné dans SelectGame"
                                    : "Check Language file (en/fr.json)",
                                style: textStyle,
                              ),
                              AutoSizeText(
                                temp != null
                                    ? idGame == ID_PLANE_ACTIVITY
                                        ? AppLocalizations.of(this.context)
                                                .translate('type_activite') +
                                            " " +
                                            AppLocalizations.of(this.context)
                                                .translate('type_activite_EI') +
                                            "\n\n" +
                                            //On adapte le texte au mode choisi
                                            //Si sportif, on remplace XX par 3 (nb de minutes)
                                            //Sinon par 2
                                            AppLocalizations.of(this.context)
                                                .translate('info_avion')
                                                .replaceAll(
                                                    "XX",
                                                    user.userMode == AppLocalizations.of(this.context).translate('sportif')
                                                        ? "3"
                                                        : "2")
                                        : idGame == ID_SWIMMER_ACTIVITY
                                            ? AppLocalizations.of(this.context).translate('type_activite') +
                                                " " +
                                                AppLocalizations.of(this.context)
                                                    .translate(
                                                        'type_activite_EE') +
                                                "\n\n" +
                                                AppLocalizations.of(this.context)
                                                    .translate('info_nageur')
                                            : idGame == ID_TEMP_ACTIVITY
                                                ? AppLocalizations.of(this.context).translate('type_activite') +
                                                    " " +
                                                    AppLocalizations.of(this.context)
                                                        .translate(
                                                            'type_activite_CMV') +
                                                    "\n\n" +
                                                    AppLocalizations.of(this.context)
                                                        .translate('info_temp')
                                                : "non renseigné dans SelectGame"
                                    : "Check Language file (en/fr.json)",
                                style: textStyle,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  RaisedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: AutoSizeText(
                                      temp != null
                                          ? AppLocalizations.of(this.context)
                                              .translate('retour')
                                          : "Check Language file (en/fr.json)",
                                      style: textStyle,
                                    ),
                                  ),
                                  Spacer(),
                                  /*
                                  RaisedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: AutoSizeText(
                                      temp != null
                                          ? AppLocalizations.of(this.context)
                                              .translate('statistiques')
                                          : "Check Language file (en/fr.json)",
                                      style: textStyle,
                                    ),
                                  ),
                                  Spacer(),*/
                                  RaisedButton(
                                    onPressed: () {
                                      //Disparition de lu popup
                                      Navigator.pop(context);
                                      lauchGame(idGame);
                                    },
                                    child: AutoSizeText(
                                      temp != null
                                          ? AppLocalizations.of(this.context)
                                              .translate('lancer_jeu')
                                          : "Check Language file (en/fr.json)",
                                      style: textStyle,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            );
          },
        );
      },
    );
  }

  Widget backCard() {
    var temp = AppLocalizations.of(context);
    return SizedBox(
      width: widthCard = screenSize.width / (numberOfCard / 1.2),
      height: heightCard = (screenSize.width / (numberOfCard) / 2),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
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

  void lauchGame(int idGame) {
    switch (idGame) {
      case ID_SWIMMER_ACTIVITY:
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoadPage(
                appLanguage: appLanguage,
                page: swimmer,
                user: user,
                messageIn: "${100 + level*10 + ID_SWIMMER_ACTIVITY}",
              ),
            ),
          );
        }
        break;
      case ID_PLANE_ACTIVITY:
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoadPage(
                appLanguage: appLanguage,
                page: plane,
                user: user,
                messageIn: "${100 + level*10 + ID_PLANE_ACTIVITY}",
              ),
            ),
          );
        }
        break;
      case ID_TEMP_ACTIVITY:
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoadPage(
                appLanguage: appLanguage,
                page: temp,
                user: user,
                messageIn: "${100 + level*10 + ID_PLANE_ACTIVITY}",
              ),
            ),
          );
        }
        break;
      default:
        {
          //statements;
        }
        break;
    }
  }

  //DEBUT Système de navigation en 3 par 3
  _moveLeft() {
    _controller.animateTo(_controller.offset - screenSize.width,
        curve: Curves.linear, duration: Duration(milliseconds: 500));
  }

  _moveRight() {
    _controller.animateTo(_controller.offset + screenSize.width,
        curve: Curves.linear, duration: Duration(milliseconds: 500));
  }

  _onUpdateScroll(ScrollMetrics metrics) {
    //right to left
    if (firstPosition < _controller.offset - screenSize.width) {
      if (_controller.offset - screenSize.width < 0.0 && !hasMoved) {
        _moveRight();
        level++;
        hasMoved = true;
      }
    }
    //left to right
    else if (firstPosition > _controller.offset - screenSize.width) {
      if (_controller.offset - screenSize.width > -screenSize.width &&
          !hasMoved) {
        _moveLeft();
        level--;
        hasMoved = true;
      }
    }
    setState(() {});
  }
  //FIN Système de navigation en 3 par 3

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

          //title: Text(AppLocalizations.of(context).translate('activites')),
          backgroundColor: Colors.blue,

          flexibleSpace: Container(
            height: screenSize.height,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10),
                ),
                Container(
                    width: (screenSize.width) / 4,
                    child: Text(
                      AppLocalizations.of(context).translate('activites'),
                      style: appBarStyle,
                      textAlign: TextAlign.left,
                    )),
                /*Container(
                  width: 30,
                  child: RaisedButton(
                    onPressed: () async {
                      //db.addStar(Star(starId: null, activityId: ID_SWIMMER_ACTIVITY, userId: user.userId, starLevel: 100 + level * 10 + ID_SWIMMER_ACTIVITY, starValue: 3.5));

                      //db.deleteScore(user.userId);
                      //db.deleteStar(user.userId);

                      //Star dataStar = await db.getStar(user.userId, ID_PLANE_ACTIVITY, 100 + level * 10 + ID_PLANE_ACTIVITY);
                      Star dataStar = await db.getStar(user.userId, ID_SWIMMER_ACTIVITY, 100 + level * 10 + ID_SWIMMER_ACTIVITY);

                      print(dataStar.starValue);
                    },
                    child: Text("Add Stars"),
                  ),
                ),*/
                Spacer(),
                Text(
                  "Hmin: " +
                      user.userHeightBottom +
                      " | Hmax:  " +
                      user.userHeightTop,
                  textAlign: TextAlign.center,
                  style: appBarStyle,
                ),
                Spacer(),
                Container(
                  width: (screenSize.width) / 4,
                  child: Text(
                    "Level 1." + level.toString(),
                    style: appBarStyle,
                    textAlign: TextAlign.right,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                ),
              ],
            ),
          ),
          actions: <Widget>[],
        ),
        body: Container(
          height: screenSize.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              //Première ligne
              NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  if (scrollNotification is ScrollStartNotification) {
                    firstPosition = 0.0;
                  } else if (scrollNotification is ScrollUpdateNotification) {
                    if (firstPosition == 0.0)
                      firstPosition = _controller.offset - screenSize.width;

                    _onUpdateScroll(scrollNotification.metrics);
                  } else if (scrollNotification is ScrollEndNotification) {
                    firstPosition = 0.0;
                    hasMoved = false;
                  }
                  return;
                },
                child: AbsorbPointer(
                  absorbing: hasMoved,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _controller,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        //Level 1.1
                        swimmerGame(1),
                        planeGame(1),
                        tempGame(1),
                        //Level 1.2
                        swimmerGame(2),
                        planeGame(2),
                        tempGame(2),
                      ],
                    ),
                  ),
                ),
              ),
              //Deuxième ligne
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  //swimmerGame(),
                  GestureDetector(
                    onTap: () {
                      if (level > 1) _moveLeft();
                      print("gauche");
                    },
                    child: Container(
                      width: screenSize.width / numberOfCard / 1.2,
                      height: screenSize.height / numberOfCard,
                      child: Icon(
                        Icons.keyboard_arrow_left,
                        size: 100,
                        color: level == 1 ? Colors.grey : Colors.black,
                      ),
                    ),
                  ),
                  backCard(),
                  GestureDetector(
                    onTap: () {
                      if (level < 2) _moveRight();
                      print("droite");
                    },
                    child: Container(
                      width: screenSize.width / numberOfCard / 1.2,
                      height: screenSize.height / numberOfCard,
                      child: Icon(
                        Icons.keyboard_arrow_right,
                        size: 100,
                        color: level == 2 ? Colors.grey : Colors.black,
                      ),
                    ),
                  ),
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
