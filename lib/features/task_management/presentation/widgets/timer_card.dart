import 'package:flutter/material.dart';

import 'task_timer_service.dart';

class TimerCard extends StatefulWidget {
  final String taskId;
  final String taskTitle;

  const TimerCard({Key? key, required this.taskId, required this.taskTitle})
      : super(key: key);

  @override
  _TimerCardState createState() => _TimerCardState();
}

class _TimerCardState extends State<TimerCard> {
  late TaskTimerService _timerService;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeTimer();
  }

  Future<void> _initializeTimer() async {
    _timerService = TaskTimerService(widget.taskId);

    await _timerService.initialize();

    setState(() {
      _isInitialized = true;
    });
  }

  void _toggleTimer() {
    setState(() {
      if (_timerService.isRunning) {
        _timerService.stop();
      } else {
        _timerService.start();
      }
    });
  }

  void _resetTimer() {
    setState(() {
      _timerService.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.taskTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            StreamBuilder<Duration>(
              stream: _timerService.timerStream,
              initialData: _timerService.getElapsedTime(),
              builder: (context, snapshot) {
                return Text(
                  _timerService.formatDuration(snapshot.data ?? Duration.zero),
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    _timerService.isRunning ? Icons.pause : Icons.play_arrow,
                    color: _timerService.isRunning ? Colors.red : Colors.green,
                  ),
                  onPressed: _toggleTimer,
                ),
                IconButton(
                  icon: const Icon(Icons.restart_alt),
                  onPressed: _resetTimer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Ensure timer is stopped when widget is disposed
    _timerService.stop();
    super.dispose();
  }
}
