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

  bool visible_swim;
  bool visible_plane;
  Color colorCard_swim;
  Color colorCard_plane;
  List<Scores> data_swim;
  List<Scores> data_plane;

  Color colorMesureButton = Colors.black;

  //RoundedProgressBarTheme colorProgressBar = RoundedProgressBarTheme.yellow;
  Color colorProgressBar = Colors.red;
  Timer _timer;
  double _start = 10.0;
  int countdown = 5;
  static double _reset = 10.0;
  bool isCorrect = false;
  int numberOfCard = 4;
  Size screenSize;
  String game = "";

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
    colorCard_swim = Colors.white;
    colorCard_plane = Colors.white;
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

  Widget swimmerGame() {
    var temp = AppLocalizations.of(context);
    return SizedBox(
      width: widthCard = screenSize.width / (numberOfCard / 2),
      height: heightCard = screenSize.width / numberOfCard,
      child: new GestureDetector(
        onTap: () async {
          if (visible_swim) {
            game = "swimmer";

            data_swim = await db.getScore(user.userId, ID_SWIMMER_ACTIVITY);

            if (data_swim.length > 0) {
              lauchGame();
            } else {
              //TODO si 1 valeur dans bdd, ne plus afficher l'aide
              launcherDialog();
            }
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
                    opacity: !visible_swim ? 1.0 : 0.0,
                    child: !visible_swim
                        ? Column(
                            children: <Widget>[
                              Align(
                                alignment: Alignment.topCenter,
                                child: temp != null
                                    ? Text(
                                        AppLocalizations.of(context)
                                                .translate('type_activite') +
                                            " " +
                                            AppLocalizations.of(context)
                                                .translate(
                                                    'type_activite_CMV') +
                                            "\n\n" +
                                            AppLocalizations.of(context)
                                                .translate('info_nageur'),
                                      )
                                    : Text("Check Language file (en/fr.json)"),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: RaisedButton(
                                  child: temp != null
                                      ? Text(
                                          AppLocalizations.of(context)
                                              .translate('retour'),
                                        )
                                      : Text(
                                          "Check Language file (en/fr.json)"),
                                  onPressed: () {
                                    if (mounted)
                                      setState(() {
                                        visible_swim = !visible_swim;
                                        !visible_swim
                                            ? colorCard_swim = Colors.white70
                                            : colorCard_swim = Colors.white;
                                      });
                                  },
                                ),
                              ),
                            ],
                          )
                        : Container(),
                  ),
                  AnimatedOpacity(
                      duration: Duration(milliseconds: 1000),
                      opacity: visible_swim ? 1.0 : 0.0,
                      child: visible_swim
                          ? Column(
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.topCenter,
                                  child: Image.asset(
                                    'assets/swim.png',
                                    width: widthCard * 0.6,
                                    height: heightCard * 0.6,
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.bottomCenter,
                                  child: FlatButton.icon(
                                    label: temp != null
                                        ? Text(
                                            AppLocalizations.of(context)
                                                .translate('nageur'),
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 24,
                                            ),
                                          )
                                        : Text(
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
                                        setState(() {
                                          visible_swim = !visible_swim;
                                          !visible_swim
                                              ? colorCard_swim = Colors.white70
                                              : colorCard_swim = Colors.white;
                                        });
                                    },
                                  ),
                                ),
                              ],
                            )
                          : Container()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget planeGame() {
    var temp = AppLocalizations.of(context);
    return SizedBox(
      width: widthCard = screenSize.width / (numberOfCard / 2),
      height: heightCard = screenSize.width / numberOfCard,
      child: new GestureDetector(
        onTap: () async {
          if(visible_plane) {
            game = "plane";

            data_plane = await db.getScore(user.userId, ID_PLANE_ACTIVITY);

            print(data_plane.length);

            if (data_plane.length > 0) {
              lauchGame();
            } else {
              launcherDialog();
            }
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
                    opacity: !visible_plane ? 1.0 : 0.0,
                    child: !visible_plane
                        ? Column(
                            children: <Widget>[
                              Align(
                                alignment: Alignment.topCenter,
                                child: temp != null
                                    ? Text(
                                        AppLocalizations.of(context)
                                                .translate('type_activite') +
                                            " " +
                                            AppLocalizations.of(context)
                                                .translate(
                                                    'type_activite_CSI') +
                                            "\n\n" +
                                            AppLocalizations.of(context)
                                                .translate('info_avion'),
                                      )
                                    : Text("Check Language file (en/fr.json)"),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: RaisedButton(
                                  child: temp != null
                                      ? Text(
                                          AppLocalizations.of(context)
                                              .translate('retour'),
                                        )
                                      : Text(
                                          "Check Language file (en/fr.json)"),
                                  onPressed: () {
                                    if (mounted)
                                      setState(() {
                                        visible_plane = !visible_plane;
                                        !visible_plane
                                            ? colorCard_plane = Colors.white70
                                            : colorCard_plane = Colors.white;
                                      });
                                  },
                                ),
                              ),
                            ],
                          )
                        : Container(),
                  ),
                  AnimatedOpacity(
                    duration: Duration(milliseconds: 1000),
                    opacity: visible_plane ? 1.0 : 0.0,
                    child: visible_plane
                        ? Column(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.topCenter,
                                child: Image.asset(
                                  'assets/plane.png',
                                  width: widthCard * 0.6,
                                  height: heightCard * 0.6,
                                ),
                              ),
                              Container(
                                alignment: Alignment.bottomCenter,
                                child: FlatButton.icon(
                                  label: temp != null
                                      ? Text(
                                          AppLocalizations.of(context)
                                              .translate('avion'),
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 24,
                                          ),
                                        )
                                      : Text(
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
                                          visible_plane = !visible_plane;
                                          !visible_plane
                                              ? colorCard_plane = Colors.white70
                                              : colorCard_plane = Colors.white;
                                        },
                                      );
                                  },
                                ),
                              ),
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

  void launcherDialog() async {
    //appLanguage = AppLanguage();
    //await appLanguage.fetchLocale();

    showDialog(
        context: this.context,
        builder: (BuildContext context) {
          var temp = AppLocalizations.of(this.context);
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text(
                temp != null
                    ? game == "plane"
                        ? AppLocalizations.of(this.context).translate('avion')
                        : game == "swimmer"
                            ? AppLocalizations.of(this.context)
                                .translate('nageur')
                            : "non renseigné dans SelectGame"
                    : "Check Language file (en/fr.json)",
                style: textStyle,
              ),
              content: Row(
                children: <Widget>[
                  SingleChildScrollView(
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          AutoSizeText(
                            temp != null
                                ? game == "plane"
                                    ? AppLocalizations.of(this.context)
                                            .translate('type_activite') +
                                        " " +
                                        AppLocalizations.of(this.context)
                                            .translate('type_activite_CSI') +
                                        "\n\n" +
                                        AppLocalizations.of(this.context)
                                            .translate('info_avion')
                                    : game == "swimmer"
                                        ? AppLocalizations.of(this.context)
                                                .translate('type_activite') +
                                            " " +
                                            AppLocalizations.of(this.context)
                                                .translate(
                                                    'type_activite_CMV') +
                                            "\n\n" +
                                            AppLocalizations.of(this.context)
                                                .translate('info_nageur')
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
                              Spacer(),
                              RaisedButton(
                                onPressed: () {
                                  //Disparition de lu popup
                                  Navigator.pop(context);
                                  lauchGame();
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
                      width: screenSize.width * 0.8,
                      height: screenSize.height * 0.9,
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }

  Widget backCard() {
    var temp = AppLocalizations.of(context);
    return SizedBox(
      width: widthCard = screenSize.width / (numberOfCard / 2),
      height: heightCard = (screenSize.width / numberOfCard) / 2,
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


  void lauchGame() {
    switch (game) {
      case "swimmer":
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoadPage(
                appLanguage: appLanguage,
                page: swimmer,
                user: user,
                messageIn: "0",
              ),
            ),
          );
        }
        break;
      case "plane":
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoadPage(
                appLanguage: appLanguage,
                page: plane,
                user: user,
                messageIn: "0",
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

          title: Text(AppLocalizations.of(context).translate('jeux')),
          backgroundColor: Colors.blue,
          actions: <Widget>[],
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  swimmerGame(),
                  planeGame(),
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
