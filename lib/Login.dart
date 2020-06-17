import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gbsalternative/LoadPage.dart';
import 'package:gbsalternative/MainTitle.dart';
import 'package:gbsalternative/main.dart';
import 'package:provider/provider.dart';

import 'package:gbsalternative/AppLanguage.dart';
import 'DatabaseHelper.dart';
import 'Register.dart';
import 'package:gbsalternative/AppLocalizations.dart';

class Login extends StatefulWidget {
  final AppLanguage appLanguage;

  Login({@required this.appLanguage});

  @override
  _Login createState() => _Login(appLanguage);
}

double screenHeight;
double screenWidth;

class _Login extends State<Login> {
  DatabaseHelper db = new DatabaseHelper();

  File imageFile;

  // Initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  // Track the Bluetooth connection with the remote device
  BluetoothConnection connection;

  // To track whether the device is still connected to Bluetooth
  bool get isConnected => connection != null && connection.isConnected;

  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  AppLanguage appLanguage;

  _Login(AppLanguage _appLanguage) {
    appLanguage = _appLanguage;
  }

  @override
  void initState() {
    //TODO Create activities types with bdd


/*
    //Nageur
    db.addActivity(new Activity(activityId: 0, activityType: "CMV",));
    //Deuxième activité
    db.addActivity(new Activity(activityId: 1, activityType: "CSI",));
    //Troisième activité
    db.addActivity(new Activity(activityId: 2, activityType: "CSI",));
*/

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return LoginWidget(db);
  }
}

class LoginWidget extends StatelessWidget {
  DatabaseHelper db;
  int size = 0;

  LoginWidget(DatabaseHelper _db) {
    db = _db;
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    var appLanguage = Provider.of<AppLanguage>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).translate('bienvenue')),
          backgroundColor: Colors.blue,
          actions: <Widget>[
            FlatButton.icon(
              icon: Image(
                image: new AssetImage("assets/flags/fr.png"),
                width: 40,
              ),
              label: Text(
                "Français",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              splashColor: Colors.blue,
              onPressed: () {
                print("Français");
                appLanguage.changeLanguage(Locale("fr"));
              },
            ),
            FlatButton.icon(
              icon: Image(
                image: new AssetImage("assets/flags/en.png"),
                width: 40,
              ),
              label: Text(
                "English",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              splashColor: Colors.blue,
              onPressed: () {
                print("English");
                appLanguage.changeLanguage(Locale("en"));
              },
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: FutureBuilder<List<User>>(
                future: db.userList(),
                builder:
                    (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
                  if (snapshot.hasData) {
                    return ListView.separated(
                      padding: EdgeInsets.all(10.0),
                      itemCount: size = snapshot.data.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (index < size - 1) {
                          User item = snapshot.data[index];
                          return GestureDetector(
                            onTap: () {
                              //db.deleteUser(item.id);
/*                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Menu(
                                            curUser: snapshot.data[index],
                                            appLanguage: appLanguage,
                                          )));*/
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoadPage(
                                            user: snapshot.data[index],
                                            appLanguage: appLanguage,
                                            page: "mainTitle",
                                            messageIn: "0",
                                          )
                                      /*MainTitle(
                                            userIn: snapshot.data[index],
                                            messageIn: 0,
                                            appLanguage: appLanguage,
                                          )*/
                                      ));
                            },
                            child: new Container(
                              height: screenHeight * 0.3,
                              decoration: BoxDecoration(
                                color: Theme.of(context).buttonColor,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Row(
                                  children: <Widget>[
                                    Image.file(
                                            File(snapshot.data[index].userPic),
                                            height: screenHeight * 0.3,
                                            width: screenWidth * 0.3,
                                          ),
                                    Text(item.userName),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else if (index == size - 1) {
                          return GestureDetector(
                            onTap: () {
                              //db.deleteUser(item.id);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoadPage(
                                            appLanguage: appLanguage,
                                            page: "register",
                                            messageIn: "",
                                            user: null,
                                          )));
                            },
                            child: new Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).buttonColor,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      0,
                                      screenHeight * 0.15,
                                      0,
                                      screenHeight * 0.15),
                                  child: Center(
                                    child: Text(AppLocalizations.of(context)
                                        .translate('inscription')),
                                  )),
                            ),
                          ); //
                        } else
                          return Center(child: CircularProgressIndicator());
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(),
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(10),
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(),
                        ),
                        Container(
                            alignment: Alignment.center,
                            child: Text("Loading..."))
                      ],
                    );

                    /*
                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                          12.0, screenHeight * 0.15, 12.0, screenHeight * 0.15),
                      child: GestureDetector(
                        onTap: () {
                          //db.deleteUser(item.id);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Register()));
                        },
                        child: new Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).buttonColor,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Padding(
                              padding: EdgeInsets.fromLTRB(0,
                                  screenHeight * 0.15, 0, screenHeight * 0.15),
                              child: Center(
                                child: Text("S'inscrire"),
                              )),
                        ),
                      ),
                    ); */
                  }
                },
              ),
            ),
          ],
        ));
  }
}
