class Book {
  final String imagePath;
  final String path;
  final String title;
  final int postgId;
  int currentPage;

  Book({
    required this.postgId,
    required this.imagePath,
    required this.path,
    required this.title,
    required this.currentPage,
  });

  Map<String, dynamic> toMap() {
    return {
      'imagePath': imagePath,
      'path': path,
      'title': title,
      'currentPage': currentPage,
      'postgId': postgId
    };
  }
}