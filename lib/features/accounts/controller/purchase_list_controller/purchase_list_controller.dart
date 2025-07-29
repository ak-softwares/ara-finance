import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../common/dialog_box_massages/full_screen_loader.dart';
import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../data/repositories/mongodb/products/product_repositories.dart';
import '../../../../data/repositories/mongodb/purchase_list/purchase_list_repo.dart';
import '../../../../data/repositories/woocommerce/orders/woo_orders_repository.dart';
import '../../../../utils/constants/db_constants.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../../models/purchase_item_model.dart';

class PurchaseListController extends GetxController {

  // Variable
  RxInt currentPage = 1.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxBool isFetching = false.obs;
  RxBool isExtraTextUpdating = false.obs;
  RxList<OrderModel> orders = <OrderModel>[].obs;
  RxList<PurchaseItemModel> products = <PurchaseItemModel>[].obs;
  Rx<PurchaseListMetaModel> purchaseListMetaData = PurchaseListMetaModel().obs;
  TextEditingController extraNoteController = TextEditingController();

  final storage = GetStorage();

  final mongoProductRepo = Get.put(MongoProductRepo());
  final wooOrdersRepository = Get.put(WooOrdersRepository());
  final mongoPurchaseListRepo = Get.put(MongoPurchaseListRepo());

  // Using a single map to track expansion states
  var expandedSections = <String, Map<PurchaseListType, bool>>{}.obs;

  RxList<String> vendorNames = <String>[].obs;

  String get userId => AuthenticationController.instance.admin.value.id!;

  @override
  void onInit() {
    super.onInit();
    loadStoredProducts(); // Load data from storage when the controller initializes

    ever(expandedSections, (_) {
      storage.write(PurchaseListConstants.expandedSections,
        expandedSections.map((key, value) => MapEntry(key, value.cast<PurchaseListType, bool>()))
      );
    });
  }

//----------------------------------------------------------------------------------------------//

  // fetch orders
  Future<void> showDialogForSelectOrderStatus() async {
    Get.defaultDialog(
      contentPadding: const EdgeInsets.only(bottom: AppSizes.xl),
      titlePadding: const EdgeInsets.only(top: AppSizes.xl),
      radius: 10,
      title: "Choose Status",
      content: Obx(
            () => Column(
          mainAxisSize: MainAxisSize.min, // Prevents excessive height
          children: OrderStatus.values.where((status) => [OrderStatus.processing, OrderStatus.readyToShip, OrderStatus.pendingPickup,]
              .contains(status))
              .map((orderStatus) => CheckboxListTile(
            title: Text(orderStatus.prettyName),
            value: purchaseListMetaData.value.orderStatus?.contains(orderStatus) ?? false,
            onChanged: (value) => toggleSelection(orderStatus),
            controlAffinity: ListTileControlAffinity.leading, // Checkbox on left
          ),
          )
              .toList(),
        ),
      ),
      confirm: ElevatedButton(
        onPressed: confirmSelection,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: const Text("Fetch Orders"),
        ),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        style: TextButton.styleFrom(
          foregroundColor: Colors.red, // Use TColors.buttonBackground if needed
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text("Cancel"),
      ),
    );
  }

  void confirmSelection() {
    final selectedStatuses = purchaseListMetaData.value.orderStatus;

    if (selectedStatuses?.isNotEmpty ?? false) {
      Get.back(); // Close the popup
      syncOrders(orderStatus: selectedStatuses!);
    } else {
      AppMassages.errorSnackBar(title: 'Select at least one status');
    }
  }

  Future<void> syncOrders({required List<OrderStatus> orderStatus}) async {
    try {
      isFetching(true);
      currentPage.value = 1; // Reset page number
      orders.clear(); // Clear existing orders
      products.clear(); // Clear existing orders
      clearStoredProducts();
      await getAllOrdersByStatus(orderStatus: orderStatus);
      await mongoPurchaseListRepo.pushMetaData(
        userId: userId,
        value: {
          UserFieldConstants.userId: userId,
          PurchaseListFieldName.lastSyncDate: DateTime.timestamp(),
          PurchaseListFieldName.orderStatus: purchaseListMetaData.value.orderStatus?.map((e) => e.name).toList()
        },
      );
      purchaseListMetaData.value.lastSyncDate = DateTime.timestamp();
    } catch (error) {
      AppMassages.warningSnackBar(title: 'Errors', message: error.toString());
    } finally {
      isFetching(false);
    }
  }

  Future<void> getAllOrdersByStatus({required List<OrderStatus> orderStatus}) async {
    try {
      //start loader
      FullScreenLoader.openLoadingDialog('Processing your order', Images.docerAnimation);

      int currentPage = 1;
      List<OrderModel> newOrders = [];

      while (true) {
        // **Step 2: Fetch a batch of orders from API**
        List<OrderModel> fetchedOrders = await wooOrdersRepository.fetchOrdersByStatus(
          status: orderStatus.map((status) => status.name).toList(),
          page: currentPage.toString(),
        );
        if (fetchedOrders.isEmpty) break; // Stop if no more orders are available

        newOrders.addAll(fetchedOrders);
        currentPage++; // Move to the next page
      }
      orders.addAll(newOrders); // Add only new orders
      await getAggregatedProducts();
      await pushAllOrders();
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error in Orders Fetching', message: e.toString());
    } finally {
      FullScreenLoader.stopLoading();
    }
  }

