import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:confetti/confetti.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/AppLocalizations.dart';
import 'package:gbsalternative/CommonGamesUI.dart';
import 'package:gbsalternative/DatabaseHelper.dart';
import 'package:gbsalternative/DrawCharts.dart';
import 'package:gbsalternative/Login.dart';
import 'package:gbsalternative/MainTitle.dart';
import 'package:gbsalternative/Plane/PlaneGame.dart';
import 'package:intl/intl.dart';

int ACTIVITY_NUMBER = 1;

class UI extends StatefulWidget {
  final UIState state = UIState();

  State<StatefulWidget> createState() => state;
}

class UIState extends State<UI> {
  bool redFilter = false;

  void initState() {
    super.initState();
    //WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    //WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void update() {
    setState(() {});
  }

  Widget displayScore(String message, PlaneGame game, String timeRemaining) {
    if (game.screenSize == null) return Container();

    double widthBalloon = game.screenSize.width * 0.05;
    double heightBalloon = game.screenSize.height * 0.1;

    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Container(
        alignment: Alignment.topCenter,
        decoration: new BoxDecoration(
            //new Color.fromRGBO(255, 0, 0, 0.0),
            borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(20.0),
                topRight: const Radius.circular(20.0),
                bottomLeft: const Radius.circular(20.0),
                bottomRight: const Radius.circular(20.0))),
        width: game.screenSize.width * 0.25,
        height: game.screenSize.height * 0.35,
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: Row(
                children: <Widget>[
                  Image.asset(
                    'assets/images/plane/balloon-green.png',
                    width: widthBalloon,
                    height: heightBalloon,
                  ),
                  AutoSizeText("$message", minFontSize: 35, style: textStyle),
                ],
              ),
            ),
            Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0,heightBalloon, 0, 0),
                  child: AutoSizeText("$timeRemaining", minFontSize: 35, style: textStyle),
                )),
          ],
        ),
      ),
    );
  }

  Widget displayMessage(String message, PlaneGame game, Color color) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        alignment: Alignment.topCenter,
        decoration: new BoxDecoration(
            color: color.withAlpha(150), //Colors.blue.withAlpha(150),
            //new Color.fromRGBO(255, 0, 0, 0.0),
            borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(20.0),
                topRight: const Radius.circular(20.0),
                bottomLeft: const Radius.circular(20.0),
                bottomRight: const Radius.circular(20.0))),
        width: game.screenSize.width * 0.6,
        height: game.screenSize.height * 0.4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                "$message",
                style: TextStyle(
                  fontSize: 70,
                  color: Colors.black,
                  shadows: <Shadow>[
                    Shadow(
                      color: Color(0x88000000),
                      blurRadius: 10,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildScreenPlaying() {
    return Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: 30),
          child: Row(
            children: <Widget>[
              //scoreDisplay(),
              /* GestureDetector(
                  //onTapDown: (TapDownDetails d) => game.boxer.punchLeft(),
                  behavior: HitTestBehavior.opaque,
                  child: LeftPunch(),
                ),
                GestureDetector(
                  onTapDown: (TapDownDetails d) => game.boxer.upperCut(),
                  behavior: HitTestBehavior.opaque,
                  child: Uppercut(),
                ),
                GestureDetector(
                  onTapDown: (TapDownDetails d) => game.boxer.punchRight(),
                  behavior: HitTestBehavior.opaque,
                  child: RightPunch(),
                ),*/
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildScreenPlaying();
    //scoreDisplay(),
    //creditsButton(),
  }
}

enum UIScreen {
  home,
  playing,
  lost,
  help,
  credits,
}
