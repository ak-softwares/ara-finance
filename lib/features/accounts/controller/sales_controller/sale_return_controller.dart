import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../common/dialog_box_massages/full_screen_loader.dart';
import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../data/repositories/mongodb/orders/orders_repositories.dart';
import '../../../../utils/constants/db_constants.dart';
import '../../../../utils/constants/enums.dart';
import '../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../../personalization/models/user_model.dart';
import '../../models/cart_item_model.dart';
import '../../models/order_model.dart';
import '../../models/transaction_model.dart';
import '../product/product_controller.dart';
import '../transaction/transaction_controller.dart';
import 'sales_controller.dart';

class SaleReturnController extends GetxController {
  static SaleReturnController get instance => Get.find();

  RxBool isScanning = false.obs;
  RxList<OrderModel> returns = <OrderModel>[].obs;
  Rx<UserModel> selectedCustomer = UserModel().obs;

  final returnOrderTextEditingController = TextEditingController();

  final productController = Get.put(ProductController());
  final mongoOrderRepo = Get.put(MongoOrderRepo());
  final saleController = Get.put(SaleController());
  final transactionController = Get.put(TransactionController());

  UserModel get admin => AuthenticationController.instance.admin.value;

  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }
  void addCustomer(UserModel getSelectedCustomer) {
    selectedCustomer.value = getSelectedCustomer;
  }

  final MobileScannerController cameraController = MobileScannerController(
    torchEnabled: false,
    formats: [BarcodeFormat.all],
  );

  Future<void> handleDetection(BarcodeCapture capture) async {
    if (isScanning.value) return;
    try {
      FullScreenLoader.onlyCircularProgressDialog('Fetching Order...');
      isScanning.value = true;

      for (final barcode in capture.barcodes) {
        final value = int.tryParse(barcode.rawValue ?? '');
        bool exists = returns.any((order) => order.orderId == value);
        if (value != null && !exists) {
          HapticFeedback.mediumImpact();
          final OrderModel getReturn = await saleController.getSaleByOrderId(orderId: value);
          if(getReturn.id == null) {
            throw 'No sale found to add return';
          }
          returns.insert(0, getReturn);
        }
      }

      Future.delayed(const Duration(seconds: 2), () {
        isScanning.value = false;
      });
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error in Order Fetching', message: e.toString());
    } finally {
      FullScreenLoader.stopLoading();
    }
  }


  Future<void> addManualReturn() async {
    try {
      isScanning(true);
      FullScreenLoader.onlyCircularProgressDialog('Fetching Order...');
      final int manualOrderNumber = int.tryParse(returnOrderTextEditingController.text) ?? 0;
      final bool exists = returns.any((order) => order.orderId == manualOrderNumber);

      if (exists) {
        // Order already exists
        AppMassages.errorSnackBar(title: 'Duplicate', message: 'This order number already exists.');
      } else {
        HapticFeedback.mediumImpact();
        // checkIsSaleExist
        final OrderModel checkIsSaleExist = await saleController.getSaleByOrderId(orderId: manualOrderNumber);
        if(checkIsSaleExist.id == null) {
          throw 'Sale does not exist';
        }
        returns.insert(0, checkIsSaleExist);
      }
    } catch(e){
      AppMassages.errorSnackBar(title: 'Error', message: 'Add manual order failed: ${e.toString()}');
    } finally{
      FullScreenLoader.stopLoading();
      isScanning(false);
    }
  }

  Future<void> updateReturn() async {
    try {
      FullScreenLoader.onlyCircularProgressDialog('Update Return...');

      await processReturnSale(salesReturn: returns);
      returns.clear();
      Get.back();
      AppMassages.showToastMessage(message: 'Return updated successfully');
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error sale', message: e.toString());
    } finally {
      FullScreenLoader.stopLoading();
    }
  }

  Future<void> processReturnSale({required List<OrderModel> salesReturn}) async {
    try {
      // Filter out orders that are already completed
      final pendingSales = salesReturn.where((sale) => sale.status != OrderStatus.returned).toList();

      // If no pending sales remain, exit early
      if (pendingSales.isEmpty) {
        throw('All orders are already completed. No transaction created.');
      }

      if (selectedCustomer.value.id == null) {
        throw('Please select customer');
      }

      // Calculate total amount from pending sales
      final totalAmount = pendingSales.fold(0.0, (sum, sale) => sum + (sale.total ?? 0.0));

      // Collect orderIds for the transaction
      final salesIds = pendingSales.map((sale) => sale.orderId).whereType<int>().toList();

      // Create the transaction model
      final transaction = TransactionModel(
        amount: totalAmount,
        date: DateTime.now(),
        userId: admin.id,
      );

      // Process the transaction
      final transactionId = await transactionController.processTransaction(transaction: transaction);
      for (var sale in pendingSales) {
        sale.transaction = transaction;
      }      // Update the status of only pending orders
      final Map<String, dynamic> data = {
        OrderFieldName.status: OrderStatus.returned.name,
        OrderFieldName.dateReturned: DateTime.now(),
        OrderFieldName.transaction: transaction.toMap(),
      };

      // Flatten all line items from each return
      final List<CartModel> allLineItems = pendingSales.expand<CartModel>((returned) => returned.lineItems ?? []).toList();

      // Define the async operations
      await productController.updateProductQuantity(cartItems: allLineItems, isAddition: true);

      await mongoOrderRepo.updateOrders(orders: pendingSales, updatedData: data);
    } catch (e) {
      rethrow;
    }
  }

}