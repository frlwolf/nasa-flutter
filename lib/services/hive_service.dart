import 'package:hive_flutter/hive_flutter.dart';
import '../models/apod_item.dart';

class HiveService {
  static const String _apodBoxName = 'apod_items';
  static Box<ApodItem>? _apodBox;

  /// Initialize Hive and open boxes
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ApodItemAdapter());
    }
    
    // Open boxes
    _apodBox = await Hive.openBox<ApodItem>(_apodBoxName);
  }

  /// Get the APOD box
  static Box<ApodItem> get apodBox {
    if (_apodBox == null || !_apodBox!.isOpen) {
      throw Exception('Hive not initialized. Call HiveService.init() first.');
    }
    return _apodBox!;
  }

  /// Save a single APOD item to cache
  static Future<void> saveApodItem(ApodItem item) async {
    await apodBox.put(item.date, item);
  }

  /// Save multiple APOD items to cache
  static Future<void> saveApodItems(List<ApodItem> items) async {
    final Map<String, ApodItem> itemsMap = {
      for (ApodItem item in items) item.date: item
    };
    await apodBox.putAll(itemsMap);
  }

  /// Get a single APOD item by date
  static ApodItem? getApodItem(String date) {
    return apodBox.get(date);
  }

  /// Get all cached APOD items
  static List<ApodItem> getAllApodItems() {
    return apodBox.values.toList();
  }

  /// Get APOD items sorted by date (newest first)
  static List<ApodItem> getApodItemsSorted() {
    final items = getAllApodItems();
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  /// Get APOD items within a date range
  static List<ApodItem> getApodItemsInRange(DateTime startDate, DateTime endDate) {
    final startDateStr = _dateToString(startDate);
    final endDateStr = _dateToString(endDate);
    
    return getAllApodItems()
        .where((item) => 
            item.date.compareTo(startDateStr) >= 0 && 
            item.date.compareTo(endDateStr) <= 0)
        .toList();
  }

  /// Search APOD items by title or explanation
  static List<ApodItem> searchApodItems(String query) {
    final lowercaseQuery = query.toLowerCase();
    
    return getAllApodItems()
        .where((item) =>
            item.title.toLowerCase().contains(lowercaseQuery) ||
            item.explanation.toLowerCase().contains(lowercaseQuery) ||
            item.date.contains(query))
        .toList();
  }

  /// Check if an item exists in cache
  static bool hasApodItem(String date) {
    return apodBox.containsKey(date);
  }

  /// Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    final items = getAllApodItems();
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    final recentItems = items.where((item) => 
        item.cachedAt.isAfter(weekAgo)).length;
    
    return {
      'totalItems': items.length,
      'recentItems': recentItems,
      'oldestItem': items.isEmpty ? null : items
          .map((e) => e.date)
          .reduce((a, b) => a.compareTo(b) < 0 ? a : b),
      'newestItem': items.isEmpty ? null : items
          .map((e) => e.date)
          .reduce((a, b) => a.compareTo(b) > 0 ? a : b),
    };
  }

  /// Clear old cached items (older than specified days)
  static Future<void> clearOldItems({int olderThanDays = 30}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: olderThanDays));
    final itemsToDelete = <String>[];
    
    for (final item in getAllApodItems()) {
      if (item.cachedAt.isBefore(cutoffDate)) {
        itemsToDelete.add(item.date);
      }
    }
    
    await apodBox.deleteAll(itemsToDelete);
  }

  /// Clear all cached items
  static Future<void> clearAllItems() async {
    await apodBox.clear();
  }

  /// Close all boxes (call when app is closing)
  static Future<void> close() async {
    await _apodBox?.close();
  }

  /// Helper method to convert DateTime to string format used by NASA API
  static String _dateToString(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
           '${date.month.toString().padLeft(2, '0')}-'
           '${date.day.toString().padLeft(2, '0')}';
  }
}