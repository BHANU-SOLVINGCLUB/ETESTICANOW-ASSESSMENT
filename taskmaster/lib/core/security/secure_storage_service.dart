import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../logger/app_logger.dart';

class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // User Preferences
  static Future<void> saveUserPreference(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      AppLogger.debug('User preference saved: $key');
    } catch (e) {
      AppLogger.error('Failed to save user preference: $key', e);
      rethrow;
    }
  }

  static Future<String?> getUserPreference(String key) async {
    try {
      final value = await _storage.read(key: key);
      AppLogger.debug('User preference retrieved: $key');
      return value;
    } catch (e) {
      AppLogger.error('Failed to get user preference: $key', e);
      return null;
    }
  }

  static Future<void> deleteUserPreference(String key) async {
    try {
      await _storage.delete(key: key);
      AppLogger.debug('User preference deleted: $key');
    } catch (e) {
      AppLogger.error('Failed to delete user preference: $key', e);
      rethrow;
    }
  }

  // Authentication Tokens
  static Future<void> saveAuthToken(String token) async {
    try {
      await _storage.write(key: 'auth_token', value: token);
      AppLogger.info('Auth token saved');
    } catch (e) {
      AppLogger.error('Failed to save auth token', e);
      rethrow;
    }
  }

  static Future<String?> getAuthToken() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      AppLogger.debug('Auth token retrieved');
      return token;
    } catch (e) {
      AppLogger.error('Failed to get auth token', e);
      return null;
    }
  }

  static Future<void> deleteAuthToken() async {
    try {
      await _storage.delete(key: 'auth_token');
      AppLogger.info('Auth token deleted');
    } catch (e) {
      AppLogger.error('Failed to delete auth token', e);
      rethrow;
    }
  }

  // App Settings
  static Future<void> saveAppSetting(String key, String value) async {
    try {
      await _storage.write(key: 'app_setting_$key', value: value);
      AppLogger.debug('App setting saved: $key');
    } catch (e) {
      AppLogger.error('Failed to save app setting: $key', e);
      rethrow;
    }
  }

  static Future<String?> getAppSetting(String key) async {
    try {
      final value = await _storage.read(key: 'app_setting_$key');
      AppLogger.debug('App setting retrieved: $key');
      return value;
    } catch (e) {
      AppLogger.error('Failed to get app setting: $key', e);
      return null;
    }
  }

  // Clear all data
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      AppLogger.info('All secure storage cleared');
    } catch (e) {
      AppLogger.error('Failed to clear secure storage', e);
      rethrow;
    }
  }

  // Check if key exists
  static Future<bool> containsKey(String key) async {
    try {
      final value = await _storage.read(key: key);
      return value != null;
    } catch (e) {
      AppLogger.error('Failed to check key existence: $key', e);
      return false;
    }
  }
}
