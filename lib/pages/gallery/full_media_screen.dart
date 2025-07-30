import 'dart:typed_data';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:fiba_3x3/services/gallery_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class FullMediaScreen extends StatefulWidget {
  final Gallery gallery;

  const FullMediaScreen({super.key, required this.gallery});

  @override
  State<FullMediaScreen> createState() => _FullMediaScreenState();

  static Future<bool> saveImageToGallery(String imagePath) async {
    try {
      final AssetEntity result = await PhotoManager.editor.saveImageWithPath(
        imagePath,
      );
      // ignore: unnecessary_null_comparison
      return result != null;
    } catch (_) {
      return false;
    }
  }
}

class _FullMediaScreenState extends State<FullMediaScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  Image? _image;
  ImageStream? _imageStream;
  ImageInfo? _imageInfo;
  late ImageStreamListener _imageListener;

  @override
  void initState() {
    super.initState();

    if (widget.gallery.type == 'video') {
      _videoPlayerController = VideoPlayerController.network(
        widget.gallery.url,
      );
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
      );
    } else {
      _image = Image.network(widget.gallery.url);
      _imageStream = _image!.image.resolve(ImageConfiguration.empty);

      _imageListener = ImageStreamListener((info, _) {
        setState(() {
          _imageInfo = info;
        });
      });
      _imageStream!.addListener(_imageListener);
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    if (_imageStream != null) {
      _imageStream!.removeListener(_imageListener);
    }
    super.dispose();
  }

  Future<void> _downloadImage() async {
    try {
      final hasPermission = await _requestPermission();
      if (!hasPermission) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Permission denied.")));
        return;
      }

      final response = await http.get(Uri.parse(widget.gallery.url));
      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Download failed: ${response.statusCode}")),
        );
        return;
      }

      Uint8List imageBytes = Uint8List.fromList(response.bodyBytes);

      final tempDir = await getTemporaryDirectory();
      final file =
          await File(
            '${tempDir.path}/fiba_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ).create();
      await file.writeAsBytes(imageBytes);

      final saved = await FullMediaScreen.saveImageToGallery(file.path);

      if (saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image saved to gallery.")),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to save image.")));
      }

      await file.delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An unexpected error occurred. Please try again."),
        ),
      );
    }
  }

  Future<void> _downloadVideo() async {
    try {
      final hasPermission = await _requestPermission();
      if (!hasPermission) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Permission denied.")));
        return;
      }

      final response = await http.get(Uri.parse(widget.gallery.url));
      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Download failed: ${response.statusCode}")),
        );
        return;
      }

      Uint8List videoBytes = Uint8List.fromList(response.bodyBytes);

      final tempDir = await getTemporaryDirectory();
      final file =
          await File(
            '${tempDir.path}/fiba_${DateTime.now().millisecondsSinceEpoch}.mp4',
          ).create();
      await file.writeAsBytes(videoBytes);

      // ignore: unnecessary_nullable_for_final_variable_declarations
      final AssetEntity? result = await PhotoManager.editor.saveVideo(
        File(file.path),
      );

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Video saved to gallery.")),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to save video.")));
      }

      await file.delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An unexpected error occurred. Please try again."),
        ),
      );
    }
  }

  Future<bool> _requestPermission() async {
    if (Theme.of(context).platform == TargetPlatform.android) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        var photosStatus = await Permission.photos.status;
        if (!photosStatus.isGranted) {
          photosStatus = await Permission.photos.request();
        }
        return photosStatus.isGranted;
      } else {
        var storageStatus = await Permission.storage.status;
        if (!storageStatus.isGranted) {
          storageStatus = await Permission.storage.request();
        }
        return storageStatus.isGranted;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isPhoto = widget.gallery.type == 'photo';

    if (!isPhoto) {
      return Scaffold(
        appBar: AppBar(title: const Text("Media")),
        body:
            _chewieController != null
                ? Chewie(controller: _chewieController!)
                : const Center(child: CircularProgressIndicator()),
        floatingActionButton: FloatingActionButton(
          onPressed: _downloadVideo,
          tooltip: 'Download Video',
          child: const Icon(Icons.download),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Media"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download Image',
            onPressed: _downloadImage,
          ),
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (_imageInfo == null) {
            return const Center(child: CircularProgressIndicator());
          }

          double imgWidth = _imageInfo!.image.width.toDouble();
          double imgHeight = _imageInfo!.image.height.toDouble();

          bool isTallImage = imgHeight > imgWidth;
          bool isLandscape = orientation == Orientation.landscape;

          if (isTallImage) {
            return SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.9,
                      ),
                      child: _image,
                    ),
                  ),
                ),
              ),
            );
          } else {
            double maxWidth = MediaQuery.of(context).size.width * 0.9;
            double maxHeight =
                isLandscape
                    ? MediaQuery.of(context).size.height * 0.9
                    : MediaQuery.of(context).size.height * 0.5;

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: maxWidth,
                      maxHeight: maxHeight,
                    ),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: imgWidth,
                        height: imgHeight,
                        child: _image,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
