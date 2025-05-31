import 'package:get/get.dart';

import '../../../../data/repositories/mongodb/products/product_repositories.dart';
import '../../../../data/repositories/woocommerce/products/woo_product_repositories.dart';
import '../../../../utils/constants/enums.dart';
import '../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../models/product_model.dart';

class SyncProductController extends GetxController {

  final mongoProductRepository = Get.put(MongoProductRepo());
  final wooProductRepository = Get.put(WooProductRepository());

  SyncStatus _status = SyncStatus.idle;
  SyncType? _syncType;
  double _progress = 0.0;
  int _processedItems = 0;
  int _totalItems = 0;
  String _currentProductName = '';
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasMorePages = true;

  SyncStatus get status => _status;
  SyncType? get syncType => _syncType;
  double get progress => _progress;
  int get processedItems => _processedItems;
  int get totalItems => _totalItems;
  String get currentProductName => _currentProductName;
  String get errorMessage => _errorMessage;
  bool get isSyncing => _status != SyncStatus.idle;
  bool get hasError => _status == SyncStatus.failed;

  // Existing properties
  final fincomProductsCount = 0.obs;
  final wooProductsCount = 0.obs;
  final isGettingCount = false.obs;


  // New computed property
  int get newProductsCount => wooProductsCount.value - fincomProductsCount.value;

  String get userId => AuthenticationController.instance.admin.value.id ?? '';

  @override
  void onInit() {
    getTotalProductsCount();
    super.onInit();
  }

  Future<void> getTotalProductsCount() async {
    try {
      isGettingCount(true);
      fincomProductsCount.value = await mongoProductRepository.fetchProductsCount(userId: userId);
      wooProductsCount.value = await wooProductRepository.fetchProductCount();
      update(); // Notify listeners that counts changed
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch product counts: ${e.toString()}');
    } finally {
      isGettingCount(false);
    }
  }


  Future<void> startAddProducts() async {
    await _startSync(SyncType.add);
    await _syncAndAddProducts();
  }

  Future<void> startUpdateProducts() async {
    await _startSync(SyncType.update);
    await _updateProducts();
  }

  Future<void> _startSync(SyncType type) async {
    _status = SyncStatus.idle;
    _syncType = type;
    _progress = 0.0;
    _processedItems = 0;
    _totalItems = 0;
    _currentProductName = '';
    _errorMessage = '';
    _currentPage = 1;
    _hasMorePages = true;
    update();
  }

  void cancelSync() {
    if (_status != SyncStatus.completed && _status != SyncStatus.failed) {
      _status = SyncStatus.idle;
      _currentProductName = 'Sync cancelled by user';
      update();
    }
  }

  Future<void> _syncAndAddProducts() async {
    try {
      _currentPage = 1;
      _hasMorePages = true;
      _totalItems = 0;
      _processedItems = 0;
      _progress = 0.0;

      _status = SyncStatus.checking;
      _currentProductName = 'Preparing sync...';
      update();

      final Set<int> existingProductIds = await mongoProductRepository.fetchProductIds(userId: userId);
      int totalFetchedProducts = 0;

      while (_hasMorePages) {
        if (_status == SyncStatus.idle) return; // <--- check before every page loop

        _status = SyncStatus.fetching;
        _currentProductName = 'Fetching page $_currentPage from WooCommerce...';
        update();

        final products = await wooProductRepository.fetchAllProducts(
          page: _currentPage.toString(),
        );

        if (_status == SyncStatus.idle) return; // <--- check again after fetch

        if (products.isEmpty) {
          _hasMorePages = false;
          break;
        }

        totalFetchedProducts += products.length;
        _currentProductName = 'Processing ${products.length} products from page $_currentPage...';
        update();

        final productsToAdd = products.where((p) => !existingProductIds.contains(p.productId)).toList();
        _totalItems += productsToAdd.length;
        update();

        if (_status == SyncStatus.idle) return; // <--- check before processing

        if (productsToAdd.isEmpty) {
          _currentPage++;
          continue;
        }

        _status = SyncStatus.pushing;
        _currentProductName = 'Adding ${productsToAdd.length} new products...';
        update();

        await _addProductsToMongo(productsToAdd);

        if (_status == SyncStatus.idle) return; // <--- final check after push

        _currentPage++;
      }

      if (_status != SyncStatus.idle) {
        _status = SyncStatus.completed;
        _currentProductName = 'Sync completed! Processed $_processedItems/$totalFetchedProducts products';
        update();
      }
    } catch (e) {
      _status = SyncStatus.failed;
      _errorMessage = 'Error during sync: ${e.toString()}';
      _currentProductName = 'Sync failed on page $_currentPage';
      update();
    }
  }

  Future<void> _updateProducts() async {
    try {
      // Initialize progress tracking
      _currentPage = 1;
      _hasMorePages = true;
      _totalItems = 0;
      _processedItems = 0;
      _progress = 0.0;

      _status = SyncStatus.fetching;
      _currentProductName = 'Starting full update...';
      update();

      int totalFetchedProducts = 0;

      while (_hasMorePages && _status != SyncStatus.idle) {
        // 1. Fetch products from WooCommerce
        _currentProductName = 'Fetching page $_currentPage from WooCommerce...';
        update();

        final products = await wooProductRepository.fetchAllProducts(page: _currentPage.toString(),);

        if (products.isEmpty) {
          _hasMorePages = false;
          break;
        }

        totalFetchedProducts += products.length;
        _totalItems += products.length;

        _currentProductName = 'Updating ${products.length} products from page $_currentPage...';
        _status = SyncStatus.pushing;
        update();

        // 2. Update all fetched products in MongoDB
        await _updateProductsInMongo(products);

        _currentPage++;
      }

      if (_status != SyncStatus.idle) {
        _status = SyncStatus.completed;
        _currentProductName = 'Update completed! '
            'Processed $_processedItems/$totalFetchedProducts products';
        update();
      }
    } catch (e) {
      _status = SyncStatus.failed;
      _errorMessage = 'Error during update: ${e.toString()}';
      _currentProductName = 'Update failed on page $_currentPage';
      update();
    }
  }

  Future<void> _addProductsToMongo(List<ProductModel> products) async {
    if (_status == SyncStatus.idle) return;

    const batchSize = 100; // Optimal size depends on your MongoDB setup
    for (var i = 0; i < products.length; i += batchSize) {
      if (_status == SyncStatus.idle) break;

      final batch = products.sublist(
          i,
          i + batchSize > products.length ? products.length : i + batchSize
      );

      // ✅ Add userId to each product before pushing
      for (var product in batch) {
        product.userId = userId;
      }

      _currentProductName = "Adding products ${i+1}-${i+batch.length}...";
      update();

      await mongoProductRepository.pushProducts(products: batch);

      _processedItems += batch.length;
      _progress = _processedItems / _totalItems;
      update();
    }
  }

  Future<void> _updateProductsInMongo(List<ProductModel> products) async {
    if (_status == SyncStatus.idle) return;

    const batchSize = 100; // Adjust this as needed
    for (var i = 0; i < products.length; i += batchSize) {
      if (_status == SyncStatus.idle) break;

      final batch = products.sublist(
        i,
        i + batchSize > products.length ? products.length : i + batchSize,
      );

      _currentProductName = "Updating products ${i + 1}-${i + batch.length}...";
      update();

      await mongoProductRepository.updateMultipleProducts(products: batch);

      _processedItems += batch.length;
      _progress = _processedItems / _totalItems;
      update();
    }
  }


  void resetSync() {
    _status = SyncStatus.idle;
    _syncType = null;
    _errorMessage = '';
    update();
  }
}