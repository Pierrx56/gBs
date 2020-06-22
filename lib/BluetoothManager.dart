// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/AppLocalizations.dart';
import 'package:gbsalternative/DatabaseHelper.dart';
import 'package:gbsalternative/LoadPage.dart';

class BluetoothManager extends StatefulWidget {
  User user;
  String inputMessage;
  AppLanguage appLanguage;

  BluetoothManager({
    @required this.user,
    @required this.inputMessage,
    @required this.appLanguage,
  });

  @override
  _BluetoothManager createState() =>
      new _BluetoothManager(user, inputMessage, appLanguage);
}

class _BluetoothManager extends State<BluetoothManager> {
  static const MethodChannel sensorChannel =
      MethodChannel('samples.flutter.io/sensor');

  String _pairedDevices = 'No devices paired';
  String _connectDevices;
  String _incomeData = "Data: ";
  bool isConnected = false;
  bool isRunning = true;
  Timer timer;
  String macAdress;
  String data;
  User user;
  String inputMessage;
  AppLanguage appLanguage;

  //Initializing databse
  DatabaseHelper db = new DatabaseHelper();

  // Initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  _BluetoothManager(
      User _user, String _inputMessage, AppLanguage _appLanguage) {
    user = _user;
    inputMessage = _inputMessage;
    appLanguage = _appLanguage;
  }

  @override
  void initState() {
    super.initState();
    _connectDevices = "Disconnected";
    enableBluetooth();
  }

  @override
  void dispose() {
    // Avoid memory leak and disconnect
    if (isConnected) {
/*      isDisconnecting = true;
      connection.dispose();
      connection = null;*/
    }

    super.dispose();
  }

  // Request Bluetooth permission from the user
  Future<void> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    // If the bluetooth is off, then turn it on first
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      return true;
    }
    return false;
  }

  Future<String> getPairedDevices(String origin) async {
    String pairedDevices;
    try {
      final String paired =
      await sensorChannel.invokeMethod('getPairedDevices');
      pairedDevices = 'Devices paired: $paired.';
      macAdress = paired;
    } on PlatformException {
      pairedDevices = 'Failed to get paired devices.';
    }

    if (origin == "connexion"){
      setState(() {
        _pairedDevices = pairedDevices;
      });
  }

    return macAdress;

  }

  Future<bool> getStatus() async{
    isConnected = await sensorChannel.invokeMethod('getStatus');
    return isConnected;
  }

  Future<bool> connect(String origin) async {
    String connectStatus;
    String result;
    try {
      sensorChannel.invokeMethod('connect');
      result = await sensorChannel.invokeMethod('getStatus').toString();
      connectStatus = 'Connection status: $result.';
      isConnected = true;
/*      if (result != "Connected") {
        Future.delayed(const Duration(milliseconds: 1000), () async {
          connect(inputMessage);
          isConnected = await getStatus();
          if(isConnected)
            connectStatus = 'Connection status: Connected.';
          else {
            connectStatus = 'Connection status: Failed';
            connect(inputMessage);
          }
          if(origin == "connexion")
            setState(() {
              _connectDevices = connectStatus;
            });
        });
      }
      else {
        startDataReceiver();
        print("résulttaaaaaaaaat" + result);

        isConnected = await getStatus();
        if(isConnected)
          connectStatus = 'Connection status: Connected.';
        else {
          connectStatus = 'Connection status: Failed';
          connect(inputMessage);
        }
        if(origin == "connexion")
          setState(() {
            _connectDevices = connectStatus;
          });
      }*/
    } on PlatformException {
      //connect();
      //connect(inputMessage);
      connectStatus = 'Connection status: Failed';
    }
    if(origin == "connexion"){
      setState(() {
        _connectDevices = connectStatus;
        print(connectStatus);
      });
    }

    if (isConnected) {
      //Lorsque l'on viens de l'inscription
      if (origin == "inscription") {
        //Déconnexion immédiate sinon bug lors de lancement de jeux
        disconnect();
        inputMessage = "";
        Navigator.pop(
          context,
          macAdress,
        );
      }
      else if(origin == "connexion");
      else if(origin == "register");
      else if(origin == "swimmer");

      else {
        //Insertion dans l'adresse MAC dans la BDD
        User updatedUser = User(
          userId: user.userId,
          userName: user.userName,
          userMode: user.userMode,
          userPic: user.userPic,
          userHeightTop: user.userHeightBottom,
          userHeightBottom: user.userHeightBottom,
          userMacAddress: macAdress,
        );
        db.updateUser(updatedUser);

        //Déconnexion immédiate sinon bug lors de lancement de jeux
        //disconnect();
/*
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => LoadPage(
                      appLanguage: appLanguage,
                      page: "mainTitle",
                      user: user,
                      messageIn: "0",
                    )));*/
        //show('Vous êtes connecté à gBs');
      }
    }
    /*else
      show("Échec de connexion");
        connection.input.listen(_onDataReceived).onDone((){
          if (this.mounted) {
            setState(() {});
          }
        }
        );*/

    //setState(() => _isButtonUnavailable = false);
    return isConnected;
  }

  Future<void> disconnect() async {
    String connectStatus;
    try {
      final String result = await sensorChannel.invokeMethod('disconnect');
      connectStatus = 'Connection status: $result.';
      isConnected = false;
    } on PlatformException {
      connectStatus = 'Connection status: Disconnected';
    }
    setState(() {
      //startDataReceiver();
      _connectDevices = connectStatus;
      isConnected = false;
    });
  }

  void startDataReceiver() async {
    const oneSec = const Duration(milliseconds: 500);
    timer = new Timer.periodic(oneSec, (timer) async {
      if (!isRunning) {
        timer.cancel();
      } else
        data = await getData();
    });
  }

  Future<String> getData() async {
    String result = "salut";
    String data = "null";

    double delta = 102.0;
    double coefKg = 0.45359237;

    try {
      result = await sensorChannel.invokeMethod('getData');
      data = 'Data: $result';
      _incomeData = data;
    } on PlatformException {
      data = 'Failed to get data from device.';
    }

    double convVoltToLbs = (921 - delta) / 100;
    double tempResult = double.parse(
        ((double.parse(result) - delta) / (convVoltToLbs * coefKg))
            .toStringAsExponential(1));

    //print("Résultat: " + tempResult.toString());
    return tempResult.toString();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: [
        Locale('en', 'US'),
        Locale('fr', 'FR'),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          //title: Text(AppLocalization.of(context).heyWorld),

          title: Text("Appairer/connecter son apprareil"),
          backgroundColor: Colors.blue,
          actions: <Widget>[
            FlatButton.icon(
              icon: Icon(
                Icons.refresh,
                color: Colors.white,
              ),
              label: Text(
                "Refresh",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              splashColor: Colors.blue,
              onPressed: () async {
                // So, that when new devices are paired
                // while the app is running, user can refresh
                // the paired devices list.
                getPairedDevices("");
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(_pairedDevices),
                  RaisedButton(
                    onPressed: () {
                      getPairedDevices("");
                    },
                    child: Text("Get Devices"),
                  ),
                  RaisedButton(
                    onPressed: () {
                      connect("connexion");
                    },
                    child: Text("Connect Device"),
                  ),
                  /*
                  RaisedButton(
                    onPressed: () {
                      isRunning = true;
                      startDataReceiver();
                    },
                    child: Text("Get Data"),
                  ),
                  RaisedButton(
                    onPressed: () {
                      isRunning = false;
                      disconnect();
                    },
                    child: Text("Disconnect"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: RaisedButton(
                      child: const Text('Refresh'),
                      onPressed: () {},
                    ),
                  ),*/
                ],
              ),
              Text(_connectDevices),
            ],
          ),
        ),
      ),
    );
  }

  // Method to show a Snackbar,
  // taking message as the text
  Future show(
    String message, {
    Duration duration: const Duration(seconds: 3),
  }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: new Text(
          message,
        ),
        duration: duration,
      ),
    );
  }
}
