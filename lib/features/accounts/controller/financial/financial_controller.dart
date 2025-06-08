import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../data/repositories/mongodb/user/user_repositories.dart';
import '../../../../utils/constants/db_constants.dart';
import '../../../../utils/constants/enums.dart';
import '../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../models/coupon_model.dart';
import '../../models/expense_model.dart';
import '../../models/order_model.dart';
import '../product/product_controller.dart';
import '../sales_controller/sales_controller.dart';

class FinancialController extends GetxController {

  List<String> short = [
    'Today',
    'Yesterday',
    'This Month',
    'Last 7 Days',
    'Last 30 Days',
    'Last 90 Days',
    'Last Month',
    'Last Year',
    'Custom',
  ];

  RxBool isLoading = false.obs;
  RxString selectedOption = 'This Month'.obs;
  Rx<DateTime> startDate = Rx<DateTime>(DateTime.now());
  Rx<DateTime> endDate = Rx<DateTime>(DateTime.now());
  RxInt userCount = 0.obs;

  RxList<OrderModel> sales = <OrderModel>[].obs;
  RxList<OrderModel> purchases = <OrderModel>[].obs;
  RxList<ExpenseModel> expenses = <ExpenseModel>[].obs;

  RxList<Map<String, dynamic>> productPrice = <Map<String, dynamic>>[].obs;

  // Profit & Loss
  final RxBool isRevenueExpanded = false.obs;
  final RxBool isExpensesExpanded = false.obs;
  final RxBool isProfitExpanded = false.obs;

  // Balance sheet
  final RxBool isAssetsExpanded = false.obs;
  final RxBool isLiabilitiesExpanded = false.obs;
  final RxBool isEquityExpanded = false.obs;
  final RxBool isNetWorthExpanded = false.obs;

  // General Matrix
  final RxBool isPurchaseExpanded = false.obs;
  final RxBool isUnitMatrixExpanded = false.obs;
  final RxBool isGeneralMatrixExpanded = false.obs;
  final RxBool isAttributesExpanded = false.obs;


  final OrderStatus completeStatus = OrderStatus.completed;
  final OrderStatus inTransitStatus = OrderStatus.inTransit;
  final OrderStatus returnStatus = OrderStatus.returned;

  final saleController = Get.put(SaleController());
  final productController = Get.put(ProductController());
  // final bankAccountController = Get.put(BankAccountController());
  // final expenseController = Get.put(ExpenseController());
  // final vendorController = Get.put(VendorController());
  final mongoUserRepository = Get.put(MongoUserRepository());

  String get userEmail => AuthenticationController.instance.admin.value.email ?? '';

  @override
  void onInit() {
    super.onInit();
    initFunctions();
  }

  Future<void> totalUserCount() async {
    final getUserCount = await mongoUserRepository.fetchAppUserCount(userType: UserType.admin);
    userCount.value = getUserCount;
  }

  Future<void> initFunctions({bool isRefresh = false}) async {
    await selectDate(isRefresh: isRefresh);
    await calculateStock();
    await calculateCash();
    await calculateAccountsPayable();
    await totalUserCount();
  }

  Future<void> refreshFinancials() async {
    try {
      sales.clear();
      purchases.clear();
      expenses.clear();
      await initFunctions(isRefresh : true);
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error in Payment Methods getting', message: e.toString());
    }
  }

  Future<void> selectDate({bool isRefresh = false}) async {
    final now = DateTime.now();

    if (selectedOption.value == 'Custom') {
      if(!isRefresh){
        final picked = await showDateRangePicker(
          context: Get.context!,
          firstDate: DateTime(now.year - 5),
          lastDate: DateTime(now.year + 1),
          initialDateRange: DateTimeRange(start: startDate.value, end: endDate.value),
        );
        if (picked != null) {
          startDate.value = picked.start;
          endDate.value = picked.end;
          await getSalesByShortcut();
        }
      }else {
        startDate.value = DateTime.now();
        endDate.value = DateTime.now();
        await getSalesByShortcut();
      }

      return;
    }

    switch (selectedOption.value) {
      case 'Today':
        startDate.value = DateTime(now.year, now.month, now.day);
        endDate.value = now;
        break;
      case 'Yesterday':
        final yesterday = now.subtract(Duration(days: 1));
        startDate.value = DateTime(yesterday.year, yesterday.month, yesterday.day);
        endDate.value = DateTime(now.year, now.month, now.day).subtract(Duration(seconds: 1));
        break;
      case 'This Month':
        startDate.value = DateTime(now.year, now.month, 1); // Start of current month
        endDate.value = now; // Current time
        break;
      case 'Last 7 Days':
        startDate.value = now.subtract(Duration(days: 6));
        endDate.value = now;
        break;
      case 'Last 30 Days':
        startDate.value = now.subtract(Duration(days: 29));
        endDate.value = now;
        break;
      case 'Last 90 Days':
        startDate.value = now.subtract(Duration(days: 89));
        endDate.value = now;
        break;
      case 'Last Month':
        final firstDay = DateTime(now.year, now.month - 1, 1);
        final lastDay = DateTime(now.year, now.month, 1).subtract(Duration(seconds: 1));
        startDate.value = firstDay;
        endDate.value = lastDay;
        break;
      case 'Last Year':
        startDate.value = DateTime(now.year - 1, 1, 1);
        endDate.value = DateTime(now.year - 1, 12, 31, 23, 59, 59);
        break;
      default:
        return;
    }
    await getSalesByShortcut();
  }

