import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';

class StorageService {
  final _secureStorage = const FlutterSecureStorage();

    Future<void> writeSecureData(var k, var v) async {
      await _secureStorage.write(key: k, value: v, aOptions: _getAndroidOptions());
    }

    AndroidOptions _getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );

    Future<String?> readSecureData(var key) async {
      var readData = await _secureStorage.read(key: key, aOptions: _getAndroidOptions());
      return readData;
    }

    Future<void> deleteSecureData(var key) async {
      await _secureStorage.delete(key: key, aOptions: _getAndroidOptions());
    }

}


final StorageService storageService = StorageService();

