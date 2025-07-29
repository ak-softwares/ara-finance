
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../common/dialog_box_massages/dialog_massage.dart';
import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../data/repositories/mongodb/transaction/transaction_repo.dart';
import '../../../../utils/constants/db_constants.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/data/state_iso_code_map.dart';
import '../../../../utils/formatters/formatters.dart';
import '../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../../personalization/models/user_model.dart';
import '../../models/cart_item_model.dart';
import '../../models/transaction_model.dart';
import '../product/product_controller.dart';
import 'payment/add_payment_controller.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'dart:typed_data';

class TransactionController extends GetxController {

  // Variables
  RxInt currentPage = 1.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;

  RxList<TransactionModel> transactions = <TransactionModel>[].obs;

  final mongoTransactionRepo = Get.put(MongoTransactionRepo());
  final productController = Get.put(ProductController());

  String get userId => AuthenticationController.instance.admin.value.id!;

  Future<List<TransactionModel>> getTransactionsByDate({required DateTime startDate, required DateTime endDate, AccountVoucherType? voucherType,}) async {
    try {
      final fetchedTransactions = await mongoTransactionRepo.fetchTransactionsByDate(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        voucherType: voucherType,
        page: currentPage.value
      );
      return fetchedTransactions;
    }catch(e) {
      rethrow;
    }
  }

