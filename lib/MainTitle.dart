import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/AppLocalizations.dart';
import 'package:gbsalternative/BluetoothSync.dart';
import 'package:gbsalternative/ManageProfile.dart';

import 'DatabaseHelper.dart';
import 'Login.dart';
import 'Menu.dart';
import 'Register_bk.dart';

class MainTitle extends StatefulWidget {
  final AppLanguage appLanguage;
  final User userIn;
  final int messageIn;

  MainTitle({
    Key key,
    @required this.appLanguage,
    @required this.userIn,
    @required this.messageIn,
  }) : super(key: key);

  @override
  _MainTitle createState() => _MainTitle(appLanguage, userIn, messageIn);
}

class _MainTitle extends State<MainTitle> {
  Widget menuPage;
  Widget settingsPage;
  Widget bluetoothPage;
  Widget loginPage;
  PageController _c;

  AppLanguage appLanguage;
  User user;
  int message;

  //0:menu 1:settings 2:bluetooth
  static int defaultIndex = 2;
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

    if (appLanguage != null)
      menuPage = Menu(
        curUser: user,
        appLanguage: appLanguage,
      );

    settingsPage = ManageProfile(
      curUser: user,
    );
    bluetoothPage = BluetoothSync(
      curUser: user,
    );
    loginPage = MyApp(
      appLanguage: appLanguage,
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;

        if (appLanguage != null)
          menuPage = Menu(
            curUser: user,
            appLanguage: appLanguage,
          );

        settingsPage = ManageProfile(
          curUser: user,
        );
        bluetoothPage = BluetoothSync(
          curUser: user,
        );
        loginPage = MyApp(
          appLanguage: appLanguage,
        );
      });
    }

    if (message != defaultIndex) {
      _selectedIndex = message;
      message = defaultIndex;
    }

    List<Widget> _widgetOptions = <Widget>[
      menuPage,
      settingsPage,
      bluetoothPage,
    ];

    return MaterialApp(
      key: _scaffoldKey,
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          bottomNavigationBar: BottomNavigationBar(
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
