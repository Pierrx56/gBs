import 'dart:async';
import 'dart:ui';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/AppLocalizations.dart';
import 'package:gbsalternative/DatabaseHelper.dart';
import 'package:gbsalternative/DrawCharts.dart';
import 'package:gbsalternative/LoadPage.dart';
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

/*
  Widget displayScore(int score, PlaneGame game, String timeRemaining) {
    return Container(
      child: Row(
        children: <Widget>[
          Text(
            "Score: $score",
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
          Image.asset(
            'assets/images/plane/balloon-green.png',
            width: game.screenSize.width * 0.05,
            height: game.screenSize.height * 0.2,
          ),
        ],
      ),
    );
  }*/

  Widget displayScore(String message, PlaneGame game, String timeRemaining) {
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
        height: game.screenSize.height * 0.35,
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              FittedBox(
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
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "$message",
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
                  Image.asset(
                    'assets/images/plane/balloon-green.png',
                    width: game.screenSize.width * 0.05,
                    height: game.screenSize.height * 0.2,
                  ),
                ],
              ),
            ],
          ),
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
            color: color.withAlpha(150),//Colors.blue.withAlpha(150),
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

  Widget creditsButton() {
    return Ink(
      decoration: ShapeDecoration(
        shape: CircleBorder(),
      ),
      child: IconButton(
        color: Colors.white,
        icon: Icon(
          Icons.nature_people,
        ),
        onPressed: () {
          update();
        },
      ),
    );
  }

  void saveAndExit(BuildContext context, AppLanguage appLanguage, User user,
      int score, PlaneGame game) async {
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

    if (everyScores.length == 0 && score != 0)
      db.addScore(newScore);
    else if (score != 0) {
      //Check si un score a déjà été enregister le même jour et s'il est plus grand ou pas
      for (int i = 0; i < everyScores.length; i++) {
        //On remplace la valeur dans la bdd
        //print(everyScores[i].scoreId);
        if (everyScores[i].date == date && score > everyScores[i].score)
          db.updateScore(Score(
              scoreId: everyScores[i].scoreId,
              userId: user.userId,
              activityId: ACTIVITY_NUMBER,
              scoreValue: score,
              scoreDate: date));
      }
      //Sinon on enregistre si la dernière date enregistrée est différente du jour
      if (everyScores[everyScores.length - 1].date != date)
        db.addScore(newScore);
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
      int score, PlaneGame game) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: game.screenSize.height * 0.2,
        width: game.screenSize.width / 3,
        child: RaisedButton(
          onPressed: () async {
            //Get date etc
            //db.getScore(user.userId);
            saveAndExit(context, appLanguage, user, score, game);
          },
          child: Text(
            "Quitter le jeu",
            style: textStyle,
          ),
        ),
      ),
    );
  }

  Widget pauseButton(BuildContext context, AppLanguage appLanguage,
      PlaneGame game, User user) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: game.screenSize.height * 0.2,
        width: game.pauseGame ? game.screenSize.width / 3 :game.screenSize.width / 4 ,
        child: RaisedButton(
          onPressed: game.getConnectionState()
              ? () async {
            game.pauseGame = !game.pauseGame;
          } : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                !game.pauseGame ? Icons.pause : Icons.play_arrow,
              ),
              !game.pauseGame
                  ? Text(
                      (AppLocalizations.of(context).translate('menu')),
                      style: textStyle,
                    )
                  : Text(
                      (AppLocalizations.of(context).translate('play')),
                      style: textStyle,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget restartButton(BuildContext context, AppLanguage appLanguage, User user,
      PlaneGame game) {
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
                          page: plane,
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

  Widget menu(BuildContext context, AppLanguage appLanguage, PlaneGame game,
      User user) {
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
            pauseButton(context, appLanguage, game, user),
            restartButton(context, appLanguage, user, game),
            closeButton(context, appLanguage, user, game.getScore(), game),
          ],
        ),
      ),
    );
  }

  Widget endScreen(BuildContext context, AppLanguage appLanguage,
      PlaneGame game, User user) {
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
        height: game.screenSize.height / 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Fin du jeu, retour au menu !",
              textAlign: TextAlign.center,
              style: textStyle,
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
