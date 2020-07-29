import 'package:flutter/material.dart';
import 'package:gbsalternative/AppLanguage.dart';
import 'package:gbsalternative/AppLocalizations.dart';
import 'package:gbsalternative/DatabaseHelper.dart';
import 'package:gbsalternative/DrawCharts.dart';
import 'package:gbsalternative/LoadPage.dart';
import 'package:gbsalternative/Login.dart';

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
        width: screenSize.width,
        height: screenSize.height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[

            Container(
              height: screenSize.height,
              width: screenSize.width/2,
              alignment: Alignment.bottomCenter,
              child: Column(
                children: <Widget>[
                  Spacer(),
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
                            page: selectStatistic,
                            user: user,
                            messageIn: "0",
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              height: screenSize.height,
              width: screenSize.width/2,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    messageIn == "$ID_SWIMMER_ACTIVITY"
                        ? Text(
                            AppLocalizations.of(context).translate('stat_nageur'),
                            style: textStyle,
                          )
                        //Plane
                        : messageIn == "$ID_PLANE_ACTIVITY"
                            ? Text(
                                AppLocalizations.of(context)
                                    .translate('stat_avion'),
                                style: textStyle,
                              )
                            : Container(),
                    Container(
                      child: DrawCharts(data: scores),
                      height: screenSize.height / 2,
                      width: screenSize.width / 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