  // Fetch all transactions
  Future<void> getAllTransactions() async {
    try {
      final fetchedTransactions = await mongoTransactionRepo.fetchAllTransactions(userId: userId, page: currentPage.value);
      transactions.addAll(fetchedTransactions);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshTransactions() async {
    try {
      isLoading(true);
      currentPage.value = 1; // Reset page number
      transactions.clear(); // Clear existing transactions
      await getAllTransactions();
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error: ', message: e.toString());
    } finally {
      isLoading(false);
    }
  }

  // Get transaction by ID
  Future<TransactionModel> getTransactionByID({required String id}) async {
    try {
      return await mongoTransactionRepo.fetchTransactionById(id: id);
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error fetching transaction', message: e.toString());
      return TransactionModel();
    }
  }

  // Get transaction Id
  Future<TransactionModel> getTransactionByTransactionId({required int transactionId, required AccountVoucherType voucherType}) async {
    try {
      return await mongoTransactionRepo.fetchTransactionWithFilter(filter: {
        TransactionFieldName.userId: userId,
        TransactionFieldName.transactionId: transactionId,
        TransactionFieldName.transactionType: voucherType.name
      });
    } catch (e) {
      return TransactionModel();
    }
  }

  // Get transaction Id
  Future<TransactionModel> getTransactionByOrderId({required int orderId, required AccountVoucherType voucherType}) async {
    try {
      return await mongoTransactionRepo.fetchTransactionWithFilter(
          filter: {
            TransactionFieldName.userId: userId,
            TransactionFieldName.orderIds: orderId,
            TransactionFieldName.transactionType: voucherType.name
          }
      );
    } catch (e) {
      return TransactionModel();
    }
  }

  Future<List<TransactionModel>> getTransactionByOrderIds({required List<int> orderIds, required AccountVoucherType voucherType,}) async {
    try {
      final List<TransactionModel> transactions =
      await mongoTransactionRepo.fetchTransactionsWithFilter(
        filter: {
          TransactionFieldName.userId: userId,
          TransactionFieldName.transactionType: voucherType.name,
          TransactionFieldName.orderIds: {r'$in': orderIds},
        },
      );
      return transactions;
    } catch (e) {
      return [];
    }
  }

  Future<List<TransactionModel>> getTransactionByStatus({required OrderStatus status}) async {
    try {
      final List<TransactionModel> transactions = await mongoTransactionRepo.fetchTransactionsWithFilter(
        filter: {
          TransactionFieldName.userId: userId,
          TransactionFieldName.transactionType: AccountVoucherType.sale.name,
          TransactionFieldName.status: status.name,
        },
      );
      return transactions;
    } catch (e) {
      return [];
    }
  }

  Future<void> processTransactions({required List<TransactionModel> transactions}) async {
    try {
      await mongoTransactionRepo.pushTransactions(transactions: transactions);
    } catch(e) {
      rethrow;
    } finally {
      if(transactions.first.transactionType == AccountVoucherType.purchase) {
        await updatePriceVendorAndDate(transactions: transactions);
      }
    }
  }

  Future<void> updatePriceVendorAndDate({required List<TransactionModel> transactions}) async {
    try {
      final List<CartModel> products = transactions.expand((transaction) => transaction.products!).toList();
      if(products.isNotEmpty) {
          for (var product in products) {
            product.vendor = transactions.first.fromAccountVoucher;
          }
          await productController.updateVendorAndPurchasePriceById(cartItems: products);
      }
    }catch(e){
      rethrow;
    }
  }

  // Delete a transaction
  Future<void> deleteTransaction({required TransactionModel transaction}) async {
    try {
      await mongoTransactionRepo.deleteTransaction(id: transaction.id ?? '');
    } catch (e) {
      throw 'Failed to delete transaction: $e';
    }
  }

  Future<void> processUpdateTransaction({required TransactionModel transaction}) async {
    try{
      await mongoTransactionRepo.updateTransactionById(id: transaction.id!, transaction: transaction);
    } catch(e) {
      rethrow;
    }
  }

  Future<void> deleteTransactionByDialog({required TransactionModel transaction, required BuildContext context}) async {
    try {
        DialogHelper.showDialog(
          context: context,
          title: 'Delete Transaction',
          message: 'Are you sure you want to delete this transaction?',
          onSubmit: () async {
            await deleteTransaction(transaction: transaction);
            await refreshTransactions();
            Navigator.pop(context);
          },
          toastMessage: 'Transaction deleted successfully!',
        );

    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> updateTransactions({required List<String> ids, required Map<String, dynamic> updatedData}) async {
    try{
      await mongoTransactionRepo.updateTransactions(
          ids: ids,
          updatedData: updatedData
      );
    }catch(e){
      rethrow;
    }
  }

  Future<void> saveAndOpenPdf({required BuildContext context, required TransactionModel transaction}) async {

    final Uint8List pdfData = await generateExportInvoicePDF(transaction: transaction);

    // 2. Get storage directory (Downloads or fallback)
    final directory = await getDownloadsDirectory() ?? await getExternalStorageDirectory();
    final filePath = '${directory!.path}/invoice_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(filePath);

    // 3. Save PDF
    await file.writeAsBytes(pdfData);

    // 4. Show message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invoice saved to ${file.path}')),
    );

    // 5. Open in external PDF viewer
    final result = await OpenFile.open(file.path);
    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open PDF: ${result.message}')),
      );
    }
  }


  Future<Uint8List> generateExportInvoicePDF({required TransactionModel transaction}) async {
    final UserModel company = AuthenticationController.instance.admin.value;
    final pdf = pw.Document();
    final robotoFont = pw.Font.ttf(await rootBundle.load('assets/fonts/roboto/Roboto-Bold.ttf'));
    final font = pw.Font.ttf(await rootBundle.load('assets/fonts/times-new-roman/times.ttf'));
    final fontBold = pw.Font.ttf(await rootBundle.load('assets/fonts/times-new-roman/times-new-roman-bold.ttf'));
    final double fontSizeBig = 9;
    final double fontSizeNormal = 8;
    final double fontSizeSmall = 7;
    final double spaceBtwLine = 3;
    final double spaceBtwSection = 20;

    pw.Widget buildInvoiceRow({
      required String item,
      required int hsn,
      required int quantity,
      required int rate,
      required int gstRate,
      required int taxableValue,
      required int gst,
      required int total,
    }) {
      return pw.Container(
        color: PdfColor.fromInt(0xFFFFFFFF), // Change as needed
        padding: pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: pw.Row(
          children: [
            pw.Expanded(
              flex: 5,
              child: pw.Text(item, style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
            ),
            pw.SizedBox(width: 5),
            pw.Expanded(
              flex: 2,
              child: pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(hsn.toString(), style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
              ),
            ),
            pw.SizedBox(width: 5),
            pw.Expanded(
              flex: 2,
              child: pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(quantity.toString(), style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
              ),
            ),
            pw.SizedBox(width: 5),
            pw.Expanded(
              flex: 2,
              child: pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(rate.toString(), style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
              ),
            ),
            pw.SizedBox(width: 5),
            pw.Expanded(
              flex: 2,
              child: pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(gstRate.toString(), style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
              ),
            ),
            pw.SizedBox(width: 5),
            pw.Expanded(
              flex: 2,
              child: pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(taxableValue.toString(), style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
              ),
            ),
            pw.SizedBox(width: 5),
            pw.Expanded(
              flex: 2,
              child: pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(gst.toString(), style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
              ),
            ),
            pw.SizedBox(width: 5),
            pw.Expanded(
              flex: 2,
              child: pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(total.toString(), style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
              ),
            ),
          ],
        ),
      );
    }

    List<pw.Widget> itemRows = [];

    for (final product in transaction.products!) {
      itemRows.add(
        buildInvoiceRow(
          item: product.name ?? '',
          hsn: product.hsnCode ?? 0,
          quantity: product.quantity ?? 0,
          rate: product.price ?? 0,
          gstRate: 18,
          taxableValue: int.parse(product.total ?? '0'),
          gst: 0,
          total: int.parse(product.total ?? '0'),
        ),
      );
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(35),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(height: spaceBtwSection),

              // Tax Invoice
              pw.Center(child: pw.Text("TAX INVOICE", style: pw.TextStyle(font: robotoFont, fontSize: 12, color: PdfColor.fromInt(0xFFD32F2F) )),),
              pw.SizedBox(height: spaceBtwSection),

              // Company Name
              pw.Text(company.companyName ?? 'N/A', style: pw.TextStyle(font: robotoFont, fontSize: 10, color: PdfColor.fromInt(0xFFD32F2F))),
              pw.SizedBox(height: spaceBtwLine),

              // Address1, Gst no., Date
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 8,
                    child: pw.Text(
                      company.billing?.address1 ?? '',
                      style: pw.TextStyle(font: font, fontSize: fontSizeNormal),
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text("GSTIN:", style: pw.TextStyle(font: fontBold, fontSize: fontSizeNormal),
                    ),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                    company.gstNumber ?? '', style: pw.TextStyle(font: font, fontSize: fontSizeNormal)),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      "Date:",
                      style: pw.TextStyle(font: fontBold, fontSize: fontSizeNormal),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      AppFormatter.formatDate(transaction.date),
                      style: pw.TextStyle(font: font, fontSize: fontSizeNormal),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: spaceBtwLine),

              // Address2, PAN, Invoice Number
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 8,
                    child: pw.Text(
                      company.billing?.address2 ?? '',
                      style: pw.TextStyle(font: font, fontSize: fontSizeNormal),
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text(
                      "PAN:",
                      style: pw.TextStyle(font: fontBold, fontSize: fontSizeNormal),
                    ),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(company.panNumber ?? '',
                      style: pw.TextStyle(font: font, fontSize: fontSizeNormal),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      "Invoice No:",
                      style: pw.TextStyle(font: fontBold, fontSize: fontSizeNormal),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      "#${transaction.transactionId}",
                      style: pw.TextStyle(font: font, fontSize: fontSizeNormal),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: spaceBtwLine),

              // Address3, State, Reference Number
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 8,
                    child: pw.Text(
                      "${StateData.getStateNameFromCodeOrName(company.billing?.state ?? '')} - ${company.billing?.pincode}, ${CountryData.getCountryFromISOCode(company.billing?.country ?? '')}",
                      style: pw.TextStyle(font: font, fontSize: fontSizeNormal),
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text(
                      "State:",
                      style: pw.TextStyle(font: fontBold, fontSize: fontSizeNormal),
                    ),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      StateData.getStateNameFromCodeOrName(company.billing?.state ?? '') ?? '',
                      style: pw.TextStyle(font: font, fontSize: fontSizeNormal),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      "Reference No:",
                      style: pw.TextStyle(font: fontBold, fontSize: fontSizeNormal),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      '#${transaction.orderIds!.first.toString()}',
                      style: pw.TextStyle(font: font, fontSize: fontSizeNormal),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: spaceBtwLine),

              // Mob, Payment Method
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 8,
                    child: pw.Text(
                      "Mob: ${company.phone}",
                      style: pw.TextStyle(font: font, fontSize: fontSizeNormal),
                    ),
                  ),
                  pw.Expanded(
                    flex: 4,
                    child: pw.Text(
                      "Payment Method:",
                      style: pw.TextStyle(font: fontBold, fontSize: fontSizeNormal),
                    ),
                  ),
                  pw.Expanded(
                    flex: 4,
                    child: pw.Text(
                      "Advance Payment",
                      style: pw.TextStyle(font: font, fontSize: fontSizeNormal),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: spaceBtwLine),

              // Email, Customer Incoterms
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 8,
                    child: pw.Text(
                      "Email: ${company.email}",
                      style: pw.TextStyle(font: font, fontSize: fontSizeNormal),
                    ),
                  ),
                  pw.Expanded(
                    flex: 4,
                    child: pw.Text(
                      "CUSTOMER INCOTERMS",
                      style: pw.TextStyle(font: fontBold, fontSize: fontSizeNormal),
                    ),
                  ),
                  pw.Expanded(
                    flex: 4,
                    child: pw.Text(
                      "Cost and Freight",
                      style: pw.TextStyle(font: font, fontSize: fontSizeNormal),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: spaceBtwSection),

              // Customer Name and address
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 5,
                    child: pw.Text("Customer Name", style: pw.TextStyle(font: font, fontSize: fontSizeSmall)),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    flex: 5,
                    child: pw.Text("Billing Address", style: pw.TextStyle(font: font, fontSize: fontSizeSmall)),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    flex: 5,
                    child: pw.Text("Shipping Address", style: pw.TextStyle(font: font, fontSize: fontSizeSmall)),

                  ),
                ],
              ),
              pw.SizedBox(height: spaceBtwLine),

              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 5,
                    child: pw.Text(transaction.address?.name ?? 'N/A', style: pw.TextStyle(font: fontBold, fontSize: fontSizeBig)),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    flex: 5,
                    child: pw.Text(transaction.address?.name ?? 'N/A', style: pw.TextStyle(font: fontBold, fontSize: fontSizeBig)),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    flex: 5,
                    child: pw.Text(transaction.address?.name ?? 'N/A', style: pw.TextStyle(font: fontBold, fontSize: fontSizeBig)),
                  ),
                ],
              ),
              pw.SizedBox(height: spaceBtwLine),

              // Customer address1
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text("Mob:", style: pw.TextStyle(font: fontBold, fontSize: fontSizeBig)),
                  ),
                  pw.Expanded(
                    flex: 4,
                    child: pw.Text(transaction.address?.phone ?? '', style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    flex: 5,
                    child: pw.Text(transaction.address?.address1 ?? '', style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    flex: 5,
                    child: pw.Text(transaction.address?.address1 ?? '', style: pw.TextStyle(font: font, fontSize: fontSizeBig)),

                  ),
                ],
              ),
              pw.SizedBox(height: spaceBtwLine),

              // Customer address2
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text("Email:", style: pw.TextStyle(font: fontBold, fontSize: fontSizeBig)),
                  ),
                  pw.Expanded(
                    flex: 4,
                    child: pw.Text(transaction.address?.email ?? '', style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    flex: 5,
                    child: pw.Text(transaction.address?.address2 ?? '', style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    flex: 5,
                    child: pw.Text(transaction.address?.address2 ?? '', style: pw.TextStyle(font: font, fontSize: fontSizeBig)),

                  ),
                ],
              ),
              pw.SizedBox(height: spaceBtwLine),

              // Customer address3
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text("GSTIN:", style: pw.TextStyle(font: fontBold, fontSize: fontSizeBig)),
                  ),
                  pw.Expanded(
                    flex: 4,
                    child: pw.Text(transaction.address?.gstNumber ?? '', style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    flex: 5,
                    child: pw.Text("${StateData.getStateNameFromCodeOrName(transaction.address?.state ?? '')} - ${transaction.address?.pincode}, ${CountryData.getCountryFromISOCode(transaction.address?.country ?? '')}", style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    flex: 5,
                    child: pw.Text("${StateData.getStateNameFromCodeOrName(transaction.address?.state ?? '')} - ${transaction.address?.pincode}, ${CountryData.getCountryFromISOCode(transaction.address?.country ?? '')}", style: pw.TextStyle(font: font, fontSize: fontSizeBig)),

                  ),
                ],
              ),
              pw.SizedBox(height: spaceBtwSection),

              // Place of supply
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 4,
                    child: pw.Text("Place of supply", style: pw.TextStyle(font: fontBold, fontSize: fontSizeBig)),
                  ),
                  pw.Expanded(
                    flex: 4,
                    child: pw.Text(StateData.getStateNameFromCodeOrName(transaction.address?.state ?? '') ?? '', style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                  ),
                  pw.Expanded(
                    flex: 4,
                    child: pw.Text("Country of supply", style: pw.TextStyle(font: fontBold, fontSize: fontSizeBig)),
                  ),
                  pw.Expanded(
                    flex: 4,
                    child: pw.Text(CountryData.getCountryFromISOCode(transaction.address?.country ?? '') ?? '', style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                  ),
                ],
              ),
              pw.SizedBox(height: spaceBtwSection),

              // Header
              pw.Container(
                color: PdfColor.fromInt(0xFFFFFF99), // Light yellow background (same as header)
                padding: pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4), // Optional padding
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text("Items", style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                    ),
                    pw.SizedBox(width: 5),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text("HSN / SAC", style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                      ),
                    ),
                    pw.SizedBox(width: 5),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text("Quantity", style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                      ),
                    ),
                    pw.SizedBox(width: 5),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text("Rate / Item", style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                      ),
                    ),
                    pw.SizedBox(width: 5),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text("GST Rate", style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                      ),
                    ),
                    pw.SizedBox(width: 5),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text("Taxable Value ", style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                      ),
                    ),
                    pw.SizedBox(width: 5),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text("GST", style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                      ),
                    ),
                    pw.SizedBox(width: 5),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text("Total", style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                      ),
                    ),
                  ],
                ),
              ),

              // Items
              pw.Column(
                children: itemRows,
              ),

              // Footer
              pw.Container(
                color: PdfColor.fromInt(0xFFFFFF99), // Light yellow background (same as header)
                padding: pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4), // Optional padding
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text("", style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                    ),
                    pw.SizedBox(width: 5),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text("", style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                      ),
                    ),
                    pw.SizedBox(width: 5),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text("", style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                      ),
                    ),
                    pw.SizedBox(width: 5),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text("Total", style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                      ),
                    ),
                    pw.SizedBox(width: 5),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text("", style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                      ),
                    ),
                    pw.SizedBox(width: 5),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text("7000", style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                      ),
                    ),
                    pw.SizedBox(width: 5),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text("00", style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                      ),
                    ),
                    pw.SizedBox(width: 5),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text("7000", style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: spaceBtwSection),

              // Total
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 12,
                          child: pw.Text("", style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text("Taxable Amount", style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text("7710.00", style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: spaceBtwLine),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 12,
                          child: pw.Text("", style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text("Total Tax", style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text("0.00", style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: spaceBtwLine),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 12,
                          child: pw.Text("", style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text("Total Value", style: pw.TextStyle(font: fontBold, fontSize: 12)),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text(transaction.amount.toString(), style: pw.TextStyle(font: fontBold, fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: spaceBtwSection),

              // Total in words
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 6,
                    child: pw.Text("", style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text("Total amount (in words):", style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                  ),
                  pw.Expanded(
                    flex: 7,
                    child: pw.Text(convertNumberToWords(transaction.amount?.toInt() ?? 0), style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                  ),
                ],
              ),
              pw.SizedBox(height: spaceBtwSection),

              // Bank account details
              pw.Row(
                children: [
                  pw.Text("Bank Details:", style: pw.TextStyle(font: font, fontSize: 8)),
                ],
              ),
              pw.SizedBox(height: spaceBtwLine),
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text("Account Number:", style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                  ),
                  pw.Expanded(
                    flex: 4,
                    child: pw.Text(company.bankAccount?.accountNumber ?? '', style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                  ),
                  pw.Expanded(
                    flex: 5,
                    child: pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text("For ${company.companyName}", style: pw.TextStyle(font: fontBold, fontSize: fontSizeBig)),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: spaceBtwLine),
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text("Swift Code:", style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                  ),
                  pw.Expanded(
                    flex: 4,
                    child: pw.Text(company.bankAccount?.swiftCode ?? '', style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                  ),
                  pw.Expanded(
                    flex: 5,
                    child: pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text("", style: pw.TextStyle(font: fontBold, fontSize: fontSizeBig)),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: spaceBtwLine),
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text("IFSC:", style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                  ),
                  pw.Expanded(
                    flex: 4,
                    child: pw.Text(company.bankAccount?.ifscCode ?? '', style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                  ),
                  pw.Expanded(
                    flex: 5,
                    child: pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text("", style: pw.TextStyle(font: fontBold, fontSize: fontSizeBig)),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: spaceBtwLine),
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text("Bank Name:", style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                  ),
                  pw.Expanded(
                    flex: 4,
                    child: pw.Text(company.bankAccount?.bankName ?? '', style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                  ),
                  pw.Expanded(
                    flex: 5,
                    child: pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text("Authorised Signatory", style: pw.TextStyle(font: font, fontSize: fontSizeBig)),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: spaceBtwSection),

              // Terms
              pw.Text("SUPPLY MEANT FOR EXPORT UNDER BOND OR LETTER OF UNDERTAKING WITHOUT PAYMENT OF INTEGRATED TAX", style: pw.TextStyle(font: fontBold, fontSize: 7, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: spaceBtwLine),
              pw.Text("Payment: Advance payment along with purchase order.", style: pw.TextStyle(font: font, fontSize: 7)),
              pw.SizedBox(height: spaceBtwLine),
              pw.Text("Taxes: GST applicable as per govt. guidelines.", style: pw.TextStyle(font: font, fontSize: 7)),
              pw.SizedBox(height: spaceBtwLine),
              pw.Text("Other Charges: General shipping charges (if applicable).", style: pw.TextStyle(font: font, fontSize: 7)),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }

  String convertNumberToWords(int number) {
    if (number == 0) return 'Zero Rupees';

    final units = [
      '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine'
    ];
    final teens = [
      'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen',
      'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'
    ];
    final tens = [
      '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty',
      'Sixty', 'Seventy', 'Eighty', 'Ninety'
    ];

    String twoDigit(int n) {
      if (n < 10) return units[n];
      if (n < 20) return teens[n - 10];
      return tens[n ~/ 10] + (n % 10 != 0 ? '-${units[n % 10]}' : '');
    }

    String threeDigit(int n) {
      if (n < 100) return twoDigit(n);
      return '${units[n ~/ 100]} Hundred${(n % 100 != 0) ? ' ${twoDigit(n % 100)}' : ''}';
    }

    String inWords(int n) {
      if (n < 1000) return threeDigit(n);
      if (n < 100000) {
        return '${inWords(n ~/ 1000)} Thousand${(n % 1000 != 0) ? ' ${threeDigit(n % 1000)}' : ''}';
      }
      if (n < 10000000) {
        return '${inWords(n ~/ 100000)} Lakh${(n % 100000 != 0) ? ' ${inWords(n % 100000)}' : ''}';
      }
      return '${inWords(n ~/ 10000000)} Crore${(n % 10000000 != 0) ? ' ${inWords(n % 10000000)}' : ''}';
    }

    return '${inWords(number)} Rupees';
  }


}
