import 'dart:async';

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_rounded_progress_bar/flutter_rounded_progress_bar.dart';
import 'package:flutter_rounded_progress_bar/rounded_progress_bar_style.dart';
import 'package:gbsalternative/BluetoothSync.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../DatabaseHelper.dart';
import '../MainTitle.dart';

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

String btData;
String _messageBuffer = '';
List<_Message> messages = List<_Message>();

class Register extends StatefulWidget {
  @override
  _Register createState() => _Register();
}

class _Register extends State<Register> {
  DatabaseHelper db = new DatabaseHelper();
  double screenHeight;

  String _pathSaved;
  File imageFile;

  String _userMode;
  bool isSwitched = false;
  String macAddress;

  static double delta = 102.0;
  double coefKg = 0.45359237;
  double result;
  String recording;

  var name = new TextEditingController();


  @override
  void initState() {
    btData = "0.0";
    recording = "Démarrer l'enregistrement";
    super.initState();
  }

  void updateMacAddress(String address) {
    setState(() => macAddress = address);
    connectBT();
  }

  bool isDisconnecting = false;
  BluetoothConnection connection;
  bool isConnected = false;
  Timer _timer;
  double _start = 10.0;
  static double _reset = 10.0;
  int i = 20;
  List<double> average = new List(2*_reset.toInt());

