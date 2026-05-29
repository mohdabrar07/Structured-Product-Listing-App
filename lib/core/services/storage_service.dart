import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/cart/data/models/cart_item_model.dart';
import '../../features/products/data/models/product_model.dart';

class StorageService {
  static late final SharedPreferences _prefs;

  // Keys used to separate distinct data matrices in memory storage
  static const String _keyLoginSession = 'user_login_session';
  static const String _keyCartItems = 'user_cart_items';
  static const String _keyWishlistItems = 'user_wishlist_items';
  static const String _keyUserAddress = 'user_shipping_address';

  // Initialize SharedPreferences asynchronously during app bootup
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 1. LOGIN SESSION STATE ENGINE
  // ───────────────────────────────────────────────────────────────────────────
  static Future<void> saveLoginSession(bool isLoggedIn) async {
    await _prefs.setBool(_keyLoginSession, isLoggedIn);
  }

  static bool getLoginSession() {
    return _prefs.getBool(_keyLoginSession) ?? false; // Defaults to false if never saved
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 2. CART PERSISTENCE PIPELINE (JSON Encoding/Decoding Matrix)
  // ───────────────────────────────────────────────────────────────────────────
  static Future<void> saveCart(List<CartItem> items) async {
    // Edge Case / Core Rule: Convert custom object structural arrays into readable text strings
    final List<Map<String, dynamic>> rawJsonList = items.map((item) => {
      'quantity': item.quantity,
      'product': item.product.toJson(), // Assumes your Product model has a toJson() method
    }).toList();

    final String encodedString = jsonEncode(rawJsonList);
    await _prefs.setString(_keyCartItems, encodedString);
  }

  static List<CartItem> getCart() {
    final String? encodedString = _prefs.getString(_keyCartItems);
    if (encodedString == null || encodedString.isEmpty) return [];

    try {
      final List<dynamic> decodedRawList = jsonDecode(encodedString);
      return decodedRawList.map((itemMap) => CartItem(
        quantity: itemMap['quantity'] as int,
        product: Product.fromJson(itemMap['product']),
      )).toList();
    } catch (_) {
      return []; // Returns empty fallback list gracefully if parsing fails
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 3. WISHLIST PERSISTENCE PIPELINE
  // ───────────────────────────────────────────────────────────────────────────
  static Future<void> saveWishlist(List<Product> products) async {
    final List<Map<String, dynamic>> rawJsonList = products.map((p) => p.toJson()).toList();
    await _prefs.setString(_keyWishlistItems, jsonEncode(rawJsonList));
  }

  static List<Product> getWishlist() {
    final String? encodedString = _prefs.getString(_keyWishlistItems);
    if (encodedString == null || encodedString.isEmpty) return [];

    try {
      final List<dynamic> decodedRawList = jsonDecode(encodedString);
      return decodedRawList.map((pMap) => Product.fromJson(pMap)).toList();
    } catch (_) {
      return [];
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 4. SHIPPING ADDRESS PERSISTENCE PIPELINE
  // ───────────────────────────────────────────────────────────────────────────
  static Future<void> saveAddress(String address) async {
    await _prefs.setString(_keyUserAddress, address);
  }

  static String getAddress() {
    return _prefs.getString(_keyUserAddress) ?? ''; // Returns empty string if unassigned
  }

  // Clear data on user logout
  static Future<void> clearAllData() async {
    await _prefs.clear();
  }
}