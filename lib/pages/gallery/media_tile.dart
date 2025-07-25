import 'package:cached_network_image/cached_network_image.dart';
import 'package:fiba_3x3/pages/gallery/full_media_screen.dart';
import 'package:fiba_3x3/services/gallery_service.dart';
import 'package:flutter/material.dart';

class MediaTile extends StatelessWidget {
  final Gallery gallery;
  final int index;

  const MediaTile({super.key, required this.gallery, required this.index});

  @override
  Widget build(BuildContext context) {
    final isImage = gallery.type == 'photo'; // use 'photo' instead of 'image'

    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FullMediaScreen(gallery: gallery),
            ),
          ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isImage)
              CachedNetworkImage(
                imageUrl: gallery.url,
                fit: BoxFit.cover,
                height: (150 + (index % 3) * 50).toDouble(),
                width: double.infinity,
                placeholder:
                    (context, url) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
              )
            else
              Container(
                height: 200,
                color: Colors.black26,
                child: const Center(
                  child: Icon(Icons.videocam, color: Colors.white70, size: 50),
                ),
              ),
            if (!isImage)
              const Icon(Icons.play_circle_fill, color: Colors.white, size: 40),
          ],
        ),
      ),
    );
  }
}
