import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/live_tv_channel.dart';
import '../services/iptv_api_service.dart';

class LiveTvProvider extends ChangeNotifier {
  static const String _tvFavoritesKey = 'iptv_favorite_channel_ids';

  List<LiveTvChannel> _channels = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _selectedCategory = 'all';
  String _selectedCountry = 'ALL';
  String _searchQuery = '';

  final Set<String> _favoriteIds = {};
  LiveTvChannel? _currentPlayingChannel;

  List<LiveTvChannel> get channels => _channels;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get selectedCategory => _selectedCategory;
  String get selectedCountry => _selectedCountry;
  String get searchQuery => _searchQuery;

  LiveTvChannel? get currentPlayingChannel => _currentPlayingChannel;
  Set<String> get favoriteIds => _favoriteIds;

  LiveTvProvider() {
    _loadFavorites();
    loadChannels();
  }

  /// Get channels matching the active filters & search query
  List<LiveTvChannel> get filteredChannels {
    return _channels.where((channel) {
      // Filter by category
      if (_selectedCategory != 'all') {
        final catLower = channel.category.toLowerCase();
        if (!catLower.contains(_selectedCategory.toLowerCase())) {
          return false;
        }
      }

      // Filter by country
      if (_selectedCountry != 'ALL') {
        if (channel.country.toUpperCase() != _selectedCountry.toUpperCase()) {
          return false;
        }
      }

      // Filter by search query
      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.toLowerCase().trim();
        final nameMatch = channel.name.toLowerCase().contains(query);
        final catMatch = channel.category.toLowerCase().contains(query);
        final countryMatch = channel.country.toLowerCase().contains(query);
        if (!nameMatch && !catMatch && !countryMatch) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Get favorite channels
  List<LiveTvChannel> get favoriteChannels {
    return _channels.where((c) => _favoriteIds.contains(c.id)).toList();
  }

  Future<void> loadChannels({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final list = await IptvApiService.fetchChannels(
        category: _selectedCategory,
        countryCode: _selectedCountry,
        forceRefresh: forceRefresh,
      );
      _channels = list;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String categoryId) {
    if (_selectedCategory == categoryId) return;
    _selectedCategory = categoryId;
    loadChannels();
  }

  void selectCountry(String countryCode) {
    if (_selectedCountry == countryCode) return;
    _selectedCountry = countryCode;
    loadChannels();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCurrentPlaying(LiveTvChannel? channel) {
    _currentPlayingChannel = channel;
    notifyListeners();
  }

  bool isFavorite(LiveTvChannel channel) {
    return _favoriteIds.contains(channel.id);
  }

  Future<void> toggleFavorite(LiveTvChannel channel) async {
    if (_favoriteIds.contains(channel.id)) {
      _favoriteIds.remove(channel.id);
    } else {
      _favoriteIds.add(channel.id);
    }
    notifyListeners();
    await _saveFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_tvFavoritesKey);
      if (saved != null) {
        _favoriteIds.addAll(saved);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading TV favorites: $e');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_tvFavoritesKey, _favoriteIds.toList());
    } catch (e) {
      debugPrint('Error saving TV favorites: $e');
    }
  }
}
