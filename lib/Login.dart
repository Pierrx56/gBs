import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:gbsalternative/LoadPage.dart';
import 'package:provider/provider.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'DatabaseHelper.dart';
import 'package:gbsalternative/AppLocalizations.dart';

TextStyle textStyle =
    TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold);

class Login extends StatefulWidget {
  final AppLanguage appLanguage;

  Login({@required this.appLanguage});

  @override
  _Login createState() => _Login(appLanguage);
}

class _Login extends State<Login> {
  DatabaseHelper db = new DatabaseHelper();
  File imageFile;
  AppLanguage appLanguage;

  //Constructeur
  _Login(AppLanguage _appLanguage) {
    appLanguage = _appLanguage;
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
    Size screenSize = MediaQuery.of(context).size;
    var appLanguage = Provider.of<AppLanguage>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context).translate('bienvenue'),
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
                        user: null,
                        appLanguage: appLanguage,
                        messageIn: "fromLogin",
                        page: faq),
                  ),
                );
              },
            ),
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
                        if (index < size && index > 0) {
                          User item = snapshot.data[index - 1];
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoadPage(
                                            user: snapshot.data[index - 1],
                                            appLanguage: appLanguage,
                                            page: mainTitle,
                                            messageIn: "0",
                                          )));
                            },
                            child: new Container(
                              height: screenSize.height * 0.3,
                              decoration: BoxDecoration(
                                color: Theme.of(context).buttonColor,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Row(
                                  children: <Widget>[
                                    Image.file(
                                      File(snapshot.data[index - 1].userPic),
                                      height: screenSize.height * 0.3,
                                      width: screenSize.width * 0.3,
                                    ),
                                    //Text(AppLocalizations.of(context).translate('profil_existant') + ": "),
                                    Text(
                                      item.userName,
                                      style: textStyle,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else if (index == 0) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoadPage(
                                            appLanguage: appLanguage,
                                            page: register,
                                            messageIn: "",
                                            user: null,
                                          )));
                            },
                            child: new Container(
                              height: screenSize.height * 0.3,
                              decoration: BoxDecoration(
                                color: Theme.of(context).buttonColor,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Row(
                                  children: <Widget>[
                                    Image.asset(
                                      "assets/add.png",
                                      height: screenSize.height * 0.3,
                                      width: screenSize.width * 0.3,
                                    ),
                                    Text(
                                      AppLocalizations.of(context)
                                          .translate('inscription'),
                                      style: textStyle,
                                    ),
                                  ],
                                ),
                              ),
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
                  }
                },
              ),
            ),
          ],
        ));
  }
}
