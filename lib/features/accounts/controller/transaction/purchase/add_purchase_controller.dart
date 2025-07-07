import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/dialog_box_massages/full_screen_loader.dart';
import '../../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../../common/widgets/network_manager/network_manager.dart';
import '../../../../../data/repositories/image_kit/image_kit_repo.dart';
import '../../../../../data/repositories/mongodb/transaction/transaction_repo.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../../models/account_voucher_model.dart';
import '../../../models/cart_item_model.dart';
import '../../../models/image_model.dart';
import '../../../models/product_model.dart';
import '../../../models/transaction_model.dart';
import '../../product/product_controller.dart';
import '../transaction_controller.dart';

class AddPurchaseTransactionController extends GetxController {
  static AddPurchaseTransactionController get instance => Get.find();

  final AccountVoucherType voucherType = AccountVoucherType.purchase;
  RxInt transactionId = 0.obs;

  Rx<AccountVoucherModel> selectedVendor = AccountVoucherModel().obs;
  Rx<AccountVoucherModel> selectedPurchaseVoucher = AccountVoucherModel().obs;
  RxList<CartModel> selectedProducts = <CartModel>[].obs;

  RxDouble purchaseTotal = 0.0.obs;
  RxInt productCount = 0.obs;

  final date = TextEditingController();
  GlobalKey<FormState> purchaseFormKey = GlobalKey<FormState>();

  RxBool isUploadingImage = false.obs;
  RxBool isDeletingImage = false.obs;
  Rx<File?> image = Rx<File?>(null);
  RxString uploadedImageUrl = ''.obs;
  final ImageKitService imageKitService = ImageKitService();
  RxList<ImageModel> purchaseInvoiceImages = <ImageModel>[].obs;

  final mongoTransactionRepo = Get.put(MongoTransactionRepo());
  final transactionController = Get.put(TransactionController());
  final productController = Get.put(ProductController());

  String get userId => AuthenticationController.instance.admin.value.id!;

  @override
  Future<void> onInit() async {
    super.onInit();
    date.text = DateTime.now().toIso8601String();
    transactionId.value = await mongoTransactionRepo.fetchTransactionGetNextId(userId: userId, voucherType: voucherType);
  }


  @override
  void onClose() {
    clearPurchaseTransaction();
    super.onClose();
  }


  Future<void> pickImage() async {
    final pickedImage = await imageKitService.pickImage();
    if (pickedImage != null) {
      purchaseInvoiceImages.add(ImageModel(
          image: pickedImage
      ));
    }
  }

  Future<void> uploadImage(ImageModel image) async {
    try {
      isUploadingImage(true);
      if (image.image != null) {
        final fetchImage = await imageKitService.uploadImage(image.image!);
        if (fetchImage.imageUrl != null) {
          int index = purchaseInvoiceImages.indexWhere((img) => img.imageId == image.imageId);
          if (index != -1) {
            purchaseInvoiceImages[index].imageUrl = fetchImage.imageUrl; // Directly update the property
            purchaseInvoiceImages[index].imageId = fetchImage.imageId; // Directly update the property
            purchaseInvoiceImages.refresh(); // Notify listeners about the change
          }
          AppMassages.showToastMessage(message: 'Image Upload successfully');
        }
      }
    } catch(e) {
      AppMassages.errorSnackBar(title: 'Error Upload Image', message: e.toString());
    } finally {
      isUploadingImage(false);
    }
  }

  Future<void> deleteImage(ImageModel image) async {
    try {
      isDeletingImage(true);
      if (image.imageId != null && image.imageId!.isNotEmpty) {
        await imageKitService.deleteImage(image.imageId!);
        AppMassages.showToastMessage(message: 'Image Deleted successfully');
      }
      purchaseInvoiceImages.removeWhere((img) => img.image == image.image);
    } catch(e) {
      AppMassages.errorSnackBar(title: 'Error Delete Image', message: e.toString());
    } finally {
      isDeletingImage(false);
    }
  }

  void selectVendor(AccountVoucherModel getSelectedVendor) {
    selectedVendor.value = getSelectedVendor;
  }

