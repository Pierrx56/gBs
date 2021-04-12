import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:confetti/confetti.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/AppLocalizations.dart';
import 'package:gbsalternative/BluetoothManager.dart';
import 'package:gbsalternative/CommonGamesUI.dart';
import 'package:gbsalternative/DatabaseHelper.dart';
import 'package:gbsalternative/Car/CarGame.dart';
import 'package:gbsalternative/Login.dart';
import 'package:gbsalternative/MainTitle.dart';

import 'Ui.dart';

String btData;
bool isConnected;

class Car extends StatefulWidget {
  final User user;
  final AppLanguage appLanguage;
  final String level;
  final String message;

  Car(
      {Key key,
      @required this.user,
      @required this.appLanguage,
      @required this.level,
      @required this.message})
      : super(key: key);

  @override
  _Car createState() => new _Car(user, appLanguage, level, message);
}

class _Car extends State<Car> with TickerProviderStateMixin {
  User user;
  AppLanguage appLanguage;
  CarGame game;

  BluetoothManager btManage =
      new BluetoothManager(user: null, inputMessage: null, appLanguage: null);

  CommonGamesUI commonGamesUI = new CommonGamesUI();

  String timeRemaining;
  Timer timer;
  Timer _timer;
  Timer timerRedirection;
  Timer pauseTimer;
  bool start;
  bool gameOver;
  int seconds;
  Timer timerConnexion;
  UI gameUI;
  int score = 0;
  double starValue;
  int level;
  String message = "";

  ConfettiController _controllerTopCenter;

  _Car(User _user, AppLanguage _appLanguage, String _level, String _message) {
    user = _user;
    appLanguage = _appLanguage;
    level = int.parse(_level);
    message = _message;
  }

  @override
  void initState() {
    game = null;
    if (user.userInitialPush != "0.0") {
      score = 0;
      starValue = 0.0;

      _controllerTopCenter =
          ConfettiController(duration: const Duration(seconds: 10));

      start = false;
      gameOver = false;
      isConnected = false;
      connect();
    }

    super.initState();
  }

  @override
  void dispose() {
    timerConnexion?.cancel();
    timer?.cancel();
    _timer?.cancel();
    timerRedirection?.cancel();
    _controllerTopCenter?.dispose();
    pauseTimer?.cancel();
    game.timerPause?.cancel();
    super.dispose();
  }

  initPlane() async {
    WidgetsFlutterBinding.ensureInitialized();

    game = new CarGame(getData, user, appLanguage);

    game.setStarLevel(level);
    gameUI = new UI();
    refreshScore();
    Flame.device.fullScreen();

    TapGestureRecognizer tapper = TapGestureRecognizer();

    tapper.onTapDown = game.onTapDown;
    //TODO Ajust values
    //On double la vitesse des ballon et la vitesse de remontée/redescente de l'avion
    //Le temps passe de 2 min à 3 min
    if (user.userMode == "1") {
      timeRemaining = "3:00";
      seconds = 180;
      game.difficulte = 6.0;
      game.setRoadSpeed(6);
    } else {
      timeRemaining = "2:00";
      seconds = 120;
      game.difficulte = 3.0;
      game.setRoadSpeed(6);
    }
    //Start timer of 2 minutes
    //startTimer(true);

    //flameUtil.addGestureRecognizer(tapper);
  }

  bool isDisconnecting = false;

  void connect() async {
    //Tant que le bluetooth n'est pas activé, on demande son activation
    if (await btManage.enableBluetooth()) {
      connect();
    } else {
      isConnected = await btManage.getStatus();
      if (!isConnected) {
        btManage.connect(user.userMacAddress, user.userSerialNumber);
        Timer(Duration(milliseconds: 500), (){
          connect();
        });
      } else {
        launchGame();
        return;
      }
      //testConnect();
    }
  }

  void launchGame() {
    initPlane();
  }

  void setData() async {
    var temp = await btManage.getStatus();
    if (!temp)
      btData = "-1.0";
    else
      btData = await btManage.getData("F");
  }

  double getData() {
    setData();

    if (btData != null)
      return double.parse(btData);
    else if (btData == "-1.0")
      return -1.0;
    else {
      //print("salut");
      return 2.0;
    }
  }

  refreshScore() async {
    int temporaire = 0;
    timer = new Timer.periodic(Duration(milliseconds: 300), (timer) {
      temporaire++;
      if (this.mounted) {
        if (game != null) {
          setState(() {
            score = game.getScore();
          });
          //Toutes les 900ms, change la taille de pause
          if (game.isWaiting && temporaire % 3 == 0 && !game.pauseGame)
            switchSize();
        }
      }
    });
  }

