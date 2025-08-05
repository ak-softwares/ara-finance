import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../common/layout_models/product_grid_layout.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/local_storage_constants.dart';
import '../../../../utils/constants/sizes.dart';
import '../../screen/search/search/search_picker_screen.dart';
import '../../screen/search/search/search_screen.dart';

class AppSearchDelegate extends SearchDelegate {

  final localStorage = GetStorage();
  RxMap<String, List<String>> recentlySearches = <String, List<String>>{}.obs;

  final SearchType? searchType;
  final AccountVoucherType? voucherType;
  final bool isPicker;
  final int numberOfSearch =  3;

  @override
  String? get searchFieldLabel => 'Search ${_getSearchLabel()}..';

  AppSearchDelegate({this.voucherType, this.searchType,  this.isPicker = false}) {
    _loadRecentSearchesFromLocal(); // Initialize searches
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [];

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    _addRecentSearch(key: _getSearchLabel(), term: query);
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isNotEmpty && query.length >= 3) {
      return _buildSearchResults();
    }

    return SingleChildScrollView(
      child: Obx(() {
        return _hasRecentSearches(_getSearchLabel())
            ? _searchHistory()
            : const SizedBox.shrink();
      }),
    );
  }

  Widget _buildSearchResults() {
    if (isPicker) {
      return SearchPickerScreen(
        title: 'Search result for ${query.isEmpty ? '' : '"$query"'}',
        searchQuery: query,
        voucherType: voucherType!,
      );
    } else {
      return SearchScreen(
        title: 'Search result for ${query.isEmpty ? '' : '"$query"'}',
        searchQuery: query,
        searchType: searchType!,
        voucherType: voucherType,
      );
    }
  }

  Widget _searchHistory() {
    final search = getRecentSearches(_getSearchLabel());
    return GridLayout(
      mainAxisSpacing: 0,
      mainAxisExtent: 35,
      itemCount: search.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          dense: true,
          leading: Icon(Icons.history, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 18),
          trailing: IconButton(
            icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 18),
            onPressed: () => _removeSearchTerm(key: _getSearchLabel(), searchQuery: search[index]),
          ),
          title: Text(
            search[index],
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          onTap: () {
            query = search[index];
            showResults(context);
          },
        );
      },
    );
  }

  String _getSearchLabel() {
    return (voucherType?.name ?? searchType?.name) ?? '';
  }

  void _addRecentSearch({required String key, required String term}) {
    if (term.isEmpty) return;
    final currentList = recentlySearches[key] ?? [];
    if (!currentList.contains(term)) {
      currentList.insert(0, term); // optional: insert at the top
      recentlySearches[key] = currentList.take(numberOfSearch).toList(); // keep max 10
      _saveRecentSearchesToLocal();
    }
  }

  void _saveRecentSearchesToLocal() {
    final jsonString = jsonEncode(recentlySearches);
    localStorage.write(LocalStorageName.searches, jsonString);
  }

  List<String> getRecentSearches(String key) {
    return recentlySearches[key] ?? [];
  }


  void _loadRecentSearchesFromLocal() {
    final jsonString = localStorage.read(LocalStorageName.searches);
    if (jsonString != null) {
      final Map<String, dynamic> rawMap = jsonDecode(jsonString);
      recentlySearches.value = rawMap.map((key, value) => MapEntry(key, List<String>.from(value)));
    }
  }

  bool _hasRecentSearches(String key) {
    return recentlySearches.containsKey(key) && recentlySearches[key]!.isNotEmpty;
  }

  void _removeSearchTerm({required String key, required String searchQuery}) {
    if (recentlySearches.containsKey(key)) {
      final updatedList = recentlySearches[key]!..remove(searchQuery);

      // Update the map
      if (updatedList.isEmpty) {
        recentlySearches.remove(key); // Optionally remove key if empty
      } else {
        recentlySearches[key] = updatedList;
      }

      // Save to local storage
      final jsonString = jsonEncode(recentlySearches);
      localStorage.write(LocalStorageName.searches, jsonString);
    }
  }


  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        // iconTheme: theme.primaryIconTheme.copyWith(color: Colors.grey),
        // titleTextStyle: TextStyle(color: Colors.blue),
        // toolbarTextStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        // toolbarHeight: 90,
      ),
      // primaryColor: TColors.primaryColor,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Theme.of(context).colorScheme.onSurface,
        selectionColor: Colors.blue.shade200,
        selectionHandleColor: Colors.blue.shade200,
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          fontSize: 15, // Customize font size
          fontWeight: FontWeight.w500, // Customize font weight
          color: Theme.of(context).colorScheme.onSurface, // Customize font color
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        // hintStyle: searchFieldStyle ?? theme.inputDecorationTheme.hintStyle,
        // border: InputBorder.none,
        isDense: true, // Ensures the padding takes effect
        contentPadding: const EdgeInsets.symmetric(vertical: AppSizes.sm, horizontal: AppSizes.md), // Define input field height
        fillColor: Theme.of(context).colorScheme.surface, // Customize the background color
        filled: true, // Ensure the fill color is applied
        hintStyle: TextStyle(
          fontSize: 15, // Customize hint text font size
          color: Theme.of(context).colorScheme.onSurfaceVariant, // Customize hint text color
        ),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            // borderSide: BorderSide(
            //   color: Theme.of(context).colorScheme.surface,
            //   width: 2.0, // Customize the border width
            // ),
            borderRadius: BorderRadius.circular(AppSizes.searchFieldRadius) // Optional: Customize the border radius
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          // borderSide: BorderSide(
          //   color: Theme.of(context).colorScheme.surface,
          //   width: 2.0, // Customize the border width
          // ),
          borderRadius: BorderRadius.circular(AppSizes.searchFieldRadius),
        ),
        border: OutlineInputBorder(
            borderSide: BorderSide.none,
            // borderSide: BorderSide(
            //   color: Theme.of(context).colorScheme.surface,
            //   width: 1.0, // Customize the default border width
            // ),
            borderRadius: BorderRadius.circular(AppSizes.searchFieldRadius)
        ),
      ),
    );
  }
}
