import 'dart:io';
import 'dart:async';
import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/AppLocalizations.dart';
import 'package:gbsalternative/BluetoothManager.dart';
import 'package:gbsalternative/DrawCharts.dart';
import 'package:gbsalternative/FAQ.dart';
import 'package:gbsalternative/Login.dart';
import 'package:gbsalternative/ManageProfile.dart';
import 'package:gbsalternative/MaxPush.dart';
import 'package:gbsalternative/NotificationManager.dart';
import 'package:gbsalternative/SelectGame.dart';
import 'package:gbsalternative/SelectStatistic.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'DatabaseHelper.dart';

class MainTitle extends StatefulWidget {
  final AppLanguage appLanguage;
  final User userIn;
  final String messageIn;

  MainTitle({
    @required this.appLanguage,
    @required this.userIn,
    @required this.messageIn,
  });

  @override
  _MainTitle createState() => _MainTitle(appLanguage, userIn, messageIn);
}

class _MainTitle extends State<MainTitle> {
  Widget menuPage;
  Widget settingsPage;
  Widget loginPage;
  bool visible_swim;
  bool visible_plane;
  Color colorCard_swim;
  Color colorCard_plane;
  double widthCard, heightCard;

  AppLanguage appLanguage;
  User user;
  String message;
  double voltage;
  bool isConnected;
  bool isWakedUp;
  bool hasAlerted;
  bool isInformed;
  Timer timerConnexion;
  bool hasChanged;

  double heightBattery = 0.0;
  double widthBattery = 0.0;

  DatabaseHelper db = new DatabaseHelper();
  NotificationManager notificationManager = new NotificationManager();
  List<Scores> data_swim;
  List<Scores> data_plane;

  //0:menu 1:settings 2:bluetooth
  static int defaultIndex = 0;
  int _selectedIndex = defaultIndex;

  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const Color orangeColor = Colors.orange; //Colors.amber[800];

  BluetoothManager btManage;

  _MainTitle(AppLanguage _appLanguage, User userIn, String messageIn) {
    appLanguage = _appLanguage;
    user = userIn;
    message = messageIn;
    isConnected = false;

    settingsPage = ManageProfile(appLanguage: appLanguage, user: user);
    /*
    settingsPage = LoadPage(
      appLanguage: appLanguage,
      user: user,
      page: manageProfile,
      messageIn: "0",
    );*/
  }

  @override
  void initState() {
    visible_swim = true;
    visible_plane = true;
    hasChanged = false;
    hasAlerted = false;
    isWakedUp = false;
    isConnected = false;
    colorCard_swim = Colors.white;
    colorCard_plane = Colors.white;
    voltage = 0.0;
    btManage =
        new BluetoothManager(user: user, inputMessage: null, appLanguage: null);

    heightBattery = 0.0;
    widthBattery = 0.0;

    //Gestion des notifications
    //initialise une notification pour le/les jours suivants
    notificationManager.init(user);
    notificationManager.setNotificationAlert();

    //Connexion directement dès le login
    connect();

    super.initState();
  }

  @override
  void dispose() {
    timerConnexion?.cancel();
    isWakedUp = false;
    btManage.user = null;

    //btManage.disconnect("");

    super.dispose();
  }

  void connect() async {
    //Tant que le bluetooth n'est pas activé, on demande son activation
    if (await btManage.enableBluetooth()) {
      connect();
    } else {
      isConnected = await btManage.getStatus();
      if (!isConnected) {
        btManage.connect(user.userMacAddress, user.userSerialNumber);
      }
      getConnectState();
      //testConnect();
    }
  }

  void getConnectState() async {
    timerConnexion = new Timer.periodic(Duration(milliseconds: 1000),
        (timerConnexion) async {
      isConnected = await btManage.getStatus();
      if (isConnected) {
        if (!isWakedUp) {
          btManage.sendData("WU");
          isWakedUp = true;
        }

        //Delay voltage get to avoid alert battery
        if (voltage == 0.0) {
          voltage = await btManage.getVoltage();

          Timer(Duration(seconds: 2), () async {

            //if (voltage == 0.0) voltage = 0.5;

            //Alert battery under 15%
            if (voltage < 0.15 && !hasAlerted) {
              notificationManager.alertBattery();
              hasAlerted = true;
            }
          });
        } else {
          voltage = await btManage.getVoltage();

          //if (voltage == 0.0) voltage = 0.5;

          //Alert battery under 15%
          if (voltage < 0.15 && !hasAlerted) {
            notificationManager.alertBattery();
            hasAlerted = true;
          }
        }
      }
      //else
      //voltage = 0.5;

      if (mounted) setState(() {});
    });
  }

