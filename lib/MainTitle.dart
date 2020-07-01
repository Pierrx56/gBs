import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/AppLocalizations.dart';
import 'package:gbsalternative/BluetoothManager.dart';
import 'package:gbsalternative/DrawCharts.dart';
import 'package:gbsalternative/FirstPush.dart';
import 'package:gbsalternative/LoadPage.dart';
import 'DatabaseHelper.dart';

class MainTitle extends StatefulWidget {
  final AppLanguage appLanguage;
  final User userIn;
  final int messageIn;

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
  Widget firstPush;
  Widget loginPage;
  bool visible_swim;
  bool visible_plane;
  Color colorCard_swim;
  Color colorCard_plane;

  AppLanguage appLanguage;
  User user;
  int message;

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

  _MainTitle(AppLanguage _appLanguage, User userIn, int messageIn) {
    appLanguage = _appLanguage;
    user = userIn;
    message = messageIn;
    settingsPage = LoadPage(
      appLanguage: appLanguage,
      user: user,
      page: "manageProfile",
      messageIn: "",
    );
    if (user.userInitialPush == "0.0") {
      firstPush = LoadPage(
        appLanguage: appLanguage,
        user: user,
        page: "firstPush",
        messageIn: "0",
      );
    } else
      firstPush = null;
  }

