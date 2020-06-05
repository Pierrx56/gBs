import 'dart:async';

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_rounded_progress_bar/flutter_rounded_progress_bar.dart';
import 'package:flutter_rounded_progress_bar/rounded_progress_bar_style.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/AppLocalizations.dart';
import 'package:gbsalternative/LoadPage.dart';
import 'package:gbsalternative/MainTitle.dart';
import 'package:image_picker/image_picker.dart';
import 'DatabaseHelper.dart';
import 'Login.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'DatabaseHelper.dart';

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

String btData;
String _messageBuffer = '';
List<_Message> messages = List<_Message>();

class ManageProfile extends StatefulWidget {
  final User curUser;
  final AppLanguage appLanguage;

  ManageProfile({@required this.curUser, @required this.appLanguage});

  @override
  _ManageProfile createState() => _ManageProfile(curUser, appLanguage);
}

class _ManageProfile extends State<ManageProfile> {
  DatabaseHelper db = new DatabaseHelper();
  User user;
  bool isDisconnecting = false;
  BluetoothConnection connection;
  bool isConnected = false;
  AppLanguage appLanguage;

  Color colorMesureButton = Colors.black;
  Timer _timer;
  double _start = 10.0;
  static double _reset = 10.0;
  int i = 20;
  List<double> average = new List(2 * _reset.toInt());
  double delta = 102.0;
  double coefKg = 0.45359237;
  double result;
  double tempResult;
  String recording;

  _ManageProfile(User curUser, AppLanguage _appLanguage) {
    user = curUser;
    appLanguage = _appLanguage;

    if (user.userMode == "Sportif") {
      isSwitched = true;
    }
  }

  double screenHeight;

  String _pathSaved;
  File imageFile;

  String _userMode;
  bool isSwitched = false;

  var hauteur_min = new TextEditingController();
  var hauteur_max = new TextEditingController();
  String initialPush;

  Color colorButton = Colors.black;

