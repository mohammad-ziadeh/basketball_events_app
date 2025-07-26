import 'package:dropdown_button2/dropdown_button2.dart';
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
      setState(() => isLoading = false);
    }
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField2<String>(
              style: const TextStyle(color: Colors.white),
              value: selectedType,
              items:
                  _types
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
              onChanged:
                  isLoading
                      ? null
                      : (value) {
                        if (value != null) {
                          setState(() {
                            selectedType = value;
                          });
                          fetchGalleries();
                        }
                      },
              decoration: InputDecoration(
                labelText: 'Type',
                labelStyle: const TextStyle(color: Colors.white),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                filled: true,
                fillColor: Colors.black,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              dropdownStyleData: DropdownStyleData(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField2<String>(
              style: const TextStyle(color: Colors.white),
              value: selectedEventTitle,
              items:
                  eventTitles
                      .map(
                        (title) =>
                            DropdownMenuItem(value: title, child: Text(title)),
                      )
                      .toList(),
              onChanged:
                  isLoading
                      ? null
                      : (value) {
                        if (value != null) {
                          setState(() {
                            selectedEventTitle = value;
                          });
                          fetchGalleries();
                        }
                      },
              decoration: InputDecoration(
                labelText: 'Event',
                labelStyle: const TextStyle(color: Colors.white),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                filled: true,
                fillColor: Colors.black,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              dropdownStyleData: DropdownStyleData(
                maxHeight: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.black,
                ),
              ),
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
