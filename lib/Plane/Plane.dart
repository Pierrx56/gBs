import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flame/util.dart';
import 'dart:math' as math;
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/AppLocalizations.dart';
import 'package:gbsalternative/BluetoothManager.dart';
import 'package:gbsalternative/DatabaseHelper.dart';
import 'package:gbsalternative/LoadPage.dart';
import 'package:gbsalternative/Plane/PlaneGame.dart';

import 'Ui.dart';

String btData;
List<_Message> messages = List<_Message>();
bool isConnected;
PlaneGame game;

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class Plane extends StatefulWidget {
  final User user;
  final AppLanguage appLanguage;

  Plane({Key key, @required this.user, @required this.appLanguage})
      : super(key: key);

  @override
  _Plane createState() => new _Plane(user, appLanguage);
}

class _Plane extends State<Plane> with TickerProviderStateMixin {
  User user;
  AppLanguage appLanguage;

  BluetoothManager btManage =
      new BluetoothManager(user: null, inputMessage: null, appLanguage: null);

  static double delta = 102.0;
  double coefKg = 0.45359237;
  double result;
  String recording;
  String timeRemaining;
  Timer timer;
  bool start;
  int seconds;
  Timer timerConnexion;
  UI gameUI;
  int score;

  _Plane(User _user, AppLanguage _appLanguage) {
    user = _user;
    appLanguage = _appLanguage;
  }

  @override
  void initState() {
    game = null;
    if (user.userInitialPush != "0.0") {
      score = 0;
      if (user.userMode == "Sportif") {
        timeRemaining = "3:00";
        seconds = 180;
      } else {
        timeRemaining = "2:00";
        seconds = 120;
      }

      start = false;
      isConnected = false;
      connect();
    }

    super.initState();
  }

  @override
  void dispose() {
    timerConnexion?.cancel();
    timer?.cancel();
    super.dispose();
  }

  initPlane() async {
    WidgetsFlutterBinding.ensureInitialized();

    game = new PlaneGame(getData, user, appLanguage);
    //Start timer of 2 minutes
    startTimer(true);
    gameUI = new UI();
    refreshScore();
    Util flameUtil = Util();
    flameUtil.fullScreen();

    TapGestureRecognizer tapper = TapGestureRecognizer();

    tapper.onTapDown = game.onTapDown;

    flameUtil.addGestureRecognizer(tapper);
  }

  bool isDisconnecting = false;

  void connect() async {
    /*btManage.enableBluetooth();*/
    if (await btManage.enableBluetooth()) {
      //print("salut");
      connect();
    } else {
      btManage.connect(user.userMacAddress, user.userSerialNumber);
      isConnected = await btManage.getStatus();
      testConnect();
    }
  }

  testConnect() async {
    isConnected = await btManage.getStatus();
    if (!isConnected) {
      timerConnexion = new Timer.periodic(Duration(milliseconds: 1500),
          (timerConnexion) async {
        btManage.connect(user.userMacAddress, user.userSerialNumber);
        print("Status: $isConnected");
        isConnected = await btManage.getStatus();
        if (isConnected) {
          timerConnexion.cancel();
          initPlane();
          //refreshScore();
        }
      });
    }
    if (isConnected) {
      initPlane();
    }
  }

  // Method to disconnect bluetooth
  void _disconnect() async {
    btManage.disconnect("plane");
    isConnected = false;
    print('Device disconnected');
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
    Timer _timer;
    int _start = seconds;
    const int delay = 1;

    if (!boolean && isConnected) {
      _start = seconds;
    } else {
      const time = const Duration(seconds: delay);
      _timer = new Timer.periodic(
        time,
        (Timer timer) {
          if (_start < delay.toDouble()) {
            //TODO Display menu ?
            timer.cancel();
          } else if (!game.getConnectionState())
            timer.cancel();
          else if (game.pauseGame) {
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
    return Material(
      child: ColorFiltered(
        colorFilter: game != null
            ? game.getColorFilter()
            : ColorFilter.mode(Colors.transparent, BlendMode.luminosity),
        child: Stack(
          children: <Widget>[
            game == null
                ? Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircularProgressIndicator(),
                        user.userInitialPush == "0.0"
                            ? Text(AppLocalizations.of(context)
                                .translate('premiere_poussee_sw'))
                            : Text(AppLocalizations.of(context)
                                .translate('verif_alim')),
                        RaisedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoadPage(
                                        appLanguage: appLanguage,
                                        user: user,
                                        messageIn: "0",
                                        page: "mainTitle",
                                      )),
                            );
                          },
                          child: Text(
                              AppLocalizations.of(context).translate('retour')),
                        )
                      ],
                    ),
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
                      ? !game.pauseGame
                          ? Container(
                              alignment: Alignment.topLeft,
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: game == null
                                  ? Container()
                                  : gameUI.state.pauseButton(
                                      context, appLanguage, game, user),
                            )
                          : Container(
                              alignment: Alignment.topCenter,
                              child: gameUI.state
                                  .menu(context, appLanguage, game, user))
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
            Container(
              alignment: Alignment.bottomLeft,
              padding: EdgeInsets.fromLTRB(10, 10, 10, 25),
              child:
                  game == null ? Container() : gameUI.state.displayScore(score),
            ),
            //Display message pour relancher
            Container(
              alignment: Alignment.center,
              child: game != null
                  ? game.getColorFilterBool() &&
                          game.getPosition() &&
                          !game.getGameOver()
                      ? gameUI.state.displayMessage(
                          AppLocalizations.of(context).translate('relacher'))
                      : Container()
                  : Container(),
            ),
            //Display message pour pousser
            Container(
              alignment: Alignment.center,
              child: game != null
                  ? game.getColorFilterBool() &&
                          !game.getPosition() &&
                          !game.getGameOver()
                      ? gameUI.state.displayMessage(
                          AppLocalizations.of(context).translate('pousser'))
                      : Container()
                  : Container(),
            ),
            //Display message Game Over
            Container(
              alignment: Alignment.center,
              child: game != null
                  ? game.getGameOver()
                      ? gameUI.state.displayMessage(
                          AppLocalizations.of(context).translate('game_over'))
                      : Container()
                  : Container(),
            ),
            //Display message Lost connexion
            Container(
              alignment: Alignment.center,
              child: game != null
                  ? !game.getConnectionState()
                      ? gameUI.state.displayMessage(AppLocalizations.of(context)
                          .translate('connexion_perdue'))
                      : Container()
                  : Container(),
            ),
            //Display timer
            Container(
                alignment: Alignment.bottomRight,
                child: game != null
                    ? gameUI.state.displayMessage(timeRemaining)
                    : Container()),
          ],
        ),
      ),
    );
  }
}
