class GetResponseRequest {
  final int documentId;
  final String question;

  GetResponseRequest({required this.documentId, required this.question});

  Map<String, dynamic> toJson() {
    return {
      'documentId': documentId,
      'question': question,
    };
  }

  factory GetResponseRequest.fromJson(Map<String, dynamic> json) {
    return GetResponseRequest(
      documentId: json['documentId'],
      question: json['question'],
    );
  }
}