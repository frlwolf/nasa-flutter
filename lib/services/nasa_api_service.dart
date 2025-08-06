import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/apod_item.dart';
import '../config/api_config.dart';
import 'hive_service.dart';

class NasaApiService {
  static const String _baseUrl = ApiConfig.nasaApodBaseUrl;
  static const String _apiKey = ApiConfig.nasaApiKey; // Use your actual API key
  
  // Singleton pattern for the API service
  static final NasaApiService _instance = NasaApiService._internal();
  factory NasaApiService() => _instance;
  NasaApiService._internal();

  final http.Client _client = http.Client();

  /// Fetches a single APOD item for today or a specific date
  Future<ApodItem> getApodForDate([DateTime? date]) async {
    try {
      final Map<String, String> params = {
        'api_key': _apiKey,
      };
      
      if (date != null) {
        params['date'] = DateFormat('yyyy-MM-dd').format(date);
      }

      final uri = Uri.parse(_baseUrl).replace(queryParameters: params);
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final item = ApodItem.fromJson(json);
        
        // Save to cache
        await HiveService.saveApodItem(item);
        
        return item;
      } else if (response.statusCode == 429) {
        throw ApiException('Rate limit exceeded. Please try again later.');
      } else if (response.statusCode == 403) {
        throw ApiException('Invalid API key. Please check your NASA API key.');
      } else {
        throw ApiException('Failed to load APOD: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// Fetches multiple APOD items for a date range
  Future<List<ApodItem>> getApodRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final Map<String, String> params = {
        'api_key': _apiKey,
        'start_date': DateFormat('yyyy-MM-dd').format(startDate),
        'end_date': DateFormat('yyyy-MM-dd').format(endDate),
      };

      final uri = Uri.parse(_baseUrl).replace(queryParameters: params);
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final items = jsonList
            .map((json) => ApodItem.fromJson(json as Map<String, dynamic>))
            .toList()
            .reversed // NASA returns newest first, we want oldest first
            .toList();
        
        // Save all items to cache
        await HiveService.saveApodItems(items);
        
        return items;
      } else if (response.statusCode == 429) {
        throw ApiException('Rate limit exceeded. Please try again later.');
      } else if (response.statusCode == 403) {
        throw ApiException('Invalid API key. Please check your NASA API key.');
      } else {
        throw ApiException('Failed to load APOD range: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// Fetches a random set of APOD items
  Future<List<ApodItem>> getRandomApods({int count = 10}) async {
    try {
      final Map<String, String> params = {
        'api_key': _apiKey,
        'count': count.toString(),
      };

      final uri = Uri.parse(_baseUrl).replace(queryParameters: params);
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final items = jsonList
            .map((json) => ApodItem.fromJson(json as Map<String, dynamic>))
            .toList();
        
        // Save all items to cache
        await HiveService.saveApodItems(items);
        
        return items;
      } else if (response.statusCode == 429) {
        throw ApiException('Rate limit exceeded. Please try again later.');
      } else if (response.statusCode == 403) {
        throw ApiException('Invalid API key. Please check your NASA API key.');
      } else {
        throw ApiException('Failed to load random APODs: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// Gets recent APOD items (last N days)
  Future<List<ApodItem>> getRecentApods({int days = 30}) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    
    return getApodRange(startDate: startDate, endDate: endDate);
  }

  /// Disposes the HTTP client
  void dispose() {
    _client.close();
  }
}

/// Custom exception class for API-related errors
class ApiException implements Exception {
  final String message;
  
  const ApiException(this.message);
  
  @override
  String toString() => 'ApiException: $message';
}