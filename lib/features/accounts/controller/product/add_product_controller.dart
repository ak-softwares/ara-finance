import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/full_screen_loader.dart';
import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../common/widgets/network_manager/network_manager.dart';
import '../../../../data/repositories/mongodb/products/product_repositories.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../../personalization/models/user_model.dart';
import '../../models/account_voucher_model.dart';
import '../../models/product_model.dart';
import 'product_controller.dart';

class AddProductController extends GetxController {
  static AddProductController get instance => Get.find();


  // Form Key
  TextEditingController productTitleController = TextEditingController();
  TextEditingController purchasePriceController = TextEditingController();
  TextEditingController openingStock = TextEditingController();
  TextEditingController hsnCode = TextEditingController();
  TaxRate selectedTaxRate = TaxRate.rate18;

  Rx<AccountVoucherModel> selectedVendor = AccountVoucherModel().obs;
  final GlobalKey<FormState> productFormKey = GlobalKey<FormState>();

  final mongoProductRepo = Get.put(MongoProductRepo());
  final productController = Get.put(ProductController());

  String get userId => AuthenticationController.instance.admin.value.id ?? '';

  void addVendor(AccountVoucherModel getSelectedVendor) {
    selectedVendor.value = getSelectedVendor;
  }

  // Save Product
  void saveProduct() {
    ProductModel product = ProductModel(
      userId: userId,
      title: productTitleController.text,
      purchasePrice: double.tryParse(purchasePriceController.text) ?? 0.0,
      openingStock: int.tryParse(openingStock.text) ?? 0,
      dateCreated: DateTime.now(),
      hsnCode: int.tryParse(hsnCode.text) ?? 0,
      taxRate: selectedTaxRate,
      vendor: selectedVendor.value,
    );

    addProduct(product: product);
  }

  // Add Product
  Future<void> addProduct({required ProductModel product}) async {
    try {
      FullScreenLoader.openLoadingDialog('Adding new product...', Images.docerAnimation);

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        return;
      }

      await mongoProductRepo.pushProduct(product: product);

      await productController.refreshProducts();
      clearProductFields();
      FullScreenLoader.stopLoading();
      AppMassages.showToastMessage(message: 'Product added successfully!');
      Navigator.of(Get.context!).pop();
    } catch (e) {
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  // Clear Product Fields
  void clearProductFields() {
    productTitleController.text = '';
    purchasePriceController.text = '';
    openingStock.text = '';
    hsnCode.text = '';
    selectedVendor.value = AccountVoucherModel();
  }

  // Reset Product Values
  void resetProductValues(ProductModel product) {
    productTitleController.text = product.title ?? '';
    purchasePriceController.text = product.purchasePrice.toString();
    openingStock.text = (product.openingStock ?? 0).toString();
    hsnCode.text = (product.hsnCode ?? 0).toString();
    selectedTaxRate = product.taxRate ?? TaxRate.rate18;
    selectedVendor.value = product.vendor ?? AccountVoucherModel();
  }

  // Save Updated Product
  void saveUpdatedProduct({required ProductModel previousProduct}) {
    ProductModel product = ProductModel(
      id: previousProduct.id,
      title: productTitleController.text,
      purchasePrice: double.tryParse(purchasePriceController.text) ?? 0.0,
      openingStock: int.tryParse(openingStock.text) ?? 0,
      dateModified: DateTime.now(),
      hsnCode: int.tryParse(hsnCode.text) ?? 0,
      taxRate: selectedTaxRate,
      vendor: selectedVendor.value,
    );

    updateProduct(product: product);
  }

  // Update Product
  Future<void> updateProduct({required ProductModel product}) async {
    try {
      FullScreenLoader.openLoadingDialog('Updating product...', Images.docerAnimation);

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        return;
      }

      await mongoProductRepo.updateProduct(id: product.id ?? '', product: product);

      await productController.refreshProducts();
      FullScreenLoader.stopLoading();
      AppMassages.showToastMessage(message: 'Product updated successfully!');
      Get.close(2); // Closes two routes/screens
    } catch (e) {
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

}