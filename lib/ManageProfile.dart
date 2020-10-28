import 'dart:async';

import 'dart:io';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rounded_progress_bar/flutter_rounded_progress_bar.dart';
import 'package:flutter_rounded_progress_bar/rounded_progress_bar_style.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/AppLocalizations.dart';
import 'package:gbsalternative/BluetoothManager.dart';
import 'package:gbsalternative/LoadPage.dart';
import 'package:gbsalternative/Login.dart';
import 'package:gbsalternative/MainTitle.dart';
import 'package:gbsalternative/Register.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'DatabaseHelper.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

String btData;
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
  bool isConnected = false;
  AppLanguage appLanguage;

  BluetoothManager btManage =
      new BluetoothManager(user: null, inputMessage: null, appLanguage: null);

  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Color colorMesureButton = Colors.black;
  Timer timerConnexion;
  double _start = 10.0;
  static double _reset = 10.0;
  int i = 100;
  List<double> average = new List(10 * _reset.toInt());
  RoundedProgressBarStyle colorProgressBar = RoundedProgressBarStyle(
      colorProgress: Colors.blueAccent, colorProgressDark: Colors.blue);
  double delta = 102.0;
  double coefProgressBar = 2.0;
  double result;
  double tempResult;
  String recording;

  Size screenSize;

  String _pathSaved;
  File imageFile;
  Timer timer;

  String _userMode;
  bool isSwitched = false;
  bool hasChangedState;

  var hauteur_min = new TextEditingController();
  var hauteur_max = new TextEditingController();
  String initialPush;

  Color colorButton = Colors.black;

  var name = new TextEditingController();

  @override
  void initState() {
    btData = "0.0";
    name.text = '';
    hauteur_min.text = '';
    hauteur_max.text = '';
    hasChangedState = false;

    timer = Timer.periodic(
        Duration(milliseconds: 500), (Timer t) => hasChangedThread());

    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  //Constructeur
  _ManageProfile(User curUser, AppLanguage _appLanguage) {
    user = curUser;
    appLanguage = _appLanguage;
  }

  Future<bool> hasChangedThread() async {
    if (name.text != '') {
      if (mounted)
        setState(() {
          hasChangedState = true;
        });
    }
    if (_pathSaved != user.userPic) {
      if (mounted)
        setState(() {
          hasChangedState = true;
        });
    }
    if (_userMode != user.userMode) {
      if (mounted)
        setState(() {
          hasChangedState = true;
        });
    }
    if (hauteur_max.text != '') {
      if (mounted)
        setState(() {
          hasChangedState = true;
        });
    }
    if (hauteur_min.text != '') {
      if (mounted)
        setState(() {
          hasChangedState = true;
        });
    }
    if (name.text == '' &&
        _pathSaved == user.userPic &&
        _userMode == user.userMode &&
        hauteur_min.text == '' &&
        hauteur_max.text == '') {
      if (mounted)
        setState(() {
          hasChangedState = false;
        });
    }

    return hasChangedState;
  }

  pickImage(ImageSource source) async {
    final directory = await getApplicationDocumentsDirectory();
    final String path = directory.path;

    String tmpName = user.userName;

    //We first delete the existing file
    final tmpFile = File(user.userPic);
    if (tmpFile.existsSync()) tmpFile.delete(recursive: true);

    imageFile = await ImagePicker.pickImage(source: source);

    String nameImage = tmpName + "_" + basename(imageFile.path);

    final File newImage = await imageFile.copy('$path/$nameImage');

    setState(() {
      _pathSaved = newImage.path;
      imageFile = newImage;
    });

    //var fileName = basename(imageFile.path);
    //final File localImage = await imageFile.copy('$path/$fileName');
    return _pathSaved = newImage.path;
  }

  void setData() async {
    btData = await btManage.getData();
  }

  double getData() {
    setData();

    if (btData != null)
      return double.parse(btData);
    else
      return 2.0;
  }

  void _updateSwitch(bool value) => setState(() => isSwitched = value);

  void updateUser() {
    if (name.text == '') name.text = user.userName;
    if (_pathSaved == '') _pathSaved = user.userPic;
    if (_userMode == null) _userMode = user.userMode;
    if (hauteur_max.text == '') hauteur_max.text = user.userHeightTop;
    if (hauteur_min.text == '') hauteur_min.text = user.userHeightBottom;
    if (initialPush == null) initialPush = user.userInitialPush;

    String macAddress = user.userMacAddress;
    String serialNumber = user.userSerialNumber;

    db.updateUser(user = User(
      userId: user.userId,
      userName: name.text,
      userMode: _userMode,
      userPic: _pathSaved,
      userHeightTop: hauteur_max.text,
      userHeightBottom: hauteur_min.text,
      userInitialPush: initialPush,
      userMacAddress: macAddress,
      userSerialNumber: serialNumber,
    ));

    show(AppLocalizations.of(this.context).translate('modification_prise'));

    //Réinitialisation des champs pour virer le message enregister
    name.text = '';
    hauteur_min.text = '';
    hauteur_max.text = '';
    hasChangedState = false;
    _userMode = user.userMode;
    _pathSaved = user.userPic;

    //Redirection vers l'écran d'accueil
    Future.delayed(const Duration(milliseconds: 2000), () {
      Navigator.pushReplacement(
        this.context,
        MaterialPageRoute(
          builder: (context) => LoadPage(
              user: user,
              appLanguage: appLanguage,
              messageIn: "",
              page: mainTitle),
        ),
      );
    });
  }

  final _formKey = GlobalKey<FormState>();

  Widget manageCard(BuildContext context) {
    screenSize = MediaQuery.of(context).size;

    if (_pathSaved == null) _pathSaved = user.userPic;

    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(
                                AppLocalizations.of(context)
                                    .translate('familial'),
                                style: textStyle,
                              ),
                              Switch(
                                value: isSwitched,
                                onChanged: (value) {
                                  _updateSwitch(value);
                                  isSwitched = value;
                                  if (isSwitched)
                                    _userMode = AppLocalizations.of(context)
                                        .translate('sportif');
                                  else
                                    _userMode = AppLocalizations.of(context)
                                        .translate('familial');
                                },
                                activeTrackColor: Colors.lightGreenAccent,
                                activeColor: Colors.green,
                              ),
                              Text(
                                AppLocalizations.of(context)
                                    .translate('sportif'),
                                style: textStyle,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(50, 0, 0, 0),
                      ),
                      /*hasChangedState
                          ? Icon(
                              Icons.warning,
                              color: Colors.red,
                              size: screenSize.height / 4,
                            )
                          : Container(),
                      hasChangedState
                          ? Flexible(
                              child: Container(
                                height: screenSize.height / 4,
                                width: screenSize.width / 2,
                                child: Stack(
                                  children: <Widget>[
                                    AutoSizeText(
                                      AppLocalizations.of(context)
                                          .translate('enregistrer_avert'),
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 5,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(),*/
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: name,
                    decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(context).translate('prenom') +
                                ": " +
                                user.userName,
                        hasFloatingPlaceholder: true),
                  ),
