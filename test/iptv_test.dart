import 'package:flutter_test/flutter_test.dart';
import 'package:radio_channel/models/live_tv_channel.dart';
import 'package:radio_channel/models/epg_program.dart';
import 'package:radio_channel/services/iptv_api_service.dart';

void main() {
  group('Live TV & IPTV Models and Parser Tests', () {
    test('LiveTvChannel.fromJson parses all fields accurately', () {
      final json = {
        'id': 'AlJazeera.qa@SD',
        'name': 'Al Jazeera',
        'logo': 'https://example.com/logo.png',
        'category': 'News',
        'country': 'QA',
        'language': 'ara',
        'streamUrl': 'https://live-hls.example.com/master.m3u8',
        'quality': '1080p',
        'httpReferrer': 'https://aljazeera.net',
        'httpUserAgent': 'CustomUA/1.0',
        'isGeoBlocked': false,
      };

      final channel = LiveTvChannel.fromJson(json);

      expect(channel.id, 'AlJazeera.qa@SD');
      expect(channel.name, 'Al Jazeera');
      expect(channel.logo, 'https://example.com/logo.png');
      expect(channel.category, 'News');
      expect(channel.country, 'QA');
      expect(channel.language, 'ara');
      expect(channel.streamUrl, 'https://live-hls.example.com/master.m3u8');
      expect(channel.quality, '1080p');
      expect(channel.httpReferrer, 'https://aljazeera.net');
      expect(channel.httpUserAgent, 'CustomUA/1.0');
      expect(channel.isGeoBlocked, false);
    });

    test('IptvApiService.parseM3u parses IPTV-org M3U format correctly', () {
      const sampleM3u = '''
#EXTM3U
#EXTINF:-1 tvg-id="AlJazeera.qa@SD" tvg-logo="https://example.com/aljazeera.png" group-title="News",Al Jazeera (1080p)
https://live-hls.example.com/aljazeera/master.m3u8
#EXTINF:-1 tvg-id="AfaqTV.iq@SD" tvg-logo="https://example.com/afaq.png" group-title="General",Afaq TV (720p) [Geo-blocked]
http://stream.afaq.iq/live/afaqtv/playlist.m3u8
#EXTINF:-1 tvg-id="2MMonde.ma@SD" tvg-logo="https://example.com/2m.png" http-referrer="http://www.radio2m.ma/" group-title="General",2M Monde (360p)
#EXTVLCOPT:http-referrer=http://www.radio2m.ma/
https://cdn-globecast.akamaized.net/live/2m_monde.m3u8
''';

      final channels = IptvApiService.parseM3u(sampleM3u);

      expect(channels.length, 3);

      // Channel 1
      expect(channels[0].id, 'AlJazeera.qa@SD');
      expect(channels[0].name, 'Al Jazeera');
      expect(channels[0].quality, '1080p');
      expect(channels[0].country, 'QA');
      expect(channels[0].category, 'News');
      expect(channels[0].streamUrl, 'https://live-hls.example.com/aljazeera/master.m3u8');
      expect(channels[0].isGeoBlocked, false);

      // Channel 2
      expect(channels[1].id, 'AfaqTV.iq@SD');
      expect(channels[1].name, 'Afaq TV');
      expect(channels[1].quality, '720p');
      expect(channels[1].country, 'IQ');
      expect(channels[1].isGeoBlocked, true);
      expect(channels[1].streamUrl, 'http://stream.afaq.iq/live/afaqtv/playlist.m3u8');

      // Channel 3
      expect(channels[2].id, '2MMonde.ma@SD');
      expect(channels[2].name, '2M Monde');
      expect(channels[2].quality, '360p');
      expect(channels[2].country, 'MA');
      expect(channels[2].httpReferrer, 'http://www.radio2m.ma/');
    });

    test('EpgProgram calculates airing and progress correctly', () {
      final now = DateTime.now();
      final currentProgram = EpgProgram(
        channelId: 'test.ch',
        title: 'Current Live Program',
        start: now.subtract(const Duration(minutes: 30)),
        stop: now.add(const Duration(minutes: 30)),
      );

      expect(currentProgram.isCurrentlyAiring, true);
      expect(currentProgram.progressPercentage, greaterThan(0.4));
      expect(currentProgram.progressPercentage, lessThan(0.6));

      final futureProgram = EpgProgram(
        channelId: 'test.ch',
        title: 'Future Program',
        start: now.add(const Duration(hours: 1)),
        stop: now.add(const Duration(hours: 2)),
      );

      expect(futureProgram.isCurrentlyAiring, false);
      expect(futureProgram.progressPercentage, 0.0);
    });
  });
}
