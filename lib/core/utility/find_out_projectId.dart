class ProjectIdMapper {
  static String findOutProjectId(String columnName) {
    switch (columnName) {
      case "To Do":
        return "2344836189";
      case "In Progress":
        return "2344836280";
      case "Done":
        return "2344836299";
      default:
        throw Exception("Invalid column name: $columnName");
    }
  }
}