  Future<void> getSalesByShortcut() async {
    try {
        isLoading(true);
        final fetchedSales = await saleController.getSalesByDate(startDate: startDate.value, endDate: endDate.value);
        // final fetchedPurchases = await purchaseController.getPurchasesByDate(startDate: startDate.value, endDate: endDate.value);
        // final fetchedExpenses = await expenseController.getExpensesByDate(startDate: startDate.value, endDate: endDate.value);
        sales.assignAll(fetchedSales);
        // purchases.assignAll(fetchedPurchases);
        // expenses.assignAll(fetchedExpenses);
        await calculateCogs();
    } catch(e){
        AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
        isLoading(false);
    }
  }

  int get revenue => sales.where((o) => o.status == completeStatus).fold(0, (sum, o) => sum + (o.total?.toInt() ?? 0));

  int get revenueTotal => sales.fold(0, (sum, order) => sum + (order.total?.toInt() ?? 0));
  int get orderTotal => sales.length;

  int get revenueCompleted => sales.where((o) => o.status == completeStatus).fold(0, (sum, o) => sum + (o.total?.toInt() ?? 0));
  int get revenueCompletedPercent => revenueTotal == 0 ? 0 : ((revenueCompleted / revenueTotal) * 100).round();
  int get orderCompleted => sales.where((o) => o.status == completeStatus).length;

  int get revenueInTransit => sales.where((o) => o.status == inTransitStatus).fold(0, (sum, o) => sum + (o.total?.toInt() ?? 0));
  int get revenueInTransitPercent => revenueTotal == 0 ? 0 : ((revenueInTransit / revenueTotal) * 100).round();
  int get orderInTransit => sales.where((o) => o.status == inTransitStatus).length;

  int get revenueReturn => sales.where((o) => o.status == returnStatus).fold(0, (sum, o) => sum + (o.total?.toInt() ?? 0));
  int get revenueReturnPercent => revenueTotal == 0 ? 0 : ((revenueReturn / revenueTotal) * 100).round();
  int get orderReturnCount => sales.where((o) => o.status == returnStatus).length;

  //----------------------------------------------------------------------------------------------//

  // Expenses
  RxInt expensesCogs = 0.obs;
  int get expensesCogsPercent => revenue == 0 ? 0 : ((expensesCogs / revenue) * 100).round();

  RxInt expensesCogsInTransit = 0.obs;
  int get expensesCogsInTransitPercent => assets == 0 ? 0 : ((expensesCogsInTransit / assets) * 100).round();

  // Total of all expenses
  int get expensesTotal => expenses.fold(0, (sum, e) => sum + ((e.openingBalance ?? 0).round()));

  // Total per expenseType as a Map
  List<ExpenseSummary> get expenseSummaries {
    final total = expensesTotal; // assuming this is already calculated
    final Map<String, int> grouped = {};

    for (var e in expenses) {
      // final type = e.expenseType?.name ?? 'Unknown';
      // final amount = (e.openingBalance ?? 0).toInt();
      // grouped[type] = (grouped[type] ?? 0) + amount;
    }

    return grouped.entries.map((entry) {
      final percent = total == 0 ? 0.0 : (entry.value / total * 100);
      return ExpenseSummary(
        name: entry.key,
        total: entry.value,
        percent: percent,
      );
    }).toList();
  }