  String convertDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    /*${twoDigits(duration.inHours)}:*/
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  void switchSize() async {
    game.changeSize = !game.changeSize;
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;    //Pause set by quitting app/lock phone
    if(commonGamesUI != null){
      if(commonGamesUI.getGamePauseState())
        game.pauseGame = true;
    }

    return WillPopScope(
      onWillPop: () {
        if (!game.endOfGame) game.pauseGame = !game.pauseGame;
        return;
        /*
        if (message == "fromRestart") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainTitle(
                appLanguage: appLanguage,
                messageIn: "",
                userIn: user,
              ),
            ),
          );
        } else
          Navigator.pop(context);

        return;

         */
      },
      child: Material(
        child: Stack(
          children: <Widget>[
            game == null || double.parse(user.userInitialPush) == 0
                ? Center(
                    child: Container(
                        width: screenSize.width,
                        height: screenSize.height,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: ExactAssetImage(
                                "assets/images/plane/background.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                          child: Stack(
                            children: <Widget>[
                              Center(
                                child: Container(
                                  width: screenSize.width / 2,
                                  height: screenSize.height / 2,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Color.fromRGBO(255, 255, 255, 0.7),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: <Widget>[
                                      CircularProgressIndicator(),
                                      double.parse(user.userInitialPush) == 0
                                          ? AutoSizeText(
                                              AppLocalizations.of(context)
                                                  .translate(
                                                      'premiere_poussee_sw'))
                                          : AutoSizeText(
                                              AppLocalizations.of(context)
                                                  .translate('verif_alim'),
                                              minFontSize: 15,
                                              maxLines: 3,
                                              style: TextStyle(fontSize: 25),
                                              textAlign: TextAlign.center,
                                            ),
                                      ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor: colorButton),
                                        onPressed: () {
                                          Navigator.pop(
                                            context, /*
                                            MaterialPageRoute(
                                                builder: (context) => LoadPage(
                                                      appLanguage: appLanguage,
                                                      user: user,
                                                      messageIn: "0",
                                                      page: mainTitle,
                                                    )),*/
                                          );
                                        },
                                        child: Text(AppLocalizations.of(context)
                                            .translate('retour'), style: textStyle,),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  )
                : GameWidget(game: game),

            SingleChildScrollView(
              child: Stack(
                children: <Widget>[
/*                Container(
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: game == null
                        ? Container()
                        : gameUI.state.closeButton(
                        context, appLanguage, user, game.getScore()),
                  ),*/
                  game != null
                      ? !game.pauseGame &&
                              !game.getGameOver() &&
                              game.getConnectionState()
                          ? Container(
                              alignment: Alignment.topRight,
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: game == null
                                  ? Container()
                                  : commonGamesUI.pauseDebugButton(
                                      context, appLanguage, game, user),
                            )
                          : !game.endOfGame && !game.getGameOver()
                              ? Container(
                                  alignment: Alignment.topRight,
                                  //alignment: Alignment.topLeft,
                                  child: commonGamesUI.menu(
                                      context,
                                      appLanguage,
                                      game,
                                      user,
                                      ID_CAR_ACTIVITY,
                                      message))
                              : Container(
                                  alignment: Alignment.topCenter,
                                  height: screenSize.height,
                                  child: Stack(
                                    children: <Widget>[
                                      Align(
                                        alignment: Alignment.center,
                                        child: commonGamesUI.endScreen(
                                            context,
                                            appLanguage,
                                            game,
                                            ID_CAR_ACTIVITY,
                                            user,
                                            game.getStarValue(),
                                            game.getStarLevel(),
                                            game.score,
                                            message),
                                      ), /*
                                      //TOP CENTER - shoot down
                                      Align(
                                        alignment: Alignment.center,
                                        child: ConfettiWidget(
                                          confettiController:
                                              _controllerTopCenter,
                                          blastDirection: math.pi / 2,
                                          maxBlastForce: 5,
                                          // set a lower max blast force
                                          minBlastForce: 2,
                                          // set a lower min blast force
                                          emissionFrequency: 0.05,
                                          numberOfParticles: 50,
                                          // a lot of particles at once
                                          gravity: 1,
                                        ),
                                      ),*/
                                    ],
                                  ))
                      : Container(),

                  //Display coins and life
                  game != null && !game.getGameOver()
                      ? game.getConnectionState()
                          ? Container(
                              alignment: Alignment.topLeft,
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 25),
                              child: game == null
                                  ? Container()
                                  : gameUI.state
                                      .displayItems(score.toString(), game),
                            )
                          : Container()
                      : Container(),

                  //Display waiting screen
                  game != null && !game.getGameOver()
                      ? game.getConnectionState()
                          ? Container(
                              alignment: Alignment.center,
                              height: game.screenSize.height,
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 25),
                              child: game.isWaiting
                                  ? gameUI.state.waitingScreen(game)
                                  : Container(),
                            )
                          : Container()
                      : Container(),
                  /*              Container(
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: game == null
                        ? Container()
                        : gameUI.state.restartButton(context, appLanguage, user),
                  ),
*/
                ],
              ),
            ),
            //Display message afficher le score et les secondes
/*              game != null
                ? !game.getGameOver() && game.getConnectionState()
                    ? Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 25),
                        child: game == null
                            ? Container()
                            : gameUI.state.displayScore(
                                score.toString(), game, timeRemaining),
                      )
                    : Container()
                : Container(),*/
            //Display message Game Over
            Container(
              alignment: Alignment.centerRight,
              child: game != null
                  ? game.getGameOver()
                      ? Align(
                          alignment: Alignment.center,
                          child: commonGamesUI.endScreen(
                              context,
                              appLanguage,
                              game,
                              ID_CAR_ACTIVITY,
                              user,
                              game.getStarValue(),
                              game.getStarLevel(),
                              game.score,
                              message),
                        )
                      : Container()
                  : Container(),
            ),
            //Display message Lost connexion
            Container(
              alignment: Alignment.centerRight,
              child: game != null
                  ? !game.getConnectionState()
                      ? gameUI.state.displayMessage(
                          AppLocalizations.of(context)
                              .translate('connexion_perdue'),
                          game,
                          Colors.redAccent)
                      : Container()
                  : Container(),
            ),
            /*
            Padding(
              padding: EdgeInsets.fromLTRB(50, 0, 0, 0),
              child: Container(
                width: 50,
                height: 50,
                color: Colors.red,
              ),
            )*/

            /*
            //Display timer
            Container(
                alignment: Alignment.centerRight,
                child: game != null
                    ? gameUI.state.displayMessage(timeRemaining, game)
                    : Container()),*/
          ],
        ),
      ),
    );
  }
}