  void connectBT() async {
    //_disconnect();
    await BluetoothConnection.toAddress(macAddress).then((_connection) {
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
        } else {
          print('Disconnected remotely!');
        }
      });
    });

    if (!isConnected) {
      connection = null;
      connectBT();
    }
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
      double result =
          double.parse(((double.parse(btData) - delta) / (convVoltToLbs * coefKg)).toStringAsExponential(1));

      btData = result.toString();
      //print(btData);
    }).toList();
  }

  pickImageFromGallery(ImageSource source) async {
    imageFile = await ImagePicker.pickImage(source: source);

    final directory = await getApplicationDocumentsDirectory();
    final String path = directory.path;

    String nameImage = name.text + "_" + basename(imageFile.path);

    print("Nom de l'image: " + nameImage);

    final File newImage = await imageFile.copy('$path/$nameImage');

    setState(() {
      _pathSaved = newImage.path;
      imageFile = newImage;
    });

    return _pathSaved = newImage.path;
  }

  addUser() async {
    User user;

    int id = await db.addUser(User(
      userId: null,
      userName: name.text,
      userMode: _userMode,
      userPic: _pathSaved,
      userHeightTop: hauteur_max.text,
      userHeightBottom: hauteur_min.text,
      userInitialPush: result.toString(),
      userMacAddress: macAddress,
    ));
    print("ID INScr: " + id.toString());
    user = await db.getUser(id);
    print("USER ID: " + user.userId.toString());

    return user;
  }

  var hauteur_min = new TextEditingController();
  var hauteur_max = new TextEditingController();

  Color colorButton = Colors.black;
  Color colorMesureButton = Colors.black;
  int valueHolder = 20;

  //String savedImage = "";

  final _formKey = GlobalKey<FormState>();

  Widget LoginCard(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;

    setState(() {
    });
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Inscription",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Text("Normal"),
                        Switch(
                          value: isSwitched,
                          onChanged: (value) {
                            setState(() {
                              isSwitched = value;
                              if (isSwitched)
                                _userMode = "Sportif";
                              else
                                _userMode = "Normal";
                            });
                          },
                          activeTrackColor: Colors.lightGreenAccent,
                          activeColor: Colors.green,
                        ),
                        Text("Sportif"),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                        controller: name,
                        decoration: InputDecoration(
                            labelText: "Prénom", hasFloatingPlaceholder: true),
                        validator: (value) {
                          if (value.isEmpty) return 'Veuillez remplir ce champ';
                          return null;
                        }),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                        controller: hauteur_min,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          WhitelistingTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                            labelText: "Hauteur minimale",
                            hasFloatingPlaceholder: true),
                        validator: (value) {
                          if (value.isEmpty) return 'Veuillez remplir ce champ';
                          return null;
                        }),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                        controller: hauteur_max,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          WhitelistingTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                            labelText: "Hauteur maximale",
                            hasFloatingPlaceholder: true),
                        validator: (value) {
                          if (value.isEmpty) return 'Veuillez remplir ce champ';
                          return null;
                        }),
                    SizedBox(
                      height: 20,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        //showImage(),
                        //Image(image: AssetImage(_path)),
                        Center(
                            child: imageFile == null
                                ? Text('')
                                : Image.file(File(_pathSaved),
                                    height: screenHeight * 0.3,
                                    width: screenHeight * 0.3)
                            //Image.file(imageFile, width: screenHeight * 0.6, height: screenHeight*0.6,),
                            ),
                        RaisedButton(
                          child: Text("Sélectionner une image"),
                          onPressed: () {
                            _pathSaved =
                                pickImageFromGallery(ImageSource.gallery);
                          },
                          textColor: colorButton,
                        ),
                        RaisedButton(
                          child: Text("Appairer un appareil"),
                          onPressed: () async {
                            final macAddress = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BluetoothSync(
                                          curUser: null,
                                          inputMessage: "inscription",
                                        )));
                            updateMacAddress(macAddress);
                          },
                          textColor: colorButton,
                        ),
                        Text(
                            "Vous devez maintenir pendant 10 secondes entre 5 et 10."
                                " Appuyez sur démarrer l'enregistrement lorsque vous êtes prêt."),
                        RaisedButton(
                          //child: Text("Démarrer l'enregistrement."),
                          //TODO
                          onPressed: () async {
                            colorMesureButton = Colors.black;
                            const oneSec = const Duration(milliseconds: 500);
                            _timer = new Timer.periodic(
                              oneSec,
                                  (Timer timer) => setState(
                                    () {
                                  if (_start < 0.5) {
                                    timer.cancel();
                                    _start = _reset;
                                    result =  average.reduce((a, b) => a + b) / average.length;
                                    print(result.toString());
                                    i = 20;
                                    if(result <= 5.0 || result >= 10.0){
                                      //Mesure pas bonne, réajuster la toise
                                      setState(() {
                                        recording = "Mesure pas bonne, réajustez la toise et relancez la mesure";
                                        colorMesureButton = Colors.red;
                                      });
                                    }
                                    else
                                      setState(() {
                                        colorMesureButton = Colors.green;
                                        recording = "Mesure correcte";
                                      });

                                  } else {
                                    recording = _start.toString();
                                    _start = _start - 0.5;
                                    i--;
                                    average[i] = double.parse(btData);
                                  }
                                },
                              ),
                            );
                            //_showDialog();

                          },
                          textColor: colorMesureButton,
                          child: Text(recording)
                        ),
                        RoundedProgressBar(
                            percent: (double.parse(btData)),
                            theme: RoundedProgressBarTheme.yellow,
                            childCenter: Text("$btData")),
                        /*
                        new Slider(
                            value: (double.parse(btData)),
                            min: 0,
                            max: 20,
                            divisions: 200,
                            activeColor: Colors.green,
                            inactiveColor: Colors.red,
                            label: '${valueHolder.round()}',
                            onChanged: (double temp) {
                              setState(() {
                                valueHolder = (double.parse(btData)).round();
                              });
                            },
                            semanticFormatterCallback: (double newValue) {
                              return '${newValue.round()}';
                            }),*/

                        FlatButton(
                          child: Text("S'inscrire"),
                          color: Colors.blue,
                          textColor: Colors.white,
                          padding: EdgeInsets.only(
                              left: 38, right: 38, top: 15, bottom: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              User user = await addUser();
                              //getUser();
                              connectBT();

                              if (user != null) {
                                print("salut" + user.userId.toString());
                              }
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MainTitle(
                                            userIn: user,
                                            messageIn: 0,
                                          )));
                              // Navigator.pushReplacement(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) =>
                              //             Menu(
                              //               BTDevice: BTDevice,
                              //               curUser: user,
                              //             )));
                            } else {
                              print("Salut c'est bien");
                              if (_pathSaved == null) {
                                colorButton = Colors.red;
                                print("Salut c'est génial");
                                (context as Element).reassemble();
                              }
                            }
                          },
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("Inscription"),
        backgroundColor: Colors.blue,
        actions: <Widget>[
          new FlatButton(
            child: new Text(
              "AutoFill",
              style: TextStyle(
                color: Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () {
              name.text = "Jean";
              _userMode = "Sportif";
              hauteur_max.text = "125";
              hauteur_min.text = "115";
              _pathSaved =
                  "/data/user/0/genourob.gbsalternative/app_flutter/2757907402980141240.jpg";
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[LoginCard(context)],
        ),
      ),
    );
  }
}
