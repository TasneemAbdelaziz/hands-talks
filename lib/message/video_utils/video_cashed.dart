import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class CachedVideoWidget extends StatefulWidget {
  final String videoUrl;

  const CachedVideoWidget({super.key, required this.videoUrl});

  @override
  State<CachedVideoWidget> createState() => _CachedVideoWidgetState();
}

class _CachedVideoWidgetState extends State<CachedVideoWidget> {
  File? videoFile;
  String? thumbnailPath;
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    try {
      final file = await DefaultCacheManager().getSingleFile(widget.videoUrl);
      videoFile = file;

      thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: file.path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 150,
        quality: 75,
      );

      _controller = VideoPlayerController.file(file);
      await _controller.initialize();
      _controller.setLooping(true);

      setState(() {
        _initialized = true;
      });
    } catch (e) {
      print("❌ Error loading cached video: $e");
    }
  }

  @override
  void dispose() {
    if (_initialized) _controller.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    setState(() {
      _isPlaying ? _controller.pause() : _controller.play();
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return SizedBox(
        width: 250,
        height: 150,
        child: thumbnailPath != null
            ? Image.file(File(thumbnailPath!), fit: BoxFit.cover)
            : const Center(child: CircularProgressIndicator()),
      );
    }

    return InkWell(
      onTap: _togglePlayback,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          if (!_isPlaying)
            const Icon(Icons.play_circle_fill, size: 50, color: Colors.white),
        ],
      ),
    );
  }
}
