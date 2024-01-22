import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class PieChartWidget extends StatelessWidget {
  final Map<String, double> data;

  const PieChartWidget(this.data, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PieChart(
          dataMap: data,
          chartRadius: MediaQuery.of(context).size.width / 2.7,
          chartType: ChartType.disc,
          centerText: "", // Remove the center text
          legendOptions: const LegendOptions(
            showLegendsInRow: true,
            legendPosition: LegendPosition.bottom,
            showLegends: true,
            legendTextStyle: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
