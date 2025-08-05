import 'package:get/get.dart';

import '../common/widgets/network_manager/network_manager.dart';
import '../data/repositories/woocommerce/customers/woo_customer_repository.dart';
import '../features/personalization/controllers/address_controller.dart';
import '../features/authentication/controllers/authentication_controller/authentication_controller.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NetworkManager());
    Get.lazyPut(() => AuthenticationController());
    Get.lazyPut(() => AddressController());

    Get.lazyPut(() => WooCustomersRepository());
  }
}