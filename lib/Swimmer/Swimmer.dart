import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/components/animation_component.dart';
import 'package:flame/animation.dart' as flanim;
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flame/util.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:gbsalternative/BluetoothSync.dart';
import 'package:gbsalternative/DatabaseHelper.dart';
import 'package:gbsalternative/MainTitle.dart';
import 'package:gbsalternative/Menu.dart';
import 'package:gbsalternative/Swimmer/box-game.dart';

import 'Ui.dart';

String btData;
String _messageBuffer = '';
List<_Message> messages = List<_Message>();
BluetoothConnection connection;
bool isConnected = false;
BoxGame game;

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class Swimmer extends StatefulWidget {
  final User user;

  Swimmer({
    Key key,
    @required this.user,
  }) : super(key: key);

  @override
  _Swimmer createState() => new _Swimmer(user);
}

class _Swimmer extends State<Swimmer> {
  User user;
  static double delta = 102.0;
  double coefKg = 0.45359237;
  double result;
  String recording;
  Timer timer;

  _Swimmer(User _user) {
    user = _user;
  }

  @override
  void initState() {
    //myGame = GameWrapper(game);
    connectBT();
    initSwimmer();
    testConnect();

    super.initState();
  }

  initSwimmer() async {
    WidgetsFlutterBinding.ensureInitialized();
    game = BoxGame(getData, user);
    UI gameUI = UI();
    gameUI.state.game = game;
    Util flameUtil = Util();
    flameUtil.fullScreen();

    TapGestureRecognizer tapper = TapGestureRecognizer();

    tapper.onTapDown = game.onTapDown;
/*

    runApp(
      MaterialApp(
        title: 'Shadow Training',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'HVD',
        ),
        home: Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: game.onTapDown,
                  child: game.widget,
                ),
              ),
              Positioned.fill(
                child: gameUI,
              ),
            ],
          ),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
*/

    //runApp(game.widget);
    flameUtil.addGestureRecognizer(tapper);
  }

  bool isDisconnecting = false;

  void testConnect() async {
    if (!isConnected) {
      connectBT();
    }
  }

  void connectBT() async {
    //_disconnect();
    await BluetoothConnection.toAddress(user.userMacAddress)
        .then((_connection) {
      print('Connected to the device');

      connection = _connection;
      isConnected = true;

      connection.input.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
          isConnected = false;
          connectBT();
        } else {
          print('Disconnected remotely!');
          isConnected = false;
          connectBT();
        }
      });
    });
  }

  // Method to disconnect bluetooth
  void _disconnect() async {
    isConnected = false;
    await connection.close();
    print('Device disconnected');
  }

  void _onDataReceived(Uint8List data) async {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });

    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);

    int index = buffer.indexOf(13);
    if (~index != 0) {
      messages.add(
        _Message(
          1,
          backspacesCounter > 0
              ? _messageBuffer.substring(
                  0, _messageBuffer.length - backspacesCounter)
              : _messageBuffer + dataString.substring(0, index),
        ),
      );
      _messageBuffer = dataString.substring(index);
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
    //Conversion des données reçu en un String btData
    //List inutile, sert juste à convertir.
    final List<String> list = messages.map((_message) {
      //Conversion de mv en LBS puis Kg
      btData = (_message.text.trim());

      double convVoltToLbs = (921 - delta) / 100;
      result = double.parse(
          ((double.parse(btData) - delta) / (convVoltToLbs * coefKg))
              .toStringAsExponential(1));

      btData = result.toString();
      //print(btData);
    }).toList();
  }

  double getData() {
    return double.parse(btData);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UI gameUI = UI();
    gameUI.state.game = game;

    return MaterialApp(
      title: 'Shadow Training',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'HVD',
      ),
      home: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            game.widget,
            /*Positioned.fill(

              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: game.onTapDown,
                child: game.widget,
              ),
            ),*/
            Positioned.fill(
              child: gameUI,
            ),
          ],
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
