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
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/AppLocalizations.dart';
import 'package:gbsalternative/BluetoothManager.dart';

//import 'file:///C:/Users/Pierrick/Documents/Entreprise/Stage/Genourob/gBs/gbs_alternative/lib/Backup/BluetoothSync_shield.dart';
import 'package:gbsalternative/LoadPage.dart';
import 'package:gbsalternative/Swimmer/Swimmer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'DatabaseHelper.dart';
import 'MainTitle.dart';

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

String btData;
String _messageBuffer = '';
List<_Message> messages = List<_Message>();

class Register extends StatefulWidget {
  final AppLanguage appLanguage;

  Register({@required this.appLanguage});

  @override
  _Register createState() => _Register(appLanguage);
}

class _Register extends State<Register> {
  DatabaseHelper db = new DatabaseHelper();

  BluetoothManager btManage =
      new BluetoothManager(user: null, inputMessage: null, appLanguage: null);

  double screenHeight;
  double screenWidth;

  String _pathSaved;
  File imageFile;

  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  /* FORM */
  static String _userMode = "";
  final hauteur_min = new TextEditingController();
  final hauteur_max = new TextEditingController();
  var name = new TextEditingController();
  bool isSwitched = false;
  List<Step> steps;
  ScrollController _controller;
  double posScroll = 0.0;
  bool isDisabled;
  bool isFound;

  /* END FORM */

  String macAddress;

  bool isConnected;
  Timer _timer;
  double _start = 10.0;
  static double _reset = 10.0;
  int i = 20;
  List<double> average = new List(2 * _reset.toInt());

  static double delta = 102.0;
  double coefKg = 0.45359237;
  double result;
  String recording;
  String discovering;
  String statusBT;
  bool clickable = false;

  AppLanguage appLanguage;

  _Register(AppLanguage _appLanguage) {
    appLanguage = _appLanguage;
  }

