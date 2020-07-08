import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/AppLocalizations.dart';
import 'package:gbsalternative/BluetoothManager.dart';
//import 'file:///C:/Users/Pierrick/Documents/Entreprise/Stage/Genourob/gBs/gbs_alternative/lib/Backup/BluetoothSync_shield.dart';
import 'package:gbsalternative/DatabaseHelper.dart';
import 'package:gbsalternative/FAQ.dart';
import 'package:gbsalternative/FirstPush.dart';
import 'package:gbsalternative/Login.dart';
import 'package:gbsalternative/MainTitle.dart';
import 'package:gbsalternative/ManageProfile.dart';
import 'package:gbsalternative/Plane/Plane.dart';
import 'package:gbsalternative/Register.dart';
import 'package:gbsalternative/Swimmer/Swimmer.dart';
import 'package:provider/provider.dart';


/*Classe LoadPage
* Est appelée à chaque changement de page pour garder la langue d'affichage*/
class LoadPage extends StatefulWidget{
  final AppLanguage appLanguage;
  final String page;
  final User user;
  final String messageIn;

  LoadPage({
    @required this.appLanguage,
    @required this.page,
    @required this.user,
    @required this.messageIn,
  });

  @override
  _LoadPage createState() => _LoadPage(appLanguage: appLanguage, messageIn: messageIn, page: page, user: user);

}


class _LoadPage extends State<LoadPage> {
  final AppLanguage appLanguage;
  final String page;
  final User user;
  final String messageIn;

  _LoadPage({this.appLanguage, this.page, this.user, this.messageIn});


/*  @override
  void dispose() {

    super.dispose();
  }*/

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider.value(
      value: appLanguage,
      child: Consumer<AppLanguage>(builder: (context, model, child) {
        return MaterialApp(
            locale: model.appLocal != null ? model.appLocal : "",
            supportedLocales: [
              Locale('en', 'US'),
              Locale('fr', 'FR'),
            ],
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            home:
            page == "FAQ" ? FAQ(inputMessage: messageIn, appLanguage: appLanguage):
            page == "firstPush" ? FirstPush(user: user, inputMessage: messageIn, appLanguage: appLanguage):
            page == "login" ? Login(appLanguage: appLanguage):
            page == "mainTitle" ? MainTitle(userIn: user, messageIn: int.parse(messageIn), appLanguage: appLanguage,):
            page == "manageProfile" ? ManageProfile(curUser: user, appLanguage: appLanguage):
            page == "plane" ? Plane(user: user, appLanguage: appLanguage):
            page == "register" ? Register(appLanguage: appLanguage):
            page == "swimmer" ? Swimmer(user: user, appLanguage: appLanguage): Container()
        );
      }),
    );
  }
}
