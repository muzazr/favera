enum FamilyStatus {
  unpaired,
  pendingPairing,
  active,
  disconnected,
}

class FamilySpace {
  final String id;
  final String? inviteCode;
  final FamilyStatus status;
  final String primaryUserId;
  final String? partnerUserId;
  final String? partnerName;
  final bool shareFinancialSummary;
  final bool shareCheckInSummary;
  final DateTime createdAt;
  final DateTime? pairedAt;

  const FamilySpace({
    required this.id,
    this.inviteCode,
    required this.status,
    required this.primaryUserId,
    this.partnerUserId,
    this.partnerName,
    this.shareFinancialSummary = true,
    this.shareCheckInSummary = true,
    required this.createdAt,
    this.pairedAt,
  });

  factory FamilySpace.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'] as String? ?? 'unpaired';
    FamilyStatus parsedStatus;
    if (rawStatus == 'active' || rawStatus == 'paired') {
      parsedStatus = FamilyStatus.active;
    } else if (rawStatus == 'pending' || rawStatus == 'pending_pairing') {
      parsedStatus = FamilyStatus.pendingPairing;
    } else if (rawStatus == 'disconnected') {
      parsedStatus = FamilyStatus.disconnected;
    } else {
      parsedStatus = FamilyStatus.unpaired;
    }

    return FamilySpace(
      id: (json['id'] ?? json['family_id'] ?? '') as String,
      inviteCode: (json['invite_code'] ?? json['inviteCode']) as String?,
      status: parsedStatus,
      primaryUserId: (json['primary_user_id'] ?? json['user_id_1'] ?? '') as String,
      partnerUserId: (json['partner_user_id'] ?? json['user_id_2']) as String?,
      partnerName: (json['partner_name'] ?? json['partnerName']) as String?,
      shareFinancialSummary: (json['share_financial_summary'] as bool?) ?? true,
      shareCheckInSummary: (json['share_check_in_summary'] as bool?) ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      pairedAt: json['paired_at'] != null
          ? DateTime.parse(json['paired_at'] as String)
          : null,
    );
  }

  bool get isPaired => status == FamilyStatus.active;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invite_code': inviteCode,
      'status': status.name,
      'primary_user_id': primaryUserId,
      'partner_user_id': partnerUserId,
      'partner_name': partnerName,
      'share_financial_summary': shareFinancialSummary,
      'share_check_in_summary': shareCheckInSummary,
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
    bool? shareFinancialSummary,
    bool? shareCheckInSummary,
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
      shareFinancialSummary: shareFinancialSummary ?? this.shareFinancialSummary,
      shareCheckInSummary: shareCheckInSummary ?? this.shareCheckInSummary,
      createdAt: createdAt ?? this.createdAt,
      pairedAt: pairedAt ?? this.pairedAt,
    );
  }
}

class FamilyInvitation {
  final String id;
  final String inviteCode;
  final String? inviterUserId;
  final String? inviterName;
  final String? inviteeEmail;
  final String status;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const FamilyInvitation({
    required this.id,
    required this.inviteCode,
    this.inviterUserId,
    this.inviterName,
    this.inviteeEmail,
    this.status = 'pending',
    required this.createdAt,
    this.expiresAt,
  });

  factory FamilyInvitation.fromJson(Map<String, dynamic> json) {
    return FamilyInvitation(
      id: json['id'] as String,
      inviteCode: (json['invite_code'] ?? json['inviteCode']) as String,
      inviterUserId: (json['inviter_user_id'] ?? json['primary_user_id']) as String?,
      inviterName: (json['inviter_name'] ?? json['partner_name']) as String?,
      inviteeEmail: json['invitee_email'] as String?,
      status: (json['status'] as String?) ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invite_code': inviteCode,
      'inviter_user_id': inviterUserId,
      'inviter_name': inviterName,
      'invitee_email': inviteeEmail,
      'status': status,
      'created_at': createdAt.toUtc().toIso8601String(),
      'expires_at': expiresAt?.toUtc().toIso8601String(),
    };
  }
}