  @override
  void initState() {
    btData = "0.0";
    _controller = ScrollController();
    isDisabled = false;
    _pathSaved = "assets/avatar.png";
    isFound = false;
    isConnected = false;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void connect() async {
    btManage.createState().connect("register");
    //testConnect();
  }

  testConnect() async {
    if (!isConnected) {
      new Timer.periodic(Duration(milliseconds: 300), (timer) {
        setState(() async {
          isConnected = await btManage.createState().connect("connexion");
          if (isConnected) {
            timer.cancel();
          }
        });
        //isConnected = btManage.createState().isConnected;
      });
    }
  }

  Future<void> updateMacAddress(String address) async {
    setState(() => macAddress = address);
  }

  Future<void> getData() async {
    btData = await btManage.createState().getData();
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

  //write to app path
  Future<File> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
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

  Color colorButton = Colors.black;
  Color colorMesureButton = Colors.black;
  int valueHolder = 20;

  //String savedImage = "";

  final _formKey = GlobalKey<FormState>();

  int currentStep = 0;
  bool complete = false;

  next() {
    currentStep + 1 != steps.length
        ? goTo(currentStep + 1)
        : setState(() => complete = true);
    //if (currentStep == 2 || currentStep == 3) myFocusNode.requestFocus();
  }

  back() {
    if (currentStep > 0) {
      goTo(currentStep - 1);
    }
  }

  goTo(int step) {
    setState(() => currentStep = step);
  }

  void _updateSwitch(bool value) => setState(() => isSwitched = value);

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    if (recording == null)
      recording =
          AppLocalizations.of(context).translate('demarrer_enregistrement');

    if (discovering == null)
      discovering = AppLocalizations.of(context).translate('scan_app');

    if (statusBT == null)
      statusBT = AppLocalizations.of(context).translate('connecter_app');

    steps = [
      Step(
        title: Text(AppLocalizations.of(context).translate('prenom')),
        isActive: currentStep > 0,
        state: currentStep > 0 ? StepState.complete : StepState.disabled,
        content: TextFormField(
            autofocus: currentStep == 0 ? true : false,
            controller: name,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).translate('prenom'),
            ),
            validator: (value) {
              if (value.isEmpty) clickable = true;
              return null;
            }),
      ),
      Step(
        title: Text(AppLocalizations.of(context).translate('type_utilisation')),
        isActive: currentStep > 1,
        state: currentStep > 1 ? StepState.complete : StepState.disabled,
        content: Row(
          children: <Widget>[
            Text(AppLocalizations.of(context).translate('normal')),
            Switch(
              value: isSwitched,
              onChanged: (value) {
                _updateSwitch(value);
                isSwitched = value;
                if (isSwitched)
                  _userMode = "Sportif";
                else
                  _userMode = "Normal";
              },
              activeTrackColor: Colors.lightGreenAccent,
              activeColor: Colors.green,
            ),
            Text(AppLocalizations.of(context).translate('sportif')),
          ],
        ),
      ),
      Step(
        title: Text(AppLocalizations.of(context).translate('haut_min')),
        isActive: currentStep > 2,
        state: currentStep > 2 ? StepState.complete : StepState.disabled,
        content: TextFormField(
            //autofocus: currentStep == 2 ? true : false,
            controller: hauteur_min,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter.digitsOnly
            ],
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).translate('haut_min'),
            ),
            validator: (value) {
              if (value.isEmpty) return 'Veuillez remplir ce champ';
              return null;
            }),
      ),
      Step(
        title: Text(AppLocalizations.of(context).translate('haut_max')),
        isActive: currentStep > 3,
        state: currentStep > 3 ? StepState.complete : StepState.disabled,
        content: TextFormField(
            //autofocus: currentStep == 3 ? true : false,
            controller: hauteur_max,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter.digitsOnly
            ],
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).translate('haut_max'),
            ),
            validator: (value) {
              if (value.isEmpty) return 'Veuillez remplir ce champ';
              return null;
            }),
      ),
      Step(
        title: Text(AppLocalizations.of(context).translate('select_image')),
        isActive: currentStep > 4,
        state: currentStep > 4 ? StepState.complete : StepState.disabled,
        content: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              //showImage(),
              //Image(image: AssetImage(_path)),
              Center(
                  child: imageFile == null
                      ? Image.asset(
                          'assets/avatar.png',
                          width: screenWidth * 0.2,
                        )
                      : Image.file(File(_pathSaved), width: screenHeight * 0.2)
                  //Image.file(imageFile, width: screenHeight * 0.6, height: screenHeight*0.6,),
                  ),
              RaisedButton(
                child: Text(
                    AppLocalizations.of(context).translate('select_image')),
                onPressed: () {
                  _pathSaved = pickImageFromGallery(ImageSource.gallery);
                },
                textColor: colorButton,
              ),
            ]),
      ),
      Step(
          title: Text(AppLocalizations.of(context).translate('connecter_app')),
          isActive: currentStep > 5,
          state: currentStep > 5 ? StepState.complete : StepState.disabled,
          content: Column(children: <Widget>[
            RaisedButton(
              child: Text(discovering),
              onPressed: !isFound
                  ? () async {
                      btManage.createState().enableBluetooth();
                      macAddress = await btManage
                          .createState()
                          .getPairedDevices("register");

                      if (macAddress != null) {
                        //Appareil trouvé
                        setState(() {
                          discovering = AppLocalizations.of(context)
                              .translate('app_trouve');
                          isFound = true;
                        });
                      } else {
                        setState(() {
                          discovering = AppLocalizations.of(context)
                              .translate('app_non_trouve');
                          isFound = false;
                        });
                      }
                    }
                  : null,
            ),
            RaisedButton(
              child: Text(statusBT),
              onPressed: isFound
                  ? () async {
                      final macAddress = btManage.createState().macAdress;

                      //final macAddress = await Navigator.push(
                      //    context,
                      //    MaterialPageRoute(
                      //        builder: (context) =>
                      //            /*BluetoothSync(
                      //              curUser: null,
                      //              inputMessage: "inscription",
                      //              appLanguage: appLanguage,
                      //            )*/
                      //            BluetoothManager(
                      //                user: null,
                      //                inputMessage: "inscription",
                      //                appLanguage: appLanguage)));

                      updateMacAddress(macAddress);
                      connect();

                      Future.delayed(const Duration(milliseconds: 1000),
                          () async {
                        isConnected = await btManage.createState().getStatus();
                      });

                      if (isConnected) {
                        setState(() {
                          statusBT = AppLocalizations.of(context)
                              .translate('status_connexion_bon');
                        });
                      } else {
                        setState(() {
                          statusBT = AppLocalizations.of(context)
                              .translate('status_connexion_mauvais');
                        });
                      }
                    }
                  : null,
              textColor: colorButton,
            ),
          ])),
      Step(
        title: Text(AppLocalizations.of(context).translate('premiere_mesure')),
        isActive: currentStep > 6,
        state: currentStep > 6 ? StepState.complete : StepState.disabled,
        content: Column(
          children: <Widget>[
            Text(AppLocalizations.of(context).translate('explications_mesure')),
            RaisedButton(
                //child: Text("Démarrer l'enregistrement."),
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
                          result = double.parse(
                              (average.reduce((a, b) => a + b) / average.length)
                                  .toStringAsFixed(2));
                          print(result.toStringAsFixed(2));
                          i = 20;
                          if (result <= 5.0 || result >= 10.0) {
                            //Mesure pas bonne, réajuster la toise
                            setState(() {
                              recording = AppLocalizations.of(context)
                                  .translate('status_mesure_mauvais');
                              colorMesureButton = Colors.red;
                            });
                          } else
                            setState(() {
                              colorMesureButton = Colors.green;
                              recording = AppLocalizations.of(context)
                                  .translate('status_mesure_bon');
                            });
                        } else {
                          recording = _start.toString();
                          _start = _start - 0.5;
                          i--;
                          getData();
                          average[i] = double.parse(btData);
                        }
                      },
                    ),
                  );
                  //_showDialog();
                },
                textColor: colorMesureButton,
                child: Text(recording)),
            RoundedProgressBar(
                percent:
                    (double.parse(btData)) >= 0 ? (double.parse(btData)) : 0.0,
                theme: RoundedProgressBarTheme.yellow,
                childCenter: Text("$btData")),
          ],
        ),
      ),
      Step(
          title: Text(AppLocalizations.of(context).translate('recap')),
          isActive: currentStep > 7,
          state: currentStep > 7 ? StepState.complete : StepState.disabled,
          content: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Image.asset(
                        _pathSaved,
                        width: screenWidth * 0.15,
                      ),
                      Text(AppLocalizations.of(context).translate('prenom') +
                          ": " +
                          name.text),
                      Text(AppLocalizations.of(context)
                              .translate('type_utilisation') +
                          ": " +
                          _userMode),
                      Text(AppLocalizations.of(context).translate('haut_min') +
                          ": " +
                          hauteur_min.text),

                      //Si haut max est inf à haut min
                      (hauteur_min.text != '' && hauteur_max.text != '')
                          ? int.tryParse(hauteur_max.text) <=
                                  int.tryParse(hauteur_min.text)
                              ? Text(
                                  "La hauteur max doit être supérieure à la hauteur min. \n"
                                  "Veuillez corriger cela en revenant à l'étape 3",
                                  style: TextStyle(color: Colors.red),
                                )
                              : Text(AppLocalizations.of(context)
                                      .translate('haut_max') +
                                  ": " +
                                  hauteur_max.text)
                          : Text(AppLocalizations.of(context)
                                  .translate('haut_max') +
                              ": "),

                      macAddress != null
                          ? Text(AppLocalizations.of(context)
                              .translate('status_connexion_bon'))
                          : Text(
                              AppLocalizations.of(context)
                                  .translate('status_connexion_mauvais'),
                              style: TextStyle(color: Colors.red),
                            ),
                      Text(AppLocalizations.of(context)
                              .translate('premiere_mesure') +
                          ": " +
                          result.toString()),

                      Text("Adresse MAC $macAddress"),
                    ],
                  ),
                  FlatButton(
                    child: Text(
                        AppLocalizations.of(context).translate('inscription')),
                    color: Colors.blue,
                    textColor: Colors.white,
                    padding: EdgeInsets.only(
                        left: 38, right: 38, top: 15, bottom: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    onPressed: () async {
                      //Conditions d'inscriptions
                      //Prénom
                      if (name.text == '')
                        isDisabled = true;
                      //Hauteur min et max
                      else if (hauteur_min.text == '' || hauteur_max.text == '')
                        isDisabled = true;
                      //Hauteur max inférieur à hauteur min ?
                      else if (hauteur_min.text != '' &&
                          hauteur_max.text !=
                              '') if (int.tryParse(hauteur_max.text) <=
                          int.tryParse(hauteur_min.text))
                        isDisabled = true;
                      //Adresse mac
                      else if (macAddress == '')
                        isDisabled = true;
                      //Première poussée
                      else if (result.toString() == null)
                        isDisabled = true;
                      else
                        isDisabled = false;

                      if (_pathSaved == "assets/avatar.png") {
                        var bytes = await rootBundle.load(_pathSaved);
                        String dir =
                            (await getApplicationDocumentsDirectory()).path;
                        File tempFile =
                            await writeToFile(bytes, '$dir/default.png');

                        setState(() {
                          _pathSaved = tempFile.path;
                        });
                      }

                      if (!isDisabled) {
                        User user = await addUser();
                        //getUser();
                        //connectBT();

                        if (user != null) {
                          print("salut " + user.userId.toString());
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoadPage(
                                        appLanguage: appLanguage,
                                        user: user,
                                        messageIn: "0",
                                        page: "mainTitle",
                                      )));
                          dispose();
                        } else
                          print("Something went wrong");
                        // Navigator.pushReplacement(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) =>
                        //             Menu(
                        //               BTDevice: BTDevice,
                        //               curUser: user,
                        //             )));
                      } else
                        show("Veuillez corriger toutes les erreurs");
                    },
                  ),
                  FlatButton(
                    onPressed: () {
                      back();
                      _controller.animateTo((((currentStep) * 75)).toDouble(),
                          duration: Duration(milliseconds: 500),
                          curve: Curves.linear);
                    },
                    child:
                        Text(AppLocalizations.of(context).translate('retour')),
                  ),
                ],
              )
            ],
          )),
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('inscription')),
        backgroundColor: Colors.blue,
        key: _formKey,
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
              hauteur_min.text = "115";
              hauteur_max.text = "125";
              macAddress = "00:0E:EA:CF:52:62";
              result = 6.31;
              _pathSaved = "assets/avatar.png";
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        controller: _controller,
        child: Stepper(
          physics: ClampingScrollPhysics(),
          type: StepperType.vertical,
          currentStep: currentStep,
          onStepContinue: next,
          onStepTapped: (step) => goTo(step),
          onStepCancel: back,
          steps: steps,
          controlsBuilder: currentStep < steps.length - 1
              ? (BuildContext context,
                  {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
                  return Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          FlatButton(
                            onPressed: /*!clickable ? null : */ () {
                              //Retirer le clavier
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                              next();
                              _controller.animateTo(
                                  ((currentStep) * 75).toDouble(),
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.linear);
                            },
                            color: Colors.blue,
                            child: Text(
                              AppLocalizations.of(context).translate('suivant'),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          FlatButton(
                            onPressed: () {
                              back();
                              _controller.animateTo(
                                  (((currentStep) * 75)).toDouble(),
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.linear);
                            },
                            child: Text(AppLocalizations.of(context)
                                .translate('retour')),
                          ),
                        ],
                      ),
                      Padding(
                        padding:
                            EdgeInsets.fromLTRB(0, 0, 0, screenWidth * 0.5),
                      )
                    ],
                  );
                }
              : (BuildContext context,
                  {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, screenWidth * 0.5),
                  );
                },
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