  var name = new TextEditingController();

// user defined function
  void _confirmDelete() {
    // flutter defined function
    showDialog(
      context: this.context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title:
                new Text("Êtes-vous sûr de vouloir supprimer votre profil ?"),
            content: new Text("Cette action est irréversible."),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Supprimer"),
                onPressed: () {
                  print("ID à SUPPR:" + user.userId.toString());
                  db.deleteUser(user.userId);
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => LoadPage(appLanguage: appLanguage,messageIn: "",page: "login",user: null,)));
/*                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Login(
                              BTDevice: BTDevice,
                            )));*/
                },
              ),
              Padding(
                padding: EdgeInsets.all(12.0),
              ),
              new FlatButton(
                child: new Text("Annuler"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    btData = "0.0";
    connectBT();
    testConnect();

    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
  }

  pickImageFromGallery(ImageSource source) async {
    final directory = await getApplicationDocumentsDirectory();
    final String path = directory.path;

    String tmpName = user.userName;

    //We first delete the existing file
    final tmpFile = File(user.userPic);
    if (tmpFile.existsSync()) tmpFile.delete(recursive: true);

    imageFile = await ImagePicker.pickImage(source: source);

    //print('$path/$picName' + '.jpg');

    String nameImage = tmpName + "_" + basename(imageFile.path);

    print("Nom de l'image: " + nameImage);

    final File newImage = await imageFile.copy('$path/$nameImage');

    setState(() {
      _pathSaved = newImage.path;
      imageFile = newImage;
    });

    //var fileName = basename(imageFile.path);
    //final File localImage = await imageFile.copy('$path/$fileName');
    return _pathSaved = newImage.path;
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

  void testConnect() async {
    if (!isConnected) {
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
      tempResult = double.parse(
          ((double.parse(btData) - delta) / (convVoltToLbs * coefKg))
              .toStringAsExponential(1));

      btData = tempResult.toString();
      //print(btData);
    }).toList();
  }

  //String savedImage = "";

  final _formKey = GlobalKey<FormState>();

  Widget LoginCard(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;

    if (_pathSaved == null) _pathSaved = user.userPic;

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
                        AppLocalizations.of(context).translate('modifier'),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Text(AppLocalizations.of(context).translate('normal')),
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
                        Text(AppLocalizations.of(context).translate('sportif')),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                        controller: name,
                        decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)
                                    .translate('prenom') +
                                ": " +
                                user.userName,
                            hasFloatingPlaceholder: true),
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
                            labelText: AppLocalizations.of(context)
                                    .translate('haut_min') +
                                ": " +
                                user.userHeightBottom,
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
                            labelText: AppLocalizations.of(context)
                                    .translate('haut_max') +
                                ": " +
                                user.userHeightTop,
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
                            child:
                            Image.file(File(_pathSaved),
                                height: screenHeight * 0.3,
                                width: screenHeight * 0.3)
                            //Image.file(imageFile, width: screenHeight * 0.6, height: screenHeight*0.6,),
                            ),
                        RaisedButton(
                          child: Text(AppLocalizations.of(context)
                              .translate('changerImage')),
                          onPressed: () {
                            _pathSaved =
                                pickImageFromGallery(ImageSource.gallery);
                          },
                          textColor: colorButton,
                        ),
                        RaisedButton(
                          child: Text(AppLocalizations.of(context)
                              .translate('ajust_poussee')),
                          onPressed: () {
                            //TODO
                            setState(() {
                              pousseeDialog();
                            });
                          },
                          textColor: colorButton,
                        ),
                        FlatButton(
                          child: Text(AppLocalizations.of(context)
                              .translate('enregistrer')),
                          color: Colors.blue,
                          textColor: Colors.white,
                          padding: EdgeInsets.only(
                              left: 38, right: 38, top: 15, bottom: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          onPressed: () {
                            if (name.text == '') name.text = user.userName;
                            if (_pathSaved == '') _pathSaved = user.userPic;
                            if (_userMode == null) _userMode = user.userMode;
                            if (hauteur_max.text == '')
                              hauteur_max.text = user.userHeightTop;
                            if (hauteur_min.text == '')
                              hauteur_min.text = user.userHeightBottom;
                            if(initialPush == null) initialPush = user.userInitialPush;
                            /*
                            if (hauteur_min.text == '')
                              hauteur_min.text = user.userHeightBottom;
                            */

                            //TODO
                            String macAddress = user.userMacAddress;
/*
                            if (user.userInitialPush != result.toString())
                              initialPush = result.toString();
                            else
                              initialPush = user.userInitialPush;*/

                            db.updateUser(User(
                              userId: user.userId,
                              userName: name.text,
                              userMode: _userMode,
                              userPic: _pathSaved,
                              userHeightTop: hauteur_max.text,
                              userHeightBottom: hauteur_min.text,
                              userInitialPush: initialPush,
                              userMacAddress: macAddress,
                            ));

                            /*Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoadPage(
                                          user: user,
                                          appLanguage: appLanguage,
                                          messageIn: "0",
                                          page: "mainTitle",
                                        )));*/
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 15, bottom: 15),
                        ),
                        FlatButton(
                          child: Text(AppLocalizations.of(context)
                              .translate('supprimer')),
                          color: Colors.red,
                          textColor: Colors.white,
                          padding: EdgeInsets.only(
                              left: 38, right: 38, top: 15, bottom: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                // return object of type Dialog
                                return AlertDialog(
                                  title: new Text(AppLocalizations.of(this.context)
                                      .translate('confirm_suppr')),
                                  content: new Text(AppLocalizations.of(this.context)
                                      .translate('info_suppr')),
                                  actions: <Widget>[
                                    // usually buttons at the bottom of the dialog
                                    new FlatButton(
                                      child: new Text(
                                          AppLocalizations.of(this.context)
                                              .translate('supprimer')),
                                      onPressed: () {
                                        print("ID à SUPPR:" +
                                            user.userId.toString());
                                        db.deleteUser(user.userId);
                                        dispose();
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => LoadPage(appLanguage: appLanguage,page: "login",user: null,messageIn: "0",)));
                                      },
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(12.0),
                                    ),
                                    new FlatButton(
                                      child: new Text(
                                          AppLocalizations.of(this.context)
                                              .translate('annuler')),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
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

  void pousseeDialog() async {
    //appLanguage = AppLanguage();
    //await appLanguage.fetchLocale();

    showDialog(
        context: this.context,
        builder: (BuildContext context) {
          var temp = AppLocalizations.of(this.context);
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text(temp != null
                  ? AppLocalizations.of(this.context).translate('mesure')
                  : "Mesures"),
              content: Row(
                children: <Widget>[
                  SingleChildScrollView(
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          Text(temp != null
                              ? AppLocalizations.of(this.context)
                                  .translate('explications_mesure')
                              : "Explications: mesures"),
                          RoundedProgressBar(
                              percent: (double.parse(btData)),
                              theme: RoundedProgressBarTheme.yellow,
                              childCenter: Text("$btData")),
                          RaisedButton(
                              //child: Text("Démarrer l'enregistrement."),
                              onPressed: () async {
                                colorMesureButton = Colors.black;
                                const oneSec =
                                    const Duration(milliseconds: 500);
                                _timer = new Timer.periodic(
                                  oneSec,
                                  (Timer timer) => setState(
                                    () {
                                      if (_start < 0.5) {
                                        timer.cancel();
                                        _start = _reset;
                                        result =
                                            average.reduce((a, b) => a + b) /
                                                average.length;
                                        print(result.toString());
                                        i = 20;
                                        if (result <= 5.0 || result >= 10.0) {
                                          //Mesure pas bonne, réajuster la toise
                                          setState(() {
                                            recording = temp != null
                                                ? AppLocalizations.of(
                                                        this.context)
                                                    .translate(
                                                        'status_mesure_mauvais')
                                                : "Mesure ratée";
                                            colorMesureButton = Colors.red;
                                          });
                                        } else
                                          setState(() {
                                            colorMesureButton = Colors.green;
                                            initialPush = result.toString();
                                            recording = temp != null
                                                ? AppLocalizations.of(
                                                        this.context)
                                                    .translate(
                                                        'status_mesure_bon')
                                                : "Mesure bonne";
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
                              child: Text(recording)),
                          RaisedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(temp != null
                                ? AppLocalizations.of(this.context)
                                    .translate('retour')
                                : "Retourlol"),
                          )
                        ],
                      ),
                      width: 300.0,
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;

    if (recording == null)
      recording =
          AppLocalizations.of(context).translate('demarrer_enregistrement');

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('modification')),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[LoginCard(context)],
        ),
      ),
    );
  }

/*else {
      return Scaffold(
        appBar: AppBar(title: Text("Choix d'utilisateur")),
        body: Center(
          child: SingleChildScrollView(
            child: Text(
              BTDevice.address,
              style: TextStyle(fontSize: 24),
            ),
          ),
        ),
      );
    }
  }*/

//@override
//_Register createState() => new _Register();
}

/*
class _Register extends State<Register> {

  @override
  void initState() {
    super.initState();

  }


  @override
  Widget build(BuildContext context) {
    final BluetoothDevice _device = ModalRoute.of(context).settings.arguments;

    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Center(
        child:Container(
          child: Column(
            children: <Widget>[
              Text("C'est qui ?"),
              RaisedButton(
                elevation: 2,
                child: Text("Changer d'appareil"),
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/BluetoothSync');
                },
              ),
            ]
          ),
        ),
      ),
    );
  }

}

   */
