import 'package:storemate/features/auth/data/models/user_model.dart';

class ActivityLogModel {
  final String id;
  final String action;
  final String? entityType;
  final String? entityId;
  final Map<String, dynamic>? details;
  final DateTime createdAt;
  final UserModel user;

  const ActivityLogModel({
    required this.id,
    required this.action,
    this.entityType,
    this.entityId,
    this.details,
    required this.createdAt,
    required this.user,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    return ActivityLogModel(
      id: json['id'] as String,
      action: json['action'] as String,
      entityType: json['entityType'] as String?,
      entityId: json['entityId'] as String?,
      details: json['details'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      user: UserModel.fromJson(json['user']),
    );
  }
}
