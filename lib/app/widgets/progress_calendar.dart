

// lib/presentation/widgets/progress_calendar.dart
import 'package:flutter/material.dart';
import '../modules/progress/progress_controller.dart';
import '../theme/app_colors.dart';

class ProgressCalendar extends StatefulWidget {
  final String userId;
  final String planId;
  final ProgressController controller;

  const ProgressCalendar({
    required this.userId,
    required this.planId,
    required this.controller,
    Key? key,
  }) : super(key: key);

  @override
  State<ProgressCalendar> createState() => _ProgressCalendarState();
}

class _ProgressCalendarState extends State<ProgressCalendar> {
  late DateTime _selectedMonth;
  late Map<DateTime, int> _calendarData;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    _loadCalendarData();
  }

  Future<void> _loadCalendarData() async {
    final data =
    await widget.controller.getCalendarData(widget.userId, widget.planId);
    setState(() {
      _calendarData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  _selectedMonth =
                      DateTime(_selectedMonth.year, _selectedMonth.month - 1);
                });
              },
            ),
            Text(
              _getMonthString(_selectedMonth),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  _selectedMonth =
                      DateTime(_selectedMonth.year, _selectedMonth.month + 1);
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Calendar grid
        _buildCalendarGrid(),
        const SizedBox(height: 12),
        // Legend
        _buildLegend(),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDay =
    DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final startingWeekday = firstDay.weekday;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: startingWeekday + daysInMonth,
      itemBuilder: (context, index) {
        if (index < startingWeekday - 1) {
          return const SizedBox();
        }

        final day = index - startingWeekday + 2;
        final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
        final workoutCount = _calendarData[date] ?? 0;

        return _buildDayCell(date, workoutCount);
      },
    );
  }

  Widget _buildDayCell(DateTime date, int workoutCount) {
    Color backgroundColor;

    if (workoutCount == 0) {
      backgroundColor = AppColors.surfaceVariant;
    } else if (workoutCount == 1) {
      backgroundColor = AppColors.primary.withOpacity(0.5);
    } else {
      backgroundColor = AppColors.primary;
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.border,
          width: 0.5,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              date.day.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: workoutCount > 0
                    ? Colors.white
                    : AppColors.textSecondary,
              ),
            ),
            if (workoutCount > 0)
              Text(
                '$workoutCount',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      children: [
        _buildLegendItem('No workouts', AppColors.surfaceVariant),
        _buildLegendItem('1 workout', AppColors.primary.withOpacity(0.5)),
        _buildLegendItem('2+ workouts', AppColors.primary),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _getMonthString(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
