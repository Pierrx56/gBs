import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScan extends StatefulWidget {
  final AppLanguage appLanguage;
  final String message;

  QRScan({@required this.appLanguage, @required this.message});

  @override
  _QRScan createState() => _QRScan(appLanguage, message);
}

class _QRScan extends State<QRScan> {
  AppLanguage appLanguage;
  String message;
  String serial;
  Timer timerLength;
  bool flashIsOn = false;

  Barcode result;
  QRViewController qrController;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  //Constructeur
  _QRScan(AppLanguage _appLanguage, String _message) {
    appLanguage = _appLanguage;
    message = _message;
  }

  @override
  void initState() {
    super.initState();
    flashIsOn = false;
    checkLenghtQR();
    serial = "";
  }

  @override
  void dispose() {
    qrController?.dispose();
    timerLength?.cancel();
    super.dispose();
  }

  void checkLenghtQR() async {
    timerLength =
        Timer.periodic(Duration(milliseconds: 300), (Timer timer) async {
      if (serial.length >= 8) {
        Navigator.pop(context, serial);
        timerLength?.cancel();
      }
      if (mounted) {
        try{
          flashIsOn = await qrController?.getFlashStatus();
        } on Exception catch (e) {
          flashIsOn = false;
        }
        setState(() {});
      }else
        timerLength?.cancel();
    });
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      qrController?.pauseCamera();
    }
    qrController?.resumeCamera();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.qrController = controller;
    controller.scannedDataStream.listen((scanData) {
      if (mounted)
        setState(() {
          result = scanData;
          serial = result.code;
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    // return LoginWidget(db);
    Size screenSize = MediaQuery.of(context).size;
/*
    qrActivated
        ? SizedBox(
      width: screenSize.height * 0.5,
      height: screenSize.height * 0.5,
      child: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
      ),
    )
        : Container(),

        */

    return Stack(
      children: [
        SizedBox(
          width: screenSize.width,
          height: screenSize.height,
          child: QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(250, 0, 0, 8),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, "");
                },
                child: Text("Retour")),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton.icon(
              icon: Icon(flashIsOn ? Icons.flash_on : Icons.flash_off),
              label: Text("Flash"),
              onPressed: () async {
                await qrController?.toggleFlash();
              },
            ),
          ),
        ),
      ],
    );
  }
}
