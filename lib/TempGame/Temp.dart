import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flame/util.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_rounded_progress_bar/flutter_rounded_progress_bar.dart';
import 'package:flutter_rounded_progress_bar/rounded_progress_bar_style.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/AppLocalizations.dart';
import 'package:gbsalternative/BluetoothManager.dart';
import 'package:gbsalternative/DatabaseHelper.dart';
import 'package:gbsalternative/LoadPage.dart';
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

  Temp({@required this.user, @required this.appLanguage});

  @override
  _Temp createState() => new _Temp(user, appLanguage);
}

class _Temp extends State<Temp> {
  User user;
  AppLanguage appLanguage;

  BluetoothManager btManage =
      new BluetoothManager(user: null, inputMessage: null, appLanguage: null);

  String recording;
  Timer timer;
  Timer _timer;
  Timer timerHeight;
  int _start = 5;
  Timer timerThread;
  Timer timerConnexion;
  bool start;
  double push;
  UI gameUI;
  int score;

  _Temp(User _user, AppLanguage _appLanguage) {
    user = _user;
    appLanguage = _appLanguage;
  }

  @override
  void initState() {
    //myGame = GameWrapper(game);
    if (user.userInitialPush != "0.0") {
      gameUI = UI();
      score = 0;
      isConnected = false;
      start = false;
      push = 0.0;
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
    timerHeight?.cancel();
    timerThread?.cancel();
    super.dispose();
  }

  initTemp() async {
    WidgetsFlutterBinding.ensureInitialized();

    game = new TempGame(getData, getPush, user, appLanguage);
    refreshScore();
    mainThread();
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
      btManage.connect(user.userMacAddress, user.userSerialNumber);
      isConnected = await btManage.getStatus();
      if (isConnected) {
        launchGame();
        return;
      }
      testConnect();
    }
  }

  void launchGame() {
    initTemp();
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
/*    if (isConnected) {
      initSwimmer();
      //refreshScore();
    }*/
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
      heightProgressBar();
    });
  }

  //Calcul de la progress bar
  double heightProgressBar() {
    double tempPush = getData();

    if (game.isWaiting) {
      //Poussée pendant 6 secondes
      if (double.parse(user.userInitialPush) < tempPush && push <= 1) {
        timerHeight = new Timer(const Duration(milliseconds: 600), () {
          push += 0.05;
        });
      } else if (push <= 1.5 && push > 0.06) {
        timerHeight = new Timer(const Duration(milliseconds: 5), () {
          push -= 0.05;
        });
      } else if (push <= 0.1) push = 0.0;
    }
    else if(game.isRunning) {
      push = 0.0;
    }
    //On retourne un pourcentage
    return push;
  }

  double getPush() {
    return push;
  }

  @override
  Widget build(BuildContext context) {
    //UI gameUI = UI();
    //gameUI.state.game = game;

    Size screenSize = MediaQuery.of(context).size;

    return Material(
        child: ColorFiltered(
      colorFilter: game != null
          ? game.getColorFilter()
          : ColorFilter.mode(Colors.transparent, BlendMode.luminosity),
      child: Stack(
        children: <Widget>[
          game == null || user.userInitialPush == "0.0"
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    CircularProgressIndicator(),
                                    user.userInitialPush == "0.0"
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
                        : !game.isTooHigh
                            ? Container(
                                alignment: Alignment.topRight,
                                child: gameUI.state
                                    .menu(context, appLanguage, game, user))
                            : Container()
                    : Container(),
              ],
            ),
          ),
          //Display message pour afficher score
          /*Container(
            alignment: Alignment.bottomLeft,
            padding: EdgeInsets.fromLTRB(10, 10, 10, 25),
            child: game == null
                ? Container()
                : gameUI.state.displayScore(context, appLanguage, score),
          ),*/
          //Consigne et jauge à remplir
          game != null
              ? game.isWaiting
                  ? Container(
                      alignment: Alignment.topLeft,
                      padding: EdgeInsets.all(20),
                      child: Container(
                        width: screenSize.width / 2,
                        height: screenSize.height / 3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color.fromRGBO(255, 255, 255, 0.7),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(5),
                              child: Container(
                                height: screenSize.height / 3.5,
                                child: AutoSizeText(
                                  AppLocalizations.of(context)
                                      .translate('remplir_jauge'),
                                  minFontSize: 20,
                                  maxLines: 3,
                                  style: TextStyle(fontSize: 35),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container()
              : Container(),
          game != null
              ? game.isWaiting
                  ? Container(
                      alignment: Alignment.bottomLeft,
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
                          alignment: Alignment.bottomCenter,
                          child: Container(
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
              : Container(),
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