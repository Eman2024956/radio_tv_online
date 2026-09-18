import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/live_tv_provider.dart';
import '../../services/iptv_api_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_translations.dart';
import '../widgets/tv_channel_card.dart';

class LiveTvScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const LiveTvScreen({
    super.key,
    this.onNavigateToTab,
  });

  @override
  State<LiveTvScreen> createState() => _LiveTvScreenState();
}

class _LiveTvScreenState extends State<LiveTvScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppTranslations.of(context);
    final tvProvider = context.watch<LiveTvProvider>();
    final channels = tvProvider.filteredChannels;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.backgroundOf(context),
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceOf(context),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'IPTV LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  tr.liveTvTitle,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              tr.channelsSource,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: tr.retry,
            onPressed: () => tvProvider.loadChannels(forceRefresh: true),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Box
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            color: AppTheme.surfaceOf(context),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => tvProvider.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: tr.searchTvHint,
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          tvProvider.setSearchQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF1F5F9),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Horizontal Category Chips
          Container(
            height: 48,
            color: AppTheme.surfaceOf(context),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              itemCount: IptvApiService.categories.length,
              itemBuilder: (ctx, idx) {
                final cat = IptvApiService.categories[idx];
                final isSelected = tvProvider.selectedCategory == cat['id'];
                final label = tr.isArabic ? cat['nameAr']! : cat['nameEn']!;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    selected: isSelected,
                    showCheckmark: false,
                    label: Text(label),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                    selectedColor: AppTheme.accentOf(context),
                    backgroundColor: isDark ? const Color(0xFF161B22) : const Color(0xFFF1F5F9),
                    side: BorderSide(
                      color: isSelected
                          ? AppTheme.accentOf(context)
                          : (isDark ? const Color(0xFF30363D) : Colors.black12),
                    ),
                    onSelected: (_) => tvProvider.selectCategory(cat['id']!),
                  ),
                );
              },
            ),
          ),

          // Horizontal Countries Strip
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.surfaceOf(context),
              border: Border(
                bottom: BorderSide(color: AppTheme.borderOf(context), width: 1),
              ),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: IptvApiService.countries.length,
              itemBuilder: (ctx, idx) {
                final c = IptvApiService.countries[idx];
                final isSelected = tvProvider.selectedCountry == c['code'];
                final label = '${c['flag']} ${tr.isArabic ? c['nameAr'] : c['nameEn']}';

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: ChoiceChip(
                    selected: isSelected,
                    label: Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                    selectedColor: Colors.deepPurpleAccent,
                    backgroundColor: Colors.transparent,
                    side: BorderSide(
                      color: isSelected ? Colors.deepPurpleAccent : (isDark ? Colors.white24 : Colors.black12),
                    ),
                    onSelected: (_) => tvProvider.selectCountry(c['code']!),
                  ),
                );
              },
            ),
          ),

          // Channel Count & Status Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${channels.length} ${tr.channelsCount}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                  ),
                ),
                const Spacer(),
                if (tvProvider.isLoading)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),

          // Grid View of Channels
          Expanded(
            child: tvProvider.isLoading && channels.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: AppTheme.accentOf(context)),
                        const SizedBox(height: 16),
                        Text(
                          tr.isArabic ? 'جاري تحميل قنوات البث التلفزيوني...' : 'Loading Live TV streams...',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : channels.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.tv_off_rounded, size: 56, color: Colors.grey),
                              const SizedBox(height: 12),
                              Text(
                                tr.isArabic ? 'لم يتم العثور على قنوات تلفزيونية' : 'No TV channels found',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                tr.isArabic
                                    ? 'جرب تغيير التصنيف أو اختيار دولة أخرى أو مسح البحث'
                                    : 'Try selecting a different category or country',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  _searchController.clear();
                                  tvProvider.setSearchQuery('');
                                  tvProvider.selectCategory('all');
                                  tvProvider.selectCountry('ALL');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.accentOf(context),
                                ),
                                child: Text(tr.clearAll),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => tvProvider.loadChannels(forceRefresh: true),
                        child: GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.88,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: channels.length,
                          itemBuilder: (ctx, idx) {
                            return TvChannelCard(channel: channels[idx]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
