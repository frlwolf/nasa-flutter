import 'package:flutter/material.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSearchVisible;
  final TextEditingController searchController;
  final VoidCallback onSearchToggle;
  final ValueChanged<String>? onSearchChanged;
  final String? subtitle;

  const SearchAppBar({
    super.key,
    required this.isSearchVisible,
    required this.searchController,
    required this.onSearchToggle,
    this.onSearchChanged,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: isSearchVisible ? _buildSearchField() : _buildTitle(),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: Icon(isSearchVisible ? Icons.close : Icons.search),
          onPressed: onSearchToggle,
        ),
      ],
    );
  }

  Widget _buildTitle() {
    if (subtitle != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NASA APOD',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          Text(
            subtitle!,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      );
    }
    return const Text('NASA APOD');
  }

  Widget _buildSearchField() {
    return TextField(
      controller: searchController,
      decoration: const InputDecoration(
        hintText: 'Search by title or date...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white70),
      ),
      style: const TextStyle(color: Colors.white),
      autofocus: true,
      onChanged: onSearchChanged,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}