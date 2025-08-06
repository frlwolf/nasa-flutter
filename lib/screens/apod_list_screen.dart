import 'package:flutter/material.dart';
import '../models/apod_item.dart';
import '../widgets/apod_card.dart';
import '../widgets/search_app_bar.dart';

class ApodListScreen extends StatefulWidget {
  const ApodListScreen({super.key});

  @override
  State<ApodListScreen> createState() => _ApodListScreenState();
}

class _ApodListScreenState extends State<ApodListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;
  List<ApodItem> _filteredItems = [];
  
  // Mock data for demonstration - will be replaced with real data later
  final List<ApodItem> _mockItems = [
    ApodItem(
      title: "The Horsehead Nebula",
      date: "2024-01-15",
      explanation: "One of the most identifiable nebulae in the sky, the Horsehead Nebula in Orion, is part of a large, dark, molecular cloud. This image shows the nebula in infrared light, revealing details normally hidden by dust.",
      url: "https://example.com/image1.jpg",
      hdurl: "https://example.com/hd_image1.jpg",
      copyright: "NASA/ESA",
    ),
    ApodItem(
      title: "Saturn's Rings in Infrared",
      date: "2024-01-14", 
      explanation: "What do Saturn's rings look like in infrared light? The answer is revealed in this false-color composite image from the Cassini spacecraft. The different colors represent different ring particle compositions and temperatures.",
      url: "https://example.com/image2.jpg",
      mediaType: "image",
    ),
    ApodItem(
      title: "Galaxy Collision in NGC 6302",
      date: "2024-01-13",
      explanation: "The bright clusters and nebulae of planet Earth's night sky are often named for flowers or insects. Though its wingspan covers over 3 light-years, NGC 6302 is no exception. With an estimated surface temperature of about 36,000 degrees C, the central star of this particular planetary nebula has become exceptionally hot, shining brightly in ultraviolet light but hidden from direct view by a dense torus of dust.",
      url: "https://example.com/image3.jpg",
      copyright: "Hubble Heritage Team",
    ),
    ApodItem(
      title: "Mars Rover Video: Descent and Landing",
      date: "2024-01-12",
      explanation: "This video shows the dramatic descent and landing of NASA's Perseverance rover on Mars. The footage was captured by multiple cameras during the final minutes of the rover's journey to the Red Planet.",
      url: "https://example.com/video1.mp4",
      mediaType: "video",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _filteredItems = _mockItems;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = _mockItems;
      } else {
        _filteredItems = _mockItems.where((item) {
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
        _filteredItems = _mockItems;
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
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_filteredItems.isEmpty && _searchController.text.isNotEmpty) {
      return _buildEmptySearchResult();
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
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // TODO: Implement actual data refresh from API
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data refreshed!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToDetail(ApodItem item) {
    // TODO: Navigate to detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening: ${item.title}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}