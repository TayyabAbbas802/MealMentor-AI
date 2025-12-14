
// lib/presentation/widgets/set_timer_widget.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SetTimerWidget extends StatefulWidget {
  final int initialSeconds;
  final VoidCallback onCompleted;
  final Function(int)? onTick;
  final bool autoStart;

  const SetTimerWidget({
    required this.initialSeconds,
    required this.onCompleted,
    this.onTick,
    this.autoStart = true,
    Key? key,
  }) : super(key: key);

  @override
  State<SetTimerWidget> createState() => _SetTimerWidgetState();
}

class _SetTimerWidgetState extends State<SetTimerWidget> {
  late int _remainingSeconds;
  late int _totalSeconds;
  bool _isRunning = false;
  late Stopwatch _stopwatch;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialSeconds;
    _totalSeconds = widget.initialSeconds;
    _stopwatch = Stopwatch();

    if (widget.autoStart) {
      _startTimer();
    }
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });
    _stopwatch.start();

    Future.doWhile(() async {
      if (!_isRunning) return false;

      await Future.delayed(const Duration(seconds: 1));

      if (mounted && _isRunning) {
        setState(() {
          _remainingSeconds--;
          widget.onTick?.call(_remainingSeconds);

          if (_remainingSeconds <= 0) {
            _stopTimer();
            widget.onCompleted();
          }
        });
      }

      return _isRunning && _remainingSeconds > 0;
    });
  }

  void _stopTimer() {
    setState(() {
      _isRunning = false;
    });
    _stopwatch.stop();
  }

  void _resetTimer() {
    setState(() {
      _remainingSeconds = widget.initialSeconds;
      _isRunning = false;
    });
    _stopwatch.reset();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  double _getProgress() {
    return (_totalSeconds - _remainingSeconds) / _totalSeconds;
  }

  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Circular timer display
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.1),
            border: Border.all(
              color: AppColors.primary,
              width: 4,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Progress indicator
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: _getProgress(),
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _remainingSeconds <= 10
                        ? AppColors.error
                        : AppColors.primary,
                  ),
                  strokeWidth: 6,
                ),
              ),
              // Timer text
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatTime(_remainingSeconds),
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: _remainingSeconds <= 10
                          ? AppColors.error
                          : AppColors.primary,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Rest',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Control buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _isRunning ? _stopTimer : _startTimer,
              icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
              label: Text(_isRunning ? 'Pause' : 'Start'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: _resetTimer,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Skip button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              _stopTimer();
              widget.onCompleted();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ready to Continue'),
          ),
        ),
      ],
    );
  }
}
