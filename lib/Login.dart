import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:gbsalternative/BluetoothManager.dart';
import 'package:gbsalternative/FAQ.dart';
import 'package:gbsalternative/LoadPage.dart';
import 'package:gbsalternative/MainTitle.dart';
import 'package:gbsalternative/Register.dart';
import 'package:provider/provider.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'DatabaseHelper.dart';
import 'package:gbsalternative/AppLocalizations.dart';

TextStyle textStyle =
    TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold);
TextStyle textStyleW =
    TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold);
TextStyle textStyleBG =
    TextStyle(color: Colors.black45, fontSize: 20, fontWeight: FontWeight.bold);
TextStyle appBarStyle =
    TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold);

Color backgroundColor = Color(0xFFF0F8FF);
//Color backgroundColor = Colors.white;

Color iconColor = Colors.black45;
Color splashIconColor = Colors.black54;

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
  List<User> userList = [];
  int size = 0;

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
    //userList = await db.userList();
    setState(() {});

    //Demander l'autorisation à la localisation pour le bluetooth
    if (!await bluetoothManager.locationPermission()) {
      //init();
    }
  }

  //TODO Cancel every bluetooth research

  @override
  Widget build(BuildContext context) {
    // return LoginWidget(db);
    Size screenSize = MediaQuery.of(context).size;
    var appLanguage = Provider.of<AppLanguage>(context);

    var languages = [
      //Français
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
      //English
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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: iconColor),
        title: AutoSizeText(
          //AppLocalizations.of(context).translate('bienvenue'),
          "",
          style: textStyle,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
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

          Image.asset(
            "assets/spineo.png",
            width: screenSize.width * 0.20,
          ),
          Container(
            width: screenSize.width * 0.40,
            alignment: Alignment.centerRight,
            child: FlatButton.icon(
              icon: Icon(
                Icons.question_answer,
                color: iconColor,
              ),
              label: AutoSizeText(
                "FAQ",
                style: TextStyle(
                  fontSize: 15,
                  color: iconColor,
                ),
                minFontSize: 10,
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
                        inputMessage: "fromLogin",
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
                    child: Column(
                      children: <Widget>[],
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                  ),
                ),
              ),
              //Spacer -> each container -> 0.1 and divider = 16.0
              Container(
                height: screenSize.height * 0.1 + 16.0,
              ),
              Container(
                height: screenSize.height * 0.1,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: RaisedButton(
                    child: Text("Add user"),
                    onPressed: () {

                      List<String> name = [
                        "René Coty",
                        "Charles de Gaulle",
                        "Georges Pompidou",
                        "Valéry Giscard d'Estaing",
                        "François Mitterand",
                        "Jacques Chirac",
                        "Nicolas Sarkozy",
                        "François Hollande",
                        "Emmanuel Macron",
                        "Hubert Bonisseur de la Bath",
                        "Hubert Bonisseur de la Bath",
                        "Hubert Bonisseur de la Bath",
                      ];
                      Random random = new Random();

                      db.addUser(User(
                        userHeightBottom: "15",
                        userHeightTop: "19",
                        userId: null,
                        userInitialPush: "51.0",
                        userNotifEvent: "1",
                        userLastLogin: "2021-02-24 15:18:54.051196Z",
                        userMacAddress: "78:DB:2F:BF:3B:03",
                        userSerialNumber: "gBs1230997P",
                        userMode: "Athletic",
                        userName: name[random.nextInt(name.length - 1)],
                        userPic:
                            "/data/user/0/genourob.gbs/app_flutter/default.png",
                      ));
                      setState(() {

                      });
                    },
                  ),
                ),
              ),
              //FAQ
              Container(
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
                            inputMessage: "fromLogin",
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
                  onPressed: () {},
                ),
              ),
              Column(
                children: <Widget>[
                  AutoSizeText("About Spineo Home"),
                  AutoSizeText(
                    "© 2021 Genourob.  All rights reserved.",
                  ),
                ],
              ),
            ],
          ),
        ),
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
                  children: List.generate(
                    size = snapshot.data.length + 1,
                    (index) {
                      if (index < size - 1 && index >= 0) {
                        User item = snapshot.data[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    //MainTitle(appLanguage: appLanguage,messageIn: "",userIn: snapshot.data[index -1],),
                                    MainTitle(
                                  userIn: snapshot.data[index],
                                  messageIn: "0",
                                  appLanguage: appLanguage,
                                ),
                                /*
                              LoadPage(
                                user: snapshot.data[index],
                                appLanguage: appLanguage,
                                page: mainTitle,
                                messageIn: "0",
                              ),*/
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
                            child: new Container(
                              height: screenSize.height * 0.5,
                              width: screenSize.height * 0.4,
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                //color: Colors.blue,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Stack(
                                children: <Widget>[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.file(
                                      File(snapshot.data[index].userPic),
                                      height: screenSize.height * 0.3,
                                      width: screenSize.width * 0.3,
                                    ),
                                  ),
                                  Center(
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          0, screenSize.height * 0.3, 0, 0),
                                      child: AutoSizeText(
                                        item.userName,
                                        style: textStyle,
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                      ),
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
                                    builder: (context) => Register(
                                          appLanguage: appLanguage,
                                        )));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: new Container(
                              height: screenSize.height * 0.5,
                              width: screenSize.height * 0.4,
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                //color: Colors.blue,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Stack(
                                children: <Widget>[
                                  Image.asset(
                                    "assets/add.png",
                                    height: screenSize.height * 0.3,
                                    width: screenSize.width * 0.3,
                                  ),
                                  Center(
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          0, screenSize.height * 0.3, 0, 0),
                                      child: AutoSizeText(
                                        AppLocalizations.of(context)
                                            .translate('inscription'),
                                        style: textStyle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else
                        return Center(child: CircularProgressIndicator());
                    },
                  ),
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
                  color: backgroundColor,
                  child: CircularProgressIndicator(),
                ),
                Container(
                    color: backgroundColor,
                    alignment: Alignment.center,
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('chargement')))
              ],
            );
          }
        },
      ),
    );
  }
}
