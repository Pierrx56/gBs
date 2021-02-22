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
import 'package:gbsalternative/LoadPage.dart';
import 'package:gbsalternative/Login.dart';
import 'package:gbsalternative/MainTitle.dart';
import 'package:gbsalternative/CarGame/CarGame.dart';
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
                  //TODO additionner aux anciens fueltank
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

  Widget displayMessage(String message, CarGame game, Color color) {
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

  void saveAndExit(BuildContext context, AppLanguage appLanguage, User user,
      int score, CarGame game, double starValue, int starLevel) async {
    DatabaseHelper db = new DatabaseHelper();
    //Date au format FR
    String date = new DateFormat('dd-MM-yyyy').format(new DateTime.now());

    Score newScore = Score(
        scoreId: null,
        userId: user.userId,
        activityId: ACTIVITY_NUMBER,
        scoreValue: score,
        scoreDate: date);

    //db.deleteScore(user.userId);

    List<Scores> everyScores = await db.getScore(user.userId, ACTIVITY_NUMBER);
    Star tempStar = await db.getStar(user.userId, ACTIVITY_NUMBER, starLevel);

    if (everyScores.length == 0 && score != 0) {
      db.addScore(newScore);
      db.addStar(Star(
          starId: null,
          activityId: ACTIVITY_NUMBER,
          userId: user.userId,
          starValue: starValue,
          starLevel: starLevel));
    } else if (score != 0) {
      //Check si un score a déjà été enregister le même jour et s'il est plus grand ou pas
      for (int i = 0; i < everyScores.length; i++) {
        //On remplace la valeur dans la bdd
        //print(everyScores[i].scoreId);
        if (everyScores[i].date == date && score > everyScores[i].score) {
          db.updateScore(Score(
              scoreId: everyScores[i].scoreId,
              userId: user.userId,
              activityId: ACTIVITY_NUMBER,
              scoreValue: score,
              scoreDate: date));

          starValue += tempStar.starValue;
          db.updateStar(Star(
              starId: tempStar.starId,
              activityId: ACTIVITY_NUMBER,
              userId: user.userId,
              starValue: starValue,
              starLevel: starLevel));
        }
      }
      //Sinon on enregistre si la dernière date enregistrée est différente du jour
      if (everyScores[everyScores.length - 1].date != date) {
        db.addScore(newScore);
        starValue += tempStar.starValue;
        db.updateStar(Star(
            starId: tempStar.starId,
            activityId: ACTIVITY_NUMBER,
            userId: user.userId,
            starValue: starValue,
            starLevel: starLevel));
      }
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => LoadPage(
                appLanguage: appLanguage,
                user: user,
                messageIn: "0",
                page: mainTitle,
              )
          /*MainTitle(
                        appLanguage: appLanguage,
                        userIn: user,
                        messageIn: 0,
                      )*/
          /*      MainTitle(
                  userIn: user,
                  appLanguage: appLanguage,
                     )*/
          ),
    );
  }

  Widget closeButton(BuildContext context, AppLanguage appLanguage, User user,
      int score, CarGame game, double starValue, int starLevel) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: game.screenSize.height * 0.2,
        width: game.screenSize.width / 3,
        child: RaisedButton(
          onPressed: () async {
            //Get date etc
            //db.getScore(user.userId);
            saveAndExit(
                context, appLanguage, user, score, game, starValue, starLevel);
          },
          child: Text(
            AppLocalizations.of(context).translate('quitter'),
            style: textStyle,
          ),
        ),
      ),
    );
  }

  Widget restartButton(
      BuildContext context, AppLanguage appLanguage, CarGame game, User user) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: game.screenSize.height * 0.2,
        width: game.screenSize.width / 3,
        child: RaisedButton(
          onPressed: () async {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => LoadPage(
                          messageIn: "0",
                          appLanguage: appLanguage,
                          page: car,
                          user: user,
                        )));
          },
          child: Text(
            (AppLocalizations.of(context).translate('restart')),
            style: textStyle,
          ),
        ),
      ),
    );
  }

  Widget menu(
      BuildContext context, AppLanguage appLanguage, CarGame game, User user) {
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
        width: game.screenSize.width / 3,
        height: game.screenSize.height * 0.9,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "MENU",
              style: textStyle,
            ),
            commonGamesUI.pauseButton(context, appLanguage, game, user),
            restartButton(context, appLanguage, game, user),
            closeButton(context, appLanguage, user, game.getScore(), game,
                game.getStarValue(), game.getStarLevel()),
          ],
        ),
      ),
    );
  }

  Widget menuDebug(
      BuildContext context, AppLanguage appLanguage, CarGame game, User user) {
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
        width: game.screenSize.width * 0.3,
        height: game.screenSize.height * 0.3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "MENU",
              style: textStyle,
            ),
            Container(
                width: game.screenSize.width * 0.3,
                height: game.screenSize.height * 0.1,
                child: commonGamesUI.pauseButton(
                    context, appLanguage, game, user)),
            Container(
                width: game.screenSize.width * 0.3,
                height: game.screenSize.height * 0.1,
                child: restartButton(context, appLanguage, game, user)),
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
