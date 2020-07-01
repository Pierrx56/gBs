import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flame/util.dart';
import 'package:gbsalternative/AppLanguage.dart';
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

class _Plane extends State<Plane> {
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

  _Plane(User _user, AppLanguage _appLanguage) {
    user = _user;
    appLanguage = _appLanguage;
  }

  @override
  void initState() {
    game = null;
    if(user.userInitialPush != "0.0") {
      score = 0;
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

    game = new PlaneGame(getData, user);
    print(game);
    gameUI = UI();
    refreshScore();
    Util flameUtil = Util();
    flameUtil.fullScreen();

    TapGestureRecognizer tapper = TapGestureRecognizer();

    tapper.onTapDown = game.onTapDown;

    flameUtil.addGestureRecognizer(tapper);
  }

  bool isDisconnecting = false;

  void connect() async {
    btManage.enableBluetooth();
    btManage.getPairedDevices("plane");
    btManage.connect("plane");
    isConnected = await btManage.getStatus();
    testConnect();
  }

  testConnect() async {
    isConnected = await btManage.getStatus();
    if (!isConnected) {
      timerConnexion = new Timer.periodic(Duration(milliseconds: 1500),
          (timerConnexion) async {
        btManage.connect("plane");
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
    btData = await btManage.getData();
  }

  double getData() {
    setData();

    if (btData != null)
      return double.parse(btData);
    else
      return 2.0;
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
                      user.userInitialPush == "0.0" ?
                      Text("Veuillez enregister la première poussée dans le menu précédent"):
                      Text("Chargement du jeu en cours... \n"
                          "Assurez vous que le gBs est alimenté"),
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
                        child: Text("Retour"),
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
                    game == null ? Container() : gameUI.state.pauseButton(game),
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
                game == null ? Container() : gameUI.state.displayScore(score),
          ),
          //Display message pour relancher
          Container(
            alignment: Alignment.center,
            child: game != null
                ? game.getColorFilterBool() &&
                        game.getPosition() &&
                        !game.getGameOver()
                    ? gameUI.state.displayMessage("Relachez")
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
                    ? gameUI.state.displayMessage("Poussez")
                    : Container()
                : Container(),
          ),
          //Display message Game Over
          Container(
            alignment: Alignment.center,
            child: game != null
                ? game.getGameOver()
                    ? gameUI.state.displayMessage("Game Over")
                    : Container()
                : Container(),
          ),
        ],
      ),
    ));
  }
}
