import 'package:flutter/material.dart';
import '../models/apod_item.dart';
import 'apod_image.dart';

class ApodCard extends StatelessWidget {
  final ApodItem item;
  final VoidCallback onTap;

  const ApodCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(context),
            _buildContentSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Hero(
      tag: 'apod_image_${item.date}',
      child: ApodImage(
        item: item,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        showVideoIndicator: true,
        showCopyright: true,
      ),
    );
  }

  Widget _buildContentSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleAndDate(context),
          const SizedBox(height: 8),
          _buildExplanationPreview(context),
          const SizedBox(height: 8),
          _buildReadMoreIndicator(context),
        ],
      ),
    );
  }

  Widget _buildTitleAndDate(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            item.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            item.date,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExplanationPreview(BuildContext context) {
    return Text(
      item.explanation,
      style: Theme.of(context).textTheme.bodyMedium,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildReadMoreIndicator(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Tap to read more',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          Icons.arrow_forward_ios,
          size: 12,
          color: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }
}