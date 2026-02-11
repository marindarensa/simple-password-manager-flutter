import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/password_model.dart';

class StorageService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _passwordsKey = 'stored_passwords';

  // Save passwords to secure storage
  Future<void> savePasswords(List<PasswordModel> passwords) async {
    try {
      final passwordsJson = passwords.map((p) => p.toMap()).toList();
      final jsonString = jsonEncode(passwordsJson);
      await _secureStorage.write(key: _passwordsKey, value: jsonString);
    } catch (e) {
      throw Exception('Failed to save passwords: $e');
    }
  }

  // Load passwords from secure storage
  Future<List<PasswordModel>> loadPasswords() async {
    try {
      final jsonString = await _secureStorage.read(key: _passwordsKey);
      if (jsonString == null) return [];

      final List<dynamic> passwordsJson = jsonDecode(jsonString);
      return passwordsJson.map((json) => PasswordModel.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Failed to load passwords: $e');
    }
  }

  // Save a single password
  Future<void> savePassword(PasswordModel password) async {
    final passwords = await loadPasswords();
    final existingIndex = passwords.indexWhere((p) => p.id == password.id);

    if (existingIndex != -1) {
      passwords[existingIndex] = password;
    } else {
      passwords.add(password);
    }

    await savePasswords(passwords);
  }

  // Delete a password
  Future<void> deletePassword(String id) async {
    final passwords = await loadPasswords();
    passwords.removeWhere((p) => p.id == id);
    await savePasswords(passwords);
  }

  // Clear all stored passwords
  Future<void> clearAllPasswords() async {
    await _secureStorage.delete(key: _passwordsKey);
  }

  // Check if storage contains any passwords
  Future<bool> hasStoredPasswords() async {
    final jsonString = await _secureStorage.read(key: _passwordsKey);
    return jsonString != null && jsonString.isNotEmpty;
  }
}
