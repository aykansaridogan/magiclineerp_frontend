import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EnergyChart extends StatefulWidget {
  @override
  _EnergyChartState createState() => _EnergyChartState();
}

class _EnergyChartState extends State<EnergyChart> {
  late Future<List<EnergyData>> _energyDataFuture;

  @override
  void initState() {
    super.initState();
    _energyDataFuture = fetchEnergyData();
  }

  Future<List<EnergyData>> fetchEnergyData() async {
    final response = await http.get(Uri.parse('https://magiclinesarj.com/Admin/AdminDashboard/GetChartData'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => EnergyData.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load energy data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aylık Enerji Tüketimi'),
      ),
      body: FutureBuilder<List<EnergyData>>(
        future: _energyDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          }

          // Extract the data
          final List<EnergyData> data = snapshot.data!;
          final List<FlSpot> spots = data.map((e) => FlSpot(e.month.toDouble(), e.totalKwh)).toList();
          final double minX = spots.map((e) => e.x).reduce((a, b) => a < b ? a : b);
          final double maxX = spots.map((e) => e.x).reduce((a, b) => a > b ? a : b);
          final double minY = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
          final double maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 750,
              height: 500,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(value.toStringAsFixed(0), style: TextStyle(fontSize: 14)),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          final month = value.toInt();
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(_getMonthName(month), style: TextStyle(fontSize: 14)),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  minX: minX - 1,
                  maxX: maxX + 1,
                  minY: minY - 0.1 * (maxY - minY),
                  maxY: maxY + 0.1 * (maxY - minY),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getMonthName(int month) {
    List<String> months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}

class EnergyData {
  final int year;
  final int month;
  final double totalKwh;

  EnergyData({required this.year, required this.month, required this.totalKwh});

  factory EnergyData.fromJson(Map<String, dynamic> json) {
    return EnergyData(
      year: json['year'] ?? 0,
      month: json['month'] ?? 1,
      totalKwh: (json['totalKwh'] ?? 0.0).toDouble(),
    );
  }
}
