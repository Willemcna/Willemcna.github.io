class Handover {
  final int id;
  final DateTime createdAt;
  final String sessionId;
  final String bucket;

  Handover({
    required this.id,
    required this.createdAt,
    required this.sessionId,
    required this.bucket,
  });

  factory Handover.fromJson(Map<String, dynamic> json) {
    return Handover(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      sessionId: json['session_id'].toString(), // Convert numeric to string
      bucket: json['bucket'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'session_id': sessionId,
      'bucket': bucket,
    };
  }
}
