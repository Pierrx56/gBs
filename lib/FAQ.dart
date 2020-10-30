// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/AppLocalizations.dart';
import 'package:gbsalternative/DatabaseHelper.dart';
import 'package:gbsalternative/LoadPage.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class Questions {
  final Icon icon;
  final String question;
  final Container answer;

  Questions({this.icon, this.question, this.answer});
}

/*
* Classe pour gérer la FAQ
* Prend en paramètre la langue choisie et un message éventuel
* */

class FAQ extends StatefulWidget {
  String inputMessage;
  AppLanguage appLanguage;
  User user;

  FAQ({
    @required this.user,
    @required this.inputMessage,
    @required this.appLanguage,
  });

  @override
  _FAQ createState() => new _FAQ(user, inputMessage, appLanguage);
}

class _FAQ extends State<FAQ> {
  //Déclaration de variables
  String inputMessage;
  AppLanguage appLanguage;
  User user;

  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final gnrbWebsite = "https://www.genourob.com/";

  //Constructeur _BluetoothManager
  _FAQ(User _user, String _inputMessage, AppLanguage _appLanguage) {
    user = _user;
    inputMessage = _inputMessage;
    appLanguage = _appLanguage;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Avoid memory leak and disconnect
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Initialisation des questions, des réponses et des icones correspondantes
    final List<Questions> qAndA = [
      Questions(
          icon: Icon(Icons.video_library),
          question: AppLocalizations.of(context).translate('tutoriel'),
          answer: Container()),
      Questions(
          icon: Icon(Icons.power_settings_new),
          question: AppLocalizations.of(context)
              .translate('question_alimentation_gbs'),
          answer: Container()),
      Questions(
          icon: Icon(Icons.bluetooth),
          question:
              AppLocalizations.of(context).translate('question_bluetooth'),
          answer: Container()),
      Questions(
          icon: Icon(Icons.timer),
          question: AppLocalizations.of(context)
              .translate('question_changement_hauteur'),
          answer: Container()),
      Questions(
          icon: Icon(Icons.add),
          question:
              AppLocalizations.of(context).translate('explication_creation'),
          answer: Container()),
      Questions(
          icon: Icon(Icons.directions_run),
          question:
              AppLocalizations.of(context).translate('question_exercices'),
          answer: Container()),
      Questions(
          icon: Icon(Icons.airline_seat_recline_normal),
          question: AppLocalizations.of(context).translate('question_hauteur'),
          answer: Container()),
      Questions(
          icon: Icon(Icons.info),
          question: AppLocalizations.of(context).translate('question_gbs'),
          answer: Container()),
      Questions(
          icon: Icon(Icons.help),
          question:
              AppLocalizations.of(context).translate('question_maintenance'),
          answer: Container()),
      Questions(
          icon: Icon(Icons.iso),
          question: AppLocalizations.of(context).translate('question_modes'),
          answer: Container()),
      Questions(
          icon: Icon(Icons.airline_seat_recline_extra),
          question:
              AppLocalizations.of(context).translate('question_positionnement'),
          answer: Container()),
      Questions(
          icon: Icon(Icons.delete_forever),
          question: AppLocalizations.of(context).translate('explication_suppr'),
          answer: Container()),
      Questions(
        icon: Icon(Icons.info_outline),
        question: AppLocalizations.of(context).translate('question_genourob'),
        answer: Container(
          margin: EdgeInsets.all(5.0),
          child: Linkify(
            onOpen: (gnrbWebsite) async {
              if (await canLaunch(gnrbWebsite.url)) {
                await launch(gnrbWebsite.url);
              } else {
                throw 'Could not launch $gnrbWebsite';
              }
            },
            text: AppLocalizations.of(context).translate('genourob'),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
        ),
      ),
    ];

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
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              if (inputMessage == "fromLogin") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoadPage(
                        user: null,
                        appLanguage: appLanguage,
                        messageIn: "0",
                        page: login),
                  ),
                );
              } else if (inputMessage == "fromMainTitle") {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoadPage(
                        user: user,
                        appLanguage: appLanguage,
                        messageIn: "0",
                        page: mainTitle),
                  ),
                );
              }
            },
          ),
          title: Text("FAQ"),
          backgroundColor: Colors.blue,
          actions: <Widget>[],
        ),
        body: ListView.builder(
            itemCount: qAndA.length,
            itemBuilder: (context, index) {
              Questions _model = qAndA[index];
              return Column(
                children: <Widget>[
                  Divider(
                    height: 12.0,
                  ),
                  ExpansionTile(
                    leading: _model.icon,
                    title: Text(_model.question),
                    children: <Widget>[
                      ListTile(
                        onTap: () {
                          show("message");
                        },
                        title: Row(
                          children: <Widget>[
                            _model.answer,
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
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
/*ListView(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.video_library),
              title: Text(AppLocalizations.of(context).translate('tutoriel')),
            ),
            ListTile(
              leading: Icon(Icons.power_settings_new),
              title: Text(AppLocalizations.of(context).translate(
                  'question_alimentation_gbs')),
            ),
            ListTile(
              leading: Icon(Icons.bluetooth),
              title: Text(AppLocalizations.of(context).translate(
                  'question_bluetooth')),
            ),
            ListTile(
              leading: Icon(Icons.timer),
              title: Text(AppLocalizations.of(context).translate(
                  'question_changement_hauteur')),
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text(AppLocalizations.of(context).translate(
                  'explication_creation')),
            ),
            ListTile(
              leading: Icon(Icons.directions_run),
              title: Text(AppLocalizations.of(context).translate(
                  'question_exercices')),
            ),
            ListTile(
              leading: Icon(Icons.airline_seat_recline_normal),
              title: Text(AppLocalizations.of(context).translate(
                  'question_hauteur')),
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text(
                  AppLocalizations.of(context).translate('question_gbs')),
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text(AppLocalizations.of(context).translate(
                  'question_maintenance')),
            ),
            ListTile(
              leading: Icon(Icons.iso),
              title: Text(
                  AppLocalizations.of(context).translate('question_modes')),
            ),
            ListTile(
              leading: Icon(Icons.airline_seat_recline_extra),
              title: Text(AppLocalizations.of(context).translate(
                  'question_positionnement')),
            ),
            ListTile(
              leading: Icon(Icons.delete_forever),
              title: Text(
                  AppLocalizations.of(context).translate('explication_suppr')),
            ),
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text(AppLocalizations.of(context).translate('genourob')),
            ),
          ],
        ),*/