  @override
  void initState() {
    // TODO: implement initState
    //db.deleteScore(user.userId);
    visible_swim = true;
    visible_plane = true;
    colorCard_swim = Colors.white;
    colorCard_plane = Colors.white;
    getScores(user.userId, 0);
    getScores(user.userId, 1);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getScores(int userId, int activityId) async {
    //Nageur
    if (activityId == 0) {
      data_swim = await db.getScore(userId, activityId);
      if (data_swim == null) {
        getScores(userId, activityId);
      } else {
        setState(() {});
      }
    }
    //Plane
    else if (activityId == 1) {
      data_plane = await db.getScore(userId, activityId);
      if (data_plane == null) {
        getScores(userId, activityId);
      } else {
        setState(() {});
      }
    }
  }

  Widget menu() {
    Size screenSize = MediaQuery.of(context).size;
    int numberOfCard = 3;

    double widthCard, heightCard;

    //print("id: " + user.userId.toString());

    var temp = AppLocalizations.of(context);

    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              Image.file(
                new File(user.userPic),
                height: screenSize.height * 0.12,
              ),
              Padding(
                padding: EdgeInsets.all(10),
              ),
              temp != null
                  ? Text(AppLocalizations.of(context).translate('bonjour') +
                      user.userName)
                  : Text("a"),
            ],
          ),
          backgroundColor: Colors.blue,
          actions: <Widget>[
            FlatButton.icon(
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
              label: temp != null
                  ? Text(
                      "Add score",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    )
                  : Text("a"),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              splashColor: Colors.blue,
              onPressed: () {
                db.deleteScore(user.userId);

                Score newScore = Score(
                    scoreId: null,
                    userId: user.userId,
                    activityId: 0,
                    scoreValue: 123,
                    scoreDate: "01-06-2020");
                Score newScore1 = Score(
                    scoreId: null,
                    userId: user.userId,
                    activityId: 0,
                    scoreValue: 156,
                    scoreDate: "02-06-2020");
                Score newScore2 = Score(
                    scoreId: null,
                    userId: user.userId,
                    activityId: 0,
                    scoreValue: 196,
                    scoreDate: "03-06-2020");
                Score newScore3 = Score(
                    scoreId: null,
                    userId: user.userId,
                    activityId: 0,
                    scoreValue: 135,
                    scoreDate: "04-06-2020");

                db.addScore(newScore);
                db.addScore(newScore1);
                db.addScore(newScore2);
                db.addScore(newScore3);
              },
            ),
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
                  : Text("a"),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              splashColor: Colors.blue,
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LoadPage(
                              user: null,
                              appLanguage: appLanguage,
                              messageIn: "deconnexion",
                              page: "login",
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
                      width: screenSize.width / numberOfCard,
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
                                          .translate('stat_nageur'),
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    )
                                  : Text("a"),
                              data_swim == null
                                  ? Container()
                                  : DrawCharts(data: data_swim),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: RaisedButton(
                                  child: temp != null
                                      ? Text(
                                          AppLocalizations.of(context)
                                              .translate('details'),
                                        )
                                      : Text("a"),
                                  onPressed: () {
                                    setState(
                                      () {
                                        show("A venir");
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: widthCard = screenSize.width / numberOfCard,
                      child: new GestureDetector(
                        onTap: () {
                          if (visible_swim) {
                            dispose();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        /*Swimmer(
                                        user: user,
                                        appLanguage: appLanguage,
                                      ))*/
                                        LoadPage(
                                          appLanguage: appLanguage,
                                          page: "swimmer",
                                          user: user,
                                          messageIn: "0",
                                        )));
                          }
                        },
                        child: new Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 8,
                          color: colorCard_swim,
                          child: SingleChildScrollView(
                            child: Container(
                              padding:
                                  const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: Stack(
                                children: <Widget>[
                                  AnimatedOpacity(
                                    duration: Duration(milliseconds: 1000),
                                    opacity: !visible_swim ? 1.0 : 0.0,
                                    child: !visible_swim
                                        ? Column(
                                            children: <Widget>[
                                              Align(
                                                alignment: Alignment.topCenter,
                                                child: temp != null
                                                    ? Text(
                                                        AppLocalizations.of(
                                                                    context)
                                                                .translate(
                                                                    'type_activite') +
                                                            " " +
                                                            AppLocalizations.of(
                                                                    context)
                                                                .translate(
                                                                    'type_activite_CMV') +
                                                            "\n\n" +
                                                            AppLocalizations.of(
                                                                    context)
                                                                .translate(
                                                                    'info_nageur'),
                                                      )
                                                    : Text("a"),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: RaisedButton(
                                                  child: temp != null
                                                      ? Text(
                                                          AppLocalizations.of(
                                                                  context)
                                                              .translate(
                                                                  'retour'),
                                                        )
                                                      : Text("a"),
                                                  onPressed: () {
                                                    setState(() {
                                                      visible_swim =
                                                          !visible_swim;
                                                      !visible_swim
                                                          ? colorCard_swim =
                                                              Colors.white70
                                                          : colorCard_swim =
                                                              Colors.white;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          )
                                        : Container(),
                                  ),
                                  AnimatedOpacity(
                                      duration: Duration(milliseconds: 1000),
                                      opacity: visible_swim ? 1.0 : 0.0,
                                      child: visible_swim
                                          ? Column(
                                              children: <Widget>[
                                                Container(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child: Image.asset(
                                                    'assets/swim.png',
                                                    width: widthCard * 0.6,
                                                    height: widthCard * 0.6,
                                                  ),
                                                ),
                                                Container(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: FlatButton.icon(
                                                    label: temp != null
                                                        ? Text(
                                                            AppLocalizations.of(
                                                                    context)
                                                                .translate(
                                                                    'nageur'),
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 24,
                                                            ),
                                                          )
                                                        : Text("a"),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                    ),
                                                    icon: Icon(
                                                      Icons.info_outline,
                                                      color: Colors.black,
                                                    ),
                                                    splashColor: Colors.blue,
                                                    onPressed: () {
                                                      setState(() {
                                                        visible_swim =
                                                            !visible_swim;
                                                        !visible_swim
                                                            ? colorCard_swim =
                                                                Colors.white70
                                                            : colorCard_swim =
                                                                Colors.white;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Container()),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: screenSize.width / numberOfCard,
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
                                          .translate('stat_avion'),
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    )
                                  : Text("a"),
                              data_plane == null
                                  ? Container()
                                  : DrawCharts(data: data_plane),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: RaisedButton(
                                  child: temp != null
                                      ? Text(
                                          AppLocalizations.of(context)
                                              .translate('details'),
                                        )
                                      : Text("a"),
                                  onPressed: () {
                                    setState(
                                      () {
                                        show("A venir");
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: widthCard = screenSize.width / numberOfCard,
                      child: new GestureDetector(
                        onTap: () {
                          if (visible_plane) {
                            //TODO Check si l'@mac n'est pas nulle, auquel cas rediriger vers la connection BT
                            dispose();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoadPage(
                                  appLanguage: appLanguage,
                                  page: "plane",
                                  user: user,
                                  messageIn: "0",
                                ),
                              ),
                            );
                          }
                        },
                        child: new Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 8,
                          color: colorCard_plane,
                          child: SingleChildScrollView(
                            child: Container(
                              padding:
                                  const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: Stack(
                                children: <Widget>[
                                  AnimatedOpacity(
                                    duration: Duration(milliseconds: 1000),
                                    opacity: !visible_plane ? 1.0 : 0.0,
                                    child: !visible_plane
                                        ? Column(
                                            children: <Widget>[
                                              Align(
                                                alignment: Alignment.topCenter,
                                                child: temp != null
                                                    ? Text(
                                                        AppLocalizations.of(
                                                                    context)
                                                                .translate(
                                                                    'type_activite') +
                                                            " " +
                                                            AppLocalizations.of(
                                                                    context)
                                                                .translate(
                                                                    'type_activite_CSI') +
                                                            "\n\n" +
                                                            AppLocalizations.of(
                                                                    context)
                                                                .translate(
                                                                    'info_avion'),
                                                      )
                                                    : Text("a"),

                                                //TODO Requête vers la bdd pour savoir le type d'activité et comment ça marche
                                                //Text("Le jeu du Nageur est un jeu qui consiste à effectuer des poussées régulières pour maintenir le nageur le plus proche de la ligne centrale. 600m parcourus = 5 minutes"),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: RaisedButton(
                                                  child: temp != null
                                                      ? Text(
                                                          AppLocalizations.of(
                                                                  context)
                                                              .translate(
                                                                  'retour'),
                                                        )
                                                      : Text("a"),
                                                  onPressed: () {
                                                    setState(() {
                                                      visible_plane =
                                                          !visible_plane;
                                                      !visible_plane
                                                          ? colorCard_plane =
                                                              Colors.white70
                                                          : colorCard_plane =
                                                              Colors.white;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          )
                                        : Container(),
                                  ),
                                  AnimatedOpacity(
                                      duration: Duration(milliseconds: 1000),
                                      opacity: visible_plane ? 1.0 : 0.0,
                                      child: visible_plane
                                          ? Column(
                                              children: <Widget>[
                                                Container(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child: Image.asset(
                                                    'assets/plane.png',
                                                    width: widthCard * 0.6,
                                                    height: widthCard * 0.6,
                                                  ),
                                                ),
                                                Container(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: FlatButton.icon(
                                                    label: temp != null
                                                        ? Text(
                                                            AppLocalizations.of(
                                                                    context)
                                                                .translate(
                                                                    'avion'),
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 24,
                                                            ),
                                                          )
                                                        : Text("a"),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                    ),
                                                    icon: Icon(
                                                      Icons.info_outline,
                                                      color: Colors.black,
                                                    ),
                                                    splashColor: Colors.blue,
                                                    onPressed: () {
                                                      setState(() {
                                                        visible_plane =
                                                            !visible_plane;
                                                        !visible_plane
                                                            ? colorCard_plane =
                                                                Colors.white70
                                                            : colorCard_plane =
                                                                Colors.white;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Container()),
                                ],
                              ),
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

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;

        setState(() {
          menuPage = menu();
        });

        settingsPage = LoadPage(
          appLanguage: appLanguage,
          user: user,
          page: "manageProfile",
          messageIn: "",
        );
        if (user.userInitialPush == "0.0")
          firstPush = LoadPage(
            appLanguage: appLanguage,
            user: user,
            page: "firstPush",
            messageIn: "0",
          );
        else
          firstPush = null;
        /*
        bluetoothPage = BluetoothManager(
            user: user,
            inputMessage: "0",
            appLanguage: appLanguage); */
      });
    }

    if (message != defaultIndex) {
      _selectedIndex = message;
      message = defaultIndex;
    }
    List<Widget> _widgetOptions;

    if (user.userInitialPush == "0.0")
      _widgetOptions = <Widget>[
        menuPage = menu(),
        settingsPage,
        firstPush,
      ];
    else
      _widgetOptions = <Widget>[
        menuPage = menu(),
        settingsPage,
      ];

    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          bottomNavigationBar: new BottomNavigationBar(
            items: user.userInitialPush == "0.0"
                ? <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.home,
                      ),
                      title: Text(
                          AppLocalizations.of(context).translate('accueil')),
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.settings,
                      ),
                      title: Text(
                          AppLocalizations.of(context).translate('reglages')),
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.file_download,
                      ),
                      title: Text(AppLocalizations.of(context)
                          .translate('premiere_poussee')),
                    ),
                  ]
                : <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.home,
                      ),
                      title: Text(
                          AppLocalizations.of(context).translate('accueil')),
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.settings,
                      ),
                      title: Text(
                          AppLocalizations.of(context).translate('reglages')),
                    ),
                  ],
            currentIndex: _selectedIndex,
            selectedItemColor: orangeColor,
            onTap: _onItemTapped,
          ),
          body: Center(
            child: _widgetOptions.elementAt(_selectedIndex),
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
