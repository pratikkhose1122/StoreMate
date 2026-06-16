/// Represents a user in the StoreMate system.
class UserModel {
  final String id;
  final String mobileNumber;
  final String role;
  final String? shopId;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;

  final String? name;
  final bool? isActive;
  final bool? isInvited;
  final DateTime? invitedAt;
  final DateTime? joinedAt;

  const UserModel({
    required this.id,
    required this.mobileNumber,
    required this.role,
    this.shopId,
    this.lastLoginAt,
    this.createdAt,
    this.name,
    this.isActive,
    this.isInvited,
    this.invitedAt,
    this.joinedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      mobileNumber: json['mobileNumber'] as String,
      role: json['role'] as String,
      shopId: json['shopId'] as String?,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      name: json['name'] as String?,
      isActive: json['isActive'] as bool?,
      isInvited: json['isInvited'] as bool?,
      invitedAt: json['invitedAt'] != null
          ? DateTime.parse(json['invitedAt'] as String)
          : null,
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mobileNumber': mobileNumber,
      'role': role,
      'shopId': shopId,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'name': name,
      'isActive': isActive,
      'isInvited': isInvited,
      'invitedAt': invitedAt?.toIso8601String(),
      'joinedAt': joinedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? mobileNumber,
    String? role,
    String? shopId,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    String? name,
    bool? isActive,
    bool? isInvited,
    DateTime? invitedAt,
    DateTime? joinedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      role: role ?? this.role,
      shopId: shopId ?? this.shopId,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      isInvited: isInvited ?? this.isInvited,
      invitedAt: invitedAt ?? this.invitedAt,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
