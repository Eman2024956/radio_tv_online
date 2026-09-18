import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/live_tv_channel.dart';
import '../../models/epg_program.dart';
import '../../providers/live_tv_provider.dart';
import '../../services/iptv_api_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_translations.dart';

class LiveTvPlayerScreen extends StatefulWidget {
  final LiveTvChannel channel;

  const LiveTvPlayerScreen({
    super.key,
    required this.channel,
  });

  @override
  State<LiveTvPlayerScreen> createState() => _LiveTvPlayerScreenState();
}

class _LiveTvPlayerScreenState extends State<LiveTvPlayerScreen> {
  late LiveTvChannel _currentChannel;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitializing = true;
  String? _errorMessage;
  List<EpgProgram> _epgSchedule = [];
  bool _isLoadingEpg = false;
  double _aspectRatio = 16 / 9;

  @override
  void initState() {
    super.initState();
    _currentChannel = widget.channel;
    _initPlayer();
    _loadEpg();
  }

  Future<void> _initPlayer() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    await _disposeControllers();

    try {
      final Map<String, String> headers = {};
      if (_currentChannel.httpReferrer != null && _currentChannel.httpReferrer!.isNotEmpty) {
        headers['Referer'] = _currentChannel.httpReferrer!;
      }
      if (_currentChannel.httpUserAgent != null && _currentChannel.httpUserAgent!.isNotEmpty) {
        headers['User-Agent'] = _currentChannel.httpUserAgent!;
      }

      final uri = Uri.parse(_currentChannel.streamUrl);
      _videoPlayerController = VideoPlayerController.networkUrl(
        uri,
        httpHeaders: headers,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        isLive: true,
        looping: true,
        showControls: true,
        aspectRatio: _aspectRatio,
        allowFullScreen: true,
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.orangeAccent),
                  const SizedBox(height: 12),
                  Text(
                    AppTranslations.of(context).connectionError,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _initPlayer,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(AppTranslations.of(context).retry),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentOf(context),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      debugPrint('Error initializing live video player: $e');
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _loadEpg() async {
    setState(() => _isLoadingEpg = true);
    try {
      final schedule = await IptvApiService.fetchChannelEpg(_currentChannel);
      if (mounted) {
        setState(() {
          _epgSchedule = schedule;
          _isLoadingEpg = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingEpg = false);
    }
  }

  Future<void> _disposeControllers() async {
    _chewieController?.dispose();
    _chewieController = null;
    await _videoPlayerController?.dispose();
    _videoPlayerController = null;
  }

  void _switchChannel(LiveTvChannel newChannel) {
    if (newChannel.id == _currentChannel.id && newChannel.streamUrl == _currentChannel.streamUrl) {
      return;
    }
    setState(() {
      _currentChannel = newChannel;
    });
    Provider.of<LiveTvProvider>(context, listen: false).setCurrentPlaying(newChannel);
    _initPlayer();
    _loadEpg();
  }

  void _toggleAspectRatio() {
    setState(() {
      if (_aspectRatio == 16 / 9) {
        _aspectRatio = 4 / 3;
      } else if (_aspectRatio == 4 / 3) {
        _aspectRatio = 21 / 9;
      } else {
        _aspectRatio = 16 / 9;
      }
      if (_chewieController != null) {
        _chewieController!.dispose();
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          autoPlay: true,
          isLive: true,
          looping: true,
          showControls: true,
          aspectRatio: _aspectRatio,
          allowFullScreen: true,
        );
      }
    });
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppTranslations.of(context);
    final tvProvider = context.watch<LiveTvProvider>();
    final isFav = tvProvider.isFavorite(_currentChannel);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            if (_currentChannel.logo.isNotEmpty)
              Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: CachedNetworkImage(
                  imageUrl: _currentChannel.logo,
                  fit: BoxFit.contain,
                  errorWidget: (context, url, error) => const Icon(Icons.tv, size: 16, color: Colors.white70),
                ),
              ),
            Expanded(
              child: Text(
                _currentChannel.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Aspect ratio toggle
          IconButton(
            tooltip: 'Aspect Ratio',
            icon: const Icon(Icons.aspect_ratio_rounded, color: Colors.white70),
            onPressed: _toggleAspectRatio,
          ),
          // Favorite toggle
          IconButton(
            tooltip: 'Favorite',
            icon: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFav ? Colors.redAccent : Colors.white70,
            ),
            onPressed: () => tvProvider.toggleFavorite(_currentChannel),
          ),
          // Channel Drawer / Switcher icon
          IconButton(
            tooltip: 'Channels',
            icon: const Icon(Icons.playlist_play_rounded, color: Colors.white, size: 28),
            onPressed: () => _openChannelSwitcherSheet(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Video Player Container
            AspectRatio(
              aspectRatio: _aspectRatio,
              child: Container(
                color: Colors.black,
                child: _isInitializing
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: AppTheme.accentOf(context),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'جاري تشغيل البث المباشر...',
                              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    : _errorMessage != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                                  const SizedBox(height: 12),
                                  Text(
                                    tr.connectionError,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white, fontSize: 13),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: _initPlayer,
                                    icon: const Icon(Icons.refresh_rounded),
                                    label: Text(tr.retry),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.accentOf(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _chewieController != null
                            ? Chewie(controller: _chewieController!)
                            : const SizedBox.shrink(),
              ),
            ),

            // Channel Info Strip & Quick Controls
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: const Color(0xFF161B22),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _currentChannel.quality,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '🌍 ${_currentChannel.country} • ${_currentChannel.category}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const Spacer(),
                  // Reconnect button
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 20),
                    tooltip: tr.retry,
                    onPressed: _initPlayer,
                  ),
                ],
              ),
            ),

            // EPG (Electronic Program Guide) & Schedule
            Expanded(
              child: Container(
                color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.accentOf(context)),
                        const SizedBox(width: 8),
                        Text(
                          tr.epgSchedule,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (_isLoadingEpg)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else
                      ..._epgSchedule.map((program) {
                        final isAiring = program.isCurrentlyAiring;
                        final startTime = '${program.start.hour.toString().padLeft(2, '0')}:${program.start.minute.toString().padLeft(2, '0')}';
                        final stopTime = '${program.stop.hour.toString().padLeft(2, '0')}:${program.stop.minute.toString().padLeft(2, '0')}';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isAiring
                                ? (isDark ? const Color(0xFF1F2937) : const Color(0xFFEFF6FF))
                                : (isDark ? const Color(0xFF161B22) : Colors.white),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isAiring
                                  ? AppTheme.accentOf(context)
                                  : (isDark ? const Color(0xFF30363D) : Colors.black12),
                              width: isAiring ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (isAiring)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        tr.nowPlayingTv,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  Text(
                                    '$startTime - $stopTime',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isAiring ? AppTheme.accentOf(context) : Colors.grey,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (program.category != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        program.category!,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isDark ? Colors.white70 : Colors.black54,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                program.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              if (program.description.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  program.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white60 : Colors.black54,
                                  ),
                                ),
                              ],
                              if (isAiring) ...[
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: program.progressPercentage,
                                  backgroundColor: isDark ? Colors.white12 : Colors.black12,
                                  color: AppTheme.accentOf(context),
                                  minHeight: 4,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ],
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openChannelSwitcherSheet(BuildContext context) {
    final channels = Provider.of<LiveTvProvider>(context, listen: false).filteredChannels;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  AppTranslations.of(context).liveTvTitle,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: channels.length,
                  itemBuilder: (c, idx) {
                    final ch = channels[idx];
                    final isSelected = ch.id == _currentChannel.id;
                    return ListTile(
                      selected: isSelected,
                      selectedTileColor: AppTheme.accentOf(context).withValues(alpha: 0.12),
                      leading: Container(
                        width: 38,
                        height: 38,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ch.logo.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: ch.logo,
                                fit: BoxFit.contain,
                                errorWidget: (context, url, error) => const Icon(Icons.tv, size: 20),
                              )
                            : const Icon(Icons.tv, size: 20),
                      ),
                      title: Text(
                        ch.name,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppTheme.accentOf(context) : null,
                        ),
                      ),
                      subtitle: Text('${ch.country} • ${ch.category}'),
                      trailing: isSelected
                          ? Icon(Icons.play_circle_fill_rounded, color: AppTheme.accentOf(context))
                          : null,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _switchChannel(ch);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
