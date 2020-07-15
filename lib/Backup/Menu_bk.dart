import 'dart:io';

import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/AppLocalizations.dart';
import 'package:gbsalternative/LoadPage.dart';
import 'package:gbsalternative/MainTitle.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../DatabaseHelper.dart';
import '../DrawCharts.dart';
import '../Login.dart';
import '../ManageProfile.dart';
import '../Swimmer/Swimmer.dart';
import 'Swimmer_bk.dart';

class Menu extends StatefulWidget {
  final User curUser;
  final String message;
  final AppLanguage appLanguage;

  Menu({
    Key key,
    @required this.curUser,
    @required this.message,
    @required this.appLanguage,
  }) : super(key: key);

  @override
  _Menu createState() => new _Menu(curUser, message, appLanguage);
}

class _Menu extends State<Menu> {
  DatabaseHelper db = new DatabaseHelper();

  User user;
  bool stop = false;
  String _information = 'No Information Yet';
  AppLanguage appLanguage;
  List<Scores> data;

  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  _Menu(User curUser, String message, AppLanguage _appLanguage) {
    user = curUser;
    _information = message;
    appLanguage = _appLanguage;
  }

  getPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  void updateInformation(String information) {
    setState(() => _information = information);
  }

  updateUser(int id) async {
    return await db.getUser(id);
  }

  void manageProfile() async {
    final information = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MainTitle(
                  userIn: user,
                  messageIn: 1,
                  appLanguage: appLanguage,
                )));

    //final information = await Navigator.push(
    //    context,
    //    MaterialPageRoute(
    //        builder: (context) => ManageProfile(
    //              curUser: user,
    //            )));
    //updateInformation(information);
    print("INFORMATION: " + information);
  }

  void getScores(int userId) async {
    data = await db.getScore(userId, 0);
    if (data == null) {
      getScores(userId);
      stop = false;
    } else if (!stop) {
      setState(() {});
      stop = true;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    getScores(user.userId);

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    Size screenSize = MediaQuery.of(context).size;
    int numberOfCard = 3;

    double widthCard, heightCard;

    print("id: " + user.userId.toString());

    if (_information == 'Modified') {
      user = updateUser(user.userId);
      (context as Element).reassemble();
    } else if (_information == 'Deleted') Navigator.pop(context);

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
                  : Text("Check Language file (en/fr.json)"),
            ],
          ),
          backgroundColor: Colors.blue,
          actions: <Widget>[
            /*FlatButton.icon(
            icon: Icon(
              Icons.settings,
              color: Colors.white,
            ),
            label: Text(
              "Gérer mon profil",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            splashColor: Colors.blue,
            onPressed: () {
              manageProfile();
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
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LoadPage(
                              appLanguage: appLanguage,
                              messageIn: "deconnexion",
                              page: "login",
                            )));

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
                                  : Text("Check Language file (en/fr.json)"),

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
                                      : Text("Check Language file (en/fr.json)"),
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
                        },
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
                                  "Le Nageur",
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
                                "Statistiques",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              //Graph à insérer
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: RaisedButton(
                                  child: Text("Voir plus en détails"),
                                  onPressed: () {
                                    db.addScore(new Score(
                                        scoreId: null,
                                        activityId: 1,
                                        userId: user.userId,
                                        scoreDate: "25/06",
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
                                  "Le Nageur",
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
}

/*

class MenuUI extends StatelessWidget {
  DatabaseHelper db;
  User user;
  Size screenSize;
  AppLanguage appLanguage;
  List<Scores> data;
  int numberOfCard;
  double widthCard, heightCard;
  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  MenuUI(DatabaseHelper _db, User _user, Size _screenSize,
      AppLanguage _appLanguage, List<Scores> _data, int _numberOfCard) {
    db = _db;
    user = _user;
    screenSize = _screenSize;
    appLanguage = _appLanguage;
    data = _data;
    numberOfCard = _numberOfCard;
  }


  @override
  Widget build(BuildContext context) {


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
                  : Text("Check Language file (en/fr.json)"),
            ],
          ),
          backgroundColor: Colors.blue,
          actions: <Widget>[
            */
/*FlatButton.icon(
            icon: Icon(
              Icons.settings,
              color: Colors.white,
            ),
            label: Text(
              "Gérer mon profil",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            splashColor: Colors.blue,
            onPressed: () {
              manageProfile();
            },
          ),*/ /*

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
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LoadPage(
                          appLanguage: appLanguage,
                          messageIn: "deconnexion",
                          page: "login",
                        )));

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
                                  : Text("Check Language file (en/fr.json)"),

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
                                      : Text("Check Language file (en/fr.json)"),
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
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Swimmer(user: user, appLanguage: appLanguage,)));
                        },
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
                                  "Le Nageur",
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
                                "Statistiques",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              //Graph à insérer
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: RaisedButton(
                                  child: Text("Voir plus en détails"),
                                  onPressed: () {
                                    db.addScore(new Score(
                                        scoreId: null,
                                        activityId: 1,
                                        userId: user.userId,
                                        scoreDate: "25/06",
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
                                  "Le Nageur",
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
}
*/
