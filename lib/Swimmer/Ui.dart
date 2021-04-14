import 'dart:async';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
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
import 'package:gbsalternative/Swimmer/SwimGame.dart';
import 'package:intl/intl.dart';

int ACTIVITY_NUMBER = 0;

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

  Widget displayScore(BuildContext context, AppLanguage appLanguage,
      String score, String timeRemaining, SwimGame game) {
    if(game.screenSize == null)
      return Container();
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        alignment: Alignment.center,
        decoration: new BoxDecoration(
            color: Colors.blue.withAlpha(150),
            //new Color.fromRGBO(255, 0, 0, 0.0),
            borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(20.0),
                topRight: const Radius.circular(20.0),
                bottomLeft: const Radius.circular(20.0),
                bottomRight: const Radius.circular(20.0))),
        width: game.screenSize.width * 0.25,
        height: game.screenSize.height * 0.35,
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AutoSizeText("$timeRemaining", minFontSize: 35, style: textStyle),
              AutoSizeText("Score: $score m",
                  minFontSize: 35, style: textStyle),

              Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: Image.asset(
                      'assets/images/temp/red_heart.png',
                      width: game.screenSize.height * 0.1,
                      height: game.screenSize.height * 0.1,
                    ),
                  ),

                  game.life > 1
                      ? Padding(
                    padding: EdgeInsets.fromLTRB(
                        game.screenSize.height * 0.1 + 10, 0, 10, 0),
                    child: Image.asset(
                      'assets/images/temp/red_heart.png',
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
                      'assets/images/temp/red_heart.png',
                      width: game.screenSize.height * 0.1,
                      height: game.screenSize.height * 0.1,
                    ),
                  )
                      : Container(),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget displayMessage(String message, SwimGame game, Color color) {
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
        height: game.screenSize.height * 0.3,
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

  @override
  Widget build(BuildContext context) {
    return null;
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
