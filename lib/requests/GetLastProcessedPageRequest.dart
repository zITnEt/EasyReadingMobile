class GetLastProcessedPageRequest {
  final int id;

  GetLastProcessedPageRequest({required this.id});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }

  factory GetLastProcessedPageRequest.fromJson(Map<String, dynamic> json) {
    return GetLastProcessedPageRequest(
      id: json['id'],
    );
  }
}
