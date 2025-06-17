import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';

/// Local data source for user data persistence
/// Following clean architecture - data layer
abstract class UserLocalDataSource {
  Future<UserModel?> getCurrentUser();
  Future<void> saveUser(UserModel user);
  Future<void> deleteUser(String gameId);
  Future<bool> userExists(String gameId);
  Future<void> clearAllUserData();
  String generateGameId();
  bool isValidGameId(String gameId);
}

/// Implementation of user local data source using SharedPreferences
class UserLocalDataSourceImpl implements UserLocalDataSource {
  final SharedPreferences _prefs;
  final Random _random = Random();

  UserLocalDataSourceImpl(this._prefs);

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final userJson = _prefs.getString(AppConstants.userDataKey);
      if (userJson == null) return null;

      return UserModel.fromJsonString(userJson);
    } catch (e) {
      // If loading fails, clear corrupted data
      await clearAllUserData();
      return null;
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      final userJson = user.toJsonString();
      await _prefs.setString(AppConstants.userDataKey, userJson);
      await _prefs.setString(AppConstants.currentUserIdKey, user.gameId);
    } catch (e) {
      throw UserDataException('Failed to save user data: $e');
    }
  }

  @override
  Future<void> deleteUser(String gameId) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser?.gameId == gameId) {
        await _prefs.remove(AppConstants.userDataKey);
        await _prefs.remove(AppConstants.currentUserIdKey);
      }
    } catch (e) {
      throw UserDataException('Failed to delete user: $e');
    }
  }

  @override
  Future<bool> userExists(String gameId) async {
    try {
      final currentUser = await getCurrentUser();
      return currentUser?.gameId == gameId;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> clearAllUserData() async {
    try {
      // Clear all user-related data to fix persistence bug
      await Future.wait([
        _prefs.remove(AppConstants.userDataKey),
        _prefs.remove(AppConstants.currentUserIdKey),
        _prefs.remove(AppConstants.userStatisticsKey),
        // Clear payment data as well during logout
        _prefs.remove(AppConstants.adRemovalPurchaseKey),
        _prefs.remove(AppConstants.paymentTransactionKey),
        _prefs.remove(AppConstants.lastPaymentAttemptKey),
        // Clear any theme/font settings that might be user-specific
        // Note: We keep general app settings like theme mode and language
      ]);
    } catch (e) {
      throw UserDataException('Failed to clear user data: $e');
    }
  }

  @override
  String generateGameId() {
    const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final buffer = StringBuffer();

    for (int i = 0; i < AppConstants.gameIdLength; i++) {
      buffer.write(chars[_random.nextInt(chars.length)]);
    }

    return buffer.toString();
  }

  @override
  bool isValidGameId(String gameId) {
    if (gameId.length != AppConstants.gameIdLength) return false;

    // Check if all characters are alphanumeric
    final regex = RegExp(r'^[A-Z0-9]+$');
    return regex.hasMatch(gameId);
  }
}

/// Exception for user data operations
class UserDataException implements Exception {
  final String message;

  const UserDataException(this.message);

  @override
  String toString() => 'UserDataException: $message';
}
