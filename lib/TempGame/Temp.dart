import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flame/util.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/AppLocalizations.dart';
import 'package:gbsalternative/BluetoothManager.dart';
import 'package:gbsalternative/CommonGamesUI.dart';
import 'package:gbsalternative/DatabaseHelper.dart';
import 'package:gbsalternative/LoadPage.dart';
import 'package:gbsalternative/Login.dart';
import 'package:gbsalternative/TempGame/TempGame.dart';

import 'Ui.dart';

String btData;
String _messageBuffer = '';
List<_Message> messages = List<_Message>();
BluetoothConnection connexion;
bool isConnected;
TempGame game;

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class Temp extends StatefulWidget {
  final User user;
  final AppLanguage appLanguage;
  final String level;
  final String message;

  Temp({
    @required this.user,
    @required this.appLanguage,
    @required this.level,
    @required this.message,
  });

  @override
  _Temp createState() => new _Temp(user, appLanguage, level, message);
}

class _Temp extends State<Temp> {
  User user;
  AppLanguage appLanguage;

  BluetoothManager btManage =
      new BluetoothManager(user: null, inputMessage: null, appLanguage: null);

  String recording;
  Timer _timer;
  int _start = 5;
  Timer timerThread;
  Timer timerProgressBar;
  Timer timerProgressBar2;
  Timer timerConnexion;
  bool start;
  double push;
  UI gameUI;
  CommonGamesUI commonGamesUI;
  int coins;
  int jumpCounter;
  int previousJumpCounter;
  double starValue;
  int level;
  String message;
  int cinq = 5;
  double totalPush = 0.0;
  double determineJump = 0.0;
  int k = 0;

  //Si raté 0, sinon étage 1, 2 ou 3
  int jumpToFloor = 1;

  _Temp(User _user, AppLanguage _appLanguage, String _level, String _message) {
    user = _user;
    appLanguage = _appLanguage;
    level = int.parse(_level);
    message = _message;
  }

  @override
  void initState() {
    //myGame = GameWrapper(game);
    if (user.userInitialPush != "0.0") {
      gameUI = UI();
      commonGamesUI = CommonGamesUI();
      coins = 0;
      isConnected = false;
      start = false;
      push = 0.99;
      connect();
    }
    game = null;

    super.initState();
  }

  @override
  void dispose() {
    timerConnexion?.cancel();
    _timer?.cancel();
    timerThread?.cancel();
    timerProgressBar?.cancel();
    timerProgressBar2?.cancel();
    game.tempTimer?.cancel();
    game.timerPosition?.cancel();
    game.timerTuto?.cancel();

    super.dispose();
  }

  initTemp() async {
    WidgetsFlutterBinding.ensureInitialized();

    game = TempGame(getData, getPush, getFloor, setFloor, user, appLanguage);

    //gameUI.state.game = game;
    Util flameUtil = Util();
    flameUtil.fullScreen();
    game.setStarLevel(level);

    TapGestureRecognizer tapper = TapGestureRecognizer();

    tapper.onTapDown = game.onTapDown;

    previousJumpCounter = game.getJumpCounter();

    refreshScore();
    //setSignPosition();
    //runApp(game.widget);
    flameUtil.addGestureRecognizer(tapper);
  }

  void connect() async {
    /*btManage.enableBluetooth();*/
    if (await btManage.enableBluetooth()) {
      connect();
    } else {
      isConnected = await btManage.getStatus();
      if (!isConnected) {
        btManage.connect(user.userMacAddress, user.userSerialNumber);
        connect();
      } else {
        launchGame();
        return;
      }
      //testConnect();
    }
  }

  void launchGame() {
    initTemp();
  }

  void setData() async {
    var temp = await btManage.getStatus();
    if (!temp)
      btData = "-1.0";
    else
      btData = await btManage.getData();
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
    timerThread =
        new Timer.periodic(Duration(milliseconds: 300), (Timer timer) {
      //Condition de victoire
      if (game.getJumpCounter() >= 10) {
        game.endGame = true;
        game.gameOver = true;
        game.pauseGame = true;
        timerThread.cancel();
      }

      if (mounted) {
        if (game != null) {
          setState(() {
            coins = game.getCoins();
            jumpCounter = game.getJumpCounter();
          });
        }
      }
      heightProgressBar();
    });
  }

