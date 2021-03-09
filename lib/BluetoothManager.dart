// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
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
  double previousVoltage = 0.0;
  double previousValue = 0.0;

  //Initializing database
  DatabaseHelper db = new DatabaseHelper();

  // Initializing the Bluetooth connexion state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future<bool> locationPermission() async {
    bool paired = false;
    if (Platform.isAndroid) {
      try {
        paired = await sensorChannel.invokeMethod('locationPermission');
      } on PlatformException {}
      return paired;
    }
    return true;
  }

  // Request Bluetooth permission from the user
  Future<bool> enableBluetooth() async {
    //On utilise la librairie flutter_bluetooth_serial pour détecter l'état du bluetoothh
    if (Platform.isAndroid) {
      // Retrieving the current Bluetooth state
      _bluetoothState = await FlutterBluetoothSerial.instance.state;

      //If location permission is not accepted, spam to accept
      if (!await locationPermission()) {
        enableBluetooth();
      }
      // If the bluetooth is off, then turn it on first
      if (_bluetoothState == BluetoothState.STATE_OFF) {
        await FlutterBluetoothSerial.instance.requestEnable();
        return true;
      }
      return false;
    }
    //On utilise aucune librairie, aucune compatible à àce jour
    //On averti juste l'utilisateur que le BT est off et suggère d'aller dans les réglages
    else if (Platform.isIOS) {
      final bool isOn = await sensorChannel.invokeMethod('getBLEState');
      if (!isOn) {
        //print("isOFFFFF");
        return true;
      } else {
        //print("isOOONNNNN");
        return false;
      }
    }
  }

  //Fonction pour récupérer l'adresse mac de l'appareil bluetooth
  Future<String> getDevice(String serialNumber) async {
    String pairedDevices;

    if (await enableBluetooth()) {
      return "";
    } else {
      try {
        final String paired = await sensorChannel
            .invokeMethod('getPairedDevices,${"gBs" + serialNumber}');
        pairedDevices = 'Devices paired: $paired.';
        print(pairedDevices);
        macAddress = paired;
      } on PlatformException {
        pairedDevices = 'Failed to get paired devices.';
      }
    }

    return macAddress;
  }

  //Fonction qui récupère le status de connexion
  //Retourne true ou false
  Future<bool> getStatus() async {
    isConnected = await sensorChannel.invokeMethod('getStatus');
    return isConnected;
  }

  //Fonction qui récupère l'adresse mac
  //Retourne l'adresse mac
  Future<String> getMacAddress() async {
    macAddress = await sensorChannel.invokeMethod('getMacAddress');
    return macAddress;
  }

  //Fonction pour se connecter au gBs
  Future<bool> connect(String macAddress, String serialNumber) async {
    String connectStatus;
    bool result;
    try {
      //Origin = adresse mac
      //TODO modifier la fonction sous mac swift
      sensorChannel.invokeMethod('connect,$serialNumber,$macAddress');
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
      //TODO Implement swift
      final String result = await sensorChannel.invokeMethod('disco');
      connectStatus = 'Connection status: $result.';
      print(connectStatus);
      isConnected = false;
    } on PlatformException {
      connectStatus = 'Connection status: Disconnected';
    }
  }

  //Fonction qui appelle toutes les 500 ms la fonction getData()
  void startDataReceiver() async {
    const oneSec = const Duration(milliseconds: 200);
    timer = new Timer.periodic(oneSec, (timer) async {
      if (!isRunning) {
        timer.cancel();
      } else
        data = await getStringFromBluetooth();
      //data = await getData();
    });
  }

  Future<String> getStringFromBluetooth() async {
    String result = "null";
    try {
      result = await sensorChannel.invokeMethod('getData');
      data = '$result';
    } on PlatformException {
      data = 'Failed to get data from device.';
    }
    return data;
  }

  //Fonction qui récupère les données du capteur de force
  //Converti ces données en Kg
  //TODO UPDATE IOS SWIFT FUNCTIONS
  Future<String> getData() async {
    List<String> result = [];
    double value = 0.0;

    double delta = 102.0;
    double coefKg = 0.45359237;

    /*
    try {
      //TODO Résoudre bug: 2 appareils connectés au même tel, on recoit les valeurs des 2 capteurs
      //Cancel toute recherche dans login ?


      result = await sensorChannel.invokeMethod('getData');
      data = 'Data: $result';
    } on PlatformException {
      data = 'Failed to get data from device.';
    }*/

    data = await getStringFromBluetooth();

    result = data.split(";");

    //2 valeurs dans tableau, taille conforme avec force + voltage
    if(result.length == 2) {
      double convVoltToLbs = (921 - delta) / 100;

      try {
        value = double.parse(result[0]);

        //Sécurité valeur volt au lieu de capteur pression
        if (value > 1000) {
          value = 230;
        }

      } catch (error) {
        value = previousVoltage;
      }

      double tempResult = double.parse(
          ((value - delta) / (convVoltToLbs * coefKg))
              .toStringAsExponential(1))
          .abs();

      previousValue = tempResult;
      //print("Résultat: $tempResult");
      return tempResult.toString();
    }
    else
      return previousValue.toString();
  }

  //Fonction qui récupère le voltage des piles en valeur analogique
  //Converti ces données en V
  //Volt max: ~4.81 V réel soit ~4.38V sur l'appli
  //Volt min: ~3.17V réel soit ~2.84V sur l'appli
  Future<double> getVoltage() async {
    List<String> result = [];
    double reference = 4.4;
    double voltage = 3.5;

    data = await getStringFromBluetooth();

    //print(data);
    try {
      result = data.split(";");
      // Receiving voltage in mV
      voltage = double.parse(result[1]) / 1000;
    } catch (error) {
      voltage = previousVoltage;
    }

    //2 valeurs dans tableau, taille conforme avec force + voltage
    if(result.length == 2) {
      //voltage min /reference -> 0.64 donc conversion en pourcentage pour la jauge
      double percent = ((voltage / reference) - 0.64) / 0.36;

      if (percent < 0.0) percent = previousVoltage;

      if (percent > 1.0) percent = 1.0;

      previousVoltage = percent;

      //print("Résultat: $tempResult");
      return percent;
    }
    else
      return previousVoltage;
  }

}

///8 + 6h30 + 6h50 + 2:15 + 1h30 + 3:30 + 4:30 + 7:20 + 45 = 2470 minutes
/// = 41:10
/// = 41,16 heures
/// 247 séances
/// 3 séances/semaine = 82 semaines = 1,58 ans
///