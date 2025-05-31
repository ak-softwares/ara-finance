import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:intl/intl.dart';

import '../../../../common/dialog_box_massages/dialog_massage.dart';
import '../../../../common/dialog_box_massages/full_screen_loader.dart';
import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../common/widgets/network_manager/network_manager.dart';
import '../../../../data/repositories/mongodb/expanses/expanses_repo.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../models/expense_model.dart';
import '../../models/account_model.dart';
import '../../models/transaction_model.dart';
import '../transaction/add_payment_controller.dart';
import '../transaction/transaction_controller.dart';

class ExpenseController extends GetxController {
  // Variables
  RxInt currentPage = 1.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxDouble totalMonthlyExpense = 0.0.obs;
  RxInt categoryCount = 0.obs;

  RxList<ExpenseModel> expenses = <ExpenseModel>[].obs;

  final mongoExpenseRepo = Get.put(MongoExpenseRepo());
  final transactionController = Get.put(TransactionController());

  String get userId => AuthenticationController.instance.admin.value.id!;

  @override
  Future<void> onInit() async {
    super.onInit();
    await calculateMonthlySummary();
  }

  // Calculate monthly summary
  Future<void> calculateMonthlySummary() async {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    final monthlyExpenses = expenses.where((expense) =>
    expense.dateCreated != null &&
        expense.dateCreated!.isAfter(firstDayOfMonth) &&
        expense.dateCreated!.isBefore(lastDayOfMonth)
    ).toList();

    totalMonthlyExpense.value = monthlyExpenses.fold(0, (sum, expense) => sum + (expense.amount ?? 0));

    final uniqueCategories = monthlyExpenses.map((e) => e.expenseType).toSet();
    categoryCount.value = uniqueCategories.length;
  }

  // Get all expenses
  Future<void> getAllExpenses() async {
    try {
      final fetchedExpenses = await mongoExpenseRepo.fetchAllExpenses(userId: userId, page: currentPage.value);
      expenses.addAll(fetchedExpenses);
      await calculateMonthlySummary();
    } catch (e) {
      rethrow;
    }
  }


  Future<List<ExpenseModel>> getExpensesByDate({required DateTime startDate, required DateTime endDate}) async {
    try {
      final fetchedOrders = await mongoExpenseRepo.fetchExpensesByDate(
          userId: userId,
          startDate: startDate,
          endDate: endDate
      );
      return fetchedOrders;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshExpenses() async {
    try {
      isLoading(true);
      currentPage.value = 1; // Reset page number
      expenses.clear(); // Clear existing expenses
      await getAllExpenses();
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error loading expenses', message: e.toString());
    } finally {
      isLoading(false);
    }
  }


  // Get expense by ID
  Future<ExpenseModel> getExpenseById({required String id}) async {
    try {
      final fetchedExpense = await mongoExpenseRepo.fetchExpenseById(id: id);
      return fetchedExpense;
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error loading expense', message: e.toString());
      return ExpenseModel();
    }
  }

  // Delete expense
  Future<void> deleteExpense({required ExpenseModel expense, required BuildContext context}) async {
    try {
      DialogHelper.showDialog(
        context: context,
        title: 'Delete Purchase',
        message: 'Are you sure to delete this purchase?',
        actionButtonText: 'Delete',
        toastMessage: 'Purchase deleted successfully!',
        onSubmit: () async {

          await Future.wait([
            transactionController.processTransaction(transaction: expense.transaction ?? TransactionModel(), isDelete: true),
            mongoExpenseRepo.deleteExpense(id: expense.id ?? ''),
            refreshExpenses(),
          ]);
          Get.back();
        },
      );
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

}