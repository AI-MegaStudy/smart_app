class OwnerProfileRecord {
  final int ownerId;
  final String ownerName;
  final String ownerPhone;
  final String? businessNumber;
  final String email;
  final String accountStatus;

  const OwnerProfileRecord({
    required this.ownerId,
    required this.ownerName,
    required this.ownerPhone,
    this.businessNumber,
    required this.email,
    required this.accountStatus,
  });

  factory OwnerProfileRecord.fromJson(Map<String, dynamic> json) {
    return OwnerProfileRecord(
      ownerId: _readInt(json['owner_id']),
      ownerName: (json['owner_name'] ?? '').toString(),
      ownerPhone: (json['owner_phone'] ?? '').toString(),
      businessNumber: json['business_number']?.toString(),
      email: (json['email'] ?? '').toString(),
      accountStatus: (json['account_status'] ?? '').toString(),
    );
  }

  OwnerProfileRecord copyWith({
    String? ownerName,
    String? ownerPhone,
    String? businessNumber,
  }) {
    return OwnerProfileRecord(
      ownerId: ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      businessNumber: businessNumber ?? this.businessNumber,
      email: email,
      accountStatus: accountStatus,
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'owner_name': ownerName,
      'owner_phone': ownerPhone,
      'business_number': businessNumber,
    };
  }
}

int _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
