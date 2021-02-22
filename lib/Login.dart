import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:gbsalternative/BluetoothManager.dart';
import 'package:gbsalternative/LoadPage.dart';
import 'package:gbsalternative/MainTitle.dart';
import 'package:provider/provider.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'DatabaseHelper.dart';
import 'package:gbsalternative/AppLocalizations.dart';

TextStyle textStyle =
    TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold);
TextStyle textStyleW =
    TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold);
TextStyle appBarStyle =
    TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold);

class Login extends StatefulWidget {
  final AppLanguage appLanguage;

  Login({@required this.appLanguage});

  @override
  _Login createState() => _Login(appLanguage);
}

class _Login extends State<Login> {
  DatabaseHelper db = new DatabaseHelper();
  BluetoothManager bluetoothManager =
      new BluetoothManager(user: null, inputMessage: null, appLanguage: null);
  File imageFile;
  AppLanguage appLanguage;

  //Constructeur
  _Login(AppLanguage _appLanguage) {
    appLanguage = _appLanguage;
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void init() async {
    //Demander l'autorisation à la localisation pour le bluetooth
    if (!await bluetoothManager.locationPermission()) {
      //init();
    }
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

    var languages = [
      FlatButton.icon(
        icon: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image(
            image: new AssetImage("assets/flags/fr.png"),
            width: 40,
          ),
        ),
        label: Text(
          "Français",
          style: TextStyle(
            color: Colors.black,
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
            color: Colors.black,
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
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('bienvenue'),
        ),
        backgroundColor: Colors.blue,
        actions: <Widget>[
          /*FlatButton.icon(
              icon: Icon(
                Icons.exit_to_app,
                color: Colors.white,
              ),
              label: AutoSizeText(
                AppLocalizations.of(context).translate('quitter_appli'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
                minFontSize: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              splashColor: Colors.blue,
              onPressed: () {
                if (Platform.isAndroid)
                  SystemNavigator.pop();
                else if (Platform.isIOS) exit(0);
              },
            ),*/
          FlatButton.icon(
            icon: Icon(
              Icons.question_answer,
              color: Colors.white,
            ),
            label: AutoSizeText(
              "FAQ",
              style: TextStyle(
                fontSize: 15,
                color: Colors.white,
              ),
              minFontSize: 10,
            ),
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
                      messageIn: "fromLogin",
                      page: faq),
                ),
              );
            },
          ),
          //Choix de la langue
          /*Container(
              width: screenSize.width / 4,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: <Widget>[
                  Container(
                    width: screenSize.width / 5,
                    child: AutoSizeText(
                      AppLocalizations.of(context).translate('choix_langue'),
                      style: TextStyle(fontSize: 25),
                      minFontSize: 15,
                      maxLines: 1,
                    ),
                  ),
                  DropdownButton<FlatButton>(
                    */ /*value: languages[0],*/ /*
                    items: languages.map((FlatButton value) {
                      return DropdownMenuItem<FlatButton>(
                        value: value,
                        child: value,
                      );
                    }).toList(),
                    onChanged: (FlatButton button) {
                      setState() {}
                    },
                  ),
                ],
              ),
            )*/
        ],
      ),
      body: FutureBuilder<List<User>>(
        future: db.userList(),
        builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              child: Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 40,
                  children:
                      List.generate(size = snapshot.data.length + 1, (index) {
                    if (index < size - 1 && index >= 0) {
                      User item = snapshot.data[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  //MainTitle(appLanguage: appLanguage,messageIn: "",userIn: snapshot.data[index -1],),
                                  LoadPage(
                                user: snapshot.data[index],
                                appLanguage: appLanguage,
                                page: mainTitle,
                                messageIn: "0",
                              ),
                            ),
                          );
                          /*
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoadPage(
                                          user: snapshot.data[index - 1],
                                          appLanguage: appLanguage,
                                          page: mainTitle,
                                          messageIn: "0",
                                        )));*/
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            height: screenSize.height * 0.5,
                            width: screenSize.height * 0.4,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                new Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).buttonColor.withAlpha(100),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: <Widget>[
                                        Container(
                                          height: screenSize.height * 0.3,
                                          width: screenSize.width * 0.3,
                                        ),
                                        Align(
                                          alignment: Alignment.topCenter,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Image.file(
                                              File(
                                                  snapshot.data[index].userPic),
                                              height: screenSize.height * 0.3,
                                              width: screenSize.width * 0.3,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: AutoSizeText(
                                    item.userName,
                                    style: textStyle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else if (index == size - 1) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoadPage(
                                        appLanguage: appLanguage,
                                        page: register,
                                        messageIn: "0",
                                        user: null,
                                      )));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            height: screenSize.height * 0.5,
                            width: screenSize.height * 0.4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).buttonColor.withAlpha(100),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: Column(
                                      children: <Widget>[
                                        Image.asset(
                                          "assets/add.png",
                                          height: screenSize.height * 0.3,
                                          width: screenSize.width * 0.3,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                AutoSizeText(
                                  AppLocalizations.of(context)
                                      .translate('inscription'),
                                  style: textStyle,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else
                      return Center(child: CircularProgressIndicator());
                  }),
                  //separatorBuilder: (BuildContext context, int index) =>
                  //    const Divider(),
                ),
              ),
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
                    alignment: Alignment.center, child: Text("Loading..."))
              ],
            );
          }
        },
      ),
    );
  }
}
