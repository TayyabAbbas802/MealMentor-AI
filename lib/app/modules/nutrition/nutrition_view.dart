import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import 'nutrition_controller.dart';

class NutritionView extends GetView<NutritionController> {
  const NutritionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Stats'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateSelector(),
              const SizedBox(height: 24),
              _buildCalorieCard(),
              const SizedBox(height: 24),
              const Text(
                'Macros Distribution',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildPieChart(),
              const SizedBox(height: 32),
              const Text(
                'Daily Breakdown',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildMacroCards(),
              const SizedBox(height: 32),
              const Text(
                'Weekly Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildWeeklyChart(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDateSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: controller.previousDay,
            ),
            Obx(() => Text(
              DateFormat('EEEE, MMM dd').format(controller.selectedDate.value),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            )),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: controller.nextDay,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Calories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 150,
                  width: 150,
                  child: CircularProgressIndicator(
                    value: controller.caloriesPercentage / 100,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.caloriesConsumed.value.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'of ${controller.caloriesGoal.value.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            )),
            const SizedBox(height: 16),
            Obx(() => Text(
              '${(controller.caloriesGoal.value - controller.caloriesConsumed.value).toStringAsFixed(0)} cal remaining',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          height: 250,
          child: Obx(() => PieChart(
            PieChartData(
              sections: controller.getPieChartSections(),
              sectionsSpace: 2,
              centerSpaceRadius: 0,
              borderData: FlBorderData(show: false),
            ),
          )),
        ),
      ),
    );
  }

  Widget _buildMacroCards() {
    return Column(
      children: [
        Obx(() => _buildMacroCard(
          'Protein',
          controller.proteinConsumed.value,
          controller.proteinGoal.value,
          controller.proteinPercentage,
          AppColors.primary,
          Icons.egg,
        )),
        const SizedBox(height: 12),
        Obx(() => _buildMacroCard(
          'Carbs',
          controller.carbsConsumed.value,
          controller.carbsGoal.value,
          controller.carbsPercentage,
          AppColors.secondary,
          Icons.rice_bowl,
        )),
        const SizedBox(height: 12),
        Obx(() => _buildMacroCard(
          'Fat',
          controller.fatConsumed.value,
          controller.fatGoal.value,
          controller.fatPercentage,
          const Color(0xFFE91E63),
          Icons.water_drop,
        )),
      ],
    );
  }

  Widget _buildMacroCard(
      String title,
      double consumed,
      double goal,
      double percentage,
      Color color,
      IconData icon,
      ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${consumed.toStringAsFixed(1)}g / ${goal.toStringAsFixed(1)}g',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Calorie Trend',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: Obx(() => BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 2500,
                  barGroups: controller.getWeeklyCalorieData(),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          return Text(
                            days[value.toInt()],
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }
}
