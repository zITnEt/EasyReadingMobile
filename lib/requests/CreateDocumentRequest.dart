class CreateDocumentRequest{
  final String title;
  final int pagesCount;

  CreateDocumentRequest({required this.title, required this.pagesCount});

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'pagesCount': pagesCount,
    };
  }

  factory CreateDocumentRequest.fromJson(Map<String, dynamic> json) {
    return CreateDocumentRequest(
      title: json['title'],
      pagesCount: json['pagesCount'],
    );
  }
}