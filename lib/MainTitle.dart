import 'dart:io';
import 'dart:async';
import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/AppLocalizations.dart';
import 'package:gbsalternative/BluetoothManager.dart';
import 'package:gbsalternative/DrawCharts.dart';
import 'package:gbsalternative/FAQ.dart';
import 'package:gbsalternative/LoadPage.dart';
import 'package:gbsalternative/Login.dart';
import 'package:gbsalternative/ManageProfile.dart';
import 'package:gbsalternative/MaxPush.dart';
import 'package:gbsalternative/NotificationManager.dart';
import 'package:gbsalternative/SelectGame.dart';
import 'package:gbsalternative/SelectStatistic.dart';
import 'package:rxdart/subjects.dart';
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
  bool isConnected;
  bool isInformed;
  Timer timerConnexion;
  bool hasChanged;

  DatabaseHelper db = new DatabaseHelper();
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

  BluetoothManager btManage =
      new BluetoothManager(user: null, inputMessage: null, appLanguage: null);

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
    colorCard_swim = Colors.white;
    colorCard_plane = Colors.white;

    //Obtention des scores
    //Swimmer
    getScores(user.userId, ID_SWIMMER_ACTIVITY);
    //Plane
    getScores(user.userId, ID_PLANE_ACTIVITY);
    //Temp
    getScores(user.userId, ID_TEMP_ACTIVITY);

    //Gestion des notifications
    //initialise une notification pour le/les jours suivants
    NotificationManager notificationManager = new NotificationManager();
    notificationManager.init(user);
    notificationManager.setNotificationAlert();

    //Connexion directement dès le login
    connect();

    super.initState();
  }

  @override
  void dispose() {
    timerConnexion?.cancel();
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
      if (mounted) setState(() {});
    });
  }

  testConnect() async {
    isConnected = await btManage.getStatus();
    if (!isConnected) {
      timerConnexion = new Timer.periodic(
        Duration(milliseconds: 3000),
        (timerConnexion) async {
          btManage.connect(user.userMacAddress, user.userSerialNumber);

          isConnected = await btManage.getStatus();
          if (isConnected) {
            print("Status: $isConnected");
            timerConnexion.cancel();
          }
        },
      );
    }
  }

  void updateUser(User _user) {
    user = _user;
  }

  void getScores(int userId, int activityId) async {
    //Nageur
    if (activityId == ID_SWIMMER_ACTIVITY) {
      data_swim = await db.getScore(userId, activityId);
      if (data_swim == null) {
        getScores(userId, activityId);
      } else {
        if (mounted) setState(() {});
      }
    }
    //Plane
    else if (activityId == ID_PLANE_ACTIVITY) {
      data_plane = await db.getScore(userId, activityId);
      if (data_plane == null) {
        getScores(userId, activityId);
      } else {
        if (mounted) setState(() {});
      }
    }
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
            Image.asset(
              "assets/spineo.png",
              width: screenSize.width * 0.20,
            ),
            Container(
              width: screenSize.width * 0.40,
              alignment: Alignment.centerRight,
              child: FlatButton.icon(
                icon: Icon(
                  Icons.power_settings_new,
                  color: iconColor,
                ),
                label: temp != null
                    ? Text(
                        AppLocalizations.of(context).translate('deconnexion'),
                        style: TextStyle(
                          color: iconColor,
                        ),
                      )
                    : Text("Check Language file (en/fr.json)"),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                splashColor: Colors.blue,
                onPressed: () {
                  btManage.disconnect("");

                  if (message == "fromRegister") {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Login(
                          appLanguage: appLanguage,
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
        drawer: Container(
          width: screenSize.width * 0.2,
          child: Drawer(
            child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
                Container(
                  height: screenSize.width * 0.2,
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
                Container(
                  height: screenSize.height * 0.1,
                  alignment: Alignment.center,
                  //child: Text(user.userHeightBottom),
                ),
                //BT
                Container(
                  alignment: Alignment.centerLeft,
                  height: screenSize.height * 0.1,
                  child: FlatButton.icon(
                    icon: Icon(
                      Icons.bluetooth,
                      color: isConnected ? Colors.green : Colors.red,
                    ),
                    label: AutoSizeText(
                      "Status",
                      style: TextStyle(
                        color: isConnected ? Colors.green : Colors.red,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    splashColor: splashIconColor,
                    onPressed: () {},
                  ),
                ),
                Divider(),
                //FAQ
                Container(
                  alignment: Alignment.centerLeft,
                  height: screenSize.height * 0.1,
                  child: FlatButton.icon(
                    icon: Icon(
                      Icons.question_answer,
                      color: iconColor,
                    ),
                    label: AutoSizeText(
                      "FAQ",
                      style: TextStyle(
                        color: iconColor,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    splashColor: splashIconColor,
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
                  child: FlatButton.icon(
                    icon: Icon(
                      Icons.settings,
                      color: iconColor,
                    ),
                    label: AutoSizeText(
                      AppLocalizations.of(context).translate('reglages'),
                      style: TextStyle(color: iconColor),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    splashColor: splashIconColor,
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
                //Log Out
                Container(
                  alignment: Alignment.centerLeft,
                  height: screenSize.height * 0.1,
                  child: FlatButton.icon(
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    splashColor: Colors.blue,
                    onPressed: () {
                      btManage.disconnect("");

                      if (message == "fromRegister") {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Login(
                              appLanguage: appLanguage,
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
                              ),
                            ),
                            (Route<dynamic> route) => route is Login);
                    },
                  ),
                ),
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
    //Size screenSize = MediaQuery.of(context).size;

    Future<void> _onItemTapped(int index) async {
      user = await db.getUser(user.userId);
      if (mounted)
        setState(() {
          _selectedIndex = index;

          menuPage = menu();

          settingsPage = ManageProfile(appLanguage: appLanguage, user: user);
/*          settingsPage = LoadPage(
            appLanguage: appLanguage,
            user: user,
            page: manageProfile,
            messageIn: "0",
          );*/
          /*if (user.userInitialPush == "0.0")
          firstPush = LoadPage(
            appLanguage: appLanguage,
            user: user,
            page: "firstPush",
            messageIn: "0",
          );
        else*/
          /*
        bluetoothPage = BluetoothManager(
            user: user,
            inputMessage: "0",
            appLanguage: appLanguage); */
        });
    }

    int temp = int.tryParse(message);

    if (temp != null) {
      if (temp != defaultIndex) {
        _selectedIndex = temp;
        //message = defaultIndex.toString();
      }
    }

    List<Widget> _widgetOptions = <Widget>[
      menuPage = menu(),
      settingsPage,
    ];

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
