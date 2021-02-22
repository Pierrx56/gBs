import 'dart:async';
import 'dart:io';
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
import 'package:gbsalternative/Swimmer/SwimGame.dart';

import 'Ui.dart';

String btData;
String _messageBuffer = '';
List<_Message> messages = List<_Message>();
BluetoothConnection connexion;
bool isConnected;
SwimGame game;

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class Swimmer extends StatefulWidget {
  final User user;
  final AppLanguage appLanguage;
  final String level;

  Swimmer(
      {Key key,
      @required this.user,
      @required this.appLanguage,
      @required this.level})
      : super(key: key);

  @override
  _Swimmer createState() => new _Swimmer(user, appLanguage, level);
}

class _Swimmer extends State<Swimmer> {
  User user;
  AppLanguage appLanguage;

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

  _Swimmer(User _user, AppLanguage _appLanguage, String _level) {
    user = _user;
    appLanguage = _appLanguage;
    level = int.parse(_level);
  }

  @override
  void initState() {
    //myGame = GameWrapper(game);
    if (user.userInitialPush != "0.0") {
      score = 0;
      starValue = 0.0;
      endGame = false;
      isConnected = false;
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
    Util flameUtil = Util();
    flameUtil.fullScreen();

    TapGestureRecognizer tapper = TapGestureRecognizer();

    tapper.onTapDown = game.onTapDown;

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

  testConnect() async {
    isConnected = await btManage.getStatus();
    if (!isConnected) {
      timerConnexion = new Timer.periodic(Duration(milliseconds: 1500),
          (timerConnexion) async {
        btManage.connect(user.userMacAddress, user.userSerialNumber);
        isConnected = await btManage.getStatus();

        if (isConnected) {
          timerConnexion.cancel();
          launchGame();
          //refreshScore();
        }
      });
    }
  }

  void launchGame() {
    if (user.userMode == AppLocalizations.of(context).translate('sportif')) {
      timeRemaining = "3:00";
      seconds = 180;
    } else {
      timeRemaining = "2:00";
      seconds = 10;
    }
    initSwimmer();
  }

  mainThread() async {
    timerThread = new Timer.periodic(Duration(milliseconds: 1000),
        (timerConnexion) async {
      if (game.isTooHigh) {
        const oneSec = const Duration(seconds: 1);
        _timer = new Timer.periodic(oneSec, (Timer timer) {
          if (_start < 1) {
            timer.cancel();
            //Redirection vers le menu
            Navigator.pushReplacement(
              this.context,
              MaterialPageRoute(
                builder: (context) => LoadPage(
                  appLanguage: appLanguage,
                  user: user,
                  messageIn: "0",
                  page: mainTitle,
                ),
              ),
            );
          } else {
            _start = _start - 1;
          }
        });
      }
    });
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
            timer.cancel();
          } else if (!game.getConnectionState())
            timer.cancel();
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
    Size screenSize = MediaQuery.of(context).size;

    return Material(
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
                              "assets/images/swimmer/background.png"),
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                    RaisedButton(
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => LoadPage(
                                                    appLanguage: appLanguage,
                                                    user: user,
                                                    messageIn: "0",
                                                    page: mainTitle,
                                                  )),
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
                                : gameUI.state.pauseButton(
                                    context, appLanguage, game, user),
                          )
                        : !endGame
                            ? Container(
                                alignment: Alignment.topRight,
                                child: gameUI.state
                                    .menu(context, appLanguage, game, user))
                            : Container(
                                alignment: Alignment.topCenter,
                                child: commonGamesUI.endScreen(
                                    context,
                                    appLanguage,
                                    game,
                                    ID_SWIMMER_ACTIVITY,
                                    user,
                                    starValue,
                                    level,
                                    score))
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
            alignment: Alignment.bottomLeft,
            padding: EdgeInsets.fromLTRB(10, 10, 10, 25),
            child: game != null && !endGame
                ? gameUI.state.displayScore(
                    context, appLanguage, score.toString(), timeRemaining, game)
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
          //Display message Game Over
          Container(
            alignment: Alignment.topCenter,
            child: game != null
                ? game.getGameOver() && !game.isTooHigh
                    ? Row(
                        children: <Widget>[
                          gameUI.state.displayMessage(
                              AppLocalizations.of(context)
                                  .translate('game_over'),
                              game,
                              Colors.blueAccent),
                        ],
                      )
                    : Container()
                : Container(),
          ),
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
        );
  }
}
