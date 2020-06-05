import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/AppLocalizations.dart';
import 'package:gbsalternative/BluetoothSync.dart';
import 'package:gbsalternative/DatabaseHelper.dart';
import 'package:gbsalternative/Login.dart';
import 'package:gbsalternative/MainTitle.dart';
import 'package:gbsalternative/ManageProfile.dart';
import 'package:gbsalternative/Register.dart';
import 'package:gbsalternative/Swimmer/Swimmer.dart';
import 'package:provider/provider.dart';

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


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

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
            //messageIn == "deconnexion" ? MainTitle(userIn: user, messageIn: 9, appLanguage: appLanguage,):

            //TODO -> Stateful into dispose ? Ou navigator
            page == "login" ? Login(appLanguage: appLanguage):
            page == "register" ? Register(appLanguage: appLanguage):
            //page == "menu" ? Menu(curUser: user, appLanguage: appLanguage, message: messageIn,):
            page == "swimmer" ? Swimmer(user: user, appLanguage: appLanguage):
            page == "manageProfile" ? ManageProfile(curUser: user, appLanguage: appLanguage):
            page == "bluetoothSync" ? BluetoothSync(curUser: user, inputMessage: messageIn, appLanguage: appLanguage,):
            page == "mainTitle" ? MainTitle(userIn: user, messageIn: int.parse(messageIn), appLanguage: appLanguage,): Container()
        );
      }),
    );
  }
}
