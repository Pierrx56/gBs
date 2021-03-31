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
import 'package:gbsalternative/DatabaseHelper.dart';
import 'package:gbsalternative/Login.dart';
import 'package:gbsalternative/Plane/PlaneGame.dart';
import 'package:gbsalternative/CommonGamesUI.dart';
import 'package:gbsalternative/main.dart';

import 'Ui.dart';

class Plane extends StatefulWidget {
  final User user;
  final AppLanguage appLanguage;
  final String level;
  final String message;

  Plane({
    Key key,
    @required this.user,
    @required this.appLanguage,
    @required this.level,
    @required this.message,
  }) : super(key: key);

  @override
  _Plane createState() => new _Plane(user, appLanguage, level, message);
}

class _Plane extends State<Plane> with TickerProviderStateMixin {
  User user;
  AppLanguage appLanguage;
  PlaneGame game;
  CommonGamesUI commonGamesUI;
  bool isConnected;
  String btData;

  BluetoothManager btManage =
      new BluetoothManager(user: null, inputMessage: null, appLanguage: null);

  int i = 0;

  String timeRemaining;
  Timer timer;
  Timer _timer;
  int _start = 3;
  bool start;
  bool gameOver;
  int seconds;
  Timer timerConnexion;
  UI gameUI;
  int score;
  double starValue;
  int level;
  String message;

  _Plane(User _user, AppLanguage _appLanguage, String _level, String _message) {
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
      i = 0;

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
    game?.timerData?.cancel();
    super.dispose();
  }

  initPlane() async {
    WidgetsFlutterBinding.ensureInitialized();

    game = new PlaneGame(getData, user, appLanguage);

    commonGamesUI = new CommonGamesUI();

    game.setStarLevel(level);
    gameUI = new UI();
    refreshScore();

    Flame.device.fullScreen();

    //TODO Ajust values
    //On double la vitesse des ballon et la vitesse de remontée/redescente de l'avion
    //Le temps passe de 2 min à 3 min
    //1 pour sportif
    if (user.userMode == "1") {
      timeRemaining = "3:00";
      seconds = 180;
      game.difficulte = 6.0;
      game.setBalloonSpeed(4);
    } else {
      timeRemaining = "2:00";
      seconds = 120;
      game.difficulte = 3.0;
      game.setBalloonSpeed(2);
    }
    //Start timer of 2 minutes
    startTimer(true);

    TapGestureRecognizer tapper = TapGestureRecognizer();

    tapper.onTapDown = game.onTapDown;
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
        Timer(Duration(milliseconds: 500), () {
          connect();
        });
      } else {
        initPlane();
        return;
      }
      //testConnect();
    }
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
    timer = new Timer.periodic(Duration(milliseconds: 300), (timer) {
      if (this.mounted) {
        if (game != null) {
          setState(() {
            score = game.getScore();
          });
        }
      }
    });
  }

  void startTimer(bool boolean) async {
    int _start = seconds;
    const int delay = 1;

    if (!boolean && isConnected) {
      _start = seconds;
    } else {
      const time = const Duration(seconds: delay);
      _timer = Timer.periodic(
        time,
        (Timer timer) {
          //FIN DU JEU
          if (_start < delay) {
            game.pauseGame = true;
            gameOver = true;
            _timer.cancel();
            redirection();
          } else if (!game.getConnectionState()) {
            _timer.cancel();
          } else if (game.pauseGame) {
            timeRemaining = convertDuration(Duration(seconds: _start));
          } else {
            _start -= delay;
            timeRemaining = convertDuration(Duration(seconds: _start));
          }
        },
      );
    }
  }

  String convertDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    /*${twoDigits(duration.inHours)}:*/
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  void redirection() {
    const oneSec = const Duration(seconds: 1);
    Timer(
      oneSec,
      mounted
          ? {
              setState(
                () {
                  if (_start < 1) {
                    //TODO Update value
                    if (user.userMode == "0" && score > 15) {
                      setState(() {
                        game.setStarValue(starValue = 0.5);
                      });
                    } else if (user.userMode == "1" && score > 50) {
                      setState(() {
                        game.setStarValue(starValue = 0.5);
                      });
                    } else {
                      setState(() {
                        game.setStarValue(starValue = 0.0);
                      });
                    }

                    timer.cancel();
                    commonGamesUI.saveAndExit(context, appLanguage, user, score,
                        game, ID_PLANE_ACTIVITY, starValue, level, message);
                  } else {
                    _start = _start - 1;
                  }
                },
              )
            }
          : start = start,
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () {
        if (!gameOver) game.pauseGame = !game.pauseGame;
        return;
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      CircularProgressIndicator(),
                                      double.parse(user.userInitialPush) == 0
                                          ? AutoSizeText(AppLocalizations.of(
                                                  context)
                                              .translate('premiere_poussee_sw'))
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
                                        child: Text(
                                          AppLocalizations.of(context)
                                              .translate('retour'),
                                          style: textStyle,
                                        ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                                  : commonGamesUI.pauseButton(
                                      context, appLanguage, game, user),
                            )
                          : !gameOver
                              ? Container(
                                  alignment: Alignment.topRight,
                                  child: commonGamesUI.menu(
                                      context,
                                      appLanguage,
                                      game,
                                      user,
                                      ID_PLANE_ACTIVITY,
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
                                            ID_PLANE_ACTIVITY,
                                            user,
                                            starValue,
                                            level,
                                            score,
                                            message),
                                      ),
                                    ],
                                  ))
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
            game != null
                ? !game.getGameOver() &&
                        game.getConnectionState() &&
                        !game.pauseGame
                    ? Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 25),
                        child: game == null
                            ? Container()
                            : gameUI.state.displayScore(
                                score.toString(), game, timeRemaining),
                      )
                    : Container()
                : Container(),
            //Display message Game Over
            Container(
              alignment: Alignment.centerRight,
              child: game != null
                  ? game.getGameOver()
                      ? gameUI.state.displayMessage(
                          AppLocalizations.of(context).translate('game_over'),
                          game,
                          Colors.redAccent)
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
