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
import 'package:gbsalternative/LoadPage.dart';
import 'package:gbsalternative/ManageProfile.dart';
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
    settingsPage = LoadPage(
      appLanguage: appLanguage,
      user: user,
      page: manageProfile,
      messageIn: "0",
    );
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
      btManage.connect(user.userMacAddress, user.userSerialNumber);
      isConnected = await btManage.getStatus();
      if(isConnected) {
        return;
      }
      testConnect();
    }
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

    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.file(
                  new File(user.userPic),
                  height: screenSize.height * 0.12,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
              ),
              temp != null
                  ? Text(AppLocalizations.of(context).translate('bonjour') +
                      user.userName)
                  : Text("Check Language file (en/fr.json)"),
            ],
          ),
          backgroundColor: Colors.blue,
          actions: <Widget>[
            FlatButton.icon(
              icon: Icon(
                Icons.question_answer,
                color: Colors.white,
              ),
              label: Text(
                "FAQ",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              splashColor: Colors.blue,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoadPage(
                        user: user,
                        appLanguage: appLanguage,
                        messageIn: "fromMainTitle",
                        page: faq),
                  ),
                );
              },
            ),
            /*FlatButton.icon(
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
              label: temp != null
                  ? Text(
                      "Debug",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    )
                  : Text("Check Language file (en/fr.json)"),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              splashColor: Colors.blue,
              onPressed: () {
                //db.deleteScore(user.userId);

*/
            /*
                db.updateUser(
                  User(
                      userHeightBottom: user.userHeightBottom,
                      userHeightTop: user.userHeightTop,
                      userId: user.userId,
                      userInitialPush: "7.0",
                      userMode: user.userMode,
                      userName: user.userName,
                      userPic: user.userPic,
                      userMacAddress: user.userMacAddress,
                      userSerialNumber: user.userSerialNumber),
                );
*/
            /*
                db.updateUser(
                  User(
                      userHeightBottom: user.userHeightBottom,
                      userHeightTop: user.userHeightTop,
                      userId: user.userId,
                      userInitialPush: user.userInitialPush,
                      userMode: user.userMode,
                      userName: user.userName,
                      userPic: user.userPic,
                      userMacAddress: "78:DB:2F:BF:1F:72",
                      userSerialNumber: user.userSerialNumber),
                );*/
            /*                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoadPage(
                      user: user,
                      appLanguage: appLanguage,
                      messageIn: "0",
                      page: firstPush,
                    ),
                  ),
                );*/
            /*

                Score newScore = Score(
                    scoreId: null,
                    userId: user.userId,
                    activityId: 1,
                    scoreValue: 123,
                    scoreDate: "01-06-2020");
                Score newScore1 = Score(
                    scoreId: null,
                    userId: user.userId,
                    activityId: 1,
                    scoreValue: 156,
                    scoreDate: "02-06-2020");
                Score newScore2 = Score(
                    scoreId: null,
                    userId: user.userId,
                    activityId: 1,
                    scoreValue: 196,
                    scoreDate: "03-06-2020");
                Score newScore3 = Score(
                    scoreId: null,
                    userId: user.userId,
                    activityId: 1,
                    scoreValue: 135,
                    scoreDate: "04-06-2020");
                Score newScore4 = Score(
                    scoreId: null,
                    userId: user.userId,
                    activityId: 1,
                    scoreValue: 155,
                    scoreDate: "06-06-2020");
                Score newScore5 = Score(
                    scoreId: null,
                    userId: user.userId,
                    activityId: 1,
                    scoreValue: 195,
                    scoreDate: "09-06-2020");

                db.addScore(newScore);
                db.addScore(newScore1);
                db.addScore(newScore2);
                db.addScore(newScore3);
                db.addScore(newScore4);
                db.addScore(newScore5);
                //setState(() {});
              },
            ),*/
            FlatButton.icon(
              icon: Icon(
                Icons.power_settings_new,
                color: Colors.white,
              ),
              label: temp != null
                  ? Text(
                      AppLocalizations.of(context).translate('deconnexion'),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    )
                  : Text("Check Language file (en/fr.json)"),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              splashColor: Colors.blue,
              onPressed: () {
                btManage.disconnect("");
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LoadPage(
                              user: null,
                              appLanguage: appLanguage,
                              messageIn: "deconnexion",
                              page: login,
                            )));
              },
            ),
          ],
          leading: new Container(),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <Widget>[
              Container(
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
                              builder: (context) => LoadPage(
                                appLanguage: appLanguage,
                                page: firstPush,
                                user: user,
                                messageIn: "fromMain",
                              ),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          color: message == "fromRegister"
                              ? Colors.grey[200]
                              : Colors.white,
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
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoadPage(
                                        user: user,
                                        appLanguage: appLanguage,
                                        messageIn: "0",
                                        page: selectGame,
                                      )));
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 8,
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
                                    Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 8,
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
                                  builder: (context) => LoadPage(
                                        user: user,
                                        appLanguage: appLanguage,
                                        messageIn: "0",
                                        page: selectStatistic,
                                      )));
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 8,
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
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => LoadPage(
                  user: null,
                  appLanguage: appLanguage,
                  messageIn: "0",
                  page: login,
                )));
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

          settingsPage = LoadPage(
            appLanguage: appLanguage,
            user: user,
            page: manageProfile,
            messageIn: "0",
          );
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

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: _widgetOptions.length,
        child: WillPopScope(
          onWillPop: _onBackPressed,
          child: Scaffold(
            bottomNavigationBar: new BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.home,
                  ),
                  title:
                      Text(AppLocalizations.of(context).translate('accueil')),
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.settings,
                  ),
                  title:
                      Text(AppLocalizations.of(context).translate('reglages')),
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.blue,
              onTap: _onItemTapped,
            ),
            body: Center(
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
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
