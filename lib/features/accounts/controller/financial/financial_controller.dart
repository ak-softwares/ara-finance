import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../data/repositories/mongodb/user/user_repositories.dart';
import '../../../../utils/constants/enums.dart';
import '../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../models/coupon_model.dart';
import '../../models/expense_model.dart';
import '../../models/order_model.dart';
import '../../models/transaction_model.dart';
import '../account_voucher/account_voucher_controller.dart';
import '../product/product_controller.dart';
import '../transaction/transaction_controller.dart';

class FinancialController extends GetxController {

  final List<String> dateOptions = [
    'Custom',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
    'January',
    'February',
    'March',
  ];

  RxBool isLoading = false.obs;
  RxString selectedOption = DateFormat.MMMM().format(DateTime.now()).obs;
  Rx<DateTime> startDate = Rx<DateTime>(DateTime.now());
  Rx<DateTime> endDate = Rx<DateTime>(DateTime.now());
  RxInt userCount = 0.obs;

  RxList<TransactionModel> sales = <TransactionModel>[].obs;
  RxList<TransactionModel> purchases = <TransactionModel>[].obs;
  RxList<TransactionModel> expenses = <TransactionModel>[].obs;


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

  final productController = Get.put(ProductController());
  final mongoUserRepository = Get.put(MongoUserRepository());
  final transactionController = Get.put(TransactionController());
  final accountVoucherController = Get.put(AccountVoucherController());

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
    await getAllInTransitSales();
    // await refreshFinancials();
  }

  Future<void> refreshFinancials() async {
    try {
      sales.clear();
      purchases.clear();
      expenses.clear();
      await initFunctions(isRefresh : true);
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Refresh: ', message: e.toString());
    }
  }

  Future<void> selectDate({bool isRefresh = false}) async {
    final now = DateTime.now();

    if (selectedOption.value == 'Custom') {
      if (!isRefresh) {
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
      } else {
        startDate.value = now;
        endDate.value = now;
        await getSalesByShortcut();
      }
      return;
    }

    final selectedMonth = selectedOption.value;
    final allMonths = {
      'January': 1,
      'February': 2,
      'March': 3,
      'April': 4,
      'May': 5,
      'June': 6,
      'July': 7,
      'August': 8,
      'September': 9,
      'October': 10,
      'November': 11,
      'December': 12,
    };

    if (allMonths.containsKey(selectedMonth)) {
      int monthNumber = allMonths[selectedMonth]!;
      int year = now.year;

      // If selected month is Jan/Feb/Mar and current month is before April, subtract 1 year (financial year logic)
      if (monthNumber >= 1 && monthNumber <= 3 && now.month < 4) {
        year -= 1;
      }

      startDate.value = DateTime(year, monthNumber, 1);
      endDate.value = DateTime(
        year,
        monthNumber + 1,
        1,
      ).subtract(const Duration(seconds: 1));
    }

    await getSalesByShortcut();
  }

  Future<void> getSalesByShortcut() async {
    try {
        isLoading(true);
        final fetchedSales = await transactionController.getTransactionsByDate(startDate: startDate.value, endDate: endDate.value, voucherType: AccountVoucherType.sale);
        final fetchedPurchases = await transactionController.getTransactionsByDate(startDate: startDate.value, endDate: endDate.value, voucherType: AccountVoucherType.purchase);
        final fetchedExpenses = await transactionController.getTransactionsByDate(startDate: startDate.value, endDate: endDate.value, voucherType: AccountVoucherType.expense);
        sales.assignAll(fetchedSales);
        purchases.assignAll(fetchedPurchases);
        expenses.assignAll(fetchedExpenses);
    } catch(e){
        AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
        isLoading(false);
    }
  }

  int get revenue => sales.where((o) => o.status == completeStatus).fold(0, (sum, o) => sum + (o.amount?.toInt() ?? 0));

  int get revenueTotal => sales.fold(0, (sum, order) => sum + (order.amount?.toInt() ?? 0));
  int get orderTotal => sales.length;

  int get revenueCompleted => sales.where((o) => o.status == completeStatus).fold(0, (sum, o) => sum + (o.amount?.toInt() ?? 0));
  int get revenueCompletedPercent => revenueTotal == 0 ? 0 : ((revenueCompleted / revenueTotal) * 100).round();
  int get orderCompleted => sales.where((o) => o.status == completeStatus).length;

  int get revenueInTransit => sales.where((o) => o.status == inTransitStatus).fold(0, (sum, o) => sum + (o.amount?.toInt() ?? 0));
  int get revenueInTransitPercent => revenueTotal == 0 ? 0 : ((revenueInTransit / revenueTotal) * 100).round();
  int get orderInTransit => sales.where((o) => o.status == inTransitStatus).length;

  int get revenueReturn => sales.where((o) => o.status == returnStatus).fold(0, (sum, o) => sum + (o.amount?.toInt() ?? 0));
  int get revenueReturnPercent => revenueTotal == 0 ? 0 : ((revenueReturn / revenueTotal) * 100).round();
  int get orderReturnCount => sales.where((o) => o.status == returnStatus).length;

  //----------------------------------------------------------------------------------------------//

  // Expenses
  int get expensesCogs => sales.where((o) => o.status == completeStatus).fold(0, (totalCogs, sale) {
    return totalCogs + sale.products!.fold(0, (saleCogs, product) {
      return saleCogs + (product.purchasePrice! * product.quantity).toInt();
    });
  });

  int get expensesCogsPercent => revenue == 0 ? 0 : ((expensesCogs / revenue) * 100).round();

  RxInt expensesCogsInTransit = 0.obs;
  RxInt countSalesInTransit = 0.obs;
  int get expensesCogsInTransitPercent => assets == 0 ? 0 : ((expensesCogsInTransit.value / assets) * 100).round();

  Future<void> getAllInTransitSales() async {
    try {
      final List<TransactionModel> totalInTransitSale = await transactionController.getTransactionByStatus(status: OrderStatus.inTransit);
      expensesCogsInTransit.value = totalInTransitSale.where((o) => o.status == inTransitStatus).fold(0, (totalCogs, sale) {
        return totalCogs + sale.products!.fold(0, (saleCogs, product) {
          return saleCogs + (product.purchasePrice! * product.quantity).toInt();
        });
      });
      countSalesInTransit.value = totalInTransitSale.length;
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  // Total of all expenses
  // int get expensesTotal => expenses.fold(0, (sum, e) => sum + ((e.amount ?? 0).round()));
  int get expensesTotal => 0;

  // Total per expenseType as a Map
  List<ExpenseSummary> get expenseSummaries {
    final total = expenses.fold<int>(0, (sum, e) => sum + (e.amount?.toInt() ?? 0));
    final Map<String, int> grouped = {};

    for (var expense in expenses) {
      // Use to_account_voucher.title as the category type
      final type = expense.toAccountVoucher?.title ?? 'Unknown';
      final amount = (expense.amount ?? 0).toInt();
      grouped[type] = (grouped[type] ?? 0) + amount;
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

  int get expensesTotalOperatingCost => expensesCogs + expensesTotal;
  int get expensesTotalOperatingCostPercent => revenue == 0 ? 0 : ((expensesTotalOperatingCost / revenue) * 100).round();


//----------------------------------------------------------------------------------------------//

  // Profit
  int get grossProfit => revenue - expensesCogs;
  int get grossProfitPercent => revenue == 0 ? 0 : ((grossProfit / revenue) * 100).round();

  int get operatingProfit => revenue - expensesTotalOperatingCost;
  int get operatingProfitPercent => revenue == 0 ? 0 : ((operatingProfit / revenue) * 100).round();

  int get netProfit => operatingProfit - 0;
  int get netProfitPercent => revenue == 0 ? 0 : ((netProfit / revenue) * 100).round();

//----------------------------------------------------------------------------------------------//


  // Assets
  RxInt stock = 0.obs;
  RxInt cashTotal = 0.obs;
  RxInt accountReceivables = 0.obs;

  int get assets => stock.value + expensesCogsInTransit.value + cashTotal.value + accountReceivables.value;

  int get stockPercent => assets == 0 ? 0 : ((stock.value / assets) * 100).round();

  int get cashPercent => assets == 0 ? 0 : ((cashTotal.value / assets) * 100).round();

  Future<void> calculateStock() async {
    try {
      final double totalStockValue = await productController.getTotalStockValue();
      stock.value = totalStockValue.toInt();
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Stock: ', message: e.toString());
    }
  }

  Future<void> calculateCash() async {
    try {

      final double totalStockValue = await accountVoucherController.getAllVoucherBalance(voucherType: AccountVoucherType.bankAccount);
      cashTotal.value = totalStockValue.toInt();
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Cash: ', message: e.toString());
    }
  }


//----------------------------------------------------------------------------------------------//


  // Liabilities
  RxInt accountsPayable = 0.obs;

  int get liabilities => accountsPayable.value;

  int get accountsPayablePercent => liabilities == 0 ? 0 : ((accountsPayable.value / liabilities) * 100).round();

  Future<void> calculateAccountsPayable() async {
    try {
      final double totalAccountsPayable = await accountVoucherController.getAllVoucherBalance(voucherType: AccountVoucherType.vendor);
      accountsPayable.value = (totalAccountsPayable.toInt()).abs();
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

//----------------------------------------------------------------------------------------------//

  int get netWorth => assets - liabilities;

//----------------------------------------------------------------------------------------------//

  // Purchase
  int get purchasesTotal => purchases.fold(0, (sum, order) => sum + (order.amount?.toInt() ?? 0));
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

  double get unitCogs => orderTotal == 0 ? 0 : totalCogs / orderTotal;
  int get unitCogsPercent => averageOrderValue == 0 ? 0 : ((unitCogs / averageOrderValue) * 100).round();

  double get unitShipping => orderTotal == 0 ? 0 : unitShippingExpenseTotal / orderTotal;
  int get unitShippingPercent => averageOrderValue == 0 ? 0 : ((unitShipping / averageOrderValue) * 100).round();

  double get unitAds => orderTotal == 0 ? 0 : totalAdsExpense / orderTotal;
  int get unitAdsPercent => averageOrderValue == 0 ? 0 : ((unitAds / averageOrderValue) * 100).round();

  double get unitProfit => averageOrderValue - unitCogs - unitShipping - unitAds;
  int get unitProfitPercent => averageOrderValue == 0 ? 0 : ((unitProfit / averageOrderValue) * 100).round();

  int get totalCogs => sales.fold(0, (tCogs, sale) {
    return tCogs + sale.products!.fold(0, (saleCogs, product) {
      return saleCogs + (product.purchasePrice! * product.quantity).toInt();
    });
  });

  // Total per expenseType as a Map
  double get unitShippingExpenseTotal {
    final shippingSummary = expenseSummaries.firstWhere(
          (summary) => summary.name.toLowerCase().contains('shipping'),
      orElse: () => ExpenseSummary(name: 'Shipping', total: 0, percent: 0),
    );

    return shippingSummary.total.toDouble();
  }


  // Total for both Facebook Ads and Google Ads
  double get totalAdsExpense {
    final adsSummary = expenseSummaries.firstWhere(
          (summary) => summary.name.toLowerCase().contains('ads'),
      orElse: () => ExpenseSummary(name: 'Ads', total: 0, percent: 0),
    );

    return adsSummary.total.toDouble();
  }


//----------------------------------------------------------------------------------------------//

  // Attributes
  List<RevenueSummary> get revenueSummaries => getRevenueSummaries(sales);

  List<RevenueSummary> getRevenueSummaries(List<TransactionModel> orders) {
    final Map<String, List<TransactionModel>> groupedOrders = {};

    for (var order in orders) {
      final type = order.orderAttribute?.sourceType?.toLowerCase() ?? 'unknown';
      groupedOrders.putIfAbsent(type, () => []).add(order);
    }

    final int totalRevenue = orders.fold(0, (sum, o) => sum + (o.amount ?? 0).toInt());

    return groupedOrders.entries.map((entry) {
      final type = entry.key;
      final List<TransactionModel> typeOrders = entry.value;

      final Map<String, List<TransactionModel>> sources = {};
      for (var order in typeOrders) {
        final source = order.orderAttribute?.source?.toLowerCase() ?? 'unknown';
        sources.putIfAbsent(source, () => []).add(order);
      }

      final List<SourceBreakdown> breakdowns = sources.entries.map((s) {
        final source = s.key;
        final sourceOrders = s.value;
        final revenue = sourceOrders.fold(0, (sum, o) => sum + (o.amount ?? 0).toInt());
        final count = sourceOrders.length;
        final percent = totalRevenue == 0 ? 0.0 : (revenue / totalRevenue * 100);

        return SourceBreakdown(
          source: source,
          revenue: revenue,
          orderCount: count,
          percent: percent,
        );
      }).toList();

      final total = typeOrders.fold(0, (sum, o) => sum + (o.amount ?? 0).toInt());
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