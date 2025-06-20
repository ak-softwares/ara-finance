import 'package:ara_finance/features/accounts/models/transaction_model.dart';
import 'package:get/get.dart';

class ProfitAndLossController extends GetxController {

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

  RxList<TransactionModel> sales = <TransactionModel>[].obs;


}