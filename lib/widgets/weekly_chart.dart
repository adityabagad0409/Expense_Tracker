import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

class WeeklyChart extends StatelessWidget {
  final List<Expense> expenses;

  const WeeklyChart({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    // 1. Prepare Data: Calculate totals for the last 7 days
    final List<double> dailyTotals = List.filled(7, 0.0);
    final now = DateTime.now();
    
    // Create a list of the last 7 dates to label the X-axis
    final List<DateTime> last7Days = List.generate(7, (index) {
      return now.subtract(Duration(days: 6 - index));
    });

    for (var expense in expenses) {
      final difference = now.difference(expense.dateTime).inDays;
      if (difference >= 0 && difference < 7) {
        // Map: 6 days ago -> index 0, Today -> index 6
        final index = 6 - difference; 
        dailyTotals[index] += expense.amount;
      }
    }

    // 2. Create Spots for the Chart
    List<FlSpot> spots = [];
    for (int i = 0; i < 7; i++) {
      spots.add(FlSpot(i.toDouble(), dailyTotals[i]));
    }

    return AspectRatio(
      aspectRatio: 1.70,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.grey.shade200, blurRadius: 10, spreadRadius: 5),
          ],
        ),
        padding: const EdgeInsets.only(right: 18, left: 12, top: 24, bottom: 12),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < 7) {
                      // Show "Mon", "Tue" etc.
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          DateFormat('E').format(last7Days[index])[0], // First letter of day
                          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    if (value == 0) return const Text(''); 
                    // Abbreviate numbers: 1000 -> 1k
                    if (value >= 1000) return Text('${(value / 1000).toStringAsFixed(0)}k', style: const TextStyle(fontSize: 10));
                    return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: 6,
            minY: 0,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: Colors.blueAccent,
                barWidth: 4,
                isStrokeCapRound: true,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.blueAccent.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