  Future<void> deleteAllOrders() async {
    try {
      await mongoPurchaseListRepo.deleteAllOrders(userId: userId);
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error in Delete orders', message: e.toString());
    }
  }

  Future<void> pushAllOrders() async {
    try {
      for (var order in orders) {
        order.userId = userId;
      }
      await mongoPurchaseListRepo.pushOrders(orders: orders);
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error in Orders Pushing', message: e.toString());
    }
  }

//------------------------------------------------------------------------------------------------//

  // Initialize orders
  // Get all orders (fetch all pages iteratively)
  Future<void> getAllOrders() async {
    try {
      int page = 1; // Start with the first page
      orders.clear();
      // Fetch orders iteratively until no more orders are returned
      while (true) {
        final fetchedOrders = await mongoPurchaseListRepo.fetchOrders(userId: userId, page: page);
        if (fetchedOrders.isEmpty) break; // Stop if no more orders are available

        // Add fetched orders to the list
        orders.addAll(fetchedOrders);
        page++; // Move to the next page
      }
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error in Orders Fetching', message: e.toString());
    }
  }

  Future<void> refreshOrders() async {
    try {
      isLoading(true);
      currentPage.value = 1; // Reset page number
      orders.clear(); // Clear existing orders
      products.clear(); // Clear existing orders
      await getAllOrders();
      await getAggregatedProducts();
    } catch (error) {
      AppMassages.warningSnackBar(title: 'Errors', message: error.toString());
    } finally {
      isLoading(false);
    }
  }

//------------------------------------------------------------------------------------------------//


  Future<void> handleProductListUpdate({
    required int productId,
    required PurchaseListType purchaseListType,
    required DismissDirection direction,
  }) async {
    final metaData = purchaseListMetaData.value;

    switch (purchaseListType) {
      case PurchaseListType.purchasable:
        if (direction == DismissDirection.endToStart) {
          metaData.purchasedProductIds ??= [];
          metaData.purchasedProductIds?.add(productId);
        } else if (direction == DismissDirection.startToEnd) {
          metaData.notAvailableProductIds ??= []; // Initialize if null
          metaData.notAvailableProductIds?.add(productId);
        }
        break;

      case PurchaseListType.purchased:
        if (direction == DismissDirection.endToStart) {
          metaData.purchasedProductIds?.remove(productId);
        }
        break;

      case PurchaseListType.notAvailable:
        if (direction == DismissDirection.endToStart) {
          metaData.notAvailableProductIds?.remove(productId);
        }
        break;
      case PurchaseListType.vendors:
      // TODO: Handle this case.
        throw UnimplementedError();
    }
    purchaseListMetaData.refresh();
    await mongoPurchaseListRepo.pushMetaData(
      userId: userId,
      value: {
        PurchaseListFieldName.purchasedProductIds: purchaseListMetaData.value.purchasedProductIds?.toList(),
        PurchaseListFieldName.notAvailableProductIds: purchaseListMetaData.value.notAvailableProductIds?.toList()
      },
    );

  }

  Future<void> saveExtraNote(String extraNote) async {
    try{
      isExtraTextUpdating(true);
      await mongoPurchaseListRepo.pushMetaData(
        userId: userId,
        value: {
          PurchaseListFieldName.extraNote: extraNote,
        },
      );
      AppMassages.showToastMessage(message: 'Extra Notes updated successfully');
    } catch(e){
      AppMassages.errorSnackBar(title: 'Error in uploading Notes', message: e.toString());
    } finally{
      isExtraTextUpdating(false);
    }
  }

  // Ensure keys exist before using them
  void initializeExpansionState(String companyName) async {
    // Try to read the expansion state from local storage
    final storedExpandedSections = await storage.read(PurchaseListConstants.expandedSections);

    if (storedExpandedSections != null && storedExpandedSections.containsKey(companyName)) {
      // If the company's expansion state exists in local storage, use it
      final storedMap = Map<PurchaseListType, bool>.from(storedExpandedSections[companyName]);

      // Ensure all PurchaseListType keys exist, defaulting to false if missing
      expandedSections[companyName] = {
        PurchaseListType.vendors: storedMap[PurchaseListType.vendors] ?? false,
        PurchaseListType.purchasable: storedMap[PurchaseListType.purchasable] ?? false,
        PurchaseListType.purchased: storedMap[PurchaseListType.purchased] ?? false,
        PurchaseListType.notAvailable: storedMap[PurchaseListType.notAvailable] ?? false,
      };
    } else {
      // If the company's expansion state does not exist in local storage, initialize it with default values
      expandedSections.putIfAbsent(companyName, () => {
        PurchaseListType.vendors: false,
        PurchaseListType.purchasable: false,
        PurchaseListType.purchased: false,
        PurchaseListType.notAvailable: false,
      });
    }
  }

