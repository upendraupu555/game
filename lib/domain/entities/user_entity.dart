/// Domain entity representing a user in the 2048 game
/// Following clean architecture principles - this is pure business logic
class UserEntity {
  final String username;
  final String gameId;
  final bool isAuthenticated;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final String? email;
  final String? profileImageUrl;
  final String? supabaseUserId;

  const UserEntity({
    required this.username,
    required this.gameId,
    required this.isAuthenticated,
    required this.createdAt,
    required this.lastLoginAt,
    this.email,
    this.profileImageUrl,
    this.supabaseUserId,
  });

  /// Create a guest user with generated game ID
  factory UserEntity.guest(String gameId) {
    final now = DateTime.now();
    return UserEntity(
      username: 'guest',
      gameId: gameId,
      isAuthenticated: false,
      createdAt: now,
      lastLoginAt: now,
    );
  }

  /// Create an authenticated user
  factory UserEntity.authenticated({
    required String username,
    required String gameId,
    required String email,
    String? profileImageUrl,
    String? supabaseUserId,
  }) {
    final now = DateTime.now();
    return UserEntity(
      username: username,
      gameId: gameId,
      isAuthenticated: true,
      createdAt: now,
      lastLoginAt: now,
      email: email,
      profileImageUrl: profileImageUrl,
      supabaseUserId: supabaseUserId,
    );
  }

  /// Copy with method for immutable updates
  UserEntity copyWith({
    String? username,
    String? gameId,
    bool? isAuthenticated,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? email,
    String? profileImageUrl,
    String? supabaseUserId,
  }) {
    return UserEntity(
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

  /// Update last login time
  UserEntity updateLastLogin() {
    return copyWith(lastLoginAt: DateTime.now());
  }

  /// Convert to authenticated user
  UserEntity toAuthenticated({
    required String username,
    required String email,
    String? profileImageUrl,
  }) {
    return copyWith(
      username: username,
      email: email,
      profileImageUrl: profileImageUrl,
      isAuthenticated: true,
      lastLoginAt: DateTime.now(),
    );
  }

  /// Convert to guest user
  UserEntity toGuest() {
    return copyWith(
      username: 'guest',
      email: null,
      profileImageUrl: null,
      supabaseUserId: null,
      isAuthenticated: false,
      lastLoginAt: DateTime.now(),
    );
  }

  /// Check if user is guest
  bool get isGuest => !isAuthenticated;

  /// Get display name
  String get displayName {
    if (isGuest) {
      return 'Guest User';
    }
    return username;
  }

  /// Get account type string
  String get accountType {
    return isAuthenticated ? 'Registered User' : 'Guest User';
  }

  /// Get formatted member since date
  String get formattedMemberSince {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Get formatted last login date
  String get formattedLastLogin {
    final now = DateTime.now();
    final difference = now.difference(lastLoginAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity &&
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
    return 'UserEntity(username: $username, gameId: $gameId, isAuthenticated: $isAuthenticated, email: $email)';
  }
}
