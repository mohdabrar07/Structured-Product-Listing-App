import 'package:flutter_bloc/flutter_bloc.dart';

class AddressCubit extends Cubit<String> {
  AddressCubit() : super(''); // Defaults to an empty address

  void updateAddress(String newAddress) {
    emit(newAddress.trim());
  }
}