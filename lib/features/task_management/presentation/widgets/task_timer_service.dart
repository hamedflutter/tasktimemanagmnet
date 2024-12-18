import 'dart:async';
import 'package:hive/hive.dart';

class TaskTimerService {
  final String taskId;
  Box? _taskBox; // Hive box for storing the task data
  
  // Timer-related variables
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;
  bool isRunning = false;

  // Stream controller for timer updates
  final _timerStreamController = StreamController<Duration>.broadcast();
  Stream<Duration> get timerStream => _timerStreamController.stream;

  TaskTimerService(this.taskId);

  Future<void> initialize() async {
    try {
      // Open the box where task data is stored
      _taskBox = await Hive.openBox('taskBox');

      // Retrieve saved elapsed time for this task from Hive
      final savedTime = _taskBox?.get('${taskId}_elapsedTime', defaultValue: 0);
      _elapsedTime = Duration(seconds: savedTime);

      // Immediately add the saved time to the stream
      _timerStreamController.add(_elapsedTime);
    } catch (e) {
      print('Error initializing TaskTimerService: $e');
    }
  }

  void start() {
    if (!isRunning) {
      isRunning = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        _elapsedTime += const Duration(seconds: 1);
        
        // Save elapsed time to Hive
        _taskBox?.put('${taskId}_elapsedTime', _elapsedTime.inSeconds);
        
        // Add to stream
        _timerStreamController.add(_elapsedTime);
      });
    }
  }

  void stop() {
    if (isRunning) {
      _timer?.cancel();
      isRunning = false;
      
      // Persist the stopped time to Hive
      _taskBox?.put('${taskId}_elapsedTime', _elapsedTime.inSeconds);
    }
  }

  void reset() {
    stop();
    _elapsedTime = Duration.zero;
    
    // Remove saved time from Hive
    _taskBox?.delete('${taskId}_elapsedTime');
    
    // Add reset time to stream
    _timerStreamController.add(_elapsedTime);
  }

  Duration getElapsedTime() {
    return _elapsedTime;
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  void dispose() {
    stop();
    _timerStreamController.close();
  }
}
