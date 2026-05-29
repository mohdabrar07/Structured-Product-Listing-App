import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/storage_service.dart';

class AddressState {
  final String shippingAddress;
  AddressState({required this.shippingAddress});
}

class AddressCubit extends Cubit<AddressState> {
  AddressCubit() : super(AddressState(shippingAddress: '')) {
    _hydrateAddress();
  }

  void _hydrateAddress() {
    final savedAddress = StorageService.getAddress();
    emit(AddressState(shippingAddress: savedAddress));
  }

  void saveNewAddress(String textAddress) async {
    await StorageService.saveAddress(textAddress);
    emit(AddressState(shippingAddress: textAddress));
  }
}