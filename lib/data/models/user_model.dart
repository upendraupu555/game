import 'dart:convert';
import '../../domain/entities/user_entity.dart';

/// Data model for user serialization/deserialization
/// Following clean architecture - data layer model
class UserModel {
  final String username;
  final String gameId;
  final bool isAuthenticated;
  final String createdAt;
  final String lastLoginAt;
  final String? email;
  final String? profileImageUrl;
  final String? supabaseUserId;

  const UserModel({
    required this.username,
    required this.gameId,
    required this.isAuthenticated,
    required this.createdAt,
    required this.lastLoginAt,
    this.email,
    this.profileImageUrl,
    this.supabaseUserId,
  });

  /// Convert from domain entity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      username: entity.username,
      gameId: entity.gameId,
      isAuthenticated: entity.isAuthenticated,
      createdAt: entity.createdAt.toIso8601String(),
      lastLoginAt: entity.lastLoginAt.toIso8601String(),
      email: entity.email,
      profileImageUrl: entity.profileImageUrl,
      supabaseUserId: entity.supabaseUserId,
    );
  }

  /// Convert to domain entity
  UserEntity toEntity() {
    return UserEntity(
      username: username,
      gameId: gameId,
      isAuthenticated: isAuthenticated,
      createdAt: DateTime.parse(createdAt),
      lastLoginAt: DateTime.parse(lastLoginAt),
      email: email,
      profileImageUrl: profileImageUrl,
      supabaseUserId: supabaseUserId,
    );
  }

  /// Convert from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] as String,
      gameId: json['gameId'] as String,
      isAuthenticated: json['isAuthenticated'] as bool,
      createdAt: json['createdAt'] as String,
      lastLoginAt: json['lastLoginAt'] as String,
      email: json['email'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      supabaseUserId: json['supabaseUserId'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'gameId': gameId,
      'isAuthenticated': isAuthenticated,
      'createdAt': createdAt,
      'lastLoginAt': lastLoginAt,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'supabaseUserId': supabaseUserId,
    };
  }

  /// Convert from JSON string
  factory UserModel.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return UserModel.fromJson(json);
  }

  /// Convert to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Copy with method for immutable updates
  UserModel copyWith({
    String? username,
    String? gameId,
    bool? isAuthenticated,
    String? createdAt,
    String? lastLoginAt,
    String? email,
    String? profileImageUrl,
    String? supabaseUserId,
  }) {
    return UserModel(
      username: username ?? this.username,
      gameId: gameId ?? this.gameId,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      supabaseUserId: supabaseUserId ?? this.supabaseUserId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.username == username &&
        other.gameId == gameId &&
        other.isAuthenticated == isAuthenticated &&
        other.email == email;
  }

  @override
  int get hashCode {
    return Object.hash(username, gameId, isAuthenticated, email);
  }

  @override
  String toString() {
    return 'UserModel(username: $username, gameId: $gameId, isAuthenticated: $isAuthenticated, email: $email)';
  }
}
