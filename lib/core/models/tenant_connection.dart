class TenantConnection {
  final String orgId;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String createdBy;
  final DateTime createdAt;

  TenantConnection({
    required this.orgId,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.createdBy,
    required this.createdAt,
  });

  factory TenantConnection.fromJson(Map<String, dynamic> json) {
    return TenantConnection(
      orgId: json['org_id'] as String,
      supabaseUrl: json['supabase_url'] as String,
      supabaseAnonKey: json['supabase_anon_key'] as String,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'org_id': orgId,
      'supabase_url': supabaseUrl,
      'supabase_anon_key': supabaseAnonKey,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

