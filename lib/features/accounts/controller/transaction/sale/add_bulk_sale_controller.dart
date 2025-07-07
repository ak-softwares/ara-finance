import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../../common/dialog_box_massages/dialog_massage.dart';
import '../../../../../common/dialog_box_massages/full_screen_loader.dart';
import '../../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../../data/repositories/mongodb/transaction/transaction_repo.dart';
import '../../../../../data/repositories/woocommerce/orders/woo_orders_repository.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../../../personalization/models/user_model.dart';
import '../../../models/account_voucher_model.dart';
import '../../../models/cart_item_model.dart';
import '../../../models/order_model.dart';
import '../../../models/product_model.dart';
import '../../../models/transaction_model.dart';
import '../../product/product_controller.dart';
import '../transaction_controller.dart';

class AddBulkSaleController extends GetxController {
  static AddBulkSaleController get instance => Get.find();

  final AccountVoucherType voucherType = AccountVoucherType.sale;
  var isScanning = false.obs;
  RxInt transactionId = 0.obs;

  RxList<TransactionModel> newSales = <TransactionModel>[].obs;
  Rx<AccountVoucherModel> selectedSaleVoucher = AccountVoucherModel().obs;
  Rx<AccountVoucherModel> selectedCustomer = AccountVoucherModel().obs;

  int get saleTotal => newSales.fold(0, (sum, sale) => (sum + (sale.amount ?? 0)).toInt());

  final addOrderTextEditingController = TextEditingController();

  final authenticationController = Get.put(AuthenticationController);
  final mongoTransactionRepo = Get.put(MongoTransactionRepo());
  final wooOrdersRepository = Get.put(WooOrdersRepository());
  final transactionController = Get.put(TransactionController());
  final productController = Get.put(ProductController());

  UserModel get admin => AuthenticationController.instance.admin.value;
  String get userId => AuthenticationController.instance.admin.value.id!;

