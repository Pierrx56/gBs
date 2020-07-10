import 'package:flutter/widgets.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'DatabaseHelper.dart';

/*Classe Scores*/
class Scores {
  final int userId;
  final int scoreId;
  final int activityId;
  final String date;
  final int score;

  Scores(this.scoreId, this.activityId, this.userId, this.date, this.score);
}

/*Classe qui gère la création et l'affichage de graphiques*/
class DrawCharts extends StatelessWidget {
/*
  final List<charts.Series> seriesList;
  final bool animate;
  DrawCharts(this.seriesList, {this.animate});
*/

  bool animate = true;

  final List<Scores> data;

  DrawCharts({@required this.data});

/*
  /// Creates a [BarChart] with sample data and no transition.
  factory DrawCharts.withSampleData(List<Scores> data) {
    return new DrawCharts(
      _createSampleData(data),
      // Disable animations for image tests.
      animate: false,
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<Scores, String>> _createSampleData(
      List<Scores> data) {
    return [
      new charts.Series<Scores, String>(
        id: 'Scores',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (Scores sales, _) => sales.date,
        measureFn: (Scores sales, _) => sales.score,
        data: data,
      )
    ];
  }*/

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    List<charts.Series<Scores, String>> series = [
      new charts.Series<Scores, String>(
        id: 'Scores',
        data: data,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (Scores score, _) => score.date,
        measureFn: (Scores score, _) => score.score,
      )
    ];

    return Container(
      height: screenSize.height * 0.4,
      child: charts.BarChart(
        series,
        animate: animate,
        domainAxis: new charts.OrdinalAxisSpec(
          renderSpec: charts.SmallTickRendererSpec(labelRotation: 60,),
        ),

      ),
    );
  }
}
