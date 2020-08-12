import 'dart:async';

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/AppLocalizations.dart';
import 'package:gbsalternative/BluetoothManager.dart';
import 'package:gbsalternative/DatabaseHelper.dart';
import 'package:gbsalternative/LoadPage.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

String btData;
List<_Message> messages = List<_Message>();

class Register extends StatefulWidget {
  final AppLanguage appLanguage;

  Register({@required this.appLanguage});

  @override
  _Register createState() => _Register(appLanguage);
}

class _Register extends State<Register> {
  DatabaseHelper db = new DatabaseHelper();

  User user;

  BluetoothManager btManage =
      new BluetoothManager(user: null, inputMessage: null, appLanguage: null);

  Size screenSize;

  String _pathSaved;
  File imageFile;

  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  /* FORM */
  static String _userMode = "";
  final hauteur_min = new TextEditingController();
  final hauteur_max = new TextEditingController();
  var name = new TextEditingController();
  var serialNumber = new TextEditingController();
  int tempHautMax;
  int tempHautMin;
  bool _validate = false;
  bool isEmpty = false;
  bool isSwitched = false;
  bool isStopped = false;
  List<Step> steps;
  FocusNode nameNode;
  FocusNode posBNode;
  FocusNode posTNode;
  FocusNode serialNode;
  ScrollController _controller;
  double posScroll = 0.0;
  bool isFound;

