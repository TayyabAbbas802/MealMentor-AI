import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Widget to display and play YouTube exercise videos
class ExerciseVideoPlayer extends StatefulWidget {
  final String? youtubeVideoId;
  final String exerciseName;
  final bool autoPlay;
  final bool showControls;
  final double aspectRatio;

  const ExerciseVideoPlayer({
    Key? key,
    required this.youtubeVideoId,
    required this.exerciseName,
    this.autoPlay = false,
    this.showControls = true,
    this.aspectRatio = 16 / 9,
  }) : super(key: key);

  @override
  State<ExerciseVideoPlayer> createState() => _ExerciseVideoPlayerState();
}

class _ExerciseVideoPlayerState extends State<ExerciseVideoPlayer> {
  late YoutubePlayerController? _controller;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    if (widget.youtubeVideoId != null && widget.youtubeVideoId!.isNotEmpty) {
      _controller = YoutubePlayerController(
        initialVideoId: widget.youtubeVideoId!,
        flags: YoutubePlayerFlags(
          autoPlay: widget.autoPlay,
          mute: false,
          loop: true,
          enableCaption: false,
          controlsVisibleAtStart: widget.showControls,
          forceHD: false,
          useHybridComposition: true,
        ),
      )..addListener(_listener);
    } else {
      _controller = null;
    }
  }

  void _listener() {
    if (_isPlayerReady && mounted && !_controller!.value.isFullScreen) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || widget.youtubeVideoId == null) {
      return _buildPlaceholder();
    }

    return YoutubePlayerBuilder(
      onEnterFullScreen: () {
        // Lock to portrait mode when entering fullscreen
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      },
      onExitFullScreen: () {
        // Return to all orientations when exiting fullscreen
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      },
      player: YoutubePlayer(
        controller: _controller!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Theme.of(context).primaryColor,
        progressColors: ProgressBarColors(
          playedColor: Theme.of(context).primaryColor,
          handleColor: Theme.of(context).primaryColor,
        ),
        aspectRatio: widget.aspectRatio,
        onReady: () {
          _isPlayerReady = true;
        },
        onEnded: (data) {
          // Video ended - could show next exercise suggestion
        },
      ),
      builder: (context, player) {
        return Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: player,
            ),
            if (widget.showControls) _buildControls(),
          ],
        );
      },
    );
  }

  Widget _buildControls() {
    if (_controller == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
            ),
            onPressed: () {
              setState(() {
                _controller!.value.isPlaying
                    ? _controller!.pause()
                    : _controller!.play();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.replay_5),
            onPressed: () {
              _controller!.seekTo(
                Duration(
                  seconds: _controller!.value.position.inSeconds - 5,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.forward_5),
            onPressed: () {
              _controller!.seekTo(
                Duration(
                  seconds: _controller!.value.position.inSeconds + 5,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.fullscreen),
            onPressed: () {
              _showCustomFullscreen();
            },
          ),
        ],
      ),
    );
  }

  void _showCustomFullscreen() async {
    // Lock to portrait mode BEFORE showing dialog
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Small delay to ensure orientation is locked
    await Future.delayed(const Duration(milliseconds: 100));

    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => WillPopScope(
          onWillPop: () async {
            // Restore orientations when back button is pressed
            await SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]);
            return true;
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Stack(
                children: [
                  Center(
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: YoutubePlayer(
                        controller: _controller!,
                        showVideoProgressIndicator: true,
                        progressIndicatorColor: Colors.red,
                        progressColors: const ProgressBarColors(
                          playedColor: Colors.red,
                          handleColor: Colors.red,
                        ),
                        bottomActions: [
                          CurrentPosition(),
                          ProgressBar(isExpanded: true),
                          RemainingDuration(),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 32),
                      onPressed: () async {
                        // Restore all orientations
                        await SystemChrome.setPreferredOrientations([
                          DeviceOrientation.portraitUp,
                          DeviceOrientation.portraitDown,
                          DeviceOrientation.landscapeLeft,
                          DeviceOrientation.landscapeRight,
                        ]);
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).then((_) async {
      // Ensure orientations are restored when dialog is dismissed
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    });
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'No video available',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'for ${widget.exerciseName}',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact video thumbnail widget with play button overlay
class ExerciseVideoThumbnail extends StatelessWidget {
  final String? youtubeVideoId;
  final String exerciseName;
  final VoidCallback? onTap;
  final double height;

  const ExerciseVideoThumbnail({
    Key? key,
    required this.youtubeVideoId,
    required this.exerciseName,
    this.onTap,
    this.height = 120,
  }) : super(key: key);

  String get thumbnailUrl {
    if (youtubeVideoId == null || youtubeVideoId!.isEmpty) {
      return '';
    }
    return 'https://img.youtube.com/vi/$youtubeVideoId/mqdefault.jpg';
  }

  @override
  Widget build(BuildContext context) {
    if (youtubeVideoId == null || youtubeVideoId!.isEmpty) {
      return _buildPlaceholder(context);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: thumbnailUrl,
                height: height,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => _buildPlaceholder(context),
              ),
            ),
            // Play button overlay
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            // Exercise name overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Text(
                  exerciseName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          Icons.video_library_outlined,
          size: 32,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
