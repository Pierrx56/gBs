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
import 'package:gbsalternative/BluetoothManager.dart';
import 'package:gbsalternative/CommonGamesUI.dart';
import 'package:gbsalternative/FAQ.dart';
import 'package:gbsalternative/MainTitle.dart';
import 'package:gbsalternative/NotificationManager.dart';
import 'package:gbsalternative/Register.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'BluetoothManager.dart';
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

String softwareVersion = "11.0.1.0";

var colorButton = MaterialStateProperty.all<Color>(Colors.grey[350]);

var colorPushedButton = MaterialStateProperty.all<Color>(Colors.grey[600]);

//Color backgroundColor = Colors.white;
String attention;
String eteindre;

Color iconColor = Colors.black45;
Color splashIconColor = Colors.black54;

class Login extends StatefulWidget {
  final AppLanguage appLanguage;
  final String message;

  Login({@required this.appLanguage, @required this.message});

  @override
  _Login createState() => _Login(appLanguage, message);
}

class _Login extends State<Login> with WidgetsBindingObserver {
  DatabaseHelper db = new DatabaseHelper();
  BluetoothManager bluetoothManager =
      new BluetoothManager(user: null, inputMessage: null, appLanguage: null);
  File imageFile;
  AppLanguage appLanguage;
  List<User> userList = [];
  String message;
  int size = 0;
  Timer watchdogTimer;
  Timer _timer;
  bool timerIsOn;
  int bgState;

  CommonGamesUI commonGamesUI;

  //Constructeur
  _Login(AppLanguage _appLanguage, String _message) {
    appLanguage = _appLanguage;
    message = _message;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    timerIsOn = false;
    if (watchdogTimer == null) {
      //Looking for closed app every 3 seconds and avert user
      watchdogTimer = Timer.periodic(Duration(seconds: 3), (timer) {
        WidgetsBinding.instance.removeObserver(this);
        WidgetsBinding.instance.addObserver(this);
      });
    }
    init();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void init() async {
    //userList = await db.userList();
    setState(() {});
    commonGamesUI = new CommonGamesUI();

    if (message != "fromMain") {
      //Cancel every bluetooth research
      bluetoothManager.disconnect("fromLogin");
    }
    //Demander l'autorisation à la localisation pour le bluetooth
    if (!await bluetoothManager.locationPermission()) {
      //init();
    }
  }

  void setBGState(int state) {
    bgState = state;
  }

  AppLifecycleState getState() {

    switch (bgState) {
      case 0:
        return AppLifecycleState.resumed;
        // TODO: Handle this case.
        break;
      case 1:
        return AppLifecycleState.inactive;
        // TODO: Handle this case.
        break;
      case 2:
        return AppLifecycleState.paused;
        // TODO: Handle this case.
        break;
      case 3:
        return AppLifecycleState.detached;
        // TODO: Handle this case.
        break;
    }
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    /*if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) return;*/

    bool isBackground = false;
    int tempTimer = 0;
    switch (state) {
      case AppLifecycleState.resumed:
        print("state: $state");
        timerIsOn = false;
        commonGamesUI.setGamePauseState(timerIsOn);
        setBGState(0);
        break;
      case AppLifecycleState.inactive:
        print("state: $state");
        setBGState(1);
        break;
      case AppLifecycleState.paused:
        print("state: $state");
        setBGState(2);
        isBackground = true;
        tempTimer = 10;
        break;
      case AppLifecycleState.detached:
        print("state: $state");
        setBGState(3);
        break;
    }

    //When user quit app or lock it smartphone
    if (isBackground && tempTimer == 10 && !timerIsOn) {
      timerIsOn = true;
      commonGamesUI.setGamePauseState(timerIsOn);
      //If isConnected and have quit app, send notification

      BluetoothManager bluetoothManager = new BluetoothManager(
          user: null, inputMessage: 'inputMessage', appLanguage: appLanguage);

      bool isConnected = await bluetoothManager.getStatus();

      _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
        tempTimer--;
        print("tempTimer: $tempTimer");

        //Do nothing if app is resumed
        if (getState() == AppLifecycleState.resumed) {
          print("resumed");
          timerIsOn = false;
          commonGamesUI.setGamePauseState(timerIsOn);
          _timer.cancel();
        }

        if (tempTimer <= 0) {
          timerIsOn = false;
          _timer.cancel();
          //If still connected after XX seconds of inactivity, advert and disconnect
          if (isConnected = await bluetoothManager.getStatus()) {
            print("state: $getState()");
            print("isConnected: $isConnected");
            print("\n Disconnection \n\n ");
            bluetoothManager.disconnect("origin");
          }

          NotificationManager notificationManager = new NotificationManager();
          notificationManager.alertNotification(attention, eteindre,);
        }
      });

      //watchdogTimer?.cancel();
    }

