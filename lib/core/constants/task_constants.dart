class TaskConstants {
  static const String toDo = "To Do";
  static const String inProgress = "In Progress";
  static const String done = "Done";

  static const Map<String, String> projectIds = {
    toDo: "2344836189",
    inProgress: "2344836280",
    done: "2344836299",
  };

  static String getGroupName(String projectId) {
    return projectIds.entries
        .firstWhere(
          (entry) => entry.value == projectId,
          orElse: () => const MapEntry(toDo, ""),
        )
        .key;
  }
}
