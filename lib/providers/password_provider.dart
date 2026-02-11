import 'package:flutter/material.dart';
import '../models/password_model.dart';
import '../services/storage_service.dart';

class PasswordProvider extends ChangeNotifier {
  List<PasswordModel> _passwords = [];
  final StorageService _storageService = StorageService();
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<PasswordModel> get passwords => _passwords;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load all passwords
  Future<void> loadPasswords() async {
    _setLoading(true);
    try {
      _passwords = await _storageService.loadPasswords();
      _clearError();
    } catch (e) {
      _setError('Failed to load passwords: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add new password
  Future<void> addPassword({
    required String title,
    required String username,
    required String password,
    String? website,
    String? notes,
  }) async {
    try {
      final newPassword = PasswordModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        username: username,
        password: password,
        website: website,
        notes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _storageService.savePassword(newPassword);
      _passwords.add(newPassword);
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to add password: $e');
    }
  }

  // Update existing password
  Future<void> updatePassword(PasswordModel updatedPassword) async {
    try {
      final index = _passwords.indexWhere((p) => p.id == updatedPassword.id);
      if (index != -1) {
        final passwordWithUpdatedTime = updatedPassword.copyWith(
          updatedAt: DateTime.now(),
        );

        await _storageService.savePassword(passwordWithUpdatedTime);
        _passwords[index] = passwordWithUpdatedTime;
        _clearError();
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update password: $e');
    }
  }

  // Delete password
  Future<void> deletePassword(String id) async {
    try {
      await _storageService.deletePassword(id);
      _passwords.removeWhere((p) => p.id == id);
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete password: $e');
    }
  }

  // Search passwords
  List<PasswordModel> searchPasswords(String query) {
    if (query.isEmpty) return _passwords;

    return _passwords.where((password) {
      return password.title.toLowerCase().contains(query.toLowerCase()) ||
          password.username.toLowerCase().contains(query.toLowerCase()) ||
          (password.website?.toLowerCase().contains(query.toLowerCase()) ??
              false);
    }).toList();
  }

  // Clear all passwords
  Future<void> clearAllPasswords() async {
    try {
      await _storageService.clearAllPasswords();
      _passwords.clear();
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear passwords: $e');
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
