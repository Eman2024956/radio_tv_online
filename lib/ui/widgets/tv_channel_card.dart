import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/live_tv_channel.dart';
import '../../providers/live_tv_provider.dart';
import '../../providers/player_provider.dart';
import '../../theme/app_theme.dart';
import '../screens/live_tv_player_screen.dart';

class TvChannelCard extends StatelessWidget {
  final LiveTvChannel channel;
  final bool isCompact;

  const TvChannelCard({
    super.key,
    required this.channel,
    this.isCompact = false,
  });

  void _playChannel(BuildContext context) {
    // Pause background radio player if active
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    if (playerProvider.isPlaying) {
      playerProvider.pause();
    }

    // Set playing TV channel
    Provider.of<LiveTvProvider>(context, listen: false).setCurrentPlaying(channel);

    // Navigate to Player Screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LiveTvPlayerScreen(channel: channel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tvProvider = context.watch<LiveTvProvider>();
    final isFav = tvProvider.isFavorite(channel);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF30363D) : Colors.black12,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _playChannel(context),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Quality badge + LIVE badge + Favorite button
                Row(
                  children: [
                    // LIVE indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Quality Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.accentOf(context).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        channel.quality,
                        style: TextStyle(
                          color: AppTheme.accentOf(context),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Favorite Button
                    InkWell(
                      onTap: () => tvProvider.toggleFavorite(channel),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 18,
                          color: isFav ? Colors.redAccent : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Channel Logo Preview
                Expanded(
                  child: Center(
                    child: Hero(
                      tag: 'tv_logo_${channel.id}_${channel.streamUrl.hashCode}',
                      child: Container(
                        height: 72,
                        width: 72,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: channel.logo.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: channel.logo,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                                errorWidget: (context, url, error) => const Icon(
                                  Icons.tv_rounded,
                                  size: 32,
                                  color: Colors.grey,
                                ),
                              )
                            : const Icon(
                                Icons.tv_rounded,
                                size: 32,
                                color: Colors.grey,
                              ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Channel Title
                Text(
                  channel.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                // Category & Country info
                Row(
                  children: [
                    Text(
                      channel.country != 'Global' ? '🌍 ${channel.country}' : '🌍 Global',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '• ${channel.category}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.accentOf(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
