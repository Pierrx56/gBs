import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/AppLocalizations.dart';
import 'package:gbsalternative/BluetoothSync.dart';
import 'package:gbsalternative/DrawCharts.dart';
import 'package:gbsalternative/LoadPage.dart';
import 'package:gbsalternative/ManageProfile.dart';

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
  Widget bluetoothPage;
  Widget loginPage;
  PageController _c;
  bool _visible;
  Color colorCard;

  AppLanguage appLanguage;
  User user;
  int message;

  DatabaseHelper db = new DatabaseHelper();
  bool stop = false;
  String _information = 'No Information Yet';
  List<Scores> data;

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

    //menuPage = menu();

/*    menuPage = LoadPage(
      appLanguage: appLanguage,
      page: "menu",
      user: user,
    );*/

    settingsPage = LoadPage(
      appLanguage: appLanguage,
      user: user,
      page: "manageProfile",
      messageIn: "",
    );

    bluetoothPage = BluetoothSync(
      curUser: user,
    );
    /*
    loginPage = LoadPage(
      page: "login",
    );*/
  }

  @override
  void initState() {
    // TODO: implement initState
    //db.deleteScore(user.userId);
    _visible = true;
    colorCard = Colors.white;
    getScores(user.userId);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getScores(int userId) async {
    data = await db.getScore(userId);
    if (data == null) {
      getScores(userId);
      stop = false;
    } else if (!stop) {
      setState(() {});
      stop = true;
    }
  }

  Widget menu() {
    Size screenSize = MediaQuery.of(context).size;
    int numberOfCard = 3;

    double widthCard, heightCard;

    print("id: " + user.userId.toString());

    //TODO Fix language problem
    var temp = AppLocalizations.of(context);

    //return MenuUI(db, user, screenSize, appLanguage, data, numberOfCard);

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

                db.addScore(newScore);
                db.addScore(newScore1);
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
                              data == null
                                  ? Container()
                                  : DrawCharts(data: data),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: RaisedButton(
                                  child: temp != null
                                      ? Text(
                                          AppLocalizations.of(context)
                                              .translate('details'),
                                        )
                                      : Text("a"),
                                  onPressed: () => show("Bonjour"),
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

                          if(_visible) {
                            //TODO Check si l'@mac n'est pas nulle, auquel cas rediriger vers la connection BT
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
                                    )));
                          }
                          else {

                          }
                        },
                        child: new Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 8,
                          color: colorCard,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                            child: Stack(
                              children: <Widget>[
                                AnimatedOpacity(
                                  duration: Duration(milliseconds: 1000),
                                  opacity: !_visible ? 1.0 : 0.0,

                                  child: !_visible ? Column(
                                    children: <Widget>[

                                  Align(
                                  alignment: Alignment.topCenter,
                                    child:
                                    //TODO Requête vers la bdd pour savoir le type d'activité et comment ça marche
                                  Text("Le jeu du Nageur est un jeu qui consiste à effectuer "
                                      "des poussées régulières pour maintenir le nageur le plus "
                                      "proche de la ligne centrale. "
                                      "600m parcourus = 5 minutes"),
                                  ),
                                    Align(
                                        alignment: Alignment.bottomCenter,
                                        child: RaisedButton(
                                          child: temp != null
                                              ? Text(
                                                  AppLocalizations.of(context)
                                                      .translate('retour'),
                                                )
                                              : Text("a"),
                                          onPressed: (){
                                            setState(() {
                                              _visible = !_visible;
                                              !_visible
                                                  ? colorCard = Colors.white70
                                                  : colorCard = Colors.white;
                                            });
                                          },
                                        ),
                                      ),

                                      /*
                                        Container(
                                          child: !_visible
                                              ? Container(
                                                  child: Text(
                                                    "Texte expliquant le fonctionnement du nageur",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                )
                                              : Container(),
                                          color: Colors.grey,
                                          width: screenSize.width,
                                          height: screenSize.height,
                                        ),*/
                                      /*
                                        FlatButton.icon(
                                          label: temp != null
                                              ? Text(
                                            AppLocalizations.of(context)
                                                .translate('retour'),
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 24,
                                            ),
                                          )
                                              : Text("a"),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(50),
                                          ),
                                          icon: Icon(
                                            Icons.close,
                                            color: Colors.white,
                                          ),
                                          splashColor: Colors.blue,
                                          onPressed: () {
                                            setState(() {
                                              _visible = !_visible;
                                              !_visible
                                                  ? colorCard = Colors.grey
                                                  : colorCard = Colors.white;
                                            });
                                          },
                                        ),*/
                                    ],
                                  ): Container(),
                                ),
                                AnimatedOpacity(
                                    duration: Duration(milliseconds: 1000),
                                    opacity: _visible ? 1.0 : 0.0,
                                    child: _visible
                                        ? Column(
                                            children: <Widget>[
                                              Container(
                                                alignment: Alignment.topCenter,
                                                child: Image.asset(
                                                  'assets/swim.png',
                                                  width: widthCard * 0.6,
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
                                                            color: Colors.black,
                                                            fontSize: 24,
                                                          ),
                                                        )
                                                      : Text("a"),
                                                  shape: RoundedRectangleBorder(
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
                                                      _visible = !_visible;
                                                      !_visible
                                                          ? colorCard =
                                                              Colors.white70
                                                          : colorCard =
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
                    SizedBox(
                      width: screenSize.width / numberOfCard,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 8,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Text(
                                AppLocalizations.of(context)
                                    .translate('statistiques'),
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              //Graph à insérer
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: RaisedButton(
                                  child: Text(AppLocalizations.of(context)
                                      .translate('details')),
                                  onPressed: () {
                                    db.addScore(new Score(
                                        scoreId: null,
                                        activityId: 1,
                                        userId: user.userId,
                                        scoreDate: "29-05-2020",
                                        scoreValue: 12));
                                    show("Added");
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
                        onTap: () => show("Lancement du jeu"),
                        child: new Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 8,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Image.asset(
                                  'assets/swim.png',
                                  width: widthCard * 0.7,
                                ),
                                Text(
                                  AppLocalizations.of(context)
                                      .translate('nageur'),
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
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

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;

/*          menuPage = LoadPage(
            appLanguage: appLanguage,
            user: user,
            page: "menu",
          );*/

        setState(() {
          menuPage = menu();
        });

        settingsPage = LoadPage(
          appLanguage: appLanguage,
          user: user,
          page: "manageProfile",
          messageIn: "",
        );
        bluetoothPage = BluetoothSync(
          curUser: user,
        );
        /*
        loginPage = LoadPage(
          appLanguage: appLanguage,
          page: "login",
        );*/
      });
    }

    if (message != defaultIndex) {
      _selectedIndex = message;
      message = defaultIndex;
    }

    List<Widget> _widgetOptions = <Widget>[
      menuPage = menu(),
      settingsPage,
      bluetoothPage,
    ];

    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          bottomNavigationBar: new BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.home,
                ),
                title: Text(AppLocalizations.of(context).translate('accueil')),
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.settings,
                ),
                title: Text(AppLocalizations.of(context).translate('reglages')),
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.settings_bluetooth,
                ),
                title:
                    Text(AppLocalizations.of(context).translate('bluetooth')),
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
}
