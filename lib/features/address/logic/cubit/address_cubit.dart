import 'package:hydrated_bloc/hydrated_bloc.dart';

class AddressCubit extends HydratedCubit<Map<String, String>> {
  // State maps a User Email key directly to an Address string value: { "user@email.com": "123 Main St" }
  AddressCubit() : super({});

  void saveUserShippingAddress(String email, String address) {
    final updatedMap = Map<String, String>.from(state);
    updatedMap[email] = address;
    emit(updatedMap);
  }

  // Returns the address for a specific user, fallback to empty string if missing
  String getAddressForUser(String email) {
    return state[email] ?? '';
  }

  @override
  Map<String, String>? fromJson(Map<String, dynamic> json) {
    try {
      return Map<String, String>.from(json['user_addresses'] ?? {});
    } catch (_) {
      return {};
    }
  }

  @override
  Map<String, dynamic>? toJson(Map<String, String> state) {
    return {
      'user_addresses': state,
    };
  }
}