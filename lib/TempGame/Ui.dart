import 'dart:async';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/CommonGamesUI.dart';
import 'package:gbsalternative/DatabaseHelper.dart';
import 'package:gbsalternative/TempGame/TempGame.dart';

int ACTIVITY_NUMBER = 2;

class UI extends StatefulWidget {
  final UIState state = UIState();

  State<StatefulWidget> createState() => state;
}

class UIState extends State<UI> {
  bool redFilter = false;

  //Initializing database
  DatabaseHelper db = new DatabaseHelper();

  CommonGamesUI commonGamesUI = CommonGamesUI();

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

  Widget displayCoin(String message, TempGame game) {
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
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: <Widget>[
                  Image.asset(
                    'assets/images/temp/coin1.png',
                    width: game.screenSize.height * 0.1,
                    height: game.screenSize.height * 0.1,
                  ),
                  AutoSizeText(
                    !game.getPushState()
                        ? "${game.coins}/30"
                        : "${game.coins}/30 + ${game.getFloor()}",
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

  Widget displayTuto(
      BuildContext context, AppLanguage appLanguage, TempGame game, User user) {
    return Container(
      width: game.screenSize.width,
      height: game.screenSize.height,
      child: game.phaseTuto == 1
          ? Stack(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB((game.screenSize.width * 0.1), 0,
                      (game.screenSize.width * 0.3) + 50, 0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.arrow_back,
                        size: 50,
                      )),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      (game.screenSize.width * 0.2), 0, 0, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: game.screenSize.width * 0.3,
                      height: game.screenSize.height * 0.3,
                      decoration: new BoxDecoration(
                          color: Colors.blue.withAlpha(150),
                          //new Color.fromRGBO(255, 0, 0, 0.0),
                          borderRadius: new BorderRadius.only(
                              topLeft: const Radius.circular(20.0),
                              topRight: const Radius.circular(20.0),
                              bottomLeft: const Radius.circular(20.0),
                              bottomRight: const Radius.circular(20.0))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          AutoSizeText(
                            "Jauge qui se consomme en 6 secondes.",
                            textAlign: TextAlign.center,
                            minFontSize: 15,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      (game.screenSize.width * 0.5), 0, 0, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      "assets/images/temp/click.gif",
                      height: 125.0,
                      width: 125.0,
                    ),
                  ),
                ),
              ],
            )
          : game.phaseTuto == 2
              ? Stack(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          (game.screenSize.width * 0.2),
                          (game.screenSize.width * 0.1),
                          0,
                          0),
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: Transform.rotate(
                            angle: math.pi / 4,
                            child: Icon(
                              Icons.arrow_back,
                              size: 50,
                            ),
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          (game.screenSize.width * 0.25),
                          (game.screenSize.width * 0.15),
                          0,
                          0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          width: game.screenSize.width * 0.3,
                          height: game.screenSize.height * 0.3,
                          decoration: new BoxDecoration(
                              color: Colors.blue.withAlpha(150),
                              //new Color.fromRGBO(255, 0, 0, 0.0),
                              borderRadius: new BorderRadius.only(
                                  topLeft: const Radius.circular(20.0),
                                  topRight: const Radius.circular(20.0),
                                  bottomLeft: const Radius.circular(20.0),
                                  bottomRight: const Radius.circular(20.0))),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              AutoSizeText(
                                "Le nombre de pièces est défini en fonction des plateformes atteintes\n"
                                "Vous avez 3 chances de réessayer un saut.",
                                textAlign: TextAlign.center,
                                minFontSize: 15,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          (game.screenSize.width * 0.5), 0, 0, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Image.asset(
                          "assets/images/temp/click.gif",
                          height: 125.0,
                          width: 125.0,
                        ),
                      ),
                    ),
                  ],
                )
              : game.phaseTuto == 3
                  ? Stack(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              0, (game.screenSize.width * 0.1), 0, 0),
                          child: Align(
                              alignment: Alignment.center,
                              child: Transform.rotate(
                                angle: -math.pi / 2,
                                child: Icon(
                                  Icons.arrow_back,
                                  size: 50,
                                ),
                              )),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              0, (game.screenSize.width * 0.15), 0, 0),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: game.screenSize.width * 0.3,
                              height: game.screenSize.height * 0.2,
                              decoration: new BoxDecoration(
                                  color: Colors.blue.withAlpha(150),
                                  //new Color.fromRGBO(255, 0, 0, 0.0),
                                  borderRadius: new BorderRadius.only(
                                      topLeft: const Radius.circular(20.0),
                                      topRight: const Radius.circular(20.0),
                                      bottomLeft: const Radius.circular(20.0),
                                      bottomRight:
                                          const Radius.circular(20.0))),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  AutoSizeText(
                                    "Vous devez commencer à pousser ici.",
                                    textAlign: TextAlign.center,
                                    minFontSize: 15,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              0, 0, (game.screenSize.width * 0.2), 0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Image.asset(
                              "assets/images/temp/click.gif",
                              height: 125.0,
                              width: 125.0,
                            ),
                          ),
                        ),
                      ],
                    )
                  : game.phaseTuto == 4
                      ? Stack(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                  (game.screenSize.width * 0.20),
                                  (game.screenSize.width * 0.075),
                                  0,
                                  0),
                              child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    "+${game.expampleFloor}",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold),
                                  )),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                  (game.screenSize.width * 0.25),
                                  (game.screenSize.width * 0.1),
                                  0,
                                  0),
                              child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Transform.rotate(
                                    angle: math.pi / 4,
                                    child: Icon(
                                      Icons.arrow_back,
                                      size: 50,
                                    ),
                                  )),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                  0, (game.screenSize.width * 0.15), 0, 0),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  width: game.screenSize.width * 0.3,
                                  height: game.screenSize.height * 0.2,
                                  decoration: new BoxDecoration(
                                      color: Colors.blue.withAlpha(150),
                                      //new Color.fromRGBO(255, 0, 0, 0.0),
                                      borderRadius: new BorderRadius.only(
                                          topLeft: const Radius.circular(20.0),
                                          topRight: const Radius.circular(20.0),
                                          bottomLeft:
                                              const Radius.circular(20.0),
                                          bottomRight:
                                              const Radius.circular(20.0))),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      AutoSizeText(
                                        "Correspond à la plateforme sur laquelle vous allez sauter.",
                                        textAlign: TextAlign.center,
                                        minFontSize: 15,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                  0, 0, (game.screenSize.width * 0.2), 0),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Image.asset(
                                  "assets/images/temp/click.gif",
                                  height: 125.0,
                                  width: 125.0,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(),
    );
  }


  Widget displayMessage(String message, TempGame game, Color color) {
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
