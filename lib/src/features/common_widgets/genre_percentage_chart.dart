import 'package:flutter/material.dart';
import 'package:charts_flutter_new/flutter.dart' as charts;

class GenrePercentageGraph extends StatelessWidget {
  final List<charts.Series<MapEntry<String, double>, String>> seriesList;
  final bool animate;

  GenrePercentageGraph(this.seriesList, {required this.animate});

  @override
  Widget build(BuildContext context) {
    return charts.BarChart(
      seriesList,
      animate: animate,
      barGroupingType: charts.BarGroupingType.grouped,
      vertical: false,
      defaultRenderer: charts.BarRendererConfig<String>(),
      behaviors: [
        charts.SeriesLegend(
          position: charts.BehaviorPosition.bottom,
          desiredMaxColumns: 2,
          cellPadding: EdgeInsets.all(4.0),
          showMeasures: true,
        ),
      ],
    );
  }

  static List<charts.Series<MapEntry<String, double>, String>> createSampleData(Map<String, double> genrePercentage) {
    final List<charts.Series<MapEntry<String, double>, String>> data = [];

    genrePercentage.forEach((genre, value) {
      data.add(charts.Series<MapEntry<String, double>, String>(
        id: genre,
        domainFn: (_, index) => genre,
        measureFn: (entry, _) => entry.value,
        data: [MapEntry(genre, value)],
      ));
    });

    return data;
  }
}
