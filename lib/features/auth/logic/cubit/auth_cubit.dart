import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/storage_service.dart';

sealed class AuthState {}
class AuthLoggedOut extends AuthState {}
class AuthLoggedIn extends AuthState {}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthLoggedOut()) {
    _hydrateSession();
  }

  // RESTART TESTING ACTION: Read persistent key on bootup
  void _hydrateSession() {
    final bool isLoggedIn = StorageService.getLoginSession();
    if (isLoggedIn) {
      emit(AuthLoggedIn());
    } else {
      emit(AuthLoggedOut());
    }
  }

  void login() async {
    await StorageService.saveLoginSession(true);
    emit(AuthLoggedIn());
  }

  void logout() async {
    await StorageService.clearAllData(); // Wipes everything for security
    emit(AuthLoggedOut());
  }
}