import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/AppLocalizations.dart';
import 'package:gbsalternative/BluetoothManager.dart';
import 'package:gbsalternative/CommonGamesUI.dart';
import 'package:gbsalternative/DatabaseHelper.dart';
import 'package:gbsalternative/Login.dart';
import 'package:gbsalternative/MainTitle.dart';
import 'package:gbsalternative/Swimmer/SwimGame.dart';

import 'Ui.dart';

String btData;
String _messageBuffer = '';
BluetoothConnection connexion;
bool isConnected;

class Swimmer extends StatefulWidget {
  final User user;
  final AppLanguage appLanguage;
  final String level;
  final String message;

  Swimmer(
      {Key key,
      @required this.user,
      @required this.appLanguage,
      @required this.level,
      @required this.message})
      : super(key: key);

  @override
  _Swimmer createState() => new _Swimmer(user, appLanguage, level, message);
}

class _Swimmer extends State<Swimmer> with WidgetsBindingObserver{
  User user;
  AppLanguage appLanguage;
  SwimGame game;

  BluetoothManager btManage =
      new BluetoothManager(user: null, inputMessage: null, appLanguage: null);

  String recording;
  String timeRemaining;
  int seconds;
  Timer timer;
  Timer _timer;
  int _start = 5;
  Timer timerThread;
  Timer timerConnexion;
  UI gameUI;
  CommonGamesUI commonGamesUI;
  bool endGame;
  int score;
  double starValue;
  int level;
  String message;

  _Swimmer(
      User _user, AppLanguage _appLanguage, String _level, String _message) {
    user = _user;
    appLanguage = _appLanguage;
    level = int.parse(_level);
    message = _message;
  }

  @override
  void initState() {
    //myGame = GameWrapper(game);
    if (user.userInitialPush != "0.0") {
      score = 0;
      starValue = 0.0;
      endGame = false;
      isConnected = false;
      WidgetsBinding.instance.addObserver(this);
      connect();
    }
    game = null;

    super.initState();
  }