  @override
  Future<void> onInit() async {
    super.onInit();
    transactionId.value = await mongoTransactionRepo.fetchTransactionGetNextId(userId: userId, voucherType: voucherType);
  }

  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }

  void selectSaleVoucher(AccountVoucherModel getSelectedSale) {
    selectedSaleVoucher.value = getSelectedSale;
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
        final orderNumber = barcode.rawValue;
        await processAddSale(orderNumber: orderNumber ?? '');
      }

      Future.delayed(const Duration(seconds: 2), () {
        isScanning.value = false;
      });
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error: ', message: e.toString());
    } finally {
      FullScreenLoader.stopLoading();
    }
  }

  Future<void> addManualSale() async {
    try {
      isScanning(true);
      FullScreenLoader.onlyCircularProgressDialog('Fetching Order...');
      await processAddSale(orderNumber: addOrderTextEditingController.text);
    } catch(e){
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    } finally{
      FullScreenLoader.stopLoading();
      isScanning(false);
    }
  }

  Future<void> processAddSale({required String orderNumber}) async {
    try {
      final int manualOrderNumber = int.tryParse(orderNumber) ?? 0;

      // 1. Check if order already exists in local list
      final bool exists = newSales.any((order) => order.orderIds?.first == manualOrderNumber);
      if (exists) throw 'This order number already exists.';

      HapticFeedback.mediumImpact();

      // 2. Fetch WooCommerce order
      final OrderModel sale = await wooOrdersRepository.fetchOrderById(orderId: orderNumber);

      // 3. Check if transaction already exists in DB
      final TransactionModel checkIsSaleExist = await transactionController
          .getTransactionByOrderId(orderId: manualOrderNumber, voucherType: voucherType);
      if (checkIsSaleExist.id != null) throw 'Sale already exist';

      // 4. Extract productIds from sale.lineItems
      final List<int> productIds = sale.lineItems!.map((item) => item.productId).toSet().toList();

      if (productIds.isEmpty) throw 'No products found. Please sync products.';

      // 5. Fetch products from MongoDB
      final List<ProductModel> products = await productController.getProductsByProductIds(productIds: productIds);

      // 6. Enrich products into CartModel using quantity from lineItems
      final List<CartModel> enrichedItems = sale.lineItems!.map((item) {
        final matchedProduct = products.firstWhere(
              (p) => p.productId == item.productId,
          orElse: () => throw 'Product ${item.productId} not found. Please sync.',
        );

        return productController.convertProductToCart(
          product: matchedProduct,
          quantity: item.quantity,
        );
      }).toList();

      final getTransactionId = transactionId.value + newSales.length;
      // 7. Create and insert transaction
      final TransactionModel transaction = TransactionModel(
        transactionId: getTransactionId,
        orderIds: [sale.orderId ?? 0],
        discount: sale.discountTotal,
        shipping: sale.shippingTotal,
        amount: sale.total,
        date: sale.dateCreated ?? DateTime.now(),
        products: enrichedItems,
        couponLines: sale.couponLines,
        orderAttribute: sale.orderAttribute,
        paymentMethod: sale.paymentMethod,
        transactionType: AccountVoucherType.sale,
        address: sale.billing
      );

      newSales.insert(0, transaction);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> pushBulkSale() async {
    try {
      FullScreenLoader.onlyCircularProgressDialog('Adding Sales...');
      if (selectedSaleVoucher.value.id == null) {
        throw 'Plz select sale voucher';
      }
      if (selectedCustomer.value.id == null) {
        throw 'Plz select customer voucher';
      }
      for (var order in newSales) {
        order.userId = userId;
        order.status = OrderStatus.inTransit;
        order.dateShipped = DateTime.now();
        order.fromAccountVoucher = selectedSaleVoucher.value;
        order.toAccountVoucher = selectedCustomer.value;
      }
      await transactionController.processTransactions(transactions: newSales);
      newSales.clear();
      Get.back();
      AppMassages.showToastMessage(message: 'Sale Added Successfully');
    } catch(e) {
      AppMassages.errorSnackBar(title: 'Error sale', message: e.toString());
    } finally {
      FullScreenLoader.stopLoading();
    }
  }


  Future<void> getAllNewSalesWithDialog({required BuildContext context}) async {
    try {
      DialogHelper.showDialog(
          context: context,
          title: 'Fetch Orders',
          message: 'Do you want to fetch new sales from WooCommerce?',
          actionButtonText: 'Fetch',
          toastMessage: 'New orders fetched successfully!',
          isShowLoading: false,
          onSubmit: () async {
            await getWooAllNewSales();
          }
      );
    } catch(e){
      AppMassages.errorSnackBar(title: 'Error in Orders Fetching', message: e.toString());
    }
  }

  Future<void> getWooAllNewSales() async {
    try {
      FullScreenLoader.onlyCircularProgressDialog('Fetching WooCommerce Orders...');
      int currentPage = 1;
      List<OrderModel> allFetchedOrders = [];

      // Step 1: Fetch all orders page by page
      while (true) {
        List<OrderModel> pagedOrders = await wooOrdersRepository.fetchOrdersByStatus(
          status: [OrderStatus.pendingPickup.name, OrderStatus.inTransit.name],
          page: currentPage.toString(),
        );
        if (pagedOrders.isEmpty) {
          FullScreenLoader.stopLoading();
          break;
        }

        allFetchedOrders.addAll(pagedOrders);
        currentPage++;
      }

      // // Step 2: Extract non-null order IDs from fetched orders
      // final List<int> fetchedOrderIds = allFetchedOrders.map((order) => order.orderId).whereType<int>().toList();
      //
      // // Step 3: Fetch existing orders from the database
      // final List<OrderModel> existingOrders = await saleController.getSaleByOrderIds(orderIds: fetchedOrderIds);
      // final List<OrderModel> newUniqueOrders = allFetchedOrders.where((order) {
      //   return order.orderId != null &&
      //       !existingOrders.any((existing) => existing.orderId == order.orderId);
      // }).toList();
      //
      // // Step 5: Add only new unique orders and avoid adding duplicates
      // for (final order in newUniqueOrders) {
      //   if (!newSales.any((o) => o.orderId == order.orderId)) {
      //     order.userId = AuthenticationController.instance.admin.value.id;
      //     newSales.add(order);
      //   }
      // }
      // FullScreenLoader.stopLoading();
    } catch (e) {
      rethrow;
    }
  }

}