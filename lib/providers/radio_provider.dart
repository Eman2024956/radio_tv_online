import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/radio_station.dart';
import '../models/genre_tag.dart';
import '../services/radio_api_service.dart';

class RadioProvider extends ChangeNotifier {
  final RadioApiService _apiService = RadioApiService();

  static const String _keyTopClicked = 'cache_top_clicked_stations_v1';
  static const String _keyTopVoted = 'cache_top_voted_stations_v1';
  static const String _keyTags = 'cache_popular_tags_v1';
  static const String _keyCountryPrefix = 'cache_country_stations_';

  bool _isLoading = false;
  String? _errorMessage;

  List<RadioStation> _topClickedStations = [];
  List<RadioStation> _topVotedStations = [];
  List<GenreTag> _popularTags = [];
  final Map<String, List<RadioStation>> _countryStations = {};
  String _selectedCountryCode = 'IQ'; // Default quick highlight: Iraq / Middle East

  RadioProvider() {
    _loadFromCache().then((_) => loadHomeData());
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<RadioStation> get topClickedStations => _topClickedStations;
  List<RadioStation> get topVotedStations => _topVotedStations;
  List<GenreTag> get popularTags => _popularTags;
  String get selectedCountryCode => _selectedCountryCode;
  List<RadioStation> get currentCountryStations => _countryStations[_selectedCountryCode] ?? [];

  RadioStation? get featuredStation {
    if (_topClickedStations.isNotEmpty) {
      return _topClickedStations.first;
    }
    if (_topVotedStations.isNotEmpty) {
      return _topVotedStations.first;
    }
    return null;
  }

  /// Instant offline / cached data loader for 0ms initial render
  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final topClickedJson = prefs.getString(_keyTopClicked);
      if (topClickedJson != null) {
        final list = jsonDecode(topClickedJson) as List;
        _topClickedStations = list.map((e) => RadioStation.fromJson(e)).toList();
      }

      final topVotedJson = prefs.getString(_keyTopVoted);
      if (topVotedJson != null) {
        final list = jsonDecode(topVotedJson) as List;
        _topVotedStations = list.map((e) => RadioStation.fromJson(e)).toList();
      }

      final tagsJson = prefs.getString(_keyTags);
      if (tagsJson != null) {
        final list = jsonDecode(tagsJson) as List;
        _popularTags = list.map((e) => GenreTag.fromJson(e)).toList();
      }

      final iqJson = prefs.getString('${_keyCountryPrefix}IQ');
      if (iqJson != null) {
        final list = jsonDecode(iqJson) as List;
        _countryStations['IQ'] = list.map((e) => RadioStation.fromJson(e)).toList();
      }

      // If cache is empty (first ever launch), inject instant default stations
      if (_topClickedStations.isEmpty) {
        _injectSeedStations();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('[RadioProvider] Cache restore fallback: $e');
      if (_topClickedStations.isEmpty) {
        _injectSeedStations();
      }
    }
  }

  /// High quality seed stations for immediate 0ms enjoyment on fresh installs
  void _injectSeedStations() {
    _topClickedStations = [
      RadioStation(
        stationUuid: 'iq-sumer-fm-uuid',
        name: 'SumerFm Iraq',
        url: 'https://stream.zeno.fm/5y3b4h6v9q8uv',
        urlResolved: 'https://stream.zeno.fm/5y3b4h6v9q8uv',
        country: 'Iraq',
        countryCode: 'IQ',
        language: 'Arabic',
        tags: 'arabic,iraq,news,pop',
        codec: 'MP3',
        bitrate: 128,
        votes: 1250,
        clickCount: 8900,
      ),
      RadioStation(
        stationUuid: 'iq-radio-maria-uuid',
        name: 'radio maria iraq',
        url: 'https://dreamsiteradiocp.com:8092/stream',
        urlResolved: 'https://dreamsiteradiocp.com:8092/stream',
        country: 'Iraq',
        countryCode: 'IQ',
        language: 'Arabic',
        tags: 'arabic,iraq,christian',
        codec: 'MP3',
        bitrate: 64,
        votes: 840,
        clickCount: 5400,
      ),
      RadioStation(
        stationUuid: 'fr-rtl-uuid',
        name: 'RTL',
        url: 'http://icecast.rtl.fr/rtl-1-44-128?listen=webCwsBCgABEgEA',
        urlResolved: 'http://icecast.rtl.fr/rtl-1-44-128?listen=webCwsBCgABEgEA',
        country: 'France',
        countryCode: 'FR',
        language: 'French',
        tags: 'talk,news,general',
        codec: 'AAC',
        bitrate: 64,
        votes: 3200,
        clickCount: 15400,
      ),
    ];
    _countryStations['IQ'] = _topClickedStations.where((s) => s.countryCode == 'IQ').toList();
  }

  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_topClickedStations.isNotEmpty) {
        await prefs.setString(_keyTopClicked, jsonEncode(_topClickedStations.map((s) => s.toJson()).toList()));
      }
      if (_topVotedStations.isNotEmpty) {
        await prefs.setString(_keyTopVoted, jsonEncode(_topVotedStations.map((s) => s.toJson()).toList()));
      }
      if (_popularTags.isNotEmpty) {
        await prefs.setString(_keyTags, jsonEncode(_popularTags.map((t) => t.toJson()).toList()));
      }
      if (_countryStations.containsKey(_selectedCountryCode) && _countryStations[_selectedCountryCode]!.isNotEmpty) {
        await prefs.setString(
          '$_keyCountryPrefix$_selectedCountryCode',
          jsonEncode(_countryStations[_selectedCountryCode]!.map((s) => s.toJson()).toList()),
        );
      }
    } catch (e) {
      debugPrint('[RadioProvider] Error writing to cache: $e');
    }
  }

  Future<void> loadHomeData() async {
    if (_topClickedStations.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }
    _errorMessage = null;

    try {
      final results = await Future.wait([
        _apiService.getTopClickStations(limit: 25),
        _apiService.getTopVoteStations(limit: 25),
        _apiService.getPopularTags(limit: 30),
        _apiService.searchStations(countryCode: _selectedCountryCode, limit: 15, order: 'clickcount'),
      ]);

      _topClickedStations = results[0] as List<RadioStation>;
      _topVotedStations = results[1] as List<RadioStation>;
      _popularTags = results[2] as List<GenreTag>;
      _countryStations[_selectedCountryCode] = results[3] as List<RadioStation>;
      _errorMessage = null;

      // Persist to local cache for offline/future instant load
      _saveToCache();
    } catch (e) {
      debugPrint('[RadioProvider] Error loading home radio data: $e');
      // If we already have cached stations displayed, do not alarm the user with a blocking error banner!
      if (_topClickedStations.isEmpty) {
        _errorMessage = 'Failed to load live radio channels. Check your internet connection.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setQuickCountry(String countryCode) async {
    if (_selectedCountryCode == countryCode && (_countryStations[countryCode]?.isNotEmpty ?? false)) {
      return;
    }
    _selectedCountryCode = countryCode;
    notifyListeners();

    if (!_countryStations.containsKey(countryCode) || _countryStations[countryCode]!.isEmpty) {
      try {
        final stations = await _apiService.searchStations(
          countryCode: countryCode,
          limit: 15,
          order: 'clickcount',
        );
        _countryStations[countryCode] = stations;
        notifyListeners();
      } catch (e) {
        debugPrint('[RadioProvider] Error loading country stations: $e');
      }
    }
  }
}
