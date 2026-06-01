import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../constants/hive_constants.dart';

import '../../features/cart/data/models/cart_item_model.dart';
import '../../features/products/data/models/product_model.dart';

class StorageService {
  static late Box _authBox;
  static late Box _cartBox;
  static late Box _wishlistBox;
  static late Box _addressBox;
  static late Box _profileBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    _authBox = await Hive.openBox(HiveConstants.authBox);
    _cartBox = await Hive.openBox(HiveConstants.cartBox);
    _wishlistBox = await Hive.openBox(HiveConstants.wishlistBox);
    _addressBox = await Hive.openBox(HiveConstants.addressBox);
    _profileBox = await Hive.openBox(HiveConstants.profileBox);
  }

  // ================= AUTH =================

  static Future<void> saveLoginSession(bool value) async {
    await _authBox.put(HiveConstants.loginKey, value);
  }

  static bool getLoginSession() {
    return _authBox.get(HiveConstants.loginKey, defaultValue: false);
  }

  static Future<void> clearSession() async {
    await _authBox.clear();
  }

  // ================= CART =================

  static Future<void> saveCart(List<CartItem> items) async {
    final encoded = items.map((e) => jsonEncode(e.toJson())).toList();

    await _cartBox.put(HiveConstants.cartKey, encoded);
  }

  static List<CartItem> getCart() {
    final List<dynamic> raw =
        _cartBox.get(HiveConstants.cartKey, defaultValue: []);

    return raw
        .map((e) => CartItem.fromJson(jsonDecode(e)))
        .toList();
  }

  // ================= WISHLIST =================

  static Future<void> saveWishlist(List<Product> items) async {
    final encoded = items.map((e) => jsonEncode(e.toJson())).toList();

    await _wishlistBox.put(HiveConstants.wishlistKey, encoded);
  }

  static List<Product> getWishlist() {
    final List<dynamic> raw =
        _wishlistBox.get(HiveConstants.wishlistKey, defaultValue: []);

    return raw
        .map((e) => Product.fromJson(jsonDecode(e)))
        .toList();
  }

  // ================= ADDRESS =================

  static Future<void> saveAddress(String address) async {
    await _addressBox.put(HiveConstants.addressKey, address);
  }

  static String getAddress() {
    return _addressBox.get(HiveConstants.addressKey, defaultValue: '');
  }

  // ================= PROFILE =================

  static Future<void> saveProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    await _profileBox.put(HiveConstants.userNameKey, name);
    await _profileBox.put(HiveConstants.userEmailKey, email);
    await _profileBox.put(HiveConstants.userPhoneKey, phone);
  }

  static Map<String, String> getProfile() {
    return {
      'name':
          _profileBox.get(HiveConstants.userNameKey, defaultValue: ''),
      'email':
          _profileBox.get(HiveConstants.userEmailKey, defaultValue: ''),
      'phone':
          _profileBox.get(HiveConstants.userPhoneKey, defaultValue: ''),
    };
  }
}