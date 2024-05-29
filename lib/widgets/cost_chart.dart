import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../models/player.dart';

class CostChart extends StatelessWidget {
  final List<Player> players;
  final Function(Player) calculateCost;

  CostChart({required this.players, required this.calculateCost});

  @override
  Widget build(BuildContext context) {
    List<charts.Series<Player, String>> series = [
      charts.Series(
        id: 'Costs',
        data: players,
        domainFn: (Player player, _) => player.name,
        measureFn: (Player player, _) => calculateCost(player).toDouble(),
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      ),
    ];

    return Container(
      height: 300,
      padding: EdgeInsets.all(20),
      child: charts.BarChart(
        series,
        animate: true,
        animationDuration: Duration(seconds: 1),
        defaultRenderer: charts.BarRendererConfig(
          // Menggunakan warna default jika ada masalah dengan tema teks
          barRendererDecorator: charts.BarLabelDecorator<String>(
            labelPosition: charts.BarLabelPosition.inside,
            labelAnchor: charts.BarLabelAnchor.middle,
            insideLabelStyleSpec: charts.TextStyleSpec(
              color: charts.Color.black,
            ),
          ),
        ),
      ),
    );
  }
}