    /* if (isBackground) {
      // service.stop();
    } else {
      // service.start();
    }*/
  }

  @override
  Widget build(BuildContext context) {
    // return LoginWidget(db);
    Size screenSize = MediaQuery.of(context).size;
    //var appLanguage = Provider.of<AppLanguage>(context);

    attention = AppLocalizations.of(context).translate('attention');
    eteindre = AppLocalizations.of(context).translate('eteindre_appareil');

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
                height: screenSize.height * 0.1,
              ),
              Container(
                height: screenSize.height * 0.1,
                child: Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.black45),
                    ),
                    child: Text("Add user"),
                    onPressed: () async {
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

                      var data = await rootBundle.load("assets/default.png");
                      final buffer = data.buffer;
                      String dir =
                          (await getApplicationDocumentsDirectory()).path;
                      File tempFile = await new File("$dir/default.png")
                          .writeAsBytes(buffer.asUint8List(
                              data.offsetInBytes, data.lengthInBytes));

                      db.addUser(User(
                        userHeightBottom: "15",
                        userHeightTop: "19",
                        userId: null,
                        userInitialPush: "51.0",
                        userNotifEvent: "1",
                        userLastLogin: "2021-02-24 15:18:54.051196Z",
                        userMacAddress: "78:DB:2F:BF:3B:03",
                        userSerialNumber: "gBs1230997P",
                        userMode: "0",
                        userName: name[random.nextInt(name.length - 1)],
                        userPic: tempFile.path,
                      ));

                      setState(() {});
                    },
                  ),
                ),
              ),
              Container(
                height: screenSize.height * 0.1,
                child: Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.black45),
                    ),
                    child: Text("Add user 2110969M"),
                    onPressed: () async {
                      var data = await rootBundle.load("assets/default.png");
                      final buffer = data.buffer;
                      String dir =
                          (await getApplicationDocumentsDirectory()).path;
                      File tempFile = await new File("$dir/default.png")
                          .writeAsBytes(buffer.asUint8List(
                              data.offsetInBytes, data.lengthInBytes));

                      db.addUser(User(
                        userHeightBottom: "15",
                        userHeightTop: "19",
                        userId: null,
                        userInitialPush: "51.0",
                        userNotifEvent: "1",
                        userLastLogin: "2021-02-24 15:18:54.051196Z",
                        userMacAddress: "78:DB:2F:BF:1F:72",
                        userSerialNumber: "gBs2110969M",
                        userMode: "0",
                        userName: "Test",
                        userPic: tempFile.path,
                      ));

                      setState(() {});
                    },
                  ),
                ),
              ),
              Divider(),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AutoSizeText("Spineo Home"),
                  AutoSizeText(
                    "© 2021 Genourob\n All rights reserved.",
                  ),
                  AutoSizeText(" V.$softwareVersion"),
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
                        AppLocalizations.of(context).translate('chargement')))
              ],
            );
          }
        },
      ),
    );
  }
}
