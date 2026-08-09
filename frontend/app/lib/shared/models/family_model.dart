enum FamilyStatus {
  active,
  pending,
  disconnected,
}

class FamilySpace {
  final String id;
  final String inviteCode;
  final FamilyStatus status;
  final String primaryUserId;
  final String? partnerUserId;
  final String? partnerName;
  final DateTime createdAt;
  final DateTime? pairedAt;

  const FamilySpace({
    required this.id,
    required this.inviteCode,
    required this.status,
    required this.primaryUserId,
    this.partnerUserId,
    this.partnerName,
    required this.createdAt,
    this.pairedAt,
  });

  factory FamilySpace.fromJson(Map<String, dynamic> json) {
    return FamilySpace(
      id: json['id'] as String,
      inviteCode: json['invite_code'] as String,
      status: FamilyStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FamilyStatus.pending,
      ),
      primaryUserId: json['primary_user_id'] as String,
      partnerUserId: json['partner_user_id'] as String?,
      partnerName: json['partner_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      pairedAt: json['paired_at'] != null
          ? DateTime.parse(json['paired_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invite_code': inviteCode,
      'status': status.name,
      'primary_user_id': primaryUserId,
      'partner_user_id': partnerUserId,
      'partner_name': partnerName,
      'created_at': createdAt.toUtc().toIso8601String(),
      'paired_at': pairedAt?.toUtc().toIso8601String(),
    };
  }

  FamilySpace copyWith({
    String? id,
    String? inviteCode,
    FamilyStatus? status,
    String? primaryUserId,
    String? partnerUserId,
    String? partnerName,
    DateTime? createdAt,
    DateTime? pairedAt,
  }) {
    return FamilySpace(
      id: id ?? this.id,
      inviteCode: inviteCode ?? this.inviteCode,
      status: status ?? this.status,
      primaryUserId: primaryUserId ?? this.primaryUserId,
      partnerUserId: partnerUserId ?? this.partnerUserId,
      partnerName: partnerName ?? this.partnerName,
      createdAt: createdAt ?? this.createdAt,
      pairedAt: pairedAt ?? this.pairedAt,
    );
  }
}
