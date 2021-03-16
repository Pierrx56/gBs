import 'dart:async';

import 'dart:io';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/AppLocalizations.dart';
import 'package:gbsalternative/BluetoothManager.dart';
import 'package:gbsalternative/LoadPage.dart';
import 'package:gbsalternative/Login.dart';
import 'package:gbsalternative/MainTitle.dart';
import 'package:gbsalternative/NotificationManager.dart';
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
  final User user;
  final AppLanguage appLanguage;

  ManageProfile({@required this.user, @required this.appLanguage});

  @override
  _ManageProfile createState() => _ManageProfile(user, appLanguage);
}

class _ManageProfile extends State<ManageProfile> {
  DatabaseHelper db = new DatabaseHelper();
  User user;
  bool isDisconnecting = false;
  bool isConnected = false;
  AppLanguage appLanguage;


  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Color colorMesureButton = Colors.black;
  Timer timerConnexion;
  double _start = 10.0;
  static double _reset = 10.0;
  int i = 100;
  List<double> average = new List(10 * _reset.toInt());
  double delta = 102.0;
  double coefProgressBar = 2.0;
  double result;
  double tempResult;
  String recording;
  bool isDeleted;
  Size screenSize;

  String _pathSaved;
  File imageFile;
  Timer timer;

  String _userMode;
  bool isSwitched = false;
  bool hasChangedState;

  String selection;
  int days = 0;

  String initialPush;

  Color colorButton = Colors.black;

  var name = new TextEditingController();

  @override
  void initState() {
    btData = "0.0";
    name.text = '';
    hasChangedState = false;
    isDeleted = false;
    days = int.parse(user.userNotifEvent);

    if (days == null) days = 0;

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
    if (name.text == '' &&
        _pathSaved == user.userPic &&
        _userMode == user.userMode) {
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

  void _updateSwitch(bool value) => setState(() => isSwitched = value);

  void updateUser() {
    if (name.text == '') name.text = user.userName;
    if (_pathSaved == '') _pathSaved = user.userPic;
    if (_userMode == null) _userMode = user.userMode;
    if (initialPush == null) initialPush = user.userInitialPush;

    String macAddress = user.userMacAddress;
    String serialNumber = user.userSerialNumber;

    db.updateUser(user = User(
      userId: user.userId,
      userName: name.text,
      userMode: _userMode,
      userPic: _pathSaved,
      userHeightTop: user.userHeightTop,
      userHeightBottom: user.userHeightBottom,
      userInitialPush: initialPush,
      userMacAddress: macAddress,
      userSerialNumber: serialNumber,
      userNotifEvent: days.toString(),
      userLastLogin: user.userLastLogin,
    ));

    show(AppLocalizations.of(this.context).translate('modification_prise'));

    //Réinitialisation des champs pour virer le message enregister
    name.text = '';
    hasChangedState = false;
    _userMode = user.userMode;
    _pathSaved = user.userPic;

    //Redirection vers l'écran d'accueil
    /*Future.delayed(const Duration(milliseconds: 2000), () {
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
    });*/
  }

  //final _formKey = GlobalKey<FormState>();

  Widget manageCard(BuildContext context) {
    screenSize = MediaQuery.of(context).size;

    if (_pathSaved == null) _pathSaved = user.userPic;

    if (selection == null)
      selection = AppLocalizations.of(context).translate('notif_1_jour');

    List<String> notifs = [
      AppLocalizations.of(context).translate('notif_desactive'),
      AppLocalizations.of(context).translate('notif_1_jour'),
      AppLocalizations.of(context).translate('notif_2_jour'),
      AppLocalizations.of(context).translate('notif_3_jour'),
    ];

    selection = notifs[days];

    //key: _formKey,
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                //Notifications
                Column(
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
                    )
                  ],
                ),
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
                                  _userMode =
                                      "1"; //AppLocalizations.of(context).translate('sportif');
                                //_userMode = AppLocalizations.of(context).translate('sportif');
                                else
                                  _userMode = "0";
                                //_userMode = AppLocalizations.of(context).translate('familial');
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
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(50, 0, 0, 0),
                    ),
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
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.grey[350]),
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.image, color: Colors.black),
                              Text(" " +
                                  AppLocalizations.of(context)
                                      .translate('select_image'), style: TextStyle(color: Colors.black),),
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
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.grey[350]),
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.camera_alt, color: Colors.black),
                              Text(" " +
                                  AppLocalizations.of(context)
                                      .translate('prendre_photo'), style: TextStyle(color: Colors.black),),
                            ],
                          ),
                          onPressed: () {
                            pickImage(ImageSource.camera);
                          },
                        ),
                      ],
                    ),