  Future<void> loadStoredProducts() async {
    await refreshOrders();
    purchaseListMetaData.value = await mongoPurchaseListRepo.fetchMetaData(userId: userId);
    extraNoteController.text = purchaseListMetaData.value.extraNote ?? '';
  }

  Future<void> clearStoredProducts() async {
    await deleteAllOrders();
    await mongoPurchaseListRepo.deleteMetaData(id: purchaseListMetaData.value.id!);
    // Also clear in-memory data
    orders.clear();
    products.clear();
    purchaseListMetaData.value = PurchaseListMetaModel(orderStatus: purchaseListMetaData.value.orderStatus);
  }

  // Update this method to filter by vendor name directly
  List<PurchaseItemModel> filterProductsByVendor({required String vendorName}) {
    if (vendorName == 'Other') {
      return products.where((product) => product.vendor == null || product.vendor!.isEmpty).toList();
    }
    return products.where((product) => product.vendor == vendorName).toList();
  }

  Future<void> getAggregatedProducts() async {
    try {
      Map<int, PurchaseItemModel> productMap = {}; // Store unique products
      DateTime twoDaysAgo = DateTime.now().subtract(Duration(days: 2));

      // First collect all unique product IDs from all orders
      Set<int> productIds = {};
      for (var order in orders) {
        for (var lineItem in order.lineItems!) {
          productIds.add(lineItem.productId);
        }
      }

      // Fetch fresh product details for all unique product IDs
      final List<ProductModel> freshProducts = await mongoProductRepo.fetchProductsByProductIds(productIds: productIds.toList());

      // Now process orders with fresh product data
      for (var order in orders) {
        bool isPrepaidOrder = order.paymentMethod != PaymentMethods.cod.name;
        bool isBulkOrder = (order.lineItems?.length ?? 0) > 1;
        DateTime? orderDate = order.dateCreated;
        bool isOlderThanTwoDays = orderDate != null && orderDate.isBefore(twoDaysAgo);

        for (var lineItem in order.lineItems!) {
          int productId = lineItem.productId;
          var freshProduct = freshProducts.firstWhere((p) => p.productId == productId);

          if (productMap.containsKey(productId)) {
            // Update existing product quantities
            productMap[productId]!.prepaidQuantity = (productMap[productId]!.prepaidQuantity ?? 0) + (isPrepaidOrder ? lineItem.quantity : 0);
            productMap[productId]!.bulkQuantity = (productMap[productId]!.bulkQuantity ?? 0) + (isBulkOrder ? lineItem.quantity : 0);
            productMap[productId]!.totalQuantity = (productMap[productId]!.totalQuantity ?? 0) + lineItem.quantity;
          } else {
            // Create new product entry with fresh data
            productMap[productId] = PurchaseItemModel(
              id: productId,
              image: freshProduct.mainImage ?? '',
              name: freshProduct.title ?? '',
              prepaidQuantity: isPrepaidOrder ? lineItem.quantity : 0,
              bulkQuantity: isBulkOrder ? lineItem.quantity : 0,
              totalQuantity: lineItem.quantity,
              isOlderThanTwoDays: isOlderThanTwoDays,
              stock: freshProduct.stockQuantity,
              vendor: freshProduct.vendor?.title,
            );
          }
        }
      }

      // Remove products where total ordered quantity is less than or equal to available stock
      productMap.removeWhere((key, product) {
        final stock = product.stock ?? 0;
        final totalQty = product.totalQuantity ?? 0;
        return totalQty <= stock;
      });

      // Sort products (same as before)
      List<PurchaseItemModel> sortedProducts = productMap.values.toList()
        ..sort((a, b) {
          int cmp = (b.prepaidQuantity ?? 0).compareTo(a.prepaidQuantity ?? 0);
          if (cmp != 0) return cmp;

          cmp = (b.bulkQuantity ?? 0).compareTo(a.bulkQuantity ?? 0);
          if (cmp != 0) return cmp;

          bool aOld = a.isOlderThanTwoDays ?? false;
          bool bOld = b.isOlderThanTwoDays ?? false;

          if (bOld && !aOld) return 1;
          if (aOld && !bOld) return -1;

          return (b.totalQuantity ?? 0).compareTo(a.totalQuantity ?? 0);
        });

      // Extract unique vendor names from products
      final uniqueVendors = productMap.values
          .map((product) => product.vendor ?? '')
          .where((vendor) => vendor.isNotEmpty)
          .toSet()
          .toList();

      vendorNames.assignAll(uniqueVendors);
      vendorNames.add('Other'); // Add "Other" category for products without vendor
      products.assignAll(sortedProducts);
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error fetching products', message: e.toString());
    }
  }

  void toggleSelection(OrderStatus orderStatus) {
    final updatedOrderStatus = List<OrderStatus>.from(purchaseListMetaData.value.orderStatus ?? []);

    if (updatedOrderStatus.contains(orderStatus)) {
      updatedOrderStatus.remove(orderStatus);
    } else {
      updatedOrderStatus.add(orderStatus);
    }

    purchaseListMetaData.value = purchaseListMetaData.value.copyWith(orderStatus: updatedOrderStatus);
  }


}
