import 'dart:async';
import 'dart:ui';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gbsalternative/AppLanguage.dart';
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

  Widget displayScore(int score) {
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

  Widget displayMessage(String message) {
    return Text(
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

  Widget closeButton(
      BuildContext context, AppLanguage appLanguage, User user, int score) {
    DatabaseHelper db = new DatabaseHelper();

    return Container(
      height: screenSize.height * 0.2,
      width: screenSize.width * 0.2,
      child: RaisedButton(
        onPressed: () async {
          //TODO insérer dans bdd
          //Get date etc
          //db.getScore(user.userId);

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

          if (everyScores.length == 0)
            db.addScore(newScore);
          else {
            //Check si un score a déjà été enregister le même jour et s'il est plus grand ou pas
            for (int i = 0; i < everyScores.length; i++) {
              //On remplace la valeur dans la bdd
              print(everyScores[i].scoreId);
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
        },
        child: Text("Quitter le jeu"),
      ),
    );
  }

  Widget pauseButton(PlaneGame game) {
    return Container(
      height: screenSize.height * 0.2,
      width: screenSize.width * 0.2,
      child: RaisedButton(
        onPressed: () async {
          game.pauseGame = !game.pauseGame;
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
              Icon(
                !game.pauseGame ?
                Icons.pause : Icons.play_arrow,
              ),
                  !game.pauseGame ?
              Text("Pause") : Text("Play"),
          ],
        ),
      ),
    );
  }

  Widget restartButton(
      BuildContext context, AppLanguage appLanguage, User user) {
    return Container(
      height: screenSize.height * 0.2,
      width: screenSize.width * 0.2,
      child: RaisedButton(
        onPressed: () async {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      LoadPage(
                        appLanguage: appLanguage,
                        page: "plane",
                        user: user,
                      )));
        },
        child: Text("Restart"),
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
