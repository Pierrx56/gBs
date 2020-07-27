import 'dart:async';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
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

  Widget displayScore(
      BuildContext context, AppLanguage appLanguage, int score) {
    return Text(
      "Score: $score m",
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
    );
  }

  Widget displayMessage(String message, SwimGame game) {
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
        width: game.screenSize.width * 0.6,
        height: game.screenSize.height * 0.4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            AutoSizeText(
              "$message",
              maxLines: 3,
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
          ],
        ),
      ),
    );
  }

  Widget closeButton(BuildContext context, AppLanguage appLanguage, User user,
      int score, SwimGame game) {
    DatabaseHelper db = new DatabaseHelper();

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: game.screenSize.height * 0.2,
        width: game.screenSize.width / 3,
        child: RaisedButton(
          onPressed: () async {
            //db.getScore(user.userId);

            //Date au format FR
            String date =
                new DateFormat('dd-MM-yyyy').format(new DateTime.now());

            Score newScore = Score(
                scoreId: null,
                userId: user.userId,
                activityId: ACTIVITY_NUMBER,
                scoreValue: score,
                scoreDate: date);

            //db.deleteScore(user.userId);

            List<Scores> everyScores =
                await db.getScore(user.userId, ACTIVITY_NUMBER);

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
                  page: "mainTitle",
                ),
              ),
            );
          },
          child: Text(
            AppLocalizations.of(context).translate('quitter'),
            style: textStyle,
          ),
        ),
      ),
    );
  }

  Widget pauseButton(
      BuildContext context, AppLanguage appLanguage, SwimGame game, User user) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: game.screenSize.height * 0.2,
        width: game.screenSize.width / 3,
        child: RaisedButton(
          onPressed: !game.getGameOver()
              ? game.getConnectionState()
                  ? () async {
                      game.pauseGame = !game.pauseGame;
                    }
                  : null
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                !game.pauseGame ? Icons.pause : Icons.play_arrow,
              ),
              !game.pauseGame
                  ? Text(
                      (AppLocalizations.of(context).translate('pause')),
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

  Widget restartButton(
      BuildContext context, AppLanguage appLanguage, User user, SwimGame game) {
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
                          messageIn: "",
                          appLanguage: appLanguage,
                          page: "swimmer",
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
      BuildContext context, AppLanguage appLanguage, SwimGame game, User user) {
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
