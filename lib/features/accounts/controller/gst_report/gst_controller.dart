import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/data/state_iso_code_map.dart';
import '../../models/transaction_model.dart';
import '../../screen/transaction/widget/transaction_tile.dart';
import '../transaction/transaction_controller.dart';

class GstController extends GetxController{
  static GstController get instance => Get.find();

  // Variable
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
  RxString selectedOption = (() {
    final now = DateTime.now();
    final previousMonth = DateTime(now.year, now.month - 1, 1);
    return DateFormat.MMMM().format(previousMonth);
  })().obs;

  Rx<DateTime> startDate = Rx<DateTime>(DateTime.now());
  Rx<DateTime> endDate = Rx<DateTime>(DateTime.now());

  final OrderStatus completeStatus = OrderStatus.completed;
  final OrderStatus inTransitStatus = OrderStatus.inTransit;
  final OrderStatus returnStatus = OrderStatus.returned;

  // Profit & Loss
  final RxBool isB2BExpanded = false.obs;
  final RxBool isB2CExpanded = false.obs;
  final RxBool isHSNExpanded = false.obs;

  RxList<TransactionModel> sales = <TransactionModel>[].obs;

  final transactionController = Get.put(TransactionController());

  @override
  void onInit() {
    super.onInit();
    initFunctions();
  }

  Future<void> refreshGstReport() async {
    try {
      sales.clear();
      await initFunctions(isRefresh : true);
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Refresh: ', message: e.toString());
    }
  }

  Future<void> initFunctions({bool isRefresh = false}) async {
    await selectDate(isRefresh: isRefresh);
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
      sales.assignAll(fetchedSales);
    } catch(e){
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading(false);
    }
  }

  int get totalSale => sales.fold(0, (sum, order) => sum + (order.amount?.toInt() ?? 0));
  int get totalSaleCount => sales.length;

  int get netReturn => sales.where((o) => o.status == returnStatus).fold(0, (sum, o) => sum + (o.amount?.toInt() ?? 0));
  int get netReturnCount => sales.where((o) => o.status == returnStatus).length;
  int get netInTransit => sales.where((o) => o.status == inTransitStatus).fold(0, (sum, o) => sum + (o.amount?.toInt() ?? 0));
  int get netNetInTransitCount => sales.where((o) => o.status == inTransitStatus).length;
  int get netSale => sales.where((o) => o.status == completeStatus).fold(0, (sum, o) => sum + (o.amount?.toInt() ?? 0));
  int get netSaleCount => sales.where((o) => o.status == completeStatus).length;

  List<TransactionModel> get completedSales => sales.where((o) => o.status == completeStatus).toList();
  int get completedSalesCount => completedSales.length;

  List<TransactionModel> get b2bSales {
    return completedSales.where((transaction) {
      final gst = transaction.address?.gstNumber;
      return gst != null && gst.isNotEmpty;
    }).toList();
  }

  Map<String, int> get b2cSalesStateWise {
    final Map<String, int> result = {};

    for (var transaction in completedSales) {
      final gst = transaction.address?.gstNumber;
      if (gst != null && gst.isNotEmpty) continue; // Skip B2B

      final rawState = transaction.address?.state?.trim() ?? 'Unknown';
      final normalizedState = StateData.getStateNameFromCodeOrName(rawState) ?? rawState;
      result[normalizedState] = (result[normalizedState] ?? 0) + (transaction.amount?.toInt() ?? 0);
    }

    return result;
  }

  Map<String, List<TransactionModel>> get b2cSalesGroupedByState {
    final Map<String, List<TransactionModel>> grouped = {};

    for (var transaction in completedSales) {
      final gst = transaction.address?.gstNumber;
      if (gst != null && gst.isNotEmpty) continue; // Skip B2B

      final rawState = transaction.address?.state?.trim() ?? 'Unknown';
      final normalizedState = StateData.getStateNameFromCodeOrName(rawState) ?? rawState;

      grouped.putIfAbsent(normalizedState, () => []);
      grouped[normalizedState]!.add(transaction);
    }

    return grouped;
  }

  void showStateSales(String selectedState) {
    final selectedStateName = StateData.getStateNameFromCodeOrName(selectedState);

    if (selectedStateName == null) {
      Get.snackbar('Invalid State', 'The selected state code or name is not recognized.');
      return;
    }

    final stateSales = b2cSalesGroupedByState[selectedStateName] ?? [];

    Get.bottomSheet(
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: stateSales.isEmpty
            ? const Center(child: Text('No sales found for this state'))
            : ListView.separated(
          itemCount: stateSales.length,
          separatorBuilder: (context, index) => SizedBox(height: AppSizes.defaultSpace),
          itemBuilder: (context, index) {
            final sale = stateSales[index];
            return TransactionTile(transaction: sale);
          },
        ),
      ),
      isScrollControlled: true,
    );
  }

  void showSalesByStatus(OrderStatus status) {
    final filteredSales = sales
        .where((transaction) =>
    transaction.status == status &&
        (transaction.address?.gstNumber?.isEmpty ?? true)) // B2C only
        .toList();

    Get.bottomSheet(
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: filteredSales.isEmpty
            ? const Center(child: Text('No sales found for this status'))
            : ListView.separated(
          itemCount: filteredSales.length,
          separatorBuilder: (context, index) => SizedBox(height: AppSizes.defaultSpace),
          itemBuilder: (context, index) {
            final sale = filteredSales[index];
            return TransactionTile(transaction: sale);
          },
        ),
      ),
      isScrollControlled: true,
    );
  }

  void showAllSales() {

    Get.bottomSheet(
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: sales.isEmpty
            ? const Center(child: Text('No sales found for this status'))
            : ListView.separated(
          itemCount: sales.length,
          separatorBuilder: (context, index) => SizedBox(height: AppSizes.defaultSpace),
          itemBuilder: (context, index) {
            final sale = sales[index];
            return TransactionTile(transaction: sale);
          },
        ),
      ),
      isScrollControlled: true,
    );
  }


  Map<int, int> get hsnWiseSalesSummary {
    final Map<int, int> result = {};

    for (var transaction in completedSales) {
      final amount = transaction.amount?.toInt() ?? 0;

      // Skip if no products
      if (transaction.products == null || transaction.products!.isEmpty) continue;

      for (var product in transaction.products!) {
        final hsn = int.tryParse(product.hsnCode?.toString() ?? '') ?? 9999;
        result[hsn] = (result[hsn] ?? 0) + amount;
      }

      // Add shipping charge under HSN 996719
      final shipping = transaction.shipping?.toInt() ?? 0;
      if (shipping > 0) {
        result[996719] = (result[996719] ?? 0) + shipping;
      }
    }

    return result;
  }

}
