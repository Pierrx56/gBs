import 'dart:math' as math;

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
  List<Scores> scoresSorted;
  User user;
  String messageIn;
  int smallestScore;
  int largestScore;
  String average;
  String dayLargestScore;

  _DetailsCharts(AppLanguage _appLanguage, List<Scores> _scores, User _user,
      String _messageIn) {
    appLanguage = _appLanguage;
    scores = _scores;
    user = _user;
    messageIn = _messageIn;
  }

  @override
  void initState() {
    scoresSorted = scores;
    dataProcess();
    super.initState();
  }

  void dataProcess() {
    largestScore = 0;
    dayLargestScore = "";
    double tempAverage = 0.0;

    var listScore = scoresSorted.asMap().entries.map((entry) {
      final int score = entry.value.score;
      return score;
    });
    var listDate = scoresSorted.asMap().entries.map((entry) {
      final String date = entry.value.date;
      return date;
    });

    for (int i = 0; i < listScore.length; i++) {
      if (largestScore < listScore.toList()[i]) {
        largestScore = listScore.toList()[i];
        dayLargestScore = listDate.toList()[i];
      }

      //Ne prend que les 10 derniers score
      if((listScore.length - i) <= 10) {
        tempAverage += listScore.toList()[i];
      }
    }

    average = (tempAverage / listScore.length).toStringAsFixed(1);

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
              width: screenSize.width / 2,
              //alignment: Alignment.bottomCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Nombre de parties jouées: ${scores.length}",
                    style: textStyle,
                  ),
                  Text(
                    "Score maximal atteint: $largestScore",
                    style: textStyle,
                  ),
                  Text(
                    "C'était le : $dayLargestScore",
                    style: textStyle,
                  ),
                  Text(
                    "Moyenne des 10 dernières parties : $average",
                    style: textStyle,
                  ),
                  RaisedButton(
                    child: Text(
                      AppLocalizations.of(context).translate('retour'),
                      style: textStyle,
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
                  /*RaisedButton(
                    child: Text(
                      "Refresh",
                      style: textStyle,
                    ),
                    onPressed: () {
                      getLargestValue();
                      setState(() {});
                    },
                  ),*/
                ],
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              height: screenSize.height,
              width: screenSize.width / 2,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    messageIn == "$ID_SWIMMER_ACTIVITY"
                        ? Text(
                            AppLocalizations.of(context)
                                .translate('stat_nageur'),
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
                      height: screenSize.height * 0.75,
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
