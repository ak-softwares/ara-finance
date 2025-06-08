import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/local_storage_constants.dart';
import 'search_product_screen3.dart';

class SearchVoucher1 extends SearchDelegate {
  RxList<String> recentlySearches = <String>[].obs;
  RxList<String> suggestionList = RxList<String>(); // Observable for suggestion list

  final localStorage = GetStorage();
  final AccountVoucherType voucherType; // Enum to differentiate search types
  final dynamic selectedItems; // Enum to differentiate search types

  @override
  String? get searchFieldLabel => 'Search ${_getSearchLabel()}...';

  SearchVoucher1({required this.voucherType, this.selectedItems}) {
    recentlySearches.value = _getRecentSearches(); // Initialize searches
  }

  @override
  TextStyle? get searchFieldStyle => const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryColor,
  );

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear, color: Colors.black),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }


  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    _saveSearchQuery(query);
    return _buildSearchResults(context: context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context: context);
  }

  Widget _buildSearchResults({required BuildContext context}) {
    return SearchScreen3(
      title: 'Search result for ${query.isEmpty ? '' : '"$query"'}',
      searchQuery: query,
      voucherType: voucherType,
      selectedItems: selectedItems,
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        titleTextStyle: theme.textTheme.titleLarge,
        toolbarTextStyle: theme.textTheme.bodyMedium,
      ),
      primaryColor: AppColors.primaryColor,
    );
  }

  void _saveSearchQuery(String searchQuery) {
    if (searchQuery.isEmpty) return;
    List<String> getSearches = localStorage.read(LocalStorage.searches)?.cast<String>() ?? [];
    if (!getSearches.contains(searchQuery)) {
      recentlySearches.add(searchQuery);
      localStorage.write(LocalStorage.searches, recentlySearches);
    }
  }

  List<String> _getRecentSearches() {
    return localStorage.read(LocalStorage.searches)?.cast<String>() ?? [];
  }

  void _removeSearch(String searchQuery) {
    recentlySearches.remove(searchQuery);
    localStorage.write(LocalStorage.searches, recentlySearches);
  }

  void _updateSuggestionList(String query) {
    if (query.isEmpty) {
      suggestionList.value = recentlySearches.reversed.take(5).toList();
    } else {
      // Fetch suggestions based on search type
      List<String> searchResults;
      switch (voucherType) {
        case AccountVoucherType.product:
          searchResults = _fetchProductSuggestions(query);
          break;
        case AccountVoucherType.customer:
          searchResults = _fetchCustomerSuggestions(query);
          break;
        case AccountVoucherType.sale:
          searchResults = _fetchUserSuggestions(query);
          break;
        default:
          searchResults = [];
      }
      suggestionList.value = searchResults.take(5).toList();
    }
  }

  List<String> _fetchProductSuggestions(String query) {
    // Replace with actual product search logic
    return ['Product A', 'Product B', 'Product C'].where((p) => p.toLowerCase().contains(query.toLowerCase())).toList();
  }

  List<String> _fetchCustomerSuggestions(String query) {
    // Replace with actual customer search logic
    return ['John Doe', 'Jane Smith', 'Customer X'].where((c) => c.toLowerCase().contains(query.toLowerCase())).toList();
  }

  List<String> _fetchUserSuggestions(String query) {
    // Replace with actual user search logic
    return ['User1', 'User2', 'User3'].where((u) => u.toLowerCase().contains(query.toLowerCase())).toList();
  }

  String _getSearchLabel() {
    switch (voucherType) {
      case AccountVoucherType.product:
        return 'Products';
      case AccountVoucherType.customer:
        return 'Customers';
      case AccountVoucherType.sale:
        return 'Users';
      case AccountVoucherType.vendor:
        return 'Vendors';
      case AccountVoucherType.bankAccount:
        return 'Bank accounts';
      case AccountVoucherType.expense:
        return 'Expenses';
      default:
        return '';
    }
  }
}
