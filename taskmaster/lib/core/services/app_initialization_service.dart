import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../logger/app_logger.dart';
import '../security/secure_storage_service.dart';
import '../../models/task.dart';

class AppInitializationService {
  static bool _isInitialized = false;
  static late DeviceInfoPlugin _deviceInfo;
  static late PackageInfo _packageInfo;

  static bool get isInitialized => _isInitialized;
  static DeviceInfoPlugin get deviceInfo => _deviceInfo;
  static PackageInfo get packageInfo => _packageInfo;

  static Future<void> initialize() async {
    if (_isInitialized) {
      AppLogger.warning('App already initialized');
      return;
    }

    try {
      AppLogger.info('Initializing app...');

      // Initialize core services
      await _initializeCoreServices();
      
      // Initialize Hive
      await _initializeHive();
      
      // Initialize secure storage
      await _initializeSecureStorage();
      
      // Initialize device info
      await _initializeDeviceInfo();
      
      // Initialize package info
      await _initializePackageInfo();

      _isInitialized = true;
      AppLogger.info('App initialization completed successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize app', e, stackTrace);
      rethrow;
    }
  }

  static Future<void> _initializeCoreServices() async {
    AppLogger.info('Initializing core services...');
    
    // Initialize shared preferences
    await SharedPreferences.getInstance();
    
    // Initialize connectivity
    await Connectivity().checkConnectivity();
    
    AppLogger.info('Core services initialized');
  }

  static Future<void> _initializeHive() async {
    AppLogger.info('Initializing Hive...');
    
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(TaskPriorityAdapter());
    
    // Open boxes
    await Hive.openBox('tasks');
    await Hive.openBox('settings');
    
    AppLogger.info('Hive initialized');
  }

  static Future<void> _initializeSecureStorage() async {
    AppLogger.info('Initializing secure storage...');
    
    // SecureStorageService is already initialized as a static class
    // No additional initialization needed
    
    AppLogger.info('Secure storage initialized');
  }

  static Future<void> _initializeDeviceInfo() async {
    AppLogger.info('Initializing device info...');
    
    _deviceInfo = DeviceInfoPlugin();
    
    AppLogger.info('Device info initialized');
  }

  static Future<void> _initializePackageInfo() async {
    AppLogger.info('Initializing package info...');
    
    _packageInfo = await PackageInfo.fromPlatform();
    
    AppLogger.info('Package info initialized: ${_packageInfo.version}');
  }

  static Future<void> dispose() async {
    if (!_isInitialized) return;
    
    AppLogger.info('Disposing app services...');
    
    await Hive.close();
    
    _isInitialized = false;
    AppLogger.info('App services disposed');
  }
}