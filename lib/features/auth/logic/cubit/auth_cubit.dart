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

  AuthCubit(this.storageService) : super(AuthInitial());

  /// Checks if a session exists on app startup
  void checkAuthenticationSession() {
    try {
      final String? email = storageService.retrieveData('user_email');
      if (email != null && email.isNotEmpty) {
        emit(Authenticated(email));
      } else {
        emit(Unauthenticated());
      }
    } catch (_) {
      emit(Unauthenticated());
    }
  }

  /// Updates the application state to Authenticated when login succeeds
  void loginUserInState(String email) {
    emit(Authenticated(email));
  }

  /// Clears the persistent session data and forces an Unauthenticated state change
  void logoutUserPermanently() async {
    // Overwrite storage keys with null to wipe the persistent state cache
    await storageService.persistData('user_email', null);
    await storageService.persistData('auth_token', null);
    
    emit(Unauthenticated());
  }
}