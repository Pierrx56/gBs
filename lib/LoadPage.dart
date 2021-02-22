import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/AppLocalizations.dart';
import 'package:gbsalternative/BluetoothManager.dart';
//import 'file:///C:/Users/Pierrick/Documents/Entreprise/Stage/Genourob/gBs/gbs_alternative/lib/Backup/BluetoothSync_shield.dart';
import 'package:gbsalternative/DatabaseHelper.dart';
import 'package:gbsalternative/DetailsCharts.dart';
import 'package:gbsalternative/DrawCharts.dart';
import 'package:gbsalternative/FAQ.dart';
import 'package:gbsalternative/MaxPush.dart';
import 'package:gbsalternative/Login.dart';
import 'package:gbsalternative/MainTitle.dart';
import 'package:gbsalternative/ManageProfile.dart';
import 'package:gbsalternative/Plane/Plane.dart';
import 'package:gbsalternative/Register.dart';
import 'package:gbsalternative/CarGame/Car.dart';
import 'package:gbsalternative/SelectGame.dart';
import 'package:gbsalternative/SelectStatistic.dart';
import 'package:gbsalternative/Swimmer/Swimmer.dart';
import 'package:gbsalternative/TempGame/Temp.dart';
import 'package:provider/provider.dart';

//Déclaration du nom des pages
String detailsCharts = "DetailsCharts";
String faq = "FAQ";
String firstPush = "MaxPush";
String login = "Login";
String mainTitle = "MainTitle";
String manageProfile = "ManageProfile";
String plane = "Plane";
String car = "Car";
String temp = "Temp";
String register = "Register";
String selectGame = "SelectGame";
String selectStatistic = "SelectStatistic";
String swimmer = "Swimmer";

/*Classe LoadPage
* Est appelée à chaque changement de page pour garder la langue d'affichage
* !! Il faut ajouter le nom de la page au dessus pour pouvoir l'appeler par la suite !!
* */
class LoadPage extends StatefulWidget{
  final AppLanguage appLanguage;
  final String page;
  final User user;
  final String messageIn;
  final List<Scores> scores;

  LoadPage({
    @required this.appLanguage,
    @required this.page,
    @required this.user,
    @required this.messageIn,
    this.scores
  });

  @override
  _LoadPage createState() => _LoadPage(appLanguage: appLanguage, messageIn: messageIn, page: page, user: user, scores: scores);

}


class _LoadPage extends State<LoadPage> {
  final AppLanguage appLanguage;
  final String page;
  final User user;
  final String messageIn;
  final List<Scores> scores;

  _LoadPage({this.appLanguage, this.page, this.user, this.messageIn, this.scores});


  @override
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      //Disable physical back button to avoid page navigation bugs
      onWillPop: () {
        return Future.value(false);
      },
      child: ChangeNotifierProvider.value(
        value: appLanguage,
        child: Consumer<AppLanguage>(builder: (context, model, child) {
          return MaterialApp(
              debugShowCheckedModeBanner: false,
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
              page == car ? Car(user: user, appLanguage: appLanguage, level: messageIn):
              page == detailsCharts ? DetailsCharts(appLanguage: appLanguage, scores: scores, user: user, messageIn: messageIn,):
              page == faq ? FAQ(user: user, inputMessage: messageIn, appLanguage: appLanguage):
              page == firstPush ? MaxPush(user: user, inputMessage: messageIn, appLanguage: appLanguage):
              page == login ? Login(appLanguage: appLanguage):
              page == mainTitle ? MainTitle(userIn: user, messageIn: messageIn, appLanguage: appLanguage,):
              page == manageProfile ? ManageProfile(curUser: user, appLanguage: appLanguage):
              page == plane ? Plane(user: user, appLanguage: appLanguage, level: messageIn):
              page == register ? Register(appLanguage: appLanguage):
              page == selectGame ? SelectGame(appLanguage: appLanguage, user: user, inputMessage: messageIn):
              page == selectStatistic ? SelectStatistic(appLanguage: appLanguage, user: user, inputMessage: messageIn):
              page == swimmer ? Swimmer(user: user, appLanguage: appLanguage, level: messageIn):
              page == temp ? Temp(user: user, appLanguage: appLanguage, level: messageIn): Container()
          );
        }),
      ),
    );
  }
}
