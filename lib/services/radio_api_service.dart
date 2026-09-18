import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/radio_station.dart';
import '../models/country.dart';
import '../models/language.dart';
import '../models/genre_tag.dart';

enum ApiRoute { standardHttps, directIpHttp }

class RadioApiService {
  static final RadioApiService _instance = RadioApiService._internal();
  factory RadioApiService() => _instance;
  RadioApiService._internal();

  static const String defaultHostname = 'de1.api.radio-browser.info';
  static const String fallbackIp = '91.98.4.78';

  final String _currentServer = defaultHostname;
  String _resolvedIp = fallbackIp;
  ApiRoute _preferredRoute = ApiRoute.standardHttps;
  bool _initialized = false;

  static const Map<String, String> _baseHeaders = {
    'User-Agent': 'RadioTvOnline/1.0 (Flutter; Mobile/Desktop/Web)',
    'Accept': 'application/json',
  };

  /// Proactively resolve DNS via Cloudflare/Google DoH if ISP DNS fails
  Future<void> _resolveDnsOverHttps() async {
    try {
      final dohUri = Uri.parse(
        'https://1.1.1.1/dns-query?name=$defaultHostname&type=A',
      );
      final response = await http.get(dohUri, headers: {
        'accept': 'application/dns-json',
      }).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final answers = json['Answer'] as List?;
        if (answers != null && answers.isNotEmpty) {
          final ip = answers.first['data']?.toString();
          if (ip != null && ip.contains('.')) {
            _resolvedIp = ip;
            debugPrint('[RadioApi] Cloudflare DoH resolved $defaultHostname -> $ip');
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('[RadioApi] Cloudflare DoH lookup fallback: $e');
    }

    // Google DoH fallback
    try {
      final googleDoh = Uri.parse(
        'https://dns.google/resolve?name=$defaultHostname&type=A',
      );
      final response = await http.get(googleDoh).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final answers = json['Answer'] as List?;
        if (answers != null && answers.isNotEmpty) {
          final ip = answers.first['data']?.toString();
          if (ip != null && ip.contains('.')) {
            _resolvedIp = ip;
            debugPrint('[RadioApi] Google DoH resolved $defaultHostname -> $ip');
          }
        }
      }
    } catch (e) {
      debugPrint('[RadioApi] Google DoH lookup fallback: $e');
    }
  }

  /// Initialize server and fast-check connectivity
  Future<void> initServer() async {
    if (_initialized) return;
    _initialized = true;

    // Start background DoH resolution to ensure we have valid IP
    _resolveDnsOverHttps();
  }

  /// Resilient request runner: attempts Standard HTTPS, then immediately falls back
  /// to Direct IP HTTP (bypassing ISP DNS poisoning/throttling) and DoH resolution.
  Future<http.Response> _getWithFallback(String path, [Map<String, String>? queryParams]) async {
    await initServer();

    // If direct IP was previously proven faster/working (e.g. ISP blocks DNS), try it first!
    if (_preferredRoute == ApiRoute.directIpHttp) {
      try {
        final directResponse = await _fetchViaDirectIp(path, queryParams);
        if (directResponse.statusCode == 200) return directResponse;
      } catch (e) {
        debugPrint('[RadioApi] Direct IP route failed: $e, trying standard HTTPS...');
      }
    }

    // Attempt 1: Standard HTTPS via hostname
    try {
      final uri = Uri.https(_currentServer, path, queryParams);
      final response = await http.get(uri, headers: _baseHeaders).timeout(
        const Duration(seconds: 5),
      );
      if (response.statusCode == 200) {
        _preferredRoute = ApiRoute.standardHttps;
        return response;
      }
    } catch (e) {
      debugPrint('[RadioApi] Standard HTTPS for $_currentServer failed: $e. Switching to Direct IP (Anti-Censorship/ISP DNS bypass)...');
    }

    // Attempt 2: Direct IP HTTP (Bypasses local ISP DNS blocks completely)
    try {
      final directResponse = await _fetchViaDirectIp(path, queryParams);
      if (directResponse.statusCode == 200) {
        _preferredRoute = ApiRoute.directIpHttp;
        debugPrint('[RadioApi] Successfully connected via Direct IP (ISP DNS bypassed)!');
        return directResponse;
      }
    } catch (e) {
      debugPrint('[RadioApi] Direct IP with $_resolvedIp failed: $e');
    }

    // Attempt 3: Refresh DoH and try again
    await _resolveDnsOverHttps();
    try {
      final directResponse = await _fetchViaDirectIp(path, queryParams);
      if (directResponse.statusCode == 200) {
        _preferredRoute = ApiRoute.directIpHttp;
        return directResponse;
      }
    } catch (e) {
      debugPrint('[RadioApi] Final fallback failed: $e');
    }

    throw Exception('Failed to connect to Radio Browser API. Local network issue or ISP block.');
  }

  Future<http.Response> _fetchViaDirectIp(String path, [Map<String, String>? queryParams]) async {
    final uri = Uri.http(_resolvedIp, path, queryParams);
    final headers = {
      ..._baseHeaders,
      'Host': defaultHostname,
    };
    return await http.get(uri, headers: headers).timeout(
      const Duration(seconds: 8),
    );
  }

  /// Search radio stations with comprehensive filters
  Future<List<RadioStation>> searchStations({
    String? name,
    String? country,
    String? countryCode,
    String? language,
    String? tag,
    String? codec,
    int? bitrateMin,
    String order = 'clickcount', // 'clickcount', 'votes', 'name', 'bitrate', 'random'
    bool reverse = true,
    int limit = 50,
    int offset = 0,
    bool hideBroken = true,
  }) async {
    final Map<String, String> query = {
      'limit': limit.toString(),
      'offset': offset.toString(),
      'order': order,
      'reverse': reverse ? 'true' : 'false',
      'hidebroken': hideBroken ? 'true' : 'false',
    };

    if (name != null && name.trim().isNotEmpty) {
      query['name'] = name.trim();
    }
    if (countryCode != null && countryCode.trim().isNotEmpty) {
      query['countrycode'] = countryCode.trim();
    } else if (country != null && country.trim().isNotEmpty) {
      query['country'] = country.trim();
    }
    if (language != null && language.trim().isNotEmpty) {
      query['language'] = language.trim();
    }
    if (tag != null && tag.trim().isNotEmpty) {
      query['tag'] = tag.trim();
    }
    if (codec != null && codec.trim().isNotEmpty && codec.toLowerCase() != 'all') {
      query['codec'] = codec.trim();
    }
    if (bitrateMin != null && bitrateMin > 0) {
      query['bitrateMin'] = bitrateMin.toString();
    }

    final response = await _getWithFallback('/json/stations/search', query);
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((j) => RadioStation.fromJson(j as Map<String, dynamic>)).toList();
  }

  /// Fetch top clicked stations worldwide
  Future<List<RadioStation>> getTopClickStations({int limit = 30}) async {
    final response = await _getWithFallback('/json/stations/topclick/$limit');
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((j) => RadioStation.fromJson(j as Map<String, dynamic>)).toList();
  }

  /// Fetch top voted stations worldwide
  Future<List<RadioStation>> getTopVoteStations({int limit = 30}) async {
    final response = await _getWithFallback('/json/stations/topvote/$limit');
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((j) => RadioStation.fromJson(j as Map<String, dynamic>)).toList();
  }

  /// Fetch recently modified stations
  Future<List<RadioStation>> getLastChangedStations({int limit = 30}) async {
    final response = await _getWithFallback('/json/stations/lastchange/$limit');
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((j) => RadioStation.fromJson(j as Map<String, dynamic>)).toList();
  }

  /// Fetch all countries
  Future<List<CountryItem>> getCountries({int? limit}) async {
    final Map<String, String>? query = limit != null ? {'limit': limit.toString()} : null;
    final response = await _getWithFallback('/json/countries', query);
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((j) => CountryItem.fromJson(j as Map<String, dynamic>)).toList();
  }

  /// Fetch all supported languages
  Future<List<LanguageItem>> getLanguages({int? limit}) async {
    final Map<String, String>? query = limit != null ? {'limit': limit.toString()} : null;
    final response = await _getWithFallback('/json/languages', query);
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((j) => LanguageItem.fromJson(j as Map<String, dynamic>)).toList();
  }

  /// Fetch popular genre tags
  Future<List<GenreTag>> getPopularTags({int limit = 50}) async {
    final response = await _getWithFallback(
      '/json/tags',
      {'limit': limit.toString(), 'order': 'stationcount', 'reverse': 'true'},
    );
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((j) => GenreTag.fromJson(j as Map<String, dynamic>)).toList();
  }

  /// Register a click when station starts playing (helps Radio Browser analytics)
  Future<void> registerStationClick(String stationUuid) async {
    try {
      final uri = Uri.https(defaultHostname, '/json/url/$stationUuid');
      await http.get(uri, headers: _baseHeaders).timeout(const Duration(seconds: 3));
    } catch (_) {
      // Non-critical, ignore click registration failure
    }
  }
}