  Widget menu() {
    Size screenSize = MediaQuery.of(this.context).size;
    int numberOfCard = 3;
    //print("id: " + user.userId.toString());

    var temp = AppLocalizations.of(context);

    return WillPopScope(
      onWillPop: () {
        btManage.disconnect("");
        if (message == "fromRegister") {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => Login(
                  appLanguage: appLanguage,
                  message: "",
                ),
              ),
              (Route<dynamic> route) => route is Login);
        } else
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => Login(
                  appLanguage: appLanguage,
                  message: "",
                ),
              ),
              (Route<dynamic> route) => route is Login);

        return;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          iconTheme: IconThemeData(color: iconColor),
          backgroundColor: backgroundColor,
          elevation: 0.0,
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: screenSize.width * 0.40,
                ),
                Container(
                  width: screenSize.width * 0.20,
                  child: Image.asset(
                    "assets/spineo.png",
                  ),
                ),
                Container(
                  width: screenSize.width * 0.40,
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: Icon(
                      Icons.power_settings_new,
                      color: iconColor,
                    ),
                    label: temp != null
                        ? Text(
                            AppLocalizations.of(context)
                                .translate('deconnexion'),
                            style: TextStyle(
                              color: iconColor,
                            ),
                          )
                        : Text("Check Language file (en/fr.json)"),
                    onPressed: () {
                      btManage.disconnect("");

                      if (message == "fromRegister") {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Login(
                              appLanguage: appLanguage,
                              message: "",
                            ),
                          ),
                          (Route<dynamic> route) => route is Login,
                        );
                      } else
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Login(
                                appLanguage: appLanguage,
                                message: "",
                              ),
                            ),
                            (Route<dynamic> route) => route is Login);
                      /*Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Login(
                          appLanguage: appLanguage,
                        ),
                      ),
                    );*/

                      /*
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LoadPage(
                                user: null,
                                appLanguage: appLanguage,
                                messageIn: "deconnexion",
                                page: login,
                              )));*/
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        drawer: Container(
          width: screenSize.width * 0.25,
          child: Drawer(
            child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
                Container(
                  height: screenSize.height * 0.3,
                  child: DrawerHeader(
                    padding: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.file(
                                new File(user.userPic),
                                height: screenSize.height * 0.12,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                                0, screenSize.height * 0.12, 0, 0),
                            child: temp != null
                                ? AutoSizeText(
                                    /*AppLocalizations.of(context)
                                .translate('bonjour') +*/
                                    user.userName,
                                    style: textStyle,
                                    maxLines: 2,
                                  )
                                : AutoSizeText(
                                    "Check Language file (en/fr.json)"),
                          ),
                        ],
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                    ),
                  ),
                ),
                //Spacer -> each container -> 0.1 and divider = 16.0
                //Battery
                Container(
                  height: screenSize.height * 0.1,
                  padding: EdgeInsets.fromLTRB(
                      screenSize.width * 0.05, 0.0, 0.0, 0.0),
                  child: /*voltage != 0.0 &&*/ isConnected
                      ? Stack(
                          children: <Widget>[
                            //Battery plus
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                  screenSize.width * 0.1 -
                                      screenSize.height * 0.005,
                                  0,
                                  0,
                                  0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  height: screenSize.width * 0.01,
                                  width: screenSize.height * 0.01,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            3.0) //         <--- border radius here
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                height: heightBattery,
                                width: widthBattery * voltage,
                                //child: Text(voltage.toString()),
                                decoration: BoxDecoration(
                                  color: voltage > 0.50
                                      ? Colors.green
                                      : voltage > 0.25
                                          ? Colors.orange
                                          : Colors.red,
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          3.0) //         <--- border radius here
                                      ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                alignment: Alignment.center,
                                height: heightBattery =
                                    screenSize.height * 0.05,
                                width: widthBattery = screenSize.width * 0.1,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          3.0) //         <--- border radius here
                                      ),
                                ),
                                child: voltage != 0.0
                                    ? AutoSizeText(
                                        (voltage * 100).toStringAsFixed(0) +
                                            "%",
                                        textAlign: TextAlign.center,
                                        style: textStyle,
                                      )
                                    : Container(
                                        alignment: Alignment.center,
                                        height: screenSize.height * 0.025,
                                        width: screenSize.height * 0.025,
                                        child: CircularProgressIndicator()),
                              ),
                            ),
                          ],
                        )
                      : Container(),
                ),
                //BT
                Container(
                  alignment: Alignment.centerLeft,
                  height: screenSize.height * 0.1,
                  child: Row(
                    children: [
                      Padding(padding: EdgeInsets.fromLTRB(5, 0, 0, 0)),
                      Icon(
                        Icons.bluetooth,
                        color: isConnected ? Colors.green : Colors.red,
                        size: screenSize.height * 0.06,
                      ),
                      AutoSizeText(
                        isConnected
                            ? AppLocalizations.of(context)
                                .translate('status_connecte')
                            : AppLocalizations.of(context)
                                .translate('status_deconnecte'),
                        style: TextStyle(
                          color: isConnected ? Colors.green : Colors.red,
                        ),
                      ),
                      /*
                      TextButton.icon(
                        icon: Icon(
                          Icons.bluetooth,
                          color: isConnected ? Colors.green : Colors.red,
                          size: screenSize.height * 0.06,
                        ),
                        label: AutoSizeText(
                          isConnected
                              ? AppLocalizations.of(context)
                                  .translate('status_connecte')
                              : AppLocalizations.of(context)
                                  .translate('status_deconnecte'),
                          style: TextStyle(
                            color: isConnected ? Colors.green : Colors.red,
                          ),
                        ),
                        onPressed: () {},
                      ),*/
                    ],
                  ),
                ),
                Divider(),
                //FAQ
                Container(
                  alignment: Alignment.centerLeft,
                  height: screenSize.height * 0.1,
                  child: TextButton.icon(
                    icon: Icon(
                      Icons.question_answer,
                      color: iconColor,
                      size: screenSize.height * 0.06,
                    ),
                    label: AutoSizeText(
                      "FAQ",
                      style: TextStyle(
                        color: iconColor,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FAQ(
                              user: null,
                              inputMessage: "fromMainTitle",
                              appLanguage: appLanguage),
                          /*LoadPage(
                          user: null,
                          appLanguage: appLanguage,
                          messageIn: "fromLogin",
                          page: faq),*/
                        ),
                      );
                    },
                  ),
                ),
                Divider(),
                //Settings
                Container(
                  alignment: Alignment.centerLeft,
                  height: screenSize.height * 0.1,
                  child: TextButton.icon(
                    icon: Icon(
                      Icons.settings,
                      color: iconColor,
                      size: screenSize.height * 0.06,
                    ),
                    label: AutoSizeText(
                      AppLocalizations.of(context).translate('reglages'),
                      style: TextStyle(color: iconColor),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManageProfile(
                              user: user, appLanguage: appLanguage),
                        ),
                      );
                    },
                  ),
                ),
                Divider(),
                //Version
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AutoSizeText(
                      "Spineo Home - V.$softwareVersion",
                      style: TextStyle(fontSize: 13),
                    ),
                    AutoSizeText("© 2021 Genourob\n All rights reserved.",
                        style: TextStyle(fontSize: 13)),
                  ],
                ),
                //Log Out
                /*Container(
                  alignment: Alignment.centerLeft,
                  height: screenSize.height * 0.1,
                  child: TextButton.icon(
                    icon: Icon(
                      Icons.power_settings_new,
                      color: iconColor,
                      size: screenSize.height * 0.06,
                    ),
                    label: temp != null
                        ? Text(
                            AppLocalizations.of(context)
                                .translate('deconnexion'),
                            style: TextStyle(
                              color: iconColor,
                            ),
                          )
                        : Text("Check Language file (en/fr.json)"),
                    onPressed: () {
                      btManage.disconnect("");

                      if (message == "fromRegister") {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Login(
                              appLanguage: appLanguage,
                              message: "",
                            ),
                          ),
                          (Route<dynamic> route) => route is Login,
                        );
                      } else
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Login(
                                appLanguage: appLanguage,
                                message: "",
                              ),
                            ),
                            (Route<dynamic> route) => route is Login);
                    },
                  ),
                ),*/
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            color: backgroundColor,
            alignment: Alignment.topCenter,
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: widthCard = (screenSize.width / numberOfCard) - 7,
                  height: heightCard = screenSize.width / numberOfCard,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MaxPush(
                            appLanguage: appLanguage,
                            user: user,
                            inputMessage: "fromMain",
                          ),
                        ),
                        /*MaterialPageRoute(
                          builder: (context) => LoadPage(
                            appLanguage: appLanguage,
                            page: firstPush,
                            user: user,
                            messageIn: "fromMain",
                          ),
                        ),*/
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: message == "fromRegister"
                          ? Colors.grey[200]
                          //: Colors.white,
                          : backgroundColor,
                      elevation: 8,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            temp != null
                                ? AutoSizeText(
                                    AppLocalizations.of(context)
                                        .translate('poussee_max'),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: message == "fromRegister"
                                          ? Colors.grey
                                          : Colors.black,
                                    ),
                                  )
                                : Text("Check Language file (en/fr.json)"),
                            Transform.rotate(
                              angle: -math.pi,
                              child: Icon(
                                Icons.file_download,
                                size: heightCard * 0.7,
                                color: message == "fromRegister"
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                //Selection jeux
                SizedBox(
                  width: widthCard = (screenSize.width / numberOfCard) - 7,
                  height: heightCard = screenSize.width / numberOfCard,
                  child: GestureDetector(
                    onTap: () {
                      /*
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoadPage(
                                    user: user,
                                    appLanguage: appLanguage,
                                    messageIn: "0",
                                    page: selectGame,
                                  )));*/
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SelectGame(
                                    user: user,
                                    appLanguage: appLanguage,
                                    inputMessage: "0",
                                  )));
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 8,
                      color: backgroundColor,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            temp != null
                                ? Text(
                                    AppLocalizations.of(context)
                                        .translate('activites'),
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  )
                                : Text("Check Language file (en/fr.json)"),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 8,
                                  color: backgroundColor,
                                  child: Container(
                                    width: widthCard / 3,
                                    height: heightCard / 3,
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Image.asset(
                                        'assets/swim.png',
                                        width: widthCard / 4,
                                        height: heightCard / 4,
                                      ),
                                    ),
                                  ),
                                ),
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 8,
                                  color: backgroundColor,
                                  child: Container(
                                    width: widthCard / 3,
                                    height: heightCard / 3,
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Image.asset(
                                        'assets/plane.png',
                                        width: widthCard / 4,
                                        height: heightCard / 4,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 8,
                                  color: backgroundColor,
                                  child: Container(
                                    width: widthCard / 3,
                                    height: heightCard / 3,
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Image.asset(
                                        'assets/temp.png',
                                        width: widthCard / 4,
                                        height: heightCard / 4,
                                      ),
                                    ),
                                  ),
                                ),
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 8,
                                  color: backgroundColor,
                                  child: Container(
                                    width: widthCard / 3,
                                    height: heightCard / 3,
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Image.asset(
                                        'assets/car.png',
                                        width: widthCard / 4,
                                        height: heightCard / 4,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                //Select stat
                SizedBox(
                  width: widthCard = (screenSize.width / numberOfCard) - 7,
                  height: heightCard = screenSize.width / numberOfCard,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectStatistic(
                            user: user,
                            appLanguage: appLanguage,
                            inputMessage: "0",
                          ),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 8,
                      color: backgroundColor,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            temp != null
                                ? Text(
                                    AppLocalizations.of(context)
                                        .translate('statistiques'),
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  )
                                : Text("Check Language file (en/fr.json)"),
                            Image.asset(
                              'assets/chart.png',
                              width: widthCard * 0.7,
                              height: heightCard * 0.7,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return menu();
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
