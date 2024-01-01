class DeleteDocumentRequest {
  final int id;

  DeleteDocumentRequest({required this.id});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }

  factory DeleteDocumentRequest.fromJson(Map<String, dynamic> json) {
    return DeleteDocumentRequest(
      id: json['id'],
    );
  }
}
