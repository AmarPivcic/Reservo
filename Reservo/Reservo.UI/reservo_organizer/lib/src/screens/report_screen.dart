import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:reservo_organizer/src/models/report_models/report_models.dart';
import 'package:reservo_organizer/src/providers/report_provider.dart';
import 'package:reservo_organizer/src/screens/master_screen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      showBackButton: true,
      child: ChangeNotifierProvider(
        create: (_) => ReportProvider()..loadReports(),
        child: Consumer<ReportProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildViewToggle(
                          provider: provider,
                          view: ReportView.monthly,
                          label: "Monthly",
                        ),
                        const SizedBox(width: 8),
                        _buildViewToggle(
                          provider: provider,
                          view: ReportView.daily,
                          label: "Daily",
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DropdownButton<int>(
                          value: provider.year,
                          dropdownColor: Colors.grey[900],
                          style: const TextStyle(color: Colors.white),
                          items: List.generate(5, (i) => DateTime.now().year - i)
                              .map((y) => DropdownMenuItem(
                                  value: y, child: Text("$y")))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) provider.setYear(value);
                          },
                        ),

                        const SizedBox(width: 16),

                        if (provider.currentView == ReportView.daily)
                          DropdownButton<int>(
                            value: provider.month,
                            dropdownColor: Colors.grey[900],
                            style: const TextStyle(color: Colors.white),
                            items: List.generate(12, (i) => i + 1)
                                .map((m) => DropdownMenuItem(
                                    value: m, child: Text("$m")))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) provider.setMonth(value);
                            },
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      height: 250,
                      child: PieChart(
                        PieChartData(
                          sections: provider.categories.map((c) {
                            return PieChartSectionData(
                              value: c.profit,
                              color: Colors.primaries[
                                  provider.categories.indexOf(c) %
                                      Colors.primaries.length],
                              title:
                                  "${c.category}\n${c.profit.toStringAsFixed(0)}",
                              titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                              radius: 120,
                            );
                          }).toList(),
                          sectionsSpace: 2,
                          centerSpaceRadius: 0,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Text(
                      "Total Profit: €${_calculateTotal(provider).toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),


                    SizedBox(
                      height: 250,
                      child: LineChart(
                        LineChartData(
                          backgroundColor: Colors.transparent,
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            drawHorizontalLine: true,
                            getDrawingHorizontalLine: (value) =>
                                const FlLine(color: Colors.white12, strokeWidth: 1),
                            getDrawingVerticalLine: (value) =>
                                const FlLine(color: Colors.white12, strokeWidth: 1),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 70,
                                getTitlesWidget: (value, meta) => Text(
                                  value.toStringAsFixed(1), 
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles:
                                  SideTitles(showTitles: false), 
                            ),
                            topTitles: AxisTitles(
                              sideTitles:
                                  SideTitles(showTitles: false), 
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  if (provider.currentView ==
                                      ReportView.monthly) {
                                    const months = [
                                      'Jan',
                                      'Feb',
                                      'Mar',
                                      'Apr',
                                      'May',
                                      'Jun',
                                      'Jul',
                                      'Aug',
                                      'Sep',
                                      'Oct',
                                      'Nov',
                                      'Dec'
                                    ];
                                    int index = value.toInt() - 1;
                                    if (index >= 0 && index < 12) {
                                      return Text(
                                        months[index],
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 10),
                                      );
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  } else {
                                    return Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 10),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(color: Colors.white24),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              isCurved: true,
                              color: Colors.blueAccent,
                              barWidth: 3,
                              dotData: FlDotData(show: true),
                              spots: _getLineSpots(provider),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<FlSpot> _getLineSpots(ReportProvider provider) {
    List<FlSpot> spots = [];

    if (provider.currentView == ReportView.monthly) {
      final monthNumbers = List.generate(12, (i) => i + 1);
      final dataMap = {
        for (var d in provider.lineData.cast<ProfitByMonth>()) d.month: d.profit
      };

      for (var month in monthNumbers) {
        final profit = dataMap[month] ?? 0;
        spots.add(FlSpot(month.toDouble(), profit));
      }
    } else {
      final daysInMonth = DateTime(provider.year, provider.month + 1, 0).day;
      final dataMap = {
        for (var d in provider.lineData.cast<ProfitByDay>()) d.day: d.profit
      };

      for (int d = 1; d <= daysInMonth; d++) {
        final profit = dataMap[d] ?? 0;
        spots.add(FlSpot(d.toDouble(), profit));
      }
    }

    return spots;
  }

  double _calculateTotal(ReportProvider provider) {
    if (provider.currentView == ReportView.monthly) {
      return provider.lineData
          .cast<ProfitByMonth>()
          .fold(0.0, (sum, item) => sum + item.profit);
    } else {
      return provider.lineData
          .cast<ProfitByDay>()
          .fold(0.0, (sum, item) => sum + item.profit);
    }
  }

  Widget _buildViewToggle({
    required ReportProvider provider,
    required ReportView view,
    required String label,
  }) {
    final isSelected = provider.currentView == view;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => provider.switchView(view),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blueAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected ? Colors.blueAccent : Colors.white54,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }



}
