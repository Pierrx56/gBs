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
import 'dart:math' as math;

/*
* Classe pour gérer la connexion bluetooth
* Prend en paramètre un utilisateur, un message et la langue choisie
* */

class BluetoothManager {
  User user;
  String inputMessage;
  AppLanguage appLanguage;

  BluetoothManager({
    @required this.user,
    @required this.inputMessage,
    @required this.appLanguage,
  });

  //Initialisation de l'appel de fichiers externes
  //android: android/app/src/main/java/genourob/gbs_alternative/MainActivity.java
  //iOS: ios/Runner/AppDelegate.swift
  static const MethodChannel sensorChannel =
      MethodChannel('samples.flutter.io/sensor');

  //Déclaration de variables
  String _pairedDevices = 'No devices paired';
  String _connectDevices;
  bool isConnected = false;
  bool isRunning = true;
  Timer timer;
  String macAddress;
  String data;

  //Initializing database
  DatabaseHelper db = new DatabaseHelper();

  // Initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // Request Bluetooth permission from the user
  Future<bool> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    // If the bluetooth is off, then turn it on first
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      return true;
    }
    return false;
  }

  //Fonction pour récupérer l'adresse mac de l'appareil bluetooth
  Future<String> getPairedDevices(String origin) async {
    String pairedDevices;
    try {
      final String paired =
      await sensorChannel.invokeMethod('getPairedDevices');
      pairedDevices = 'Devices paired: $paired.';
      print(pairedDevices);
      macAddress = paired;
    } on PlatformException {
      pairedDevices = 'Failed to get paired devices.';
    }

    return macAddress;

  }

  //Fonction qui récupère le status de connexion
  //Retourne true ou false
  Future<bool> getStatus() async{
    isConnected = await sensorChannel.invokeMethod('getStatus');
    return isConnected;
  }

  //Fonction qui récupère l'adresse mac
  //Retourne l'adresse mac
  Future<String> getMacAddress() async{
    macAddress = await sensorChannel.invokeMethod('getMacAddress');
    return macAddress;
  }

  //Fonction pour se connecter au gBs
  Future<bool> connect(String origin) async {
    String connectStatus;
    bool result;
    try {
      //Origin = adresse mac
      //TODO modifier la fonction sous mac swift
      sensorChannel.invokeMethod('connect,$origin');
      result = await sensorChannel.invokeMethod('getStatus');
      connectStatus = 'Connection status: $result.';
      isConnected = true;

    } on PlatformException {
      connectStatus = 'Connection status: Failed';
    }

    return isConnected;
  }

  //Fonction pour se déconnecter du gBs
  Future<void> disconnect(String origin) async {
    String connectStatus;
    try {
      final String result = await sensorChannel.invokeMethod('disconnect');
      connectStatus = 'Connection status: $result.';
      isConnected = false;
    } on PlatformException {
      connectStatus = 'Connection status: Disconnected';
    }

  }

  //Fonction qui appelle toutes les 500 ms la fonction getData()
  void startDataReceiver() async {
    const oneSec = const Duration(milliseconds: 500);
    timer = new Timer.periodic(oneSec, (timer) async {
      if (!isRunning) {
        timer.cancel();
      } else
        data = await getData();
    });
  }

  //Fonction qui récupère les données du capteur de force
  //Converti ces données en Kg
  Future<String> getData() async {
    String result = "null";
    String data = "null";

    double delta = 102.0;
    double coefKg = 0.45359237;

    try {
      result = await sensorChannel.invokeMethod('getData');
      data = 'Data: $result';
    } on PlatformException {
      data = 'Failed to get data from device.';
    }

    double convVoltToLbs = (921 - delta) / 100;

    double tempResult = 2.0 * double.parse(
        ((double.parse(result) - delta) / (convVoltToLbs * coefKg))
            .toStringAsExponential(1)).abs();


    //print("Résultat: $tempResult");
    return tempResult.toString();
  }
/*

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
                      getPairedDevices("BluetoothManager");
                    },
                    child: Text("Get Devices"),
                  ),
                  RaisedButton(
                    onPressed: () {
                      connect("BluetoothManager");
                    },
                    child: Text("Connect Device"),
                  ),
                  */
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
                  ),*//*

                ],
              ),
              Text(_connectDevices),
            ],
          ),
        ),
      ),
    );
  }
*/

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
