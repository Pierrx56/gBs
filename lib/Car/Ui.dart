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
import 'package:gbsalternative/Car/Car.dart';
import 'package:gbsalternative/CommonGamesUI.dart';
import 'package:gbsalternative/DatabaseHelper.dart';
import 'package:gbsalternative/DrawCharts.dart';
import 'package:gbsalternative/Login.dart';
import 'package:gbsalternative/MainTitle.dart';
import 'package:gbsalternative/Car/CarGame.dart';
import 'package:intl/intl.dart';

int ACTIVITY_NUMBER = 3;

class UI extends StatefulWidget {
  final UIState state = UIState();

  State<StatefulWidget> createState() => state;
}

class UIState extends State<UI> {
  bool redFilter = false;

  CommonGamesUI commonGamesUI = new CommonGamesUI();

  int numberFuel;

  void initState() {
    numberFuel = 0;
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

  Widget displayScore(String message, CarGame game, String timeRemaining) {
    if(game.screenSize == null)
      return Container();
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        alignment: Alignment.topCenter,
        decoration: new BoxDecoration(
            color: Colors.blue.withAlpha(150),
            //new Color.fromRGBO(255, 0, 0, 0.0),
            borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(20.0),
                topRight: const Radius.circular(20.0),
                bottomLeft: const Radius.circular(20.0),
                bottomRight: const Radius.circular(20.0))),
        width: game.screenSize.width * 0.25,
        height: game.screenSize.height * 0.2,
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              /*FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  "$timeRemaining",
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
              ),*/
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "$message km",
                    style: TextStyle(
                      fontSize: 50,
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
                  /*
                  Image.asset(
                    'assets/images/plane/balloon-green.png',
                    width: game.screenSize.width * 0.05,
                    height: game.screenSize.height * 0.2,
                  ),*/
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget displayItems(String message, CarGame game) {
    if(game.screenSize == null)
      return Container();
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: new BoxDecoration(
            //color: Colors.blue.withAlpha(150),
            //new Color.fromRGBO(255, 0, 0, 0.0),
            borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(20.0),
                topRight: const Radius.circular(20.0),
                bottomLeft: const Radius.circular(20.0),
                bottomRight: const Radius.circular(20.0))),
        width: game.screenSize.width * 0.40,
        height: game.screenSize.height * 0.30,
        child: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: Image.asset(
                'assets/images/car/red_heart.png',
                width: game.screenSize.height * 0.1,
                height: game.screenSize.height * 0.1,
              ),
            ),
            game.life > 1
                ? Padding(
                    padding: EdgeInsets.fromLTRB(
                        game.screenSize.height * 0.1 + 10, 0, 10, 0),
                    child: Image.asset(
                      'assets/images/car/red_heart.png',
                      width: game.screenSize.height * 0.1,
                      height: game.screenSize.height * 0.1,
                    ),
                  )
                : Container(),
            game.life > 2
                ? Padding(
                    padding: EdgeInsets.fromLTRB(
                        2 * game.screenSize.height * 0.1 + 20, 0, 10, 0),
                    child: Image.asset(
                      'assets/images/car/red_heart.png',
                      width: game.screenSize.height * 0.1,
                      height: game.screenSize.height * 0.1,
                    ),
                  )
                : Container(),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: <Widget>[
                  Image.asset(
                    'assets/images/car/fuel.png',
                    width: game.screenSize.height * 0.1,
                    height: game.screenSize.height * 0.1,
                  ),
                  AutoSizeText(
                    (message).toString(),
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget waitingScreen(CarGame game) {
    if(game.screenSize == null)
      return Container();
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
          height: game.screenSize.width * 0.30,
          width: game.screenSize.height * 0.5,
          child: Row(
            children: <Widget>[
              AnimatedContainer(
                duration: Duration(milliseconds: 500),
                alignment: Alignment.topCenter,
                height: game.changeSize
                    ? game.screenSize.width * 0.26
                    : game.screenSize.width * 0.25,
                width: game.changeSize
                    ? game.screenSize.height * 0.21
                    : game.screenSize.height * 0.2,
                color: splashIconColor,
              ),
              Spacer(),
              AnimatedContainer(
                duration: Duration(milliseconds: 500),
                alignment: Alignment.topCenter,
                height: game.changeSize
                    ? game.screenSize.width * 0.26
                    : game.screenSize.width * 0.25,
                width: game.changeSize
                    ? game.screenSize.height * 0.21
                    : game.screenSize.height * 0.2,
                color: splashIconColor,
              ),
            ],
          )),
    );
  }

  Widget displayMessage(String message, CarGame game, Color color) {
    if(game.screenSize == null)
      return Container();
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
