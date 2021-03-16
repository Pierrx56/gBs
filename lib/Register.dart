import 'dart:async';

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gbsalternative/Login.dart';
import 'package:gbsalternative/MaxPush.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/AppLocalizations.dart';
import 'package:gbsalternative/BluetoothManager.dart';
import 'package:gbsalternative/DatabaseHelper.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

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
  FocusNode serialNode;
  ScrollController _controller;
  double posScroll = 0.0;
  bool isFound;
  String selection;

  //Par défaut: 1 notif par jour
  int days = 1;

  TextStyle textStyle =
      TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold);
  TextStyle textStyleW =
      TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold);

  CameraController controller;
  List cameras;
  int selectedCameraIdx;
  String imagePath;

  /* END FORM */

  String macAddress;

  bool isConnected;
  Timer timerConnexion;
  Timer timerNode;

  String discovering;
  String statusBT;
  bool clickable = false;

  AppLanguage appLanguage;

  Color colorButton = Colors.black;
  int valueHolder = 20;

  final _formKey = GlobalKey<FormState>();

  int currentStep = 0;
  bool complete = false;
  bool isGoodLength;

  @override
  void initState() {
    btData = "0.0";
    _controller = ScrollController();
    _pathSaved = "assets/default.png";
    nameNode = FocusNode();
    serialNode = FocusNode();

    tempHautMin = 0;
    tempHautMax = 0;

    tz.initializeTimeZones();
    isFound = false;
    isConnected = false;
    isGoodLength = false;

    if (currentStep == 0) nameNode.requestFocus();
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    nameNode.dispose();
    serialNode.dispose();
    controller?.dispose();
    timerConnexion?.cancel();
    timerNode?.cancel();
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
    timerConnexion =
        new Timer.periodic(Duration(milliseconds: 500), (timerConnexion) async {
      isConnected = await btManage.getStatus();

      if (!isConnected) {
        setState(() {
          isFound = false;
          discovering =
              AppLocalizations.of(this.context).translate('connecter_app');
        });
        show(AppLocalizations.of(this.context).translate('connexion_perdue'));
        btManage.disconnect("origin");
        //connect();
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
      userNotifEvent: days.toString(),
      userLastLogin: tz.TZDateTime.now(tz.local).toString(),
    ));
    print("ID INScr: " + id.toString());
    user = await db.getUser(id);
    print("USER ID: " + user.userId.toString());

    macAddress = null;

    return user;
  }

  next() {
    if (currentStep + 1 != steps.length) {
      if (currentStep == 0 && name.text == "")
        isEmpty = true;
      else {
        goTo(currentStep + 1);
        isEmpty = false;
      }
    } else
      setState(() => complete = true);
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

    if (selection == null)
      selection = AppLocalizations.of(context).translate('notif_1_jour');

    List<String> notifs = [
      AppLocalizations.of(context).translate('notif_desactive'),
      AppLocalizations.of(context).translate('notif_1_jour'),
      AppLocalizations.of(context).translate('notif_2_jour'),
      AppLocalizations.of(context).translate('notif_3_jour'),
    ];

    /*
    List<int> heures = [
      0,1,2,3,4,5,6,7,8,9,10,11,12,
      13,14,15,16,17,18,19,20,21,22,23];
    List<int> minutes = [0,15,30,45];*/

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
        }
        if (currentStep == 1) {
          if (_userMode == "") {
            isEmpty = true;
            show(AppLocalizations.of(context).translate('erreur_mode'));
          } else
            isEmpty = false;
        }
        /*else if (currentStep == 1) {
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
        } */
        else if (currentStep == 3) {
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

          print(currentStep);
          //Changer le focus texte
          if (currentStep == 0) {
            nameNode.requestFocus();
          } else if (currentStep == 1) {
            //if (_userMode == "")
            //_userMode = AppLocalizations.of(context).translate('familial');
          } else if (currentStep == 3) {
            serialNode.requestFocus();

            timerNode =
                Timer.periodic(Duration(milliseconds: 300), (timerNode) {
              if (serialNumber.text.length >= 8) {
                setState(() {
                  isGoodLength = true;
                });
              } else {
                setState(() {
                  isGoodLength = false;
                });
              }
            });
          } else if (currentStep == 4) {
            timerNode?.cancel();
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
              builder: (context) => Login(
                appLanguage: appLanguage,
                message: "fromRegister",
              ),
            ),
          );
        } else if (currentStep == 3) serialNode.requestFocus();

        _controller.animateTo((((currentStep) * 75)).toDouble(),
            duration: Duration(milliseconds: 500), curve: Curves.linear);
      },
      child: Text(AppLocalizations.of(context).translate('retour')),
    );

    steps = [
      //Pseudo
      Step(
        title: Text(AppLocalizations.of(context).translate('prenom')),
        isActive: currentStep > 0,
        state: currentStep > 0 ? StepState.complete : StepState.disabled,
        content: Row(
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: screenSize.width * 0.4,
                child: TextFormField(
                  style: textStyle,
                  focusNode: nameNode,
                  controller: name,
                  onFieldSubmitted: (term) {
                    next();
                  },
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).translate('prenom'),
                    errorText: isEmpty
                        ? AppLocalizations.of(context)
                            .translate('erreur_prenom')
                        : null,
                  ),
                ),
              ),
            ),
            Row(
              children: <Widget>[
                nextButton,
                backButton,
              ],
            ),
          ],
        ),
      ),
      //Mode
      Step(
        title: Text(
          AppLocalizations.of(context).translate('mode'),
        ),
        isActive: currentStep > 1,
        state: currentStep > 1 ? StepState.complete : StepState.disabled,
        content: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: screenSize.width / 3,
                  height: screenSize.height / 2.5,
                  child: Column(
                    children: <Widget>[
                      RadioListTile<String>(
                        title: Text(
                            AppLocalizations.of(context).translate('sportif')),
                        value: "1",
                        groupValue: _userMode,
                        onChanged: (String value) {
                          setState(() {
                            _userMode = value;
                          });
                        },
                      ),
                      AutoSizeText(
                        AppLocalizations.of(context).translate('mode_sportif'),
                        maxLines: 3,
                        minFontSize: 20,
                      )
                    ],
                  ),
                ),
                Spacer(),
                Container(
                  width: 5,
                  height: screenSize.height / 2.5,
                  color: Colors.black54,
                ),
                Spacer(),
                Container(
                  width: screenSize.width / 3,
                  height: screenSize.height / 2.5,
                  child: Column(
                    children: <Widget>[
                      RadioListTile<String>(
                        title: Text(
                            AppLocalizations.of(context).translate('familial')),
                        value: "0",
                        groupValue: _userMode,
                        onChanged: (String value) {
                          setState(() {
                            _userMode = value;
                          });
                        },
                      ),
                      AutoSizeText(
                        AppLocalizations.of(context)
                            .translate('mode_familiale'),
                        maxLines: 3,
                        minFontSize: 20,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      /*
      Step(
        title: Text(
          AppLocalizations.of(context).translate('mode'),
        ),
        isActive: currentStep > 1,
        state: currentStep > 1 ? StepState.complete : StepState.disabled,
        content: Column(
          children: <Widget>[
            Row(
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
                      _userMode =
                          AppLocalizations.of(context).translate('sportif');
                    else
                      _userMode =
                          AppLocalizations.of(context).translate('familial');
                  },
                  activeTrackColor: Colors.grey,
                  activeColor: Colors.grey[100],
                ),
                Text(
                  AppLocalizations.of(context).translate('sportif'),
                  style: textStyle,
                ),
              ],
            ),
            _userMode == AppLocalizations.of(context).translate('sportif')
                ? AutoSizeText(
                    AppLocalizations.of(context).translate('mode_sportif'),
                    maxLines: 2,
                    minFontSize: 20,
                  )
                : AutoSizeText(
                    AppLocalizations.of(context).translate('mode_familiale'),
                    maxLines: 2,
                    minFontSize: 20,
                  )
          ],
        ),
      ),*/
      //Image
      Step(
        title: Text(AppLocalizations.of(context).translate('select_image')),
        isActive: currentStep > 2,
        state: currentStep > 2 ? StepState.complete : StepState.disabled,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            //showImage(),
            //Image(image: AssetImage(_path)),
            Center(
                child: imageFile == null
                    ? Image.asset(
                        'assets/default.png',
                        width: screenSize.width * 0.2,
                      )
                    : Image.file(File(_pathSaved),
                        width: screenSize.width * 0.2)
                //Image.file(imageFile, width: screenHeight * 0.6, height: screenHeight*0.6,),
                ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.grey[350]),
          ),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.image),
                      Text(" " +
                          AppLocalizations.of(context)
                              .translate('select_image')),
                    ],
                  ),
                  onPressed: () {
                    pickImage(ImageSource.gallery);
                  },
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                ),
                ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.grey[350]),
          ),
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
                ),
              ],
            ),
          ],
        ),
      ),
      //Connexion appareil
      Step(
        title: Text(AppLocalizations.of(context).translate('connecter_app')),
        isActive: currentStep > 3,
        state: currentStep > 3 ? StepState.complete : StepState.disabled,
        content: Row(
          children: <Widget>[
            Container(
              width: screenSize.width * 0.3,
              child: TextFormField(
                enabled: isFound ? false : true,
                style: textStyle,
                focusNode: serialNode,
                controller: serialNumber,
                maxLength: 8,
                decoration: InputDecoration(
                  labelText: "1. " +
                      AppLocalizations.of(context).translate('num_serie'),
                ),
              ),
            ),
            Container(
              width: screenSize.width * 0.4,
              child: isGoodLength
                  ? ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.grey[350]),
          ),
                      child: Text(
                        "2. " + discovering,
                        style: textStyle,
                      ),
                      onPressed: !isFound && isGoodLength
                          ? () async {
                              //On met isFound à true pour désactiver l'appuie du bouton
                              setState(
                                () {
                                  isFound = true;
                                },
                              );
                              macAddress = await btManage.getDevice(
                                serialNumber.text
                                    .toUpperCase()
                                    .replaceAll(" ", ""),
                              );

                              int tempTimer = 0;
                              //Check tant que l'adresse mac est égale à -1 toute les secondes
                              //Si pas trouve au bout de 30 secondes, affiche message d'erreur
                              Timer.periodic(
                                const Duration(seconds: 1),
                                (timer) async {
                                  if (macAddress == "0") {
                                    macAddress = await btManage.getDevice(
                                      serialNumber.text
                                          .toUpperCase()
                                          .replaceAll(" ", ""),
                                    );
                                  }
                                  if (macAddress != "-1") {
                                    timer.cancel();
                                    //Appareil trouvé
                                    setState(
                                      () {
                                        discovering =
                                            AppLocalizations.of(context)
                                                .translate('app_trouve');
                                        isFound = true;
                                        connect();

                                        Timer.periodic(
                                          const Duration(seconds: 1),
                                          (timer) {
                                            if (isConnected) {
                                              timer.cancel();
                                              setState(
                                                () {
                                                  discovering = AppLocalizations
                                                          .of(context)
                                                      .translate(
                                                          'status_connexion_bon');
                                                },
                                              );
                                            } else {
                                              setState(
                                                () {
                                                  discovering = AppLocalizations
                                                          .of(context)
                                                      .translate(
                                                          'connexion_en_cours');
                                                },
                                              );
                                            }
                                          },
                                        );
                                      },
                                    );
                                  } else if (macAddress == "-1") {
                                    if (tempTimer >= 20) {
                                      setState(() {
                                        show(AppLocalizations.of(context)
                                            .translate('app_non_trouve'));
                                        discovering =
                                            AppLocalizations.of(context)
                                                .translate('connecter_app');
                                      });
                                      isFound = false;
                                      timer.cancel();
                                      tempTimer = 0;
                                    } else {
                                      macAddress =
                                          await btManage.getMacAddress();
                                      setState(
                                        () {
                                          discovering =
                                              AppLocalizations.of(context)
                                                  .translate('recherche_app');
                                          //isFound = false;
                                        },
                                      );
                                    }
                                  }
                                  tempTimer++;
                                },
                              );
                            }
                          : null,
                    )
                  : Container(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: !isConnected ? Colors.red : Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
      //Notifications
      Step(
        title: Text(AppLocalizations.of(context).translate('notifications')),
        isActive: currentStep > 4,
        state: currentStep > 4 ? StepState.complete : StepState.disabled,
        content: SizedBox(
          child: Column(
            children: <Widget>[
              new DropdownButton<String>(
                items: notifs.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Container(
                      width: 200.0,
                      child: Text(value),
                    ),
                  );
                }).toList(),
                hint: Text(selection),
                onChanged: (String value) {
                  selection = value;
                  for (int i = 0; i < notifs.length - 1; i++) {
                    if (selection == notifs[i]) {
                      days = i;
                      break;
                    } else
                      days = 0;
                  }
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
      //Recap
      Step(
        title: Text(AppLocalizations.of(context).translate('recap')),
        isActive: currentStep > 5,
        state: currentStep > 5 ? StepState.complete : StepState.disabled,
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
                  Container(
                    width: screenSize.width * 0.4,
                    child: Column(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            AppLocalizations.of(context).translate('prenom') +
                                ": " +
                                name.text,
                            style: textStyle,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppLocalizations.of(context).translate('mode') +
                                ": " +
                                (_userMode == "0"
                                    ? AppLocalizations.of(context)
                                        .translate('familial')
                                    : AppLocalizations.of(context)
                                        .translate('sportif')),
                            style: textStyle,
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            AppLocalizations.of(context)
                                    .translate('notifications') +
                                ": " +
                                selection,
                            style: textStyle,
                          ),
                        ),
                      ],
                    ),
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
                  padding:
                      EdgeInsets.only(left: 38, right: 38, top: 15, bottom: 15),
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
                          builder: (context) => MaxPush(
                            appLanguage: appLanguage,
                            user: user,
                            inputMessage: "fromRegister",
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
                  child: Text(AppLocalizations.of(context).translate('retour')),
                ),
              ],
            ),
          ],
        ),
      ),
    ];

    Future<bool> _onBackPressed() {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Login(
                    appLanguage: appLanguage,
                message: "fromRegister",
                  )));
    }

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: backgroundColor,
        key: _scaffoldKey,
        appBar: AppBar(
          elevation: 0.0,
          title: AutoSizeText(
            AppLocalizations.of(context).translate('inscription'),
            style: textStyleBG,
          ),
          backgroundColor: backgroundColor,
          key: _formKey,
          actions: <Widget>[
            Container(
              width: screenSize.width * 0.8,
              //color: Colors.red,
              child: Row(
                children: <Widget>[
                  Spacer(),
                  Text("$currentStep/${steps.length - 1}",
                      style: textStyleBG // TextStyle(fontSize: 20),
                      ),
                  Padding(
                    padding: EdgeInsets.all(20),
                  ),
                  StepProgressIndicator(
                    totalSteps: steps.length - 1,
                    currentStep: currentStep,
                    fallbackLength: screenSize.width / 2,
                    selectedColor: Colors.lightGreenAccent,
                    unselectedColor: iconColor,
                    roundedEdges: Radius.circular(10),
                    padding: 0.00001,
                    size: 15,
                  ),
                  Spacer(),
                  new FlatButton(
                    child: new Text(
                      "Fill",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () {
                      name.text = "Jean";
                      _userMode = "1";
                      macAddress = "78:DB:2F:BF:3B:03";
                      serialNumber.text = "1230997P";
                      //result = 6.31;
                      _pathSaved = "assets/default.png";
                    },
                  ),
                ],
              ),
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
                            currentStep >= 1 ? nextButton : Container(),
                            currentStep >= 1 ? backButton : Container(),
                            currentStep == 6 ? Container() : Container(),
                            currentStep == 6 ? Container() : Container(),
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

  //TODO clique sur next pendant la connexion = pète tout

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