  //Calcul de la progress bar
  double heightProgressBar() {
    double tempPush = getData();

    //Si le joueur a dépassé le drapeau ou qu'il attend au bout de la plateforme
    //ou si le joueur n'est pas tombé dans le vide
    if ((game.isWaiting || game.isPushable) &&
        !game.launchTuto &&
        game.previousFloor != 0) {
      //push = 0.99;
      if (double.parse(user.userInitialPush) < tempPush &&
          push > 0.0 &&
          cinq == 5 &&
          !game.pauseGame) {
        game.setPushState(true);

        cinq--;

        //Récupère les données du capteur toutes les 200ms
        timerProgressBar = Timer.periodic(
          Duration(milliseconds: 200),
          (Timer timer) {
            totalPush += getData();
            k++;
            if (cinq < 1) {
              timerProgressBar.cancel();
            }
          },
        );
        //Compteur de 5 secs
        timerProgressBar2 = Timer.periodic(
          Duration(seconds: 1),
          (Timer timer) {
            if (!game.pauseGame) {
              if (push >= 1 / 5)
                push -= 1 / 5;
              else
                push = 0.0;

              if (cinq < 1) {
                //push = 0.0;
                timerProgressBar2.cancel();
              } else {
                cinq--;
              }
            }
          },
        );
      } else if (!game.pauseGame && game.isPushable) {
        determineJump = totalPush / k;

        //if (jumpToFloor != 0) previousFloor = jumpToFloor;

        if (determineJump < double.parse(user.userInitialPush)) {
          jumpToFloor = 0;
        }
        if (determineJump >= double.parse(user.userInitialPush) &&
            determineJump < double.parse(user.userInitialPush) * 1.2) {
          if (jumpToFloor == -1 || jumpToFloor == 0) jumpToFloor = 1;
          //previousFloor = jumpToFloor;
          jumpToFloor = 1;
        }
        if (determineJump >= double.parse(user.userInitialPush) * 1.2 &&
            determineJump < double.parse(user.userInitialPush) * 1.4) {
          if (jumpToFloor == -1 || jumpToFloor == 0) jumpToFloor = 2;
          //previousFloor = jumpToFloor;
          jumpToFloor = 2;
        }
        if (determineJump >= double.parse(user.userInitialPush) * 1.4) {
          if (jumpToFloor == -1 || jumpToFloor == 0) jumpToFloor = 3;
          //previousFloor = jumpToFloor;
          jumpToFloor = 3;
        }

        //print(determineJump);
      }
    } else {
      cinq = 5;
      push = 0.99;
      k = 0;
      totalPush = 0;
      game.setPushState(false);
      determineJump = 0.0;

      //Lorsqu'il a sauté, on sauvegarde l'ancienne plateforme dans le cas où il loupe son prochain saut
      if (previousJumpCounter != jumpCounter && jumpToFloor != 0) {
        game.previousFloor = jumpToFloor;
        previousJumpCounter = jumpCounter;
      }
    }
    //On retourne un pourcentage
    return push;
  }

  void setFloor() {
    print("JumpToFloor: $jumpToFloor");
    print("PreviousFloor: ${game.previousFloor}");
    jumpToFloor = game.previousFloor;
  }

  int getFloor() {
    return jumpToFloor;
  }

