import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flame/util.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/AppLocalizations.dart';
import 'package:gbsalternative/BluetoothManager.dart';
import 'package:gbsalternative/DatabaseHelper.dart';
import 'package:gbsalternative/LoadPage.dart';
import 'package:gbsalternative/Swimmer/SwimGame.dart';

import 'Ui.dart';

String btData;
String _messageBuffer = '';
List<_Message> messages = List<_Message>();
BluetoothConnection connection;
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

  Swimmer({Key key, @required this.user, @required this.appLanguage})
      : super(key: key);

  @override
  _Swimmer createState() => new _Swimmer(user, appLanguage);
}

class _Swimmer extends State<Swimmer> {
  User user;
  AppLanguage appLanguage;

  BluetoothManager btManage =
      new BluetoothManager(user: null, inputMessage: null, appLanguage: null);

  static double delta = 102.0;
  double coefKg = 0.45359237;
  double result;
  String recording;
  Timer timer;
  Timer timerConnexion;
  UI gameUI;
  int score;

  _Swimmer(User _user, AppLanguage _appLanguage) {
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
      connect();
    }
    game = null;

    super.initState();
  }

  @override
  void dispose() {
    timerConnexion?.cancel();
    timer?.cancel();
    super.dispose();
  }

  initSwimmer() async {
    WidgetsFlutterBinding.ensureInitialized();

    game = new SwimGame(getData, user, appLanguage);
    refreshScore();
    //gameUI.state.game = game;
    Util flameUtil = Util();
    flameUtil.fullScreen();

    TapGestureRecognizer tapper = TapGestureRecognizer();

    tapper.onTapDown = game.onTapDown;

    //runApp(game.widget);
    flameUtil.addGestureRecognizer(tapper);
  }

  bool isDisconnecting = false;

  void connect() async {
    btManage.enableBluetooth();
    //btManage.getPairedDevices("swimmer");
    btManage.connect(user.userMacAddress);
    isConnected = await btManage.getStatus();
    testConnect();
  }

  testConnect() async {
    isConnected = await btManage.getStatus();
    if (!isConnected) {
      timerConnexion = new Timer.periodic(Duration(milliseconds: 1500),
          (timerConnexion) async {
        btManage.connect(user.userMacAddress);
        isConnected = await btManage.getStatus();
        if (isConnected) {
          timerConnexion.cancel();
          initSwimmer();
          //refreshScore();
        }
      });
    }
    if (isConnected) {
      initSwimmer();
      //refreshScore();
    }
  }

  // Method to disconnect bluetooth
  void _disconnect() async {
    isConnected = false;
    await connection.close();
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

  @override
  Widget build(BuildContext context) {
    //UI gameUI = UI();
    //gameUI.state.game = game;

    return Material(
        child: ColorFiltered(
      colorFilter: game != null
          ? game.getColorFilter()
          : ColorFilter.mode(Colors.transparent, BlendMode.luminosity),
      child: Stack(
        children: <Widget>[
          game == null || user.userInitialPush == "0.0"
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
                        child: Text(AppLocalizations.of(context)
                            .translate('retour')),
                      )
                    ],
                  ),
                )
              : game.widget,
          Column(
            children: <Widget>[
              Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: game == null
                    ? Container()
                    : gameUI.state.closeButton(
                        context, appLanguage, user, game.getScore()),
              ),
              Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                child:
                    game == null ? Container() : gameUI.state.pauseButton(context, appLanguage, game),
              ),
              Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: game == null
                    ? Container()
                    : gameUI.state.restartButton(context, appLanguage, user),
              ),
            ],
          ),
          Container(
            alignment: Alignment.bottomLeft,
            padding: EdgeInsets.fromLTRB(10, 10, 10, 25),
            child:
                game == null ? Container() : gameUI.state.displayScore(context, appLanguage, score),
          ),
          //Display message pour relancher
          Container(
            alignment: Alignment.center,
            child: game != null
                ? game.getColorFilterBool() &&
                        game.getPosition() &&
                        !game.getGameOver()
                    ? gameUI.state.displayMessage(AppLocalizations.of(context)
                .translate('relacher'))
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
                    ? gameUI.state.displayMessage(AppLocalizations.of(context)
                .translate('pousser'))
                    : Container()
                : Container(),
          ),
          //Display message Game Over
          Container(
            alignment: Alignment.center,
            child: game != null
                ? game.getGameOver()
                    ? gameUI.state.displayMessage(AppLocalizations.of(context)
                .translate('game_over'))
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
