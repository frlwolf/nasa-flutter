import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/apod_item.dart';
import '../widgets/apod_image.dart';

class ApodDetailScreen extends StatefulWidget {
  final ApodItem item;

  const ApodDetailScreen({
    super.key,
    required this.item,
  });

  @override
  State<ApodDetailScreen> createState() => _ApodDetailScreenState();
}

class _ApodDetailScreenState extends State<ApodDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Show title in app bar when scrolled past the image
    const threshold = 200.0;
    final showTitle = _scrollController.offset > threshold;
    
    if (showTitle != _showAppBarTitle) {
      setState(() {
        _showAppBarTitle = showTitle;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _buildContent(),
          ),
        ],
      ),
      floatingActionButton: _buildShareButton(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300.0,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      title: _showAppBarTitle
          ? Text(
              widget.item.title,
              style: const TextStyle(fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'apod_image_${widget.item.date}',
          child: ApodImageHD(
            item: widget.item,
            fit: BoxFit.cover,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: _shareApod,
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildExplanation(),
          const SizedBox(height: 24),
          _buildMetadata(),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.item.title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              _formatDate(widget.item.date),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (widget.item.mediaType == 'video')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.play_circle_filled,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Video',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildExplanation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About this image',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Text(
            widget.item.explanation,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetadata() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              _buildMetadataRow(
                'Date',
                _formatDate(widget.item.date),
                Icons.calendar_today,
              ),
              const Divider(height: 24),
              _buildMetadataRow(
                'Media Type',
                widget.item.mediaType.toUpperCase(),
                widget.item.mediaType == 'video' 
                    ? Icons.video_library 
                    : Icons.image,
              ),
              if (widget.item.copyright != null) ...[
                const Divider(height: 24),
                _buildMetadataRow(
                  'Copyright',
                  widget.item.copyright!,
                  Icons.copyright,
                ),
              ],
              if (widget.item.hdurl != null) ...[
                const Divider(height: 24),
                _buildMetadataRow(
                  'HD Version',
                  'Available',
                  Icons.hd,
                  onTap: () => _viewHDImage(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataRow(
    String label,
    String value,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton() {
    return FloatingActionButton.extended(
      onPressed: _shareApod,
      icon: const Icon(Icons.share),
      label: const Text('Share'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMMM d, y').format(date);
    } catch (e) {
      return dateString;
    }
  }

  void _shareApod() {
    // TODO: Implement actual sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing: ${widget.item.title}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _viewHDImage() {
    // TODO: Implement HD image viewer
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('HD image viewer coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}