  double getPush() {
    return push;
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () {
        if (!game.endGame) game.pauseGame = !game.pauseGame;
        return;
      },
      child: Material(
          child: ColorFiltered(
        colorFilter: game != null
            ? game.getColorFilter()
            : ColorFilter.mode(Colors.transparent, BlendMode.luminosity),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            game == null || double.parse(user.userInitialPush) == 0
                ? Center(
                    child: Container(
                        width: screenSize.width,
                        height: screenSize.height,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: ExactAssetImage(
                                "assets/images/temp/background.png"),
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
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.grey[350]),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(
                                            context,
                                            /*
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
                                            .translate('retour')),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  )
                : game.widget,

            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  //Menu
                  game != null
                      ? !game.pauseGame &&
                              !game.getGameOver() &&
                              game.getConnectionState()
                          ? Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                height: screenSize.height,
                                alignment: Alignment.topRight,
                                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                child: game != null
                                    ? commonGamesUI.pauseButton(
                                        context, appLanguage, game, user)
                                    : Container(),
                              ),
                            )
                          : !game.getEndGame() && !game.getGameOver()
                              ? Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                      alignment: Alignment.topRight,
                                      child: commonGamesUI.menu(
                                          context,
                                          appLanguage,
                                          game,
                                          user,
                                          ID_TEMP_ACTIVITY,
                                          message)),
                                )
                              : Container()
                      : Container(),
                ],
              ),
            ),
            //Display coins and life
            game != null && !game.getGameOver()
                ? game.getConnectionState()
                    ? Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 25),
                        child: game == null
                            ? Container()
                            : gameUI.state.displayCoin(coins.toString(), game),
                      )
                    : Container()
                : Container(),
            //Display tuto
            game != null && !game.getGameOver()
                ? game.getConnectionState()
                    ? game.isPushable && game.coins == 0 && game.launchTuto
                        ? Container(
                            alignment: Alignment(-0.5, 0.5),
                            padding: EdgeInsets.fromLTRB(10, 10, 10, 25),
                            child: game == null
                                ? Container()
                                : gameUI.state.displayTuto(
                                    context, appLanguage, game, user),
                          )
                        : Container()
                    : Container()
                : Container(),
            //Consigne
            game != null
                ? game.isWaiting &&
                            !game.getGameOver() &&
                            game.coins == 0 &&
                            !game.pauseGame ||
                        game.life < 2 && game.isWaiting && !game.pauseGame ||
                        game.coins == 0 &&
                            game.isPushable &&
                            !game.launchTuto &&
                            !game.pauseGame
                    ? !game.getGameOver()
                        ? game.getConnectionState()
                            ? Container(
                                alignment: Alignment.topCenter,
                                padding: EdgeInsets.fromLTRB(
                                    20, screenSize.height * 0.1, 20, 20),
                                child: Container(
                                  width: screenSize.width * 0.5,
                                  height: screenSize.height / 3,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    //color: Color.fromRGBO(255, 255, 255, 0.7),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Container(
                                          height: screenSize.height / 3.5,
                                          child: AutoSizeText(
                                            AppLocalizations.of(context)
                                                .translate('remplir_jauge'),
                                            minFontSize: 15,
                                            maxLines: 3,
                                            style: TextStyle(
                                              fontSize: 35,
                                              color: Colors.pink,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Container()
                        : Container()
                    : Container()
                : Container(),
            //Display jauge à remplir
            game != null
                ? (game.isWaiting || game.isPushable)
                    ? !game.getGameOver()
                        ? game.getConnectionState()
                            ? Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.all(20),
                                child: Container(
                                  width: screenSize.height / 8,
                                  height: screenSize.width / 4,
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: AnimatedContainer(
                                      //child: Text(jumpToFloor.toString(), textAlign: TextAlign.center, style: textStyle,),
                                      duration: Duration(seconds: 1),
                                      width: screenSize.height / 8,
                                      height:
                                          (screenSize.width / 4) * getPush(),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.blue[300],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container()
                        : Container()
                    : Container()
                : Container(),
            //Display message Game Over
            Container(
              alignment: Alignment.topCenter,
              child: game != null
                  ? game.getGameOver() && !game.getEndGame()
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            commonGamesUI.endScreen(
                                context,
                                appLanguage,
                                game,
                                ID_TEMP_ACTIVITY,
                                user,
                                starValue,
                                level,
                                coins,
                                message),

                            /*gameUI.state.displayMessage(
                                AppLocalizations.of(context)
                                    .translate('game_over'),
                                game,
                                Colors.blueAccent),*/
                          ],
                        )
                      : Container()
                  : Container(),
            ),
            //Display message Fin du jeu (pas GameOver)
            Container(
              alignment: Alignment.topCenter,
              child: game != null
                  ? game.getEndGame()
                      //? game.pauseGame
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            commonGamesUI.endScreen(
                                context,
                                appLanguage,
                                game,
                                ID_TEMP_ACTIVITY,
                                user,
                                starValue,
                                level,
                                coins,
                                message),
                            //gameUI.state.endScreen(context, appLanguage, game, user, level),
                          ],
                        )
                      : Container()
                  : Container(),
            ),
            //Display message Lost connexion
            Container(
              alignment: Alignment.topCenter,
              child: game != null
                  ? !game.getConnectionState()
                      ? Row(
                          children: <Widget>[
                            gameUI.state.displayMessage(
                                AppLocalizations.of(context)
                                    .translate('connexion_perdue'),
                                game,
                                Colors.redAccent),
                          ],
                        )
                      : Container()
                  : Container(),
            ),
          ],
        ),
      )

          /*Positioned.fill(

                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: game.onTapDown,
                  child: game.widget,
                ),
              ),*/
          ),
    );
  }
}
