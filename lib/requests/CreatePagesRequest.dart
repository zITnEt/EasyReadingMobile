class CreatePagesRequest {
  final int documentId;
  final List<GetPageDTO> pages;

  CreatePagesRequest({required this.documentId, required this.pages});

  Map<String, dynamic> toJson() {
    return {
      'documentId': documentId,
      'pages': pages.map((page) => page.toJson()).toList(),
    };
  }

  factory CreatePagesRequest.fromJson(Map<String, dynamic> json) {
    var pagesList = json['pages'] as List;
    List<GetPageDTO> pages = pagesList.map((page) => GetPageDTO.fromJson(page)).toList();
    return CreatePagesRequest(
      documentId: json['documentId'],
      pages: pages,
    );
  }
}

class GetPageDTO {
  String body;
  int page;

  GetPageDTO({required this.body, required this.page});

  factory GetPageDTO.fromJson(Map<String, dynamic> json) {
    return GetPageDTO(
      body: json['body'] as String,
      page: json['page'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'body': body,
      'page': page,
    };
  }
}
