/// Model for tracking synchronization status between local and remote data
class SyncStatusModel {
  final String id;
  final String? userId;
  final String? guestId;
  final String tableName;
  final DateTime? lastSyncAt;
  final int syncVersion;
  final bool isDirty;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SyncStatusModel({
    required this.id,
    this.userId,
    this.guestId,
    required this.tableName,
    this.lastSyncAt,
    required this.syncVersion,
    required this.isDirty,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert from Supabase JSON response
  factory SyncStatusModel.fromJson(Map<String, dynamic> json) {
    return SyncStatusModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      guestId: json['guest_id'] as String?,
      tableName: json['table_name'] as String,
      lastSyncAt: json['last_sync_at'] != null 
          ? DateTime.parse(json['last_sync_at'] as String) 
          : null,
      syncVersion: json['sync_version'] as int,
      isDirty: json['is_dirty'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to Supabase JSON for insertion/update
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'guest_id': guestId,
      'table_name': tableName,
      'last_sync_at': lastSyncAt?.toIso8601String(),
      'sync_version': syncVersion,
      'is_dirty': isDirty,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create for insertion (without ID and timestamps)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'guest_id': guestId,
      'table_name': tableName,
      'last_sync_at': lastSyncAt?.toIso8601String(),
      'sync_version': syncVersion,
      'is_dirty': isDirty,
    };
  }

  /// Create for update (only updatable fields)
  Map<String, dynamic> toUpdateJson() {
    return {
      'last_sync_at': lastSyncAt?.toIso8601String(),
      'sync_version': syncVersion,
      'is_dirty': isDirty,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Copy with new values
  SyncStatusModel copyWith({
    String? id,
    String? userId,
    String? guestId,
    String? tableName,
    DateTime? lastSyncAt,
    int? syncVersion,
    bool? isDirty,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SyncStatusModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      guestId: guestId ?? this.guestId,
      tableName: tableName ?? this.tableName,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      syncVersion: syncVersion ?? this.syncVersion,
      isDirty: isDirty ?? this.isDirty,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Mark as dirty (needs sync)
  SyncStatusModel markDirty() {
    return copyWith(
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Mark as synced
  SyncStatusModel markSynced() {
    return copyWith(
      lastSyncAt: DateTime.now(),
      syncVersion: syncVersion + 1,
      isDirty: false,
      updatedAt: DateTime.now(),
    );
  }

  /// Check if sync is needed
  bool get needsSync => isDirty || lastSyncAt == null;

  /// Check if sync is recent (within last hour)
  bool get isRecentlySync {
    if (lastSyncAt == null) return false;
    final now = DateTime.now();
    final difference = now.difference(lastSyncAt!);
    return difference.inHours < 1;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SyncStatusModel &&
        other.id == id &&
        other.userId == userId &&
        other.guestId == guestId &&
        other.tableName == tableName &&
        other.syncVersion == syncVersion &&
        other.isDirty == isDirty;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      guestId,
      tableName,
      syncVersion,
      isDirty,
    );
  }

  @override
  String toString() {
    return 'SyncStatusModel('
        'id: $id, '
        'userId: $userId, '
        'guestId: $guestId, '
        'tableName: $tableName, '
        'syncVersion: $syncVersion, '
        'isDirty: $isDirty, '
        'lastSyncAt: $lastSyncAt'
        ')';
  }
}

/// Enum for sync operation types
enum SyncOperation {
  create,
  update,
  delete,
  fetch,
}

/// Model for sync operation results
class SyncResult {
  final bool success;
  final String? error;
  final int itemsProcessed;
  final DateTime timestamp;
  final SyncOperation operation;

  const SyncResult({
    required this.success,
    this.error,
    required this.itemsProcessed,
    required this.timestamp,
    required this.operation,
  });

  factory SyncResult.success({
    required int itemsProcessed,
    required SyncOperation operation,
  }) {
    return SyncResult(
      success: true,
      itemsProcessed: itemsProcessed,
      timestamp: DateTime.now(),
      operation: operation,
    );
  }

  factory SyncResult.failure({
    required String error,
    required SyncOperation operation,
    int itemsProcessed = 0,
  }) {
    return SyncResult(
      success: false,
      error: error,
      itemsProcessed: itemsProcessed,
      timestamp: DateTime.now(),
      operation: operation,
    );
  }

  @override
  String toString() {
    return 'SyncResult('
        'success: $success, '
        'operation: $operation, '
        'itemsProcessed: $itemsProcessed, '
        'error: $error'
        ')';
  }
}

/// Enum for sync status states
enum SyncState {
  idle,
  syncing,
  success,
  error,
  offline,
}

/// Model for overall sync status
class OverallSyncStatus {
  final SyncState state;
  final String? message;
  final DateTime lastUpdate;
  final Map<String, SyncResult> tableResults;

  const OverallSyncStatus({
    required this.state,
    this.message,
    required this.lastUpdate,
    required this.tableResults,
  });

  factory OverallSyncStatus.idle() {
    return OverallSyncStatus(
      state: SyncState.idle,
      lastUpdate: DateTime.now(),
      tableResults: {},
    );
  }

  factory OverallSyncStatus.syncing({String? message}) {
    return OverallSyncStatus(
      state: SyncState.syncing,
      message: message,
      lastUpdate: DateTime.now(),
      tableResults: {},
    );
  }

  factory OverallSyncStatus.success({
    String? message,
    Map<String, SyncResult>? tableResults,
  }) {
    return OverallSyncStatus(
      state: SyncState.success,
      message: message,
      lastUpdate: DateTime.now(),
      tableResults: tableResults ?? {},
    );
  }

  factory OverallSyncStatus.error({
    required String message,
    Map<String, SyncResult>? tableResults,
  }) {
    return OverallSyncStatus(
      state: SyncState.error,
      message: message,
      lastUpdate: DateTime.now(),
      tableResults: tableResults ?? {},
    );
  }

  factory OverallSyncStatus.offline() {
    return OverallSyncStatus(
      state: SyncState.offline,
      message: 'No internet connection',
      lastUpdate: DateTime.now(),
      tableResults: {},
    );
  }

  @override
  String toString() {
    return 'OverallSyncStatus('
        'state: $state, '
        'message: $message, '
        'lastUpdate: $lastUpdate'
        ')';
  }
}
