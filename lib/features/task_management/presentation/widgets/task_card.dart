import 'package:flutter/material.dart';
  import '../widgets/task_timer_service.dart';
  import '../../domain/entities/task.dart';
  import '../widgets/rich_text_item.dart';
  import '../widgets/task_option.dart';

  class TaskCard extends StatelessWidget {
    final RichTextItem item;
    final Map<String, TaskTimerService> timerServices;

    TaskCard({required this.item, required this.timerServices});

    @override
    Widget build(BuildContext context) {
      // Create or get existing timer service for this task
      if (!timerServices.containsKey(item.id)) {
        timerServices[item.id] = TaskTimerService(item.id);
      }
      final timerService = timerServices[item.id]!;
      // Convert RichTextItem back to TaskEntity if necessary
      final taskEntity = TaskEntity(
        id: item.id,
        content: item.title,
        description: item.subtitle,
        projectId: item.projectId,
      );
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.title,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 5),
            Text(
              item.subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            StreamBuilder<Duration>(
              stream: timerService.timerStream,
              initialData:
                  timerService.getElapsedTime(), // Use the loaded elapsed time
              builder: (context, snapshot) {
                final elapsedDuration =
                    snapshot.data ?? Duration.zero; // Fallback for safety
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        timerService.formatDuration(elapsedDuration),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            timerService.isRunning
                                ? Icons.pause
                                : Icons.play_arrow,
                            size: 20,
                            color: timerService.isRunning
                                ? Colors.red
                                : Colors.green,
                          ),
                          onPressed: () {
                            if (timerService.isRunning) {
                              timerService.stop();
                            } else {
                              timerService.start();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.restart_alt, size: 20),
                          onPressed: () {
                            timerService.reset();
                          },
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.more_vert, size: 16),
                  onPressed: () {
                    showTaskOptions(context, item, taskEntity);
                  },
                ),
              ],
            ),
          ],
        ),
      );
    }
  }