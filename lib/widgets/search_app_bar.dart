import 'package:flutter/material.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSearchVisible;
  final TextEditingController searchController;
  final VoidCallback onSearchToggle;
  final ValueChanged<String>? onSearchChanged;

  const SearchAppBar({
    super.key,
    required this.isSearchVisible,
    required this.searchController,
    required this.onSearchToggle,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: isSearchVisible ? _buildSearchField() : const Text('NASA APOD'),
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