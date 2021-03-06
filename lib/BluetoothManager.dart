// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/DatabaseHelper.dart';
import 'package:location/location.dart' as loc;
import 'package:location_platform_interface/location_platform_interface.dart';

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
  bool isConnected = false;
  bool isActivated = false;
  bool isRunning = true;
  Timer timer;
  String macAddress;
  String data;
  double previousVoltage = 0.0;
  double previousValue = 0.0;
  int previousNumber = 0;

  double forceSensor = 0.0;
  double batteryVoltage = 0.0;
  bool connectStatus = false;

  //Initializing database
  DatabaseHelper db = new DatabaseHelper();

  // Initializing the Bluetooth connexion state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  //Why location permission ? https://stackoverflow.com/questions/41716452/why-location-permission-are-required-for-ble-scan-in-android-marshmallow-onwards/41717433
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

  Future<bool> activateLocation() async {
    loc.Location location =
        new loc.Location(); //explicit reference to the Location class
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    try {
      _serviceEnabled = await location.serviceEnabled();

      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          return false;
        }
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return false;
        }
      }
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        //error = 'Permission denied';
      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        //error = 'Permission denied - please ask the user to enable it from the app settings';
      }

      print(_serviceEnabled);
      print(_permissionGranted);
      print(e.code);

      location = null;
    }

    return true;
  }

  // Request Bluetooth permission from the user
  Future<bool> enableBluetooth() async {
    //Ask location enable if not connected 10 seconds after mainTitle
    Timer(Duration(seconds: 10), () async {
      //If user get back to login page, user = null
      if (!isConnected && user != null) {
        isActivated = await activateLocation();
        if (isActivated) {
          if(await sensorChannel.invokeMethod('getScanState'))
            connect(user.userMacAddress, user.userSerialNumber);
        }
      }
    });

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
    } else
      return false;
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
    //TODO send "WU" wake up to bluno beetle
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
    try {
      //Origin = adresse mac
      //TODO modifier la fonction sous mac swift
      sensorChannel.invokeMethod('connect,$serialNumber,$macAddress');
      await sensorChannel.invokeMethod('getStatus');
      isConnected = true;
    } on PlatformException {
      print('Connection status: Failed');
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
      connectStatus = 'Failed disconnected.';
    }
  }

  //Fonction qui appelle toutes les 500 ms la fonction getData()
  /*void startDataReceiver() async {
    const oneSec = const Duration(milliseconds: 200);
    timer = new Timer.periodic(oneSec, (timer) async {
      if (!isRunning) {
        timer.cancel();
      } else
        data = await getData();
      //data = await getData();
    });
  }*/

  //requestedValue: F or V for force sensor or voltage
  Future<dynamic> getData(String requestedValue) async {
    String result = "null";
    try {
      result = await sensorChannel.invokeMethod('getData');
      data = '$result';

      //print(data);

      //Frame example: F;20;V;3890
      List<String> datas = data.split(";");

      //If the frame is complete
      if (datas.length >= 4) {
        for (int i = 0; i < datas.length; i++) {
          switch (datas[i]) {
            //Force sensor
            case "F":
              {
                forceSensor = double.parse(getForceSensor(datas[i + 1]));
              }
              break;
            //Voltage
            case "V":
              {
                batteryVoltage = getVoltage(datas[i + 1]);
              }
              break;
            //Counter (if same than before, than it's disconnected)
            case "C":
              {
                if (int.parse(datas[datas.length - 1]) != previousNumber)
                  isConnected = true;
                else
                  isConnected = false;

                previousNumber = int.parse(datas[datas.length - 1]);
              }
              break;

            default:
              break;
          }
        }
      }
    } on PlatformException {
      data = 'Failed to get data from device.';
    }

    //requestedValue: F or V for force sensor or voltage
    if (requestedValue == "F")
      return forceSensor.toString();
    else if (requestedValue == "V")
      return batteryVoltage.toString();
    else if (requestedValue == "C") return isConnected;
    //return data;
  }

  //Fonction qui récupère les données du capteur de force
  //Converti ces données en Kg
  //TODO UPDATE IOS SWIFT FUNCTIONS
  String getForceSensor(String force) {
    double value = 0.0;

    double delta = 102.0;
    double coefKg = 0.45359237;

    double convVoltToLbs = (921 - delta) / 100;

    try {
      value = double.parse(force);
    } catch (error) {
      //value = previousValue;
    }

    double tempResult = double.parse(
            ((value - delta) / (convVoltToLbs * coefKg))
                .toStringAsExponential(1))
        .abs();

    previousValue = tempResult;
    return tempResult.toString();
  }

  //Fonction qui renvoie le voltage des piles en valeur analogique
  //Converti ces données en V
  //Volt max: ~4.81 V réel soit ~4.38V sur l'appli
  //Volt min: ~3.17V réel soit ~2.84V sur l'appli
  double getVoltage(String _voltage) {
    double reference = 4.4;
    double voltage = 3.5;

    try {
      // Receiving voltage in mV
      voltage = double.parse(_voltage) / 1000;
    } catch (error) {
      //voltage = previousVoltage;
    }

    //voltage min /reference -> 0.64 donc conversion en pourcentage pour la jauge
    double percent = ((voltage / reference) - 0.64) / 0.36;

    if (percent < 0.0) percent = previousVoltage;

    if (percent > 1.0) percent = 1.0;

    previousVoltage = percent;

    //print("Résultat: $tempResult");
    return percent;
  }

  Future<void> sendData(String data) async {
    bool status = false;
    try {
      //Origin = adresse mac
      //TODO implementer la fonction sous mac swift
      if (isConnected)
        status = await sensorChannel.invokeMethod('sendData,$data');

      //Retry if failed to send
      if (!status) {
        Timer(Duration(seconds: 1), () async {
          sendData(data);
        });
      }
    } on PlatformException {
      status = false;
    }
  }
}

///8 + 6h30 + 6h50 + 2:15 + 1h30 + 3:30 + 4:30 + 7:20 + 45 = 2470 minutes
/// = 41:10
/// = 41,16 heures
/// 247 séances
/// 3 séances/semaine = 82 semaines = 1,58 ans
