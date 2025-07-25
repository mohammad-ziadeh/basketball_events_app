import 'package:fiba_3x3/pages/gallery/media_tile.dart';
import 'package:fiba_3x3/services/gallery_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class GalleryScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const GalleryScreen({super.key, required this.onToggleTheme});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<Gallery> galleries = [];
  List<String> eventTitles = ['All'];
  String selectedType = 'All';
  String selectedEventTitle = 'All';
  bool isLoading = true;

  final _types = ['All', 'photo', 'video'];
  final service = GalleryService();

  @override
  void initState() {
    super.initState();

    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    fetchGalleries();
  }

  Future<void> fetchGalleries() async {
    setState(() => isLoading = true);
    try {
      final data = await service.fetchGalleries(
        type: selectedType != 'All' ? selectedType : null,
        eventTitle: selectedEventTitle != 'All' ? selectedEventTitle : null,
      );

      final titles =
          data
              .map((g) => g.event?.title ?? '')
              .where((title) => title.isNotEmpty)
              .toSet()
              .toList()
            ..sort();

      setState(() {
        galleries = data;
        eventTitles = ['All', ...titles];
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedType,
              onChanged:
                  isLoading
                      ? null
                      : (val) {
                        setState(() => selectedType = val!);
                        fetchGalleries();
                      },
              decoration: const InputDecoration(labelText: 'Type'),
              items:
                  _types
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedEventTitle,
              onChanged:
                  isLoading
                      ? null
                      : (val) {
                        setState(() => selectedEventTitle = val!);
                        fetchGalleries();
                      },
              decoration: const InputDecoration(labelText: 'Event'),
              items:
                  eventTitles
                      .map(
                        (title) =>
                            DropdownMenuItem(value: title, child: Text(title)),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    if (galleries.isEmpty) {
      return const Center(child: Text('No media found.'));
    }

    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      padding: const EdgeInsets.all(8),
      itemCount: galleries.length,
      itemBuilder: (context, index) {
        final gallery = galleries[index];
        return MediaTile(gallery: gallery, index: index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gallery')),
      body: Column(children: [_buildFilters(), Expanded(child: _buildGrid())]),
    );
  }
}
