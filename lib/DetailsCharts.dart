import 'package:flutter/material.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/AppLocalizations.dart';
import 'package:gbsalternative/DatabaseHelper.dart';
import 'package:gbsalternative/DrawCharts.dart';
import 'package:gbsalternative/LoadPage.dart';

class DetailsCharts extends StatefulWidget {
  final AppLanguage appLanguage;
  final List<Scores> scores;
  final User user;
  final String messageIn;

  DetailsCharts(
      {@required this.appLanguage,
      @required this.scores,
      @required this.user,
      @required this.messageIn});

  @override
  _DetailsCharts createState() =>
      _DetailsCharts(appLanguage, scores, user, messageIn);
}

class _DetailsCharts extends State<DetailsCharts> {
  AppLanguage appLanguage;
  List<Scores> scores;
  User user;
  String messageIn;

  _DetailsCharts(AppLanguage _appLanguage, List<Scores> _scores, User _user,
      String _messageIn) {
    appLanguage = _appLanguage;
    scores = _scores;
    user = _user;
    messageIn = _messageIn;
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Material(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.all(20),
        width: screenSize.width * 0.8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            //Swimmer
            messageIn == "0"
                ? Text(
                    AppLocalizations.of(context).translate('stat_nageur'),
                  )
                //Plane
                : messageIn == "1"
                    ? Text(
                        AppLocalizations.of(context).translate('stat_avion'),
                      )
                    : Container(),
            DrawCharts(data: scores),
            RaisedButton(
              child: Text(
                AppLocalizations.of(context).translate('retour'),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoadPage(
                      appLanguage: appLanguage,
                      page: "mainTitle",
                      user: user,
                      messageIn: "0",
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
