import 'dart:async';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:confetti/confetti.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/AppLocalizations.dart';
import 'package:gbsalternative/DatabaseHelper.dart';
import 'package:gbsalternative/DrawCharts.dart';
import 'package:gbsalternative/Login.dart';
import 'package:gbsalternative/MainTitle.dart';
import 'package:gbsalternative/CarGame/Car.dart';
import 'package:gbsalternative/Plane/Plane.dart';
import 'package:gbsalternative/Swimmer/Swimmer.dart';
import 'package:gbsalternative/TempGame/Temp.dart';
import 'package:intl/intl.dart';

class CommonGamesUI {
  //Initializing database
  DatabaseHelper db = new DatabaseHelper();

  Future<Star> getStar(int idGame, int level, User user) async {
    return await db.getStar(user.userId, idGame, level);
  }

  //Retourne un widget de 5 etoiles en lignes
  Widget numberOfStars(int idGame, int level, double starValue, User user) {
    return FutureBuilder(
        future: getStar(idGame, level, user),
        builder: (context, AsyncSnapshot<Star> snapshot) {
          List<Widget> starArray = List<Widget>();
          if (!snapshot.hasData) {
            for (int i = 0; i < 5; i++) starArray.add(Icon(Icons.star_border));
            return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: starArray);
          } else {
            getStar(idGame, level, user);
            double stars = snapshot.data.starValue;
            stars += starValue;

            for (int i = 0; i < 5; i++) {
              if (stars - 1.0 >= 0.0) {
                starArray.add(Icon(Icons.star));
                stars -= 1.0;
              } else if (stars - 0.5 >= 0.0) {
                starArray.add(Icon(Icons.star_half));
                stars -= 0.5;
              } else if (stars - 0.5 < 0.0) {
                starArray.add(Icon(Icons.star_border));
              }
            }
            return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: starArray);
          }
        });
  }

  Widget pauseButton(
      BuildContext context, AppLanguage appLanguage, var game, User user) {
    if (game.screenSize == null) return Container();

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: game.screenSize.height * 0.2,
        width: game.pauseGame
            ? game.screenSize.width * 0.3
            : game.screenSize.height * 0.2,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: !game.pauseGame
                ? MaterialStateProperty.all<Color>(Colors.transparent)
                : MaterialStateProperty.all<Color>(Colors.grey[350]),
            elevation: !game.pauseGame
                ? MaterialStateProperty.all<double>(0.0)
                : MaterialStateProperty.all<double>(3.0),
          ),
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
                color: Colors.black,
              ),
              !game.pauseGame
                  ? Text(
                      "",
                      //(AppLocalizations.of(context).translate('menu')),
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

  Widget pauseDebugButton(
      BuildContext context, AppLanguage appLanguage, var game, User user) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: game.screenSize.height * 0.2,
        width: game.pauseGame
            ? game.screenSize.width * 0.3
            : game.screenSize.height * 0.2,
        child: FlatButton(
          color: Colors.transparent,
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
                      "",
                      //(AppLocalizations.of(context).translate('menu')),
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

  /// A custom Path to paint stars.
  Path drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (math.pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * math.cos(step),
          halfWidth + externalRadius * math.sin(step));
      path.lineTo(
          halfWidth + internalRadius * math.cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * math.sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  Widget endScreen(
      BuildContext context,
      AppLanguage appLanguage,
      var game,
      int idGame,
      User user,
      double starValue,
      int level,
      int score,
      String message) {
    int tempLevel = (level ~/ 10).toInt();

    starValue = setStarValue(context, appLanguage, user, score, game, idGame,
        starValue, level, message);

    ConfettiController _controllerTopCenter =
        ConfettiController(duration: const Duration(seconds: 1));

    //Check DatabaseHelp.dart for name game order
    List<String> nameGame = [
      AppLocalizations.of(context).translate('nageur'),
      AppLocalizations.of(context).translate('avion'),
      AppLocalizations.of(context).translate('temp'),
      AppLocalizations.of(context).translate('voiture'),
    ];

    if (starValue >= 0.5) _controllerTopCenter.play();

    double widthSize = game.screenSize.width * 0.7;
    double heightSize = game.screenSize.height * 0.8;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: widthSize,
        height: heightSize,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            //Level and game name
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: game.screenSize.width * 0.3,
                height: game.screenSize.height * 0.2,
                alignment: Alignment.topCenter,
                decoration: new BoxDecoration(
                    color: Colors.blue,
                    //new Color.fromRGBO(255, 0, 0, 0.0),
                    borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(10.0),
                        topRight: const Radius.circular(10.0),
                        bottomLeft: const Radius.circular(10.0),
                        bottomRight: const Radius.circular(10.0))),
                child: Text(
                  "${nameGame[idGame]} - ${AppLocalizations.of(context).translate('niveau')} ${tempLevel / 10}",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            //Stars ans white box
            Align(
              alignment: Alignment.center,
              child: Container(
                width: widthSize * 0.75,
                height: heightSize * 0.85,
                alignment: Alignment.topCenter,
                decoration: new BoxDecoration(
                  color: Colors.grey[100],
                  //new Color.fromRGBO(255, 0, 0, 0.0),
                  borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(10.0),
                      topRight: const Radius.circular(10.0),
                      bottomLeft: const Radius.circular(10.0),
                      bottomRight: const Radius.circular(10.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.9),
                      spreadRadius: 0,
                      blurRadius: 0,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      0, game.screenSize.height * 0.05, 0, 0),
                  child: numberOfStars(idGame, level, starValue, user),
                ),
                /*
                AutoSizeText(
                  game.getStarValue() >= 0.5
                      ? "Félicitation, vous gagnez 0.5 étoile !\n"
                          "Retour au menu !"
                      : "Vous n'avez pas gagné d'étoile, ça sera pour la prochaine fois, surpassez-vous !",
                  textAlign: TextAlign.center,
                  //style: textStyle,
                ),*/
              ),
            ),
            //Score square
            Align(
              alignment: Alignment.center,
              child: Container(
                width: widthSize * 0.5,
                height: heightSize * 0.55,
                alignment: Alignment.center,
                decoration: new BoxDecoration(
                    color: Colors.grey[200],
                    //new Color.fromRGBO(255, 0, 0, 0.0),
                    borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(10.0),
                        topRight: const Radius.circular(10.0),
                        bottomLeft: const Radius.circular(10.0),
                        bottomRight: const Radius.circular(10.0))),
                child: idGame == ID_CAR_ACTIVITY
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: Image.asset(
                              'assets/images/car/fuel.png',
                              width: game.screenSize.height * 0.1,
                              height: game.screenSize.height * 0.1,
                            ),
                          ),
                          AutoSizeText(
                            score > 1
                                ? "$score ${AppLocalizations.of(context).translate('bidon')}s"
                                : "$score ${AppLocalizations.of(context).translate('bidon')}",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        ],
                      )
                    : idGame == ID_PLANE_ACTIVITY
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                child: Image.asset(
                                  'assets/images/plane/balloon-green.png',
                                  width: game.screenSize.height * 0.1,
                                  height: game.screenSize.height * 0.1,
                                ),
                              ),
                              AutoSizeText(
                                score > 1
                                    ? "$score ${AppLocalizations.of(context).translate('ballons')}s"
                                    : "$score ${AppLocalizations.of(context).translate('ballons')}",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                            ],
                          )
                        : idGame == ID_SWIMMER_ACTIVITY
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.center,
                                    child: Image.asset(
                                      'assets/images/swimmer/bouee.png',
                                      height: heightSize * 0.35,
                                      //width: game.screenSize.height * 0.1,
                                      //height: game.screenSize.height * 0.1,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: AutoSizeText(
                                      "$score m",
                                      minFontSize: 35,
                                      maxFontSize: 40,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              )
                            : idGame == ID_TEMP_ACTIVITY
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 0, 10, 0),
                                        child: Image.asset(
                                          'assets/images/temp/coin1.png',
                                          width: game.screenSize.height * 0.1,
                                          height: game.screenSize.height * 0.1,
                                        ),
                                      ),
                                      AutoSizeText(
                                        "$score/30",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                    ],
                                  )
                                : Text("Not implemented in commonGamesUI"),
              ),
            ),
            //Blue message
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding:
                    EdgeInsets.fromLTRB(0, heightSize * 0.55, 0, 0),
                child: Container(
                  width: game.screenSize.width * 0.3,
                  height: game.screenSize.height * 0.1,
                  alignment: Alignment.center,
                  decoration: new BoxDecoration(
                      color: Colors.lightBlue,
                      //new Color.fromRGBO(255, 0, 0, 0.0),
                      borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(10.0),
                          topRight: const Radius.circular(10.0),
                          bottomLeft: const Radius.circular(10.0),
                          bottomRight: const Radius.circular(10.0))),
                  child: game.getStarValue() >= 0.5
                      ? Text(
                          AppLocalizations.of(context).translate('fin_reussie'),
                          style: TextStyle(color: Colors.white))
                      : Text(
                          AppLocalizations.of(context).translate('fin_ratee'),
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ),
            //Quit
            Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () {
                  setStarValue(context, appLanguage, user, score, game, idGame,
                      starValue, level, message);
                  saveAndExit(context, appLanguage, user, score, game, idGame,
                      starValue, level, message);
                },
                child: Container(
                  width: game.screenSize.width * 0.25,
                  height: game.screenSize.height * 0.1,
                  alignment: Alignment.center,
                  decoration: new BoxDecoration(
                      color: Colors.deepPurpleAccent,
                      //new Color.fromRGBO(255, 0, 0, 0.0),
                      borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(10.0),
                          topRight: const Radius.circular(10.0),
                          bottomLeft: const Radius.circular(10.0),
                          bottomRight: const Radius.circular(10.0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurpleAccent[700],
                          spreadRadius: 0,
                          blurRadius: 0,
                          offset: Offset(0, 3), // changes position of shadow
                        )
                      ]),
                  child: Text(
                    AppLocalizations.of(context).translate('quitter'),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            //Confetti
            game.getStarValue() >= 0.5
                ? Align(
                    alignment: Alignment.center,
                    child: ConfettiWidget(
                      confettiController: _controllerTopCenter,
                      blastDirectionality: BlastDirectionality.explosive,
                      // don't specify a direction, blast randomly
                      numberOfParticles: 25,
                      // number of particles to emit
                      colors: [
                        /*
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,*/
                        Colors.yellow[700],
                      ],
                      // manually specify the colors to be used
                      createParticlePath:
                          drawStar, // define a custom shape/path.
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  double setStarValue(
      BuildContext context,
      AppLanguage appLanguage,
      User user,
      int score,
      var game,
      int idGame,
      double starValue,
      int starLevel,
      String message) {
    if (idGame == ID_CAR_ACTIVITY) {
      //TODO Update coin value
      if (user.userMode == "0" && score > 16) {
        game.setStarValue(starValue = 0.5);
      } else if (user.userMode == "1" && score > 20) {
        game.setStarValue(starValue = 0.5);
      } else {
        game.setStarValue(starValue = 0.0);
      }
      //saveAndExit(context, appLanguage, user, score, game, ID_CAR_ACTIVITY,starValue, starLevel, message);
    } else if (idGame == ID_PLANE_ACTIVITY) {
      //TODO Update coin value
      if (user.userMode == "0" && score > 2) {
        game.setStarValue(starValue = 0.5);
      } else if (user.userMode == "1" && score > 2) {
        game.setStarValue(starValue = 0.5);
      } else {
        game.setStarValue(starValue = 0.0);
      }
      //saveAndExit(context, appLanguage, user, score, game, ID_PLANE_ACTIVITY,starValue, starLevel, message);
    } else if (idGame == ID_SWIMMER_ACTIVITY) {
      //S'il fait plus de 180m alors demi-étoile
      if (user.userMode == "0" && score > 180) {
        game.setStarValue(starValue = 0.5);
      }
      //TODO Mode sportif pour le nageur
      else if (user.userMode == "1" && score > 240)
        game.setStarValue(starValue = 0.5);
      else
        game.setStarValue(starValue = 0.0);

      //saveAndExit(context, appLanguage, user, score, game, ID_SWIMMER_ACTIVITY,starValue, starLevel, message);
    } else if (idGame == ID_TEMP_ACTIVITY) {
      //TODO Update coin value
      if (user.userMode == "0" && score > 2) {
        game.setStarValue(starValue = 0.5);
      } else if (user.userMode == "1" && score > 2) {
        game.setStarValue(starValue = 0.5);
      } else {
        game.setStarValue(starValue = 0.0);
      }
      //saveAndExit(context, appLanguage, user, score, game, ID_TEMP_ACTIVITY,starValue, starLevel, message);
    }

    return starValue;
  }

  void saveAndExit(
      BuildContext context,
      AppLanguage appLanguage,
      User user,
      int score,
      var game,
      int idGame,
      double starValue,
      int starLevel,
      String message) async {
    //Date au format FR
    String date = new DateFormat('dd-MM-yyyy').format(new DateTime.now());

    Score newScore = Score(
        scoreId: null,
        userId: user.userId,
        activityId: idGame,
        scoreValue: score,
        scoreDate: date);

    Star newStar = Star(
        starId: null,
        activityId: idGame,
        userId: user.userId,
        starValue: starValue,
        starLevel: starLevel);

    List<Scores> everyScores = await db.getScore(user.userId, idGame);
    Star tempStar = await db.getStar(user.userId, idGame, starLevel);

    //First launch
    if (everyScores.length == 0 && score != 0) {
      db.addScore(newScore);
      db.addStar(newStar);
    } else if (score != 0) {
      //Check si un score a déjà été enregister le même jour et s'il est plus grand ou pas
      for (int i = 0; i < everyScores.length; i++) {
        //On remplace la valeur dans la bdd
        //print(everyScores[i].scoreId);
        if (everyScores[i].date == date && score > everyScores[i].score) {
          db.updateScore(Score(
              scoreId: everyScores[i].scoreId,
              userId: user.userId,
              activityId: idGame,
              scoreValue: score,
              scoreDate: date));

          //If he beats his score but not enough to get star
          if (tempStar != null) {
            starValue += tempStar.starValue;
            db.updateStar(Star(
                starId: tempStar.starId,
                activityId: idGame,
                userId: user.userId,
                starValue: starValue,
                starLevel: starLevel));
          }
        }
      }
      //Sinon on enregistre si la dernière date enregistrée est différente du jour
      if (everyScores[everyScores.length - 1].date != date) {
        db.addScore(newScore);
        starValue += tempStar.starValue;
        db.updateStar(Star(
            starId: tempStar.starId,
            activityId: idGame,
            userId: user.userId,
            starValue: starValue,
            starLevel: starLevel));
      }
    }
    /*Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => LoadPage(
                appLanguage: appLanguage,
                user: user,
                messageIn: "0",
                page: mainTitle,
              )),
    );*/

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainTitle(
            appLanguage: appLanguage,
            userIn: user,
            messageIn: "0",
          ),
        ),
        //(Route<dynamic> route) => route is MainTitle,
      );
    }

/*

    if (message == "fromRestart") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainTitle(
            appLanguage: appLanguage,
            userIn: user,
            messageIn: "0",
          ),
        ),
        //(Route<dynamic> route) => route is MainTitle,
      );
    } else
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainTitle(
            appLanguage: appLanguage,
            userIn: user,
            messageIn: "0",
          ),
        ),
        //  (Route<dynamic> route) => route is MainTitle,
      );
*/

    /*
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MainTitle(
            appLanguage: appLanguage,
            userIn: user,
            messageIn: "0",
          ),
        ),
      );
      */
    //Navigator.pop(context);
  }

  Widget closeButton(
      BuildContext context,
      AppLanguage appLanguage,
      User user,
      int score,
      var game,
      int idGame,
      double starValue,
      int starLevel,
      String message) {
    DatabaseHelper db = new DatabaseHelper();

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: game.screenSize.height * 0.2,
        width: game.screenSize.width / 3,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.grey[350]),
          ),
          onPressed: () async {
            //db.getScore(user.userId);

            print(message);
            saveAndExit(context, appLanguage, user, score, game, idGame,
                starValue, starLevel, message);
          },
          child: Text(
            AppLocalizations.of(context).translate('quitter'),
            style: textStyle,
          ),
        ),
      ),
    );
  }

  Widget restartButton(BuildContext context, AppLanguage appLanguage,
      int idGame, var game, User user) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: game.screenSize.height * 0.2,
        width: game.screenSize.width * 0.3,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.grey[350]),
          ),
          onPressed: () async {
            if (idGame == ID_CAR_ACTIVITY) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => new Car(
                      appLanguage: appLanguage,
                      user: user,
                      level: game.getStarLevel().toString(),
                      message: "fromRestart",
                    ),
                  ),
                  (Route<dynamic> route) => route is Car);
            } else if (idGame == ID_PLANE_ACTIVITY) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => new Plane(
                      appLanguage: appLanguage,
                      user: user,
                      level: game.getStarLevel().toString(),
                      message: "fromRestart",
                    ),
                  ),
                  (Route<dynamic> route) => route is Plane);
            } else if (idGame == ID_SWIMMER_ACTIVITY) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => new Swimmer(
                      appLanguage: appLanguage,
                      user: user,
                      level: game.getStarLevel().toString(),
                      message: "fromRestart",
                    ),
                  ),
                  (Route<dynamic> route) => route is Swimmer);
            } else if (idGame == ID_TEMP_ACTIVITY) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => new Temp(
                      appLanguage: appLanguage,
                      user: user,
                      level: game.getStarLevel().toString(),
                      message: "fromRestart",
                    ),
                  ),
                  (Route<dynamic> route) => route is Temp);
            }
          },
          child: Text(
            (AppLocalizations.of(context).translate('restart')),
            style: textStyle,
          ),
        ),
      ),
    );
  }

  Widget menu(BuildContext context, AppLanguage appLanguage, var game,
      User user, int idGame, String message) {
    if (game.screenSize == null) return Container();
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
            restartButton(context, appLanguage, idGame, game, user),
            closeButton(context, appLanguage, user, game.getScore(), game,
                idGame, game.getStarValue(), game.getStarLevel(), message),
          ],
        ),
      ),
    );
  }
}
