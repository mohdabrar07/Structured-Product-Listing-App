import 'package:hive_ce/hive_ce.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

class StorageService {
  static const String _authBoxName = 'auth_box';
  static const String _shoppingBoxName = 'shopping_box';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_authBoxName);
    await Hive.openBox(_shoppingBoxName);
  }

  String? getToken() {
    final box = Hive.box(_authBoxName);
    return box.get('token') as String?;
  }

  Future<void> saveToken(String token) async {
    final box = Hive.box(_authBoxName);
    await box.put('token', token);
  }

  // New: Core functions to isolate user sessions
  Future<void> saveUserEmail(String email) async {
    final box = Hive.box(_authBoxName);
    await box.put('active_user_email', email);
  }

  String getUserEmail() {
    final box = Hive.box(_authBoxName);
    return box.get('active_user_email', defaultValue: 'guest') as String;
  }

  Future<void> clearAuthSession() async {
    final box = Hive.box(_authBoxName);
    await box.delete('token');
    await box.delete('active_user_email');
  }

  // Scoped Data Methods
  dynamic retrieveData(String key) {
    final box = Hive.box(_shoppingBoxName);
    final userScope = getUserEmail();
    return box.get('${userScope}_$key');
  }

  Future<void> persistData(String key, dynamic value) async {
    final box = Hive.box(_shoppingBoxName);
    final userScope = getUserEmail();
    await box.put('${userScope}_$key', value);
  }

  Future<void> deleteData(String key) async {
    final box = Hive.box(_shoppingBoxName);
    final userScope = getUserEmail();
    await box.delete('${userScope}_$key');
  }
}