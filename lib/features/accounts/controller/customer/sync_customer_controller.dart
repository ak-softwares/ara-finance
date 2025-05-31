import 'package:get/get.dart';

import '../../../../data/repositories/mongodb/user/user_repositories.dart';
import '../../../../data/repositories/woocommerce/customers/woo_customer_repository.dart';
import '../../../../utils/constants/enums.dart';
import '../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../../personalization/models/user_model.dart';

class SyncCustomerController extends GetxController {
  final mongoUserRepository = Get.put(MongoUserRepository());
  final wooCustomersRepository = Get.put(WooCustomersRepository());

  SyncStatus _status = SyncStatus.idle;
  SyncType? _syncType;
  double _progress = 0.0;
  int _processedItems = 0;
  int _totalItems = 0;
  String _currentCustomerName = '';
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasMorePages = true;

  // Count tracking
  final fincomCustomersCount = 0.obs;
  final wooCustomersCount = 0.obs;
  final isGettingCount = false.obs;

  SyncStatus get status => _status;
  SyncType? get syncType => _syncType;
  double get progress => _progress;
  int get processedItems => _processedItems;
  int get totalItems => _totalItems;
  String get currentCustomerName => _currentCustomerName;
  String get errorMessage => _errorMessage;
  bool get isSyncing => _status != SyncStatus.idle;
  bool get hasError => _status == SyncStatus.failed;
  int get newCustomersCount => wooCustomersCount.value - fincomCustomersCount.value;

  String get userId => AuthenticationController.instance.admin.value.id ?? '';

  @override
  void onInit() {
    getTotalCustomersCount();
    super.onInit();
  }

  Future<void> getTotalCustomersCount() async {
    try {
      isGettingCount(true);
      fincomCustomersCount.value = await mongoUserRepository.fetchUsersCount(userId: userId, userType: UserType.customer);
      wooCustomersCount.value = await wooCustomersRepository.fetchCustomerCount();
      update();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch customer counts: ${e.toString()}');
    } finally {
      isGettingCount(false);
    }
  }

  Future<void> startAddCustomers() async {
    await _startSync(SyncType.add);
    await _syncAndAddCustomers();
  }

  Future<void> startCheckCustomers() async {
    await _startSync(SyncType.check);
    await _checkCustomers();
  }

  Future<void> _startSync(SyncType type) async {
    _status = SyncStatus.idle;
    _syncType = type;
    _progress = 0.0;
    _processedItems = 0;
    _totalItems = 0;
    _currentCustomerName = '';
    _errorMessage = '';
    _currentPage = 1;
    _hasMorePages = true;
    update();
  }

  void cancelSync() {
    if (_status != SyncStatus.completed && _status != SyncStatus.failed) {
      _status = SyncStatus.idle;
      _currentCustomerName = 'Sync cancelled by user';
      update();
    }
  }

  Future<void> _syncAndAddCustomers() async {
    try {
      _currentPage = 1;
      _hasMorePages = true;
      _totalItems = 0;
      _processedItems = 0;
      _progress = 0.0;

      _status = SyncStatus.checking;
      _currentCustomerName = 'Preparing sync...';
      update();

      final Set<int> existingCustomerIds = await mongoUserRepository.fetchUsersIds(userId: userId);
      int totalFetchedCustomers = 0;

      while (_hasMorePages) {
        if (_status == SyncStatus.idle) return;

        _status = SyncStatus.fetching;
        _currentCustomerName = 'Fetching page $_currentPage from WooCommerce...';
        update();

        final customers = await wooCustomersRepository.fetchAllCustomers(
          page: _currentPage.toString(),
        );

        if (_status == SyncStatus.idle) return;

        if (customers.isEmpty) {
          _hasMorePages = false;
          break;
        }

        totalFetchedCustomers += customers.length;
        _currentCustomerName = 'Processing ${customers.length} customers from page $_currentPage...';
        update();

        final customersToAdd = customers.where((c) => !existingCustomerIds.contains(c.documentId)).toList();
        _totalItems += customersToAdd.length;
        update();

        if (_status == SyncStatus.idle) return;

        if (customersToAdd.isEmpty) {
          _currentPage++;
          continue;
        }

        _status = SyncStatus.pushing;
        _currentCustomerName = 'Adding ${customersToAdd.length} new customers...';
        update();

        await _addCustomersToMongo(customersToAdd);

        if (_status == SyncStatus.idle) return;

        _currentPage++;
      }

      if (_status != SyncStatus.idle) {
        _status = SyncStatus.completed;
        _currentCustomerName = 'Sync completed! Processed $_processedItems/$totalFetchedCustomers customers';
        update();
      }
    } catch (e) {
      _status = SyncStatus.failed;
      _errorMessage = 'Error during sync: ${e.toString()}';
      _currentCustomerName = 'Sync failed on page $_currentPage';
      update();
    }
  }

  Future<void> _checkCustomers() async {
    try {
      _currentPage = 1;
      _hasMorePages = true;
      _totalItems = 0;
      _processedItems = 0;
      _progress = 0.0;

      _status = SyncStatus.checking;
      _currentCustomerName = 'Preparing customer check...';
      update();

      final Set<int> existingCustomerIds = await mongoUserRepository.fetchUsersIds(userId: userId);
      int totalFetchedCustomers = 0;

      while (_hasMorePages) {
        if (_status == SyncStatus.idle) return;

        _status = SyncStatus.fetching;
        _currentCustomerName = 'Fetching page $_currentPage from WooCommerce...';
        update();

        final customers = await wooCustomersRepository.fetchAllCustomers(
          page: _currentPage.toString(),
        );

        if (_status == SyncStatus.idle) return;

        if (customers.isEmpty) {
          _hasMorePages = false;
          break;
        }

        totalFetchedCustomers += customers.length;
        _totalItems = totalFetchedCustomers;
        _processedItems = customers.where((c) => existingCustomerIds.contains(c.documentId)).length;
        _progress = _processedItems / _totalItems;

        _currentCustomerName = 'Checking ${customers.length} customers from page $_currentPage...';
        update();

        _currentPage++;
      }

      if (_status != SyncStatus.idle) {
        _status = SyncStatus.completed;
        _currentCustomerName = 'Check completed! Found $_progress/$totalFetchedCustomers existing customers';
        update();
      }
    } catch (e) {
      _status = SyncStatus.failed;
      _errorMessage = 'Error during check: ${e.toString()}';
      _currentCustomerName = 'Check failed on page $_currentPage';
      update();
    }
  }

  Future<void> _addCustomersToMongo(List<UserModel> customers) async {
    if (_status == SyncStatus.idle) return;

    const batchSize = 100;
    for (var i = 0; i < customers.length; i += batchSize) {
      if (_status == SyncStatus.idle) break;

      final batch = customers.sublist(
          i,
          i + batchSize > customers.length ? customers.length : i + batchSize
      );

      // Add userId to each customer before pushing
      for (var customer in batch) {
        customer.userId = userId;
      }

      _currentCustomerName = "Adding customers ${i+1}-${i+batch.length}...";
      update();

      await mongoUserRepository.insertUsers(customers: batch);

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