  TextStyle textStyle =
      TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold);

  CameraController controller;
  List cameras;
  int selectedCameraIdx;
  String imagePath;

  /* END FORM */

  String macAddress;

  bool isConnected;
  Timer timerConnexion;

  String discovering;
  String statusBT;
  bool clickable = false;

  AppLanguage appLanguage;

  Color colorButton = Colors.black;
  int valueHolder = 20;

  final _formKey = GlobalKey<FormState>();

  int currentStep = 0;
  bool complete = false;

  @override
  void initState() {
    btData = "0.0";
    _controller = ScrollController();
    _pathSaved = "assets/default.png";
    nameNode = FocusNode();
    posBNode = FocusNode();
    posTNode = FocusNode();
    serialNode = FocusNode();
    tempHautMin = 0;
    tempHautMax = 0;

    isFound = false;
    isConnected = false;

    if (currentStep == 0) nameNode.requestFocus();
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    nameNode.dispose();
    posBNode.dispose();
    posTNode.dispose();
    serialNode.dispose();
    controller?.dispose();
    timerConnexion?.cancel();
    super.dispose();
  }

  _Register(AppLanguage _appLanguage) {
    appLanguage = _appLanguage;
  }

  void connect() async {
    //Tant que le bluetooth n'est pas activé, on demande son activation
    if (await btManage.enableBluetooth()) {
      connect();
    } else {
      btManage.connect(macAddress,
          "gBs" + serialNumber.text.toUpperCase().replaceAll(" ", ""));
      isConnected = await btManage.getStatus();
      testConnect();
    }
  }

  testConnect() async {
    isConnected = await btManage.getStatus();
    if (!isConnected) {
      timerConnexion = new Timer.periodic(Duration(milliseconds: 3000),
          (timerConnexion) async {
        btManage.connect(macAddress,
            "gBs" + serialNumber.text.toUpperCase().replaceAll(" ", ""));
        print("Status: $isConnected");
        isConnected = await btManage.getStatus();
        if (isConnected) {
          timerConnexion.cancel();
        }
      });
    }

    //Si l'utilisateur débranche le gbs pendant l'inscription
    timerConnexion = new Timer.periodic(Duration(milliseconds: 1000),
        (timerConnexion) async {
      isConnected = await btManage.getStatus();

      if (!isConnected) {
        setState(() {
          isFound = false;
          discovering =
              AppLocalizations.of(this.context).translate('connecter_app');
        });
        show(AppLocalizations.of(this.context).translate('connexion_perdue'));
        timerConnexion.cancel();
      }
    });
  }

  Future<void> getData() async {
    btData = await btManage.getData();
  }

  pickImage(ImageSource source) async {
    imageFile = await ImagePicker.pickImage(source: source);

    final directory = await getApplicationDocumentsDirectory();
    final String path = directory.path;

    String nameImage = name.text + "_" + basename(imageFile.path);

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
    int id = await db.addUser(User(
      userId: null,
      userName: name.text,
      userMode: _userMode,
      userPic: _pathSaved,
      userHeightTop: hauteur_max.text,
      userHeightBottom: hauteur_min.text,
      userInitialPush: "0.0",
      userMacAddress: macAddress,
      userSerialNumber:
          "gBs" + serialNumber.text.toUpperCase().replaceAll(" ", ""),
    ));
    print("ID INScr: " + id.toString());
    user = await db.getUser(id);
    print("USER ID: " + user.userId.toString());

    macAddress = null;

    return user;
  }

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

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;

    if (discovering == null)
      discovering = AppLocalizations.of(context).translate('connecter_app');

    if (statusBT == null)
      statusBT = AppLocalizations.of(context).translate('connecter_app');

    Widget nextButton = FlatButton(
      onPressed: /*!clickable ? null : */ () {
        if (hauteur_max != null) tempHautMax = int.tryParse(hauteur_max.text);
        if (hauteur_min != null) tempHautMin = int.tryParse(hauteur_min.text);

        if (tempHautMin == null || tempHautMax == null) {
          tempHautMin = 0;
          tempHautMax = 0;
        }
        _validate = false;
        if (currentStep == 0) {
          if (name.text == "")
            isEmpty = true;
          else
            isEmpty = false;
        } else if (currentStep == 1) {
          if (hauteur_min.text == "")
            isEmpty = true;
          else
            isEmpty = false;
        } else if (currentStep == 2) {
          if (hauteur_max.text == "")
            isEmpty = true;
          else
            isEmpty = false;
          if (tempHautMax <= tempHautMin)
            _validate = true;
          else
            _validate = false;
        } else if (currentStep == 5) {
          //Bouton connexion
          if (!isConnected) {
            show(AppLocalizations.of(context).translate('connect_av'));
            return;
          }
        }

        if (!_validate && !isEmpty) {
          _validate = false;
          //Retirer le clavier
          FocusScope.of(context).requestFocus(new FocusNode());
          next();

          //Changer le focus texte
          if (currentStep == 0) {
            nameNode.requestFocus();
          } else if (currentStep == 1) {
            posBNode.requestFocus();
          } else if (currentStep == 2) {
            posTNode.requestFocus();
          } else if (currentStep == 3) {
            if (_userMode == "")
              _userMode = AppLocalizations.of(context).translate('familial');
          } else if (currentStep == 5) {
            serialNode.requestFocus();
          }

          _controller.animateTo(((currentStep) * 75).toDouble(),
              duration: Duration(milliseconds: 500), curve: Curves.linear);
        } else {
          setState(() {
            _validate = true;
          });
        }
      },
      color: Colors.blue,
      child: Text(
        AppLocalizations.of(context).translate('suivant'),
        style: TextStyle(color: Colors.white),
      ),
    );

    Widget backButton = FlatButton(
      onPressed: () {
        //Retirer le clavier
        FocusScope.of(context).requestFocus(new FocusNode());

        if (currentStep == 1) isStopped = true;

        back();
        //Changer le focus texte
        //Si appuie retour sur le premier champs, chargement accueil
        if (currentStep == 0 && isStopped) {
          isStopped = false;
          nameNode.requestFocus();
        } else if (currentStep == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoadPage(
                appLanguage: appLanguage,
                page: login,
                user: null,
                messageIn: "0",
              ),
            ),
          );
        } else if (currentStep == 1)
          posBNode.requestFocus();
        else if (currentStep == 2)
          posTNode.requestFocus();
        else if (currentStep == 5) serialNode.requestFocus();

        _controller.animateTo((((currentStep) * 75)).toDouble(),
            duration: Duration(milliseconds: 500), curve: Curves.linear);
      },
      child: Text(AppLocalizations.of(context).translate('retour')),
    );

    steps = [
      Step(
        title: Text(AppLocalizations.of(context).translate('prenom')),
        isActive: currentStep > 0,
        state: currentStep > 0 ? StepState.complete : StepState.disabled,
        content: SizedBox(
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  style: textStyle,
                  focusNode: nameNode,
                  controller: name,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).translate('prenom'),
                    errorText: isEmpty
                        ? AppLocalizations.of(context)
                            .translate('erreur_prenom')
                        : null,
                  ),
                ),
              ),
              Expanded(child: nextButton),
              Expanded(child: backButton),
            ],
          ),
        ),
      ),
      Step(
        title: Text(AppLocalizations.of(context).translate('haut_min')),
        isActive: currentStep > 1,
        state: currentStep > 1 ? StepState.complete : StepState.disabled,
        content: SizedBox(
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  style: textStyle,
                  focusNode: posBNode,
                  //autofocus: currentStep == 2 ? true : false,
                  controller: hauteur_min,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    WhitelistingTextInputFormatter.digitsOnly
                  ],
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context).translate('haut_min'),
                    errorText: isEmpty
                        ? AppLocalizations.of(context)
                            .translate('erreur_hauteur')
                        : null,
                  ),
                ),
              ),
              Expanded(child: nextButton),
              Expanded(child: backButton),
            ],
          ),
        ),
      ),
      Step(
        title: Text(AppLocalizations.of(context).translate('haut_max')),
        isActive: currentStep > 2,
        state: currentStep > 2 ? StepState.complete : StepState.disabled,
        content: SizedBox(
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  style: textStyle,
                  autofocus: true,
                  //autofocus: currentStep == 3 ? true : false,
                  focusNode: posTNode,
                  controller: hauteur_max,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    WhitelistingTextInputFormatter.digitsOnly
                  ],
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context).translate('haut_max'),
                    errorText: isEmpty
                        ? AppLocalizations.of(context)
                            .translate('erreur_hauteur')
                        : _validate
                            ? AppLocalizations.of(context)
                                .translate('erreur_haut_max')
                            : null,
                  ),
                ),
              ),
              Expanded(child: nextButton),
              Expanded(child: backButton),
            ],
          ),
        ),
      ),
      Step(
        title: Text(
          AppLocalizations.of(context).translate('mode'),
        ),
        isActive: currentStep > 3,
        state: currentStep > 3 ? StepState.complete : StepState.disabled,
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              AppLocalizations.of(context).translate('familial'),
              style: textStyle,
            ),
            Switch(
              value: isSwitched,
              onChanged: (value) {
                _updateSwitch(value);
                isSwitched = value;
                if (isSwitched)
                  _userMode = AppLocalizations.of(context).translate('sportif');
                else
                  _userMode =
                      AppLocalizations.of(context).translate('familial');
              },
              activeTrackColor: Colors.lightGreenAccent,
              activeColor: Colors.green,
            ),
            Text(
              AppLocalizations.of(context).translate('sportif'),
              style: textStyle,
            ),
          ],
        ),
      ),
      Step(
        title: Text(AppLocalizations.of(context).translate('select_image')),
        isActive: currentStep > 4,
        state: currentStep > 4 ? StepState.complete : StepState.disabled,
        content:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <
                Widget>[
          //showImage(),
          //Image(image: AssetImage(_path)),
          Center(
              child: imageFile == null
                  ? Image.asset(
                      'assets/default.png',
                      width: screenSize.width * 0.2,
                    )
                  : Image.file(File(_pathSaved), width: screenSize.width * 0.2)
              //Image.file(imageFile, width: screenHeight * 0.6, height: screenHeight*0.6,),
              ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.image),
                    Text(" " +
                        AppLocalizations.of(context).translate('select_image')),
                  ],
                ),
                onPressed: () {
                  pickImage(ImageSource.gallery);
                },
                textColor: colorButton,
              ),
              Padding(
                padding: EdgeInsets.all(10),
              ),
              RaisedButton(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.camera_alt),
                    Text(" " +
                        AppLocalizations.of(context)
                            .translate('prendre_photo')),
                  ],
                ),
                onPressed: () {
                  pickImage(ImageSource.camera);
                },
                textColor: colorButton,
              ),
            ],
          ),
        ]),
      ),
      Step(
        title: Text(AppLocalizations.of(context).translate('connecter_app')),
        isActive: currentStep > 5,
        state: currentStep > 5 ? StepState.complete : StepState.disabled,
        content: Column(
          children: <Widget>[
            TextFormField(
              enabled: isFound ? false : true,
              style: textStyle,
              focusNode: serialNode,
              controller: serialNumber,
              decoration: InputDecoration(
                labelText:
                    "1. " + AppLocalizations.of(context).translate('num_serie'),
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    child: Text(
                      "2. " + discovering,
                      style: textStyle,
                    ),
                    onPressed: !isFound && serialNumber.text.length >= 8
                        ? () async {
                            macAddress = await btManage.getPairedDevices(
                                serialNumber.text
                                    .toUpperCase()
                                    .replaceAll(" ", ""));

                            print(
                                "MAC ADREEEEEEEEEEEEEEEEEEEEEEEEEEEEESS: $macAddress");

                            int tempTimer = 0;
                            //Check tant que l'adresse mac est égale à -1 toute les secondes
                            //Si pas trouve au bout de 30 secondes, affiche message d'erreur
                            Timer.periodic(const Duration(seconds: 1),
                                (timer) async {
                              if (macAddress == "0") {
                                macAddress = await btManage.getPairedDevices(
                                    serialNumber.text
                                        .toUpperCase()
                                        .replaceAll(" ", ""));
                              }
                              if (macAddress != "-1") {
                                timer.cancel();
                                //Appareil trouvé
                                setState(() {
                                  discovering = AppLocalizations.of(context)
                                      .translate('app_trouve');
                                  isFound = true;
                                  connect();

                                  Timer.periodic(const Duration(seconds: 1),
                                      (timer) {
                                    if (isConnected) {
                                      timer.cancel();
                                      setState(() {
                                        discovering = AppLocalizations.of(
                                                context)
                                            .translate('status_connexion_bon');
                                      });
                                    } else {
                                      setState(() {
                                        discovering = AppLocalizations.of(
                                                context)
                                            .translate('connexion_en_cours');
                                      });
                                    }
                                  });
                                });
                              } else if (macAddress == "-1") {
                                if (tempTimer >= 20) {
                                  setState(() {
                                    show(AppLocalizations.of(context)
                                        .translate('app_non_trouve'));
                                    discovering = AppLocalizations.of(context)
                                        .translate('connecter_app');
                                  });
                                  isFound = false;
                                  timer.cancel();
                                  tempTimer = 0;
                                } else {
                                  macAddress = await btManage.getMacAddress();
                                  setState(() {
                                    discovering = AppLocalizations.of(context)
                                        .translate('recherche_app');
                                    isFound = false;
                                  });
                                }
                              }
                              print(tempTimer);
                              tempTimer++;
                            });
                          }
                        : null,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                ),
                /*Expanded(
                  child: RaisedButton(
                    child: Text(
                      "2. " + statusBT,
                      style: textStyle,
                    ),
                    onPressed: isFound
                        ? statusBT !=
                                AppLocalizations.of(context)
                                    .translate('status_connexion_bon')
                            ? () async {
                                //final macAddress = btManage.createState().macAdress;

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

                                //updateMacAddress(macAddress);
                                connect();

                                Timer.periodic(const Duration(seconds: 1),
                                    (timer) {
                                  if (isConnected) {
                                    timer.cancel();
                                    setState(() {
                                      statusBT = AppLocalizations.of(context)
                                          .translate('status_connexion_bon');
                                    });
                                  } else {
                                    setState(() {
                                      statusBT = AppLocalizations.of(context)
                                          .translate('connexion_en_cours');
                                    });
                                  }
                                });
                              }
                            : null
                        : null,
                    textColor: colorButton,
                  ),
                ),*/
              ],
            ),
          ],
        ),
      ),
      Step(
          title: Text(AppLocalizations.of(context).translate('recap')),
          isActive: currentStep > 6,
          state: currentStep > 6 ? StepState.complete : StepState.disabled,
          content: Column(
            children: <Widget>[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    Image.asset(
                      _pathSaved,
                      width: screenSize.width * 0.15,
                    ),
                    Column(
                      children: <Widget>[
                        Text(
                          AppLocalizations.of(context).translate('prenom') +
                              ": " +
                              name.text,
                          style: textStyle,
                        ),
                        Text(
                          AppLocalizations.of(context).translate('mode') +
                              ": " +
                              _userMode,
                          style: textStyle,
                        ),
                        Text(
                          AppLocalizations.of(context).translate('haut_min') +
                              ": " +
                              hauteur_min.text,
                          style: textStyle,
                        ),
                        Text(
                          AppLocalizations.of(context).translate('haut_max') +
                              ": " +
                              hauteur_max.text,
                          style: textStyle,
                        ),
                        /* macAddress != null
                            ? Text(
                                AppLocalizations.of(context)
                                    .translate('status_connexion_bon'),
                                style: textStyle,
                              )
                            : Text(
                                AppLocalizations.of(context)
                                    .translate('status_connexion_mauvais'),
                                style: textStyle,
                              ),*/
                        /*Text(AppLocalizations.of(context)
                                .translate('premiere_mesure') +
                            ": " +
                            result.toString()),*/

                        //Text("Adresse MAC $macAddress"),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                    child: Text(
                        AppLocalizations.of(context).translate('valider_insc')),
                    color: Colors.blue,
                    textColor: Colors.white,
                    padding: EdgeInsets.only(
                        left: 38, right: 38, top: 15, bottom: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    onPressed: () async {
                      //Conditions d'inscriptions

                      if (_pathSaved == "assets/default.png") {
                        var bytes = await rootBundle.load(_pathSaved);
                        String dir =
                            (await getApplicationDocumentsDirectory()).path;
                        File tempFile =
                            await writeToFile(bytes, '$dir/default.png');

                        setState(() {
                          _pathSaved = tempFile.path;
                        });
                      }

                      User user = await addUser();
                      //getUser();
                      //connectBT();

                      if (user != null) {
                        //print("salut " + user.userId.toString());
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoadPage(
                              appLanguage: appLanguage,
                              user: user,
                              page: firstPush,
                              messageIn: "0",
                            ),
                          ),
                        );
                        //dispose();
                      } else
                        print("Something went wrong");
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
              ),
            ],
          )),
    ];

    Future<bool> _onBackPressed() {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => LoadPage(
                    user: null,
                    appLanguage: appLanguage,
                    messageIn: "",
                    page: login,
                  )));
    }

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).translate('inscription')),
          backgroundColor: Colors.blue,
          key: _formKey,
          actions: <Widget>[
            StepProgressIndicator(
              totalSteps: 6,
              currentStep: currentStep,
              fallbackLength: screenSize.width / 2,
              selectedColor: Colors.lightGreenAccent,
              unselectedColor: Colors.white38,
              roundedEdges: Radius.circular(10),
              padding: 1,
            ),
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
                macAddress = "78:DB:2F:BF:3B:03";
                serialNumber.text = "1230997P";
                //result = 6.31;
                _pathSaved = "assets/default.png";
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
                            currentStep >= 3 ? nextButton : Container(),
                            currentStep >= 3 ? backButton : Container(),
                            currentStep == 5 ? Container() : Container(),
                            currentStep == 5 ? Container() : Container(),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              0, 0, 0, screenSize.width * 0.5),
                        )
                      ],
                    );
                  }
                : (BuildContext context,
                    {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
                    return Padding(
                      padding:
                          EdgeInsets.fromLTRB(0, 0, 0, screenSize.width * 0.5),
                    );
                  },
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
