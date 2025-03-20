import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SensorChart extends StatelessWidget {
  final List<double> data;
  final Color color;
  final String label;
  final double minY;
  final double maxY;

  const SensorChart({
    super.key,
    required this.data,
    required this.color,
    required this.label,
    this.minY = 0,
    this.maxY = 100,
  });

  @override
  Widget build(BuildContext context) {
    return data.isEmpty
        ? Center(child: Text('Henüz veri yok'))
        : LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 10,
          verticalInterval: 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 5,
              getTitlesWidget: (value, meta) {
                // X ekseni etiketleri
                if (value % 5 == 0 && value < data.length) {
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      '${value.toInt()}',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return SideTitleWidget(
                  meta: meta,
                  child: const Text(''),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 20,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    '${value.toInt()}',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 10,
                    ),
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        minX: 0,
        maxX: data.length.toDouble() - 1,
        minY: getMinY(),
        maxY: getMaxY(),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final index = barSpot.x.toInt();
                if (index >= 0 && index < data.length) {
                  return LineTooltipItem(
                    data[index].toStringAsFixed(1),
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
                return null;
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
          touchSpotThreshold: 20,
        ),
        lineBarsData: [
          LineChartBarData(
            spots: _createSpots(),
            isCurved: true,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _createSpots() {
    return List.generate(data.length, (index) {
      return FlSpot(index.toDouble(), data[index]);
    });
  }

  double getMinY() {
    if (data.isEmpty) return minY;
    double min = data.reduce((a, b) => a < b ? a : b);
    return min < minY ? min * 0.9 : minY;
  }

  double getMaxY() {
    if (data.isEmpty) return maxY;
    double max = data.reduce((a, b) => a > b ? a : b);
    return max > maxY ? max * 1.1 : maxY;
  }
}