  @override
  void dispose() {
    timerConnexion?.cancel();
    timer?.cancel();
    _timer?.cancel();
    timerThread?.cancel();
    game.timerSwimmer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  initSwimmer() async {
    WidgetsFlutterBinding.ensureInitialized();

    game = new SwimGame(getData, user, appLanguage);
    gameUI = new UI();
    commonGamesUI = new CommonGamesUI();
    game.setStarLevel(level);
    refreshScore();
    mainThread();
    startTimer(true);
    //gameUI.state.game = game;

    Flame.device.fullScreen();

    TapGestureRecognizer tapper = TapGestureRecognizer();

    tapper.onTapDown = game.onTapDown;

    //runApp(game.widget);
    //flameUtil.addGestureRecognizer(tapper);
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    /*if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) return;*/

    int tempTimer = 0;
    switch (state) {
      case AppLifecycleState.resumed:
        print("state: $state");
        break;
      case AppLifecycleState.inactive:
        print("state heeeeeeeeeeeere:: $state");
        break;
      case AppLifecycleState.paused:
        print("state heeeeeeeeeeeere: $state");
        game.pauseGame = true;
        tempTimer = 10;
        break;
      case AppLifecycleState.detached:
        print("state: $state");
        break;
    }
  }

  void connect() async {
    /*btManage.enableBluetooth();*/
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
        btManage.sendData("WU");
        launchGame();
        return;
      }
      //testConnect();
    }
  }

  void launchGame() {
    if (user.userMode == "1") {
      timeRemaining = "3:00";
      seconds = 180;
    } else {
      timeRemaining = "2:00";
      seconds = 120;
    }
    initSwimmer();
  }

  mainThread() async {
    const oneSec = const Duration(seconds: 1);
    timerThread = new Timer.periodic(oneSec, (Timer timer) {
      if (game.isTooHigh) {
        if (_start < 1) {
          timer.cancel();
          //Redirection vers le menu
          Navigator.pushReplacement(
            this.context,
            MaterialPageRoute(
              builder: (context) => MainTitle(
                appLanguage: appLanguage,
                userIn: user,
                messageIn: "0",
              ),
            ),
          );
        } else {
          _start = _start - 1;
        }
      }
    });
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
      if (mounted) {
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
      _timer = new Timer.periodic(
        time,
        (Timer timer) {
          //FIN DU JEU
          if (_start < delay) {
            //TODO Display menu ?
            game.pauseGame = true;
            endGame = true;
            _timer.cancel();
          } else if (!game.getConnectionState())
            _timer.cancel();
          else if (game.pauseGame || game.getGameOver()) {
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

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;    //Pause set by quitting app/lock phone
    if(commonGamesUI != null){
      if(commonGamesUI.getGamePauseState())
        game.pauseGame = true;
    }

    return WillPopScope(
      onWillPop: () {
        if (!endGame) game.pauseGame = !game.pauseGame;
        return;
      },
      child: Material(
          child: ColorFiltered(
        colorFilter: game != null
            ? game.getColorFilter()
            : ColorFilter.mode(Colors.transparent, BlendMode.luminosity),
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
                                "assets/images/ship/background.png"),
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
                mainAxisAlignment: MainAxisAlignment.center,
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
                          : !endGame && !game.getGameOver()
                              ? Container(
                                  alignment: Alignment.topRight,
                                  child: commonGamesUI.menu(
                                      context,
                                      appLanguage,
                                      game,
                                      user,
                                      ID_SWIMMER_ACTIVITY,
                                      message))
                              : Container(
                                  height: screenSize.height,
                                  alignment: Alignment.center,
                                  child: commonGamesUI.endScreen(
                                      context,
                                      appLanguage,
                                      game,
                                      ID_SWIMMER_ACTIVITY,
                                      user,
                                      starValue,
                                      level,
                                      score,
                                      message))
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
            //Display message pour afficher score et les secondes
            Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: game != null && !endGame && !game.getGameOver()
                  ? gameUI.state.displayScore(context, appLanguage,
                      score.toString(), timeRemaining, game)
                  : Container(),
            ),
            //Display message pour relancher
            Container(
              alignment: Alignment.bottomCenter,
              child: game != null
                  ? game.getColorFilterBool() &&
                          game.getPosition() &&
                          !game.getGameOver() &&
                          !game.getPauseStatus() &&
                          !game.isTooHigh
                      ? gameUI.state.displayMessage(
                          AppLocalizations.of(context).translate('relacher'),
                          game,
                          Colors.redAccent)
                      : Container()
                  : Container(),
            ),
            //Display message pour pousser
            Container(
              alignment: Alignment.topCenter,
              child: game != null
                  ? game.getColorFilterBool() &&
                          !game.getPosition() &&
                          !game.getGameOver() &&
                          !game.getPauseStatus() &&
                          !game.isTooHigh
                      ? gameUI.state.displayMessage(
                          AppLocalizations.of(context).translate('pousser'),
                          game,
                          Colors.redAccent)
                      : Container()
                  : Container(),
            ),
            /*
            //Display message Game Over
            Container(
              alignment: Alignment.center,
              child: game != null
                  ? !game.getGameOver() && !game.isTooHigh
                      ? Container(
                          alignment: Alignment.topCenter,
                          child: commonGamesUI.endScreen(
                              context,
                              appLanguage,
                              game,
                              ID_SWIMMER_ACTIVITY,
                              user,
                              starValue,
                              level,
                              score,
                              message))
                      */ /* Row(
                          children: <Widget>[
                            gameUI.state.displayMessage(
                                AppLocalizations.of(context)
                                    .translate('game_over'),
                                game,
                                Colors.blueAccent),
                          ],
                        )*/ /*
                      : Container()
                  : Container(),
            ),*/
            //Display message toise trop basse
            Container(
              alignment: Alignment.topCenter,
              child: game != null
                  ? game.isTooHigh
                      ? Row(
                          children: <Widget>[
                            gameUI.state.displayMessage(
                                AppLocalizations.of(context)
                                    .translate('reajuster_toise'),
                                game,
                                Colors.redAccent),
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