/*                        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.grey[350]),
          ),
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
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.grey[350]),
                      ),
                      onPressed: () {
                        if (hasChangedState)
                          pousseeDialog();
                        else {
                          //Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MainTitle(
                                  userIn: user,
                                  appLanguage: appLanguage,
                                  messageIn: ""),
                            ),
                          );
                        }
                      },
                      child: Text(temp != null
                          ? AppLocalizations.of(this.context)
                              .translate('retour')
                          : "Retourlol", style: TextStyle(color: Colors.black),),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 15, bottom: 15),
                    ),
                    FlatButton(
                      child: Text(
                          AppLocalizations.of(context).translate('supprimer')),
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
                                    print(
                                        "ID à SUPPR:" + user.userId.toString());
                                    NotificationManager notificationManager =
                                        new NotificationManager();
                                    notificationManager.init(user);
                                    notificationManager.cancelNotification();
                                    db.deleteUser(user.userId);
                                    isDeleted = true;
                                    //dispose();
                                    if (isDeleted) {
                                      //Delay to avoid display bugs
                                      Timer(Duration(milliseconds: 300), () {
                                        Navigator.pushReplacement(
                                            this.context,
                                            MaterialPageRoute(
                                                builder: (context) => Login(
                                                      appLanguage: appLanguage,
                                                      message: "",
                                                    ))
                                            /*LoadPage(
                                      appLanguage: appLanguage,
                                      page: login,
                                      user: null,
                                      messageIn: "0",
                                    ))*/
                                            );
                                      });
                                    }
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
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.grey[350]),
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MainTitle(
                                    userIn: user,
                                    appLanguage: appLanguage,
                                    messageIn: "",
                                  ),
                                ),
                              );
                            },
                            child: Text(temp != null
                                ? AppLocalizations.of(this.context)
                                    .translate('annuler')
                                : "Check en/fr.json file"),
                          ),
                          Spacer(),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.grey[350]),
                            ),
                            //child: Text("Démarrer l'enregistrement."),
                            onPressed: () async {
                              Navigator.pop(context);
                              updateUser();
                            },
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

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;

    if (recording == null)
      recording =
          AppLocalizations.of(context).translate('demarrer_enregistrement');

    if (_userMode == null) {
      _userMode = user.userMode;
      if (user.userMode == "1") {
        isSwitched = true;
      } else
        isSwitched = false;
    }

    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainTitle(
              appLanguage: appLanguage,
              userIn: user,
              messageIn: "",
            ),
          ),
        );
        return;
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: backgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text(
            AppLocalizations.of(context).translate('modification'),
            style: textStyleBG,
          ),
          backgroundColor: backgroundColor,
          elevation: 0.0,
          /*leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: iconColor),
            onPressed: () => Navigator.pop(context),
            /*Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LoadPage(
                  appLanguage: appLanguage,
                  page: mainTitle,
                  user: user,
                  messageIn: "",
                ),
              ),
            ),*/
          ),*/
        ),
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Stack(
                children: <Widget>[
                  manageCard(this.context),
                ],
              ),
            ),
          ],
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