/*                    SizedBox(
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
                  ),
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
                      }),*/
                  SizedBox(
                    height: 20,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      //showImage(),
                      //Image(image: AssetImage(_path)),
                      Center(
                          child: Image.file(File(_pathSaved),
                              height: screenSize.height * 0.3,
                              width: screenSize.height * 0.3)),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          RaisedButton(
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
/*                        RaisedButton(
                        child: Text(AppLocalizations.of(context)
                            .translate('ajust_poussee')),
                        onPressed: () {
                          if (isConnected) {
                            setState(() {
                              pousseeDialog();
                            });
                          } else {
                            show(
                                "Connexion au gBs en cours, réessayez dans quelques instants");
                          }
                        },
                        textColor: colorButton,
                      ),*/
                      SizedBox(
                        height: 20,
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
                          updateUser();
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 15, bottom: 15),
                      ),
                      RaisedButton(
                        onPressed: () {
                          if (hasChangedState)
                            pousseeDialog();
                          else
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoadPage(
                                    user: user,
                                    appLanguage: appLanguage,
                                    messageIn: "",
                                    page: mainTitle),
                              ),
                            );
                        },
                        child: Text(temp != null
                            ? AppLocalizations.of(this.context)
                                .translate('retour')
                            : "Retourlol"),
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
                                title: new Text(
                                    AppLocalizations.of(this.context)
                                        .translate('confirm_suppr')),
                                content: new Text(
                                    AppLocalizations.of(this.context)
                                        .translate('info_suppr')),
                                actions: <Widget>[
                                  // usually buttons at the bottom of the dialog
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
                                  new FlatButton(
                                    child: new Text(
                                        AppLocalizations.of(this.context)
                                            .translate('supprimer')),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      print("ID à SUPPR:" +
                                          user.userId.toString());
                                      db.deleteUser(user.userId);
                                      //dispose();
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => LoadPage(
                                                    appLanguage: appLanguage,
                                                    page: login,
                                                    user: null,
                                                    messageIn: "0",
                                                  )));
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
                  ? AppLocalizations.of(this.context).translate('avertissement')
                  : "Check en/fr.json file"),
              content: SingleChildScrollView(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Text(temp != null
                          ? AppLocalizations.of(this.context)
                              .translate('enregistrer_avert')
                          : "Check en/fr.json file"),
                      Row(
                        children: <Widget>[
                          RaisedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoadPage(
                                      user: user,
                                      appLanguage: appLanguage,
                                      messageIn: "",
                                      page: mainTitle),
                                ),
                              );
                            },
                            child: Text(temp != null
                                ? AppLocalizations.of(this.context)
                                    .translate('annuler')
                                : "Check en/fr.json file"),
                          ),
                          Spacer(),
                          RaisedButton(
                            //child: Text("Démarrer l'enregistrement."),
                            onPressed: () async {
                              Navigator.pop(context);
                              updateUser();
                            },
                            textColor: colorMesureButton,
                            child: Text(temp != null
                                ? AppLocalizations.of(this.context)
                                    .translate('enregistrer')
                                : "Check en/fr.json file"),
                          ),
                        ],
                      ),
                    ],
                  ),
                  width: 300.0,
                ),
              ),
            );
          });
        });
  }

  void pousseeDialog2() async {
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
                  : "Check en/fr.json file"),
              content: Row(
                children: <Widget>[
                  SingleChildScrollView(
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          Text(temp != null
                              ? AppLocalizations.of(this.context)
                                  .translate('explications_mesure')
                              : "Check en/fr.json file"),
                          RoundedProgressBar(
                            percent: (double.parse(btData)) >= 0
                                ? (double.parse(btData))
                                : 0.0,
                            style: double.parse(btData) > 100.0
                                ? colorProgressBar = RoundedProgressBarStyle(
                                    colorProgress: Colors.redAccent,
                                    colorProgressDark: Colors.red)
                                : colorProgressBar = RoundedProgressBarStyle(
                                    colorProgress: Colors.blueAccent,
                                    colorProgressDark: Colors.blue),
                            childCenter: Text(
                              (double.parse(btData)).toString(),
                            ),
                          ),
                          RaisedButton(
                              //child: Text("Démarrer l'enregistrement."),
                              onPressed: recording !=
                                      AppLocalizations.of(this.context)
                                          .translate('status_mesure_bon')
                                  ? () async {
                                      colorMesureButton = Colors.black;
                                      const oneSec =
                                          const Duration(milliseconds: 100);
                                      new Timer.periodic(
                                        oneSec,
                                        (Timer timer) => setState(
                                          () {
                                            if (_start < 0.1) {
                                              timer.cancel();
                                              _start = _reset;
                                              result = double.parse(
                                                  (average.reduce(
                                                              (a, b) => a + b) /
                                                          average.length)
                                                      .toStringAsFixed(2));

                                              i = 100;
                                              if (result <= 50.0 ||
                                                  result >= 100.0) {
                                                //Mesure pas bonne, réajuster la toise
                                                setState(() {
                                                  recording = temp != null
                                                      ? AppLocalizations.of(
                                                              this.context)
                                                          .translate(
                                                              'status_mesure_mauvais')
                                                      : "Check en/fr.json file";
                                                  colorMesureButton =
                                                      Colors.red;
                                                });
                                              } else
                                                setState(
                                                  () {
                                                    colorMesureButton =
                                                        Colors.green;
                                                    initialPush =
                                                        result.toString();
                                                    recording = temp != null
                                                        ? AppLocalizations.of(
                                                                this.context)
                                                            .translate(
                                                                'status_mesure_bon')
                                                        : "Check en/fr.json file";
                                                  },
                                                );
                                            } else {
                                              recording =
                                                  _start.toStringAsFixed(1);
                                              getData();
                                              _start = _start - 0.1;
                                              i--;
                                              average[i] = double.parse(btData);
                                            }
                                          },
                                        ),
                                      );
                                      //_showDialog();
                                    }
                                  : null,
                              textColor: colorMesureButton,
                              child: Text(recording)),
                          RaisedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(temp != null
                                ? AppLocalizations.of(this.context)
                                    .translate('retour')
                                : "Check en/fr.json file"),
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
    screenSize = MediaQuery.of(context).size;

    if (recording == null)
      recording =
          AppLocalizations.of(context).translate('demarrer_enregistrement');

    if (_userMode == null) {
      _userMode = user.userMode;
      if (user.userMode ==
          AppLocalizations.of(this.context).translate('sportif')) {
        isSwitched = true;
      } else
        isSwitched = false;
    }

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('modification')),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Stack(
              children: <Widget>[
                manageCard(context),
              ],
            ),
          ),
          /*Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                height: hasChangedState ? screenSize.height * 0.1 : 0.0,
                width: screenSize.width,
                duration: Duration(seconds: 1),
                curve: Curves.fastOutSlowIn,
                color: Colors.blue,
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: screenSize.height * 0.09,
                          child: RaisedButton(
                            child: Text(AppLocalizations.of(context)
                                .translate('enregistrer')),
                            onPressed: () {
                              updateUser();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),*/
        ],
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
