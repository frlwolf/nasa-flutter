import 'package:flutter/material.dart';
import '../models/apod_item.dart';
import '../widgets/apod_card.dart';
import '../widgets/search_app_bar.dart';
import '../services/nasa_api_service.dart';
import '../services/hive_service.dart';
import 'apod_detail_screen.dart';

class ApodListScreen extends StatefulWidget {
  const ApodListScreen({super.key});

  @override
  State<ApodListScreen> createState() => _ApodListScreenState();
}

class _ApodListScreenState extends State<ApodListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final NasaApiService _apiService = NasaApiService();
  
  bool _isSearchVisible = false;
  bool _isLoading = true;
  bool _isShowingCachedData = false;
  String? _error;
  
  List<ApodItem> _allItems = [];
  List<ApodItem> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadApodData();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadApodData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // STEP 1: Load from cache first (instant display)
      final cachedItems = HiveService.getApodItemsSorted();
      
      if (cachedItems.isNotEmpty) {
        setState(() {
          _allItems = cachedItems;
          _filteredItems = cachedItems;
          _isLoading = false; // Show cached data immediately
          _isShowingCachedData = true;
        });
      }

      // STEP 2: Try to refresh from API in background
      await _refreshFromApi();
      
    } catch (e) {
      // If cache loading fails, try API directly
      await _refreshFromApi();
    }
  }

  Future<void> _refreshFromApi() async {
    try {
      // Load recent APOD items from API (last 30 days)
      final apiItems = await _apiService.getRecentApods(days: 30);
      
      // Update UI with fresh data from API
      setState(() {
        _allItems = apiItems;
        _filteredItems = apiItems;
        _isLoading = false;
        _error = null;
        _isShowingCachedData = false; // Now showing fresh data
      });
      
    } catch (e) {
      // If API fails but we have cached data, keep showing cached data
      if (_allItems.isEmpty) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      } else {
        // Show a subtle indication that refresh failed but cache is being used
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.cloud_off, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text('Showing cached data - refresh failed'),
                ],
              ),
              backgroundColor: Colors.orange[700],
              duration: Duration(seconds: 3),
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = _allItems;
      } else {
        _filteredItems = _allItems.where((item) {
          return item.title.toLowerCase().contains(query) ||
                 item.date.contains(query) ||
                 item.explanation.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _searchController.clear();
        _filteredItems = _allItems;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchAppBar(
        isSearchVisible: _isSearchVisible,
        searchController: _searchController,
        onSearchToggle: _toggleSearch,
        onSearchChanged: (value) => _onSearchChanged(),
        subtitle: _isShowingCachedData ? 'Showing cached data' : null,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading NASA APOD data...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_filteredItems.isEmpty && _searchController.text.isNotEmpty) {
      return _buildEmptySearchResult();
    }

    if (_filteredItems.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return ApodCard(
          item: item,
          onTap: () => _navigateToDetail(item),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.red[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error occurred',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadApodData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No APOD data available',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull to refresh to try loading data again',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchResult() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    // Force refresh from API (user explicitly requested fresh data)
    await _refreshFromApi();
  }

  void _navigateToDetail(ApodItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ApodDetailScreen(item: item),
      ),
    );
  }
}