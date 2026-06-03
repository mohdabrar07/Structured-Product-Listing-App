import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:structured_product_listing_app/core/services/storage_service.dart';

// --- AUTHENTICATION STATES ---
abstract class AuthState {}

class AuthInitial extends AuthState {}

class Authenticated extends AuthState {
  final String email;
  Authenticated(this.email);
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {}

// --- AUTHENTICATION CUBIT ---
class AuthCubit extends Cubit<AuthState> {
  final StorageService storageService;
  static const String _userEmailKey = 'user_email'; // 💡 Using a constant prevents typing mistakes later

  AuthCubit(this.storageService) : super(AuthInitial());

  /// Checks if a session exists on app startup
  void checkAuthenticationSession() {
    try {
      final String? email = storageService.retrieveData(_userEmailKey);
      if (email != null && email.isNotEmpty) {
        emit(Authenticated(email));
      } else {
        emit(Unauthenticated());
      }
    } catch (_) {
      emit(Unauthenticated());
    }
  }

  /// Updates the application state AND saves data to disk when login succeeds
  // 🛠️ FIXED: Made this async to properly write to persistent local storage
  Future<void> loginUserInState(String email) async {
    try {
      // 💾 Save to disk so checkAuthenticationSession() can read it next time!
      await storageService.persistData(_userEmailKey, email);
      emit(Authenticated(email));
    } catch (_) {
      emit(AuthError());
    }
  }

  /// Clears the persistent session data and forces an Unauthenticated state change
  Future<void> logoutUserPermanently() async {
    try {
      // Overwrite storage keys with null to wipe the persistent state cache
      await storageService.persistData(_userEmailKey, null);
      await storageService.persistData('auth_token', null);
    } catch (_) {
      // Log error if storage service fails, but proceed to force UI logout anyway
    } finally {
      emit(Unauthenticated());
    }
  }
}