  void selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      date.text = pickedDate.toIso8601String();
      update();
    }
  }

  void addProducts(List<ProductModel> getSelectedProducts) {
    bool isUpdated = false;

    for (var product in getSelectedProducts) {
      bool alreadyExists = selectedProducts.any((item) => item.productId == product.productId);

      if (!alreadyExists) {
        final cartItem = productController.convertProductToCart(
          product: product,
          quantity: 1,
          variationId: 0,
        );

        selectedProducts.add(cartItem);
        isUpdated = true;
      }
    }

    if (isUpdated) {
      updatePurchaseTotal();
    }
  }

  void removeProducts(CartModel item) {
    int index = selectedProducts.indexWhere((cartItem) => cartItem.productId == item.productId);
    if(index >= 0) {
      selectedProducts.removeAt(index);
    }
    updatePurchaseTotal();
  }

  void updatePurchaseTotal(){
    double calculateTotalPrice = 0.0;
    int calculatedNoOfItems = 0;

    for(var item in selectedProducts){
      calculateTotalPrice += (item.purchasePrice!) * item.quantity;
      calculatedNoOfItems += item.quantity;
    }
    purchaseTotal.value = calculateTotalPrice;
    productCount.value = calculatedNoOfItems;
    selectedProducts.refresh();
  }


  void updateQuantity({required CartModel item, required int quantity}) {
    int index = selectedProducts.indexWhere((cartItem) => cartItem.productId == item.productId);
    if(index >= 0){
      selectedProducts[index].quantity = quantity;
      selectedProducts[index].total = (selectedProducts[index].quantity * selectedProducts[index].price!).toStringAsFixed(0);
    }
    updatePurchaseTotal();
  }

  void updatePrice({required CartModel item, required double purchasePrice}) {
    int index = selectedProducts.indexWhere((cartItem) => cartItem.productId == item.productId);
    if(index >= 0){
      selectedProducts[index].purchasePrice = purchasePrice;
      selectedProducts[index].total = (selectedProducts[index].quantity * selectedProducts[index].price!).toStringAsFixed(0);
    }
    updatePurchaseTotal();
  }

  void savePurchaseTransaction() {
    TransactionModel transaction = TransactionModel(
      userId: userId,
      transactionId: transactionId.value,
      amount: purchaseTotal.value,
      date: DateTime.tryParse(date.text) ?? DateTime.now(),
      fromAccountVoucher: selectedVendor.value,
      toAccountVoucher: selectedPurchaseVoucher.value,
      products: selectedProducts,
      transactionType: AccountVoucherType.purchase,
    );

    addPurchaseTransaction(transaction: transaction);
  }

  Future<void> addPurchaseTransaction({required TransactionModel transaction}) async {
    try {
      FullScreenLoader.openLoadingDialog('Saving your purchase transaction...', Images.docerAnimation);

      await validatePurchaseFields();

      await transactionController.processTransactions(transactions: [transaction]);
      await clearPurchaseTransaction();

      FullScreenLoader.stopLoading();
      transactionController.refreshTransactions();
      AppMassages.showToastMessage(message: 'Purchase transaction added successfully!');
      Navigator.of(Get.context!).pop();
    } catch (e) {
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<bool> validatePurchaseFields() async {
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        throw 'Internet not connected';
      }
      if (!purchaseFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        throw 'Form is not valid';
      }
      if (userId.isEmpty) {
        throw Exception('User ID is required.');
      }
      if (selectedProducts.isEmpty) {
        throw Exception('Please select at least one product.');
      }
      if (selectedVendor.value.id == null) {
        throw Exception('Please select a supplier.');
      }
      if (date.text.isEmpty) {
        throw Exception('Please enter a date.');
      }
      if (selectedProducts.isEmpty) {
        throw Exception('Please select at least one product.');
      }
      // Check if any image does not have a URL
      if (purchaseInvoiceImages.any((image) => image.imageUrl == null || image.imageUrl!.isEmpty)) {
        throw Exception('One of the Invoice images is not uploaded');
      }
      return true;
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Validation Error', message: e.toString());
      return false;
    }
  }

  Future<void> clearPurchaseTransaction() async {
    transactionId.value = await mongoTransactionRepo.fetchTransactionGetNextId(userId: userId, voucherType: voucherType);
    selectedPurchaseVoucher.value = AccountVoucherModel();
    selectedVendor.value = AccountVoucherModel();
    selectedProducts.value = [];
    date.text = DateTime.now().toIso8601String();
  }

  void resetValue(TransactionModel transaction) {
    transactionId.value = transaction.transactionId ?? 0;
    purchaseTotal.value = 0.0;
    date.text = transaction.date?.toIso8601String() ?? '';
    selectedVendor.value = transaction.fromAccountVoucher ?? AccountVoucherModel();
    selectedPurchaseVoucher.value = transaction.toAccountVoucher ?? AccountVoucherModel();
    selectedProducts.value = transaction.products ?? [];
    updatePurchaseTotal();
  }

  void saveUpdatedPurchaseTransaction({required TransactionModel oldPurchaseTransaction}) {
    TransactionModel newPurchaseTransaction = TransactionModel(
      id: oldPurchaseTransaction.id,
      transactionId: oldPurchaseTransaction.transactionId,
      amount: purchaseTotal.value,
      date: DateTime.tryParse(date.text) ?? oldPurchaseTransaction.date,
      fromAccountVoucher: selectedVendor.value,
      toAccountVoucher: selectedPurchaseVoucher.value,
      products: selectedProducts,
      transactionType: oldPurchaseTransaction.transactionType,
    );

    updateTransaction(transaction: newPurchaseTransaction);
  }

  Future<void> updateTransaction({required TransactionModel transaction}) async {
    try {
      FullScreenLoader.openLoadingDialog('Updating purchase transaction...', Images.docerAnimation);

      await validatePurchaseFields();

      await transactionController.processUpdateTransaction(transaction: transaction);

      FullScreenLoader.stopLoading();
      await transactionController.refreshTransactions();
      AppMassages.showToastMessage(message: 'Purchase transaction updated successfully!');
      Get.close(2);
    } catch (e) {
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }
}
