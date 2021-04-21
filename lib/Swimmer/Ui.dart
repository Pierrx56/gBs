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
    if (game.screenSize == null) return Container();
    double heightHeart = game.screenSize.height * 0.1;
    double widthHeart = game.screenSize.height * 0.1;
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Container(
        alignment: Alignment.center,
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
            //Life
            Align(
              alignment: Alignment.topLeft,
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: Image.asset(
                      'assets/images/temp/red_heart.png',
                      width: widthHeart,
                      height: heightHeart,
                    ),
                  ),
                  game.life > 1
                      ? Padding(
                          padding:
                              EdgeInsets.fromLTRB(widthHeart + 10, 0, 10, 0),
                          child: Image.asset(
                            'assets/images/temp/red_heart.png',
                            width: widthHeart,
                            height: heightHeart,
                          ),
                        )
                      : Container(),
                  game.life > 2
                      ? Padding(
                          padding: EdgeInsets.fromLTRB(
                              2 * widthHeart + 20, 0, 10, 0),
                          child: Image.asset(
                            'assets/images/temp/red_heart.png',
                            width: widthHeart,
                            height: heightHeart,
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
            //Km
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, heightHeart, 0, 0),
                child: Row(
                  children: [
                    Image.asset(
                      "assets/images/ship/kilometre.png",
                      width: 35,
                    ),
                    Padding(
                      padding: EdgeInsets.all(5.0),
                    ),
                    AutoSizeText("$score", minFontSize: 35, style: textStyle),
                  ],
                ),
              ),
            ),
            //Timer
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 2 * heightHeart, 0, 0),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 35,
                    ),
                    Padding(
                      padding: EdgeInsets.all(5.0),
                    ),
                    AutoSizeText("$timeRemaining",
                        minFontSize: 35, style: textStyle),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget displayMessage(String message, SwimGame game, Color color) {
    if (game.screenSize == null) return Container();
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