  Future<void> calculateCogs() async {
    try {
      // Step 1: Collect product IDs from completed and in-transit sales
      final List<int> productIds = sales.where((sale) =>
      sale.status == completeStatus || sale.status == inTransitStatus)
          .expand((sale) => sale.lineItems ?? [])
          .map((item) => item.productId)
          .whereType<int>()
          .toSet()
          .toList();

      // Step 2: Get purchase prices for these product IDs
      final List<Map<String, dynamic>> totalStockValue =
          await productController.getCogsDetailsByProductIds(productIds: productIds);
      productPrice.value = totalStockValue;

      // Step 3: Build a quick lookup map from productId to purchasePrice
      final Map<int, num> purchasePriceMap = {
        for (var item in totalStockValue)
          if (item[ProductFieldName.productId] != null && item[ProductFieldName.purchasePrice] != null)
            item[ProductFieldName.productId] as int: item[ProductFieldName.purchasePrice] as num
      };

      // Step 4: Calculate total COGS from sales
      int totalCogs = 0;
      int totalCogsInTransit = 0;

      for (var sale in sales) {
        if (sale.status == completeStatus) {
          for (var item in sale.lineItems ?? []) {
            final int? productId = item.productId;
            final int? quantity = item.quantity;
            if (productId != null &&
                quantity != null &&
                purchasePriceMap.containsKey(productId)) {
              final int cogs = (purchasePriceMap[productId]! * quantity).toInt();
              totalCogs += cogs;
            }
          }
        }
      }

      for (var sale in sales) {
        if (sale.status == inTransitStatus) {
          for (var item in sale.lineItems ?? []) {
            final int? productId = item.productId;
            final int? quantity = item.quantity;
            if (productId != null &&
                quantity != null &&
                purchasePriceMap.containsKey(productId)) {
              final int cogs = (purchasePriceMap[productId]! * quantity).toInt();
              totalCogsInTransit += cogs;
            }
          }
        }
      }

      // Step 5: Set the observable
      expensesCogs.value = totalCogs;
      expensesCogsInTransit.value = totalCogsInTransit;
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }


  RxInt expensesShipping = 0.obs;
  RxInt expensesAds = 0.obs;
  RxInt expensesRent = 0.obs;
  RxInt expensesSalary = 0.obs;
  RxInt expensesTransport = 0.obs;
  RxInt expensesOthers = 0.obs;

  int get expensesTotalOperatingCost => expensesCogs.value + expensesTotal;
  int get expensesTotalOperatingCostPercent => revenue == 0 ? 0 : ((expensesTotalOperatingCost / revenue) * 100).round();


//----------------------------------------------------------------------------------------------//

  // Profit
  int get grossProfit => revenue - expensesCogs.value;
  int get grossProfitPercent => revenue == 0 ? 0 : ((grossProfit / revenue) * 100).round();

  int get operatingProfit => revenue - expensesTotalOperatingCost;
  int get operatingProfitPercent => revenue == 0 ? 0 : ((operatingProfit / revenue) * 100).round();

  int get netProfit => operatingProfit - 0;
  int get netProfitPercent => revenue == 0 ? 0 : ((netProfit / revenue) * 100).round();

//----------------------------------------------------------------------------------------------//


  // Assets
  RxInt stock = 0.obs;
  RxInt cash = 0.obs;
  RxInt accountReceivables = 0.obs;

  int get assets => stock.value + expensesCogsInTransit.value + cash.value + accountReceivables.value;

  int get stockPercent => assets == 0 ? 0 : ((stock.value / assets) * 100).round();

  int get cashPercent => assets == 0 ? 0 : ((cash.value / assets) * 100).round();

  Future<void> calculateStock() async {
    try {
      final double totalStockValue = await productController.getTotalStockValue();
      stock.value = totalStockValue.toInt();
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> calculateCash() async {
    try {
      // final double totalStockValue = await bankAccountController.getTotalBalance();
      // cash.value = totalStockValue.toInt();
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }


//----------------------------------------------------------------------------------------------//


  // Liabilities
  RxInt accountsPayable = 0.obs;

  int get liabilities => accountsPayable.value;

  int get accountsPayablePercent => liabilities == 0 ? 0 : ((accountsPayable.value / liabilities) * 100).round();

  Future<void> calculateAccountsPayable() async {
    try {
      // final double totalAccountsPayable = await vendorController.calculateAccountPayable();
      // accountsPayable.value = (totalAccountsPayable.toInt()).abs();
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

//----------------------------------------------------------------------------------------------//

  int get netWorth => assets - liabilities;

//----------------------------------------------------------------------------------------------//

  // Purchase
  int get purchasesTotal => purchases.fold(0, (sum, order) => sum + (order.total?.toInt() ?? 0));
  int get purchasesCount => purchases.length;

//----------------------------------------------------------------------------------------------//

  // General Matrix

  // Total number of orders with coupons
  int get couponUsed => sales.where((order) {
    final couponLines = order.couponLines as List?;
    return couponLines != null && couponLines.isNotEmpty;
  }).length;

  // Total coupon discount value
  double get couponDiscountTotal => sales.fold(0.0, (sum, order) {
    final List<CouponModel>? couponLines = order.couponLines;
    if (couponLines != null && couponLines.isNotEmpty) {
      for (var coupon in couponLines) {
        sum += double.tryParse(coupon.discount.toString()) ?? 0.0;
      }
    }
    return sum;
  });

//----------------------------------------------------------------------------------------------//

  // Unit Matrix
  double get averageOrderValue => revenueTotal == 0 ? 0 : revenueTotal / orderTotal;

  double get unitCogs => orderTotal == 0 ? 0 : expensesCogs.value / orderTotal;
  int get unitCogsPercent => averageOrderValue == 0 ? 0 : ((unitCogs / averageOrderValue) * 100).round();

  double get unitShipping => orderTotal == 0 ? 0 : unitShippingExpenseTotal / orderTotal;
  int get unitShippingPercent => averageOrderValue == 0 ? 0 : ((unitShipping / averageOrderValue) * 100).round();

  double get unitAds => orderTotal == 0 ? 0 : totalAdsExpense / orderTotal;
  int get unitAdsPercent => averageOrderValue == 0 ? 0 : ((unitAds / averageOrderValue) * 100).round();

  double get unitProfit => averageOrderValue - unitCogs - unitShipping - unitAds;
  int get unitProfitPercent => averageOrderValue == 0 ? 0 : ((unitProfit / averageOrderValue) * 100).round();

  // Total per expenseType as a Map
  double get unitShippingExpenseTotal {
    // Find the "Shipping" entry in expenseSummaries
    final shippingSummary = expenseSummaries.firstWhere(
          (summary) => summary.name == ExpenseType.shipping.name,
      orElse: () => ExpenseSummary(name: ExpenseType.shipping.name, total: 0, percent: 0),
    );

    return shippingSummary.total.toDouble(); // Convert to double if needed
  }

  // Total for both Facebook Ads and Google Ads
  double get totalAdsExpense {
    return expenseSummaries
        .where((summary) =>
    summary.name == ExpenseType.facebookAds.name ||
        summary.name == ExpenseType.googleAds.name)
        .fold(0.0, (sum, summary) => sum + summary.total.toDouble());
  }


//----------------------------------------------------------------------------------------------//

  // Attributes

  List<RevenueSummary> get revenueSummaries => getRevenueSummaries(sales);

  List<RevenueSummary> getRevenueSummaries(List<OrderModel> orders) {
    final Map<String, List<OrderModel>> groupedOrders = {};

    for (var order in orders) {
      final type = order.orderAttribute?.sourceType?.toLowerCase() ?? 'unknown';
      groupedOrders.putIfAbsent(type, () => []).add(order);
    }

    final int totalRevenue = orders.fold(0, (sum, o) => sum + (o.total ?? 0).toInt());

    return groupedOrders.entries.map((entry) {
      final type = entry.key;
      final List<OrderModel> typeOrders = entry.value;

      final Map<String, List<OrderModel>> sources = {};
      for (var order in typeOrders) {
        final source = order.orderAttribute?.source?.toLowerCase() ?? 'unknown';
        sources.putIfAbsent(source, () => []).add(order);
      }

      final List<SourceBreakdown> breakdowns = sources.entries.map((s) {
        final source = s.key;
        final sourceOrders = s.value;
        final revenue = sourceOrders.fold(0, (sum, o) => sum + (o.total ?? 0).toInt());
        final count = sourceOrders.length;
        final percent = totalRevenue == 0 ? 0.0 : (revenue / totalRevenue * 100);

        return SourceBreakdown(
          source: source,
          revenue: revenue,
          orderCount: count,
          percent: percent,
        );
      }).toList();

      final total = typeOrders.fold(0, (sum, o) => sum + (o.total ?? 0).toInt());
      final percent = totalRevenue == 0 ? 0.0 : (total / totalRevenue * 100);

      return RevenueSummary(
        type: type,
        totalRevenue: total,
        orderCount: typeOrders.length,
        percent: percent,
        sourceBreakdown: breakdowns,
      );
    }).toList();
  }

}