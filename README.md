# 📻📺 Radio & TV Online - راديو وتلفزيون أونلاين

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-green.svg)]()
[![Copyright](https://img.shields.io/badge/Copyright-%C2%A9%202026%20Radio%20%26%20TV%20Online-purple.svg)]()
[![Status](https://img.shields.io/badge/Build-Passing-brightgreen.svg)]()

> **Radio & TV Online (راديو وتلفزيون أونلاين)** is an all-in-one live streaming platform built with Flutter. It connects users to over **58,000+ live radio stations** and **global TV channels** worldwide with crystal-clear audio, smooth HLS video streaming, timed live MP3 recording to physical storage, interactive program guides (EPG), and a dual English / Arabic RTL interface.

---

## 🌟 Key Highlights & Features

### 1. 📻 Worldwide Radio Explorer (58,000+ Stations)
- **Extensive Global Directory**: Powered by community open radio directories with automatic mirror failover and Cloudflare DNS-over-HTTPS resilience.
- **Geographic Exploration**: 240+ countries and territories categorized into quick-filter regions (Arab World & Middle East 🕌, Europe 🏰, Americas 🌎, Asia 🏯, and All Nations 🌍).
- **Genre & Discovery**: Top-rated stations, most-streamed worldwide, and instant genre filtering (News, Talk, Quran, Pop, Classical, Rock, Jazz, Chillout, Sports).
- **Format & Bitrate Filtering**: Filter streams by audio format (MP3, AAC+, OGG, FLAC) and streaming bitrates (64k to 320k+).

### 2. 📺 World Live TV & Video Streaming
- **Live Video Streaming**: Real-time HLS video playback for news, sports, culture, documentaries, and entertainment channels.
- **Categorized Channel Lineup**: Browse channels by genre (News, Sports, Music, General, Entertainment, Kids, Movies).
- **Integrated Program Guide (EPG)**: View live schedule timetables, currently airing shows, upcoming broadcasts, and real-time progress bars.
- **Adaptive Video Player**: Controls for quality selection, aspect ratios, full-screen playback, and buffering management.

### 3. 🎙️ Live Stream MP3 Recording
- **Direct Stream Capture**: Records genuine MP3 audio streams directly into your device's physical storage:
  - Android download directory: `/storage/emulated/0/Download/RadioRecordings/`
- **Flexible Timers**:
  - `30 Seconds` (Quick Clip)
  - `1 Minute` (Standard)
  - `3 Minutes` (Music Track)
  - `5 Minutes` (Segment / News)
  - `Custom / Continuous` manual recording
- **Offline Playback**: In-app player inside the **Downloads** tab to listen to saved audio files anytime without internet connection.

### 4. ❤️ Bookmarks & Listening History
- **One-Tap Favorites**: Pin favorite radio stations and TV channels with a single tap.
- **Recent Playback History**: Automatically records your listening sessions for fast access.
- **Search within Bookmarks**: Instant real-time filtering within saved stations.

### 5. 🌐 Instant Bilingual Support (English & Arabic RTL)
- Full **Right-to-Left (RTL)** layout mirroring when Arabic is active.
- Seamless, zero-restart language switcher available from the top navigation bar and side drawer.

### 6. 🌓 Modern Cyber Dark & Clean Light Themes
- **Cyber Dark Theme**: Deep slate `#090D16` palette with neon cyan `#00E5FF` and electric purple `#8B5CF6` accents.
- **Clean Light Theme**: High-contrast, crisp typography engineered for optimal daytime visibility.
- Smooth transition between themes without interrupting ongoing audio or video playback.

---

## 📱 Navigation & App Structure

The app is designed with a persistent navigation bar and responsive floating player:

1. **Home Screen**: Featured live highlights, trending worldwide channels, regional quick-access pills, and side navigation.
2. **Live TV Screen**: Live video streams, category chips, channel cards, and EPG programming schedules.
3. **Countries Screen**: 240+ countries and territories organized into geographic tabs with real-time station counts.
4. **Search Screen**: Real-time keyword search, codec filter chips, and bitrate selectors.
5. **Favorites & History Screen**: Pinned channels and automated listening history.
6. **Downloads Screen**: Local audio recordings manager with integrated playback.
7. **Radio Player Screen**: Detailed player with live stream metadata, codec stats, and MP3 recording controls.
8. **TV Player Screen**: Interactive video player with live EPG schedule drawer and stream status indicators.
9. **Side Drawer**: User profile status, theme toggles, language switcher, and platform information.

---

## 🛠️ Architecture & Technology Stack

| Component | Technology | Description |
| :--- | :--- | :--- |
| **Framework** | Flutter 3.x | Cross-platform UI toolkit with Material 3 |
| **Language** | Dart 3.x | Modern, null-safe reactive language |
| **State Management** | `provider` | Decoupled state and reactive service scopes |
| **Audio Playback** | `audioplayers` | Live audio stream buffering and decoding |
| **Video Playback** | `video_player` & `chewie` | HLS video stream decoding and playback controls |
| **Network & DNS** | `http` | HTTP streaming, mirror failover, Cloudflare DoH |
| **Local Persistence** | `shared_preferences` | Caches favorites, history, settings, and profile |
| **File I/O** | `path_provider` & `permission_handler` | Scoped storage access for MP3 recordings |
| **Typography** | Google Fonts (`Outfit`) | Crisp typography with Arabic font pairing |

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.10.7` or newer)
- [Android Studio](https://developer.android.com/studio) / Xcode for iOS deployment
- Java JDK 17+

### Installation & Run

1. **Clone the repository**:
   ```bash
   git clone git@github.com:Eman2024956/radio_tv_online.git
   cd radio_channel
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run on connected device / emulator**:
   ```bash
   flutter run
   ```

---

## 🧪 Testing & Verification

Run automated unit and widget test suites:
```bash
flutter test
```

Run static code analysis:
```bash
dart analyze lib/ test/
```

---

## 📦 Building for Production

### Android Release APK
```bash
flutter build apk --release
```
*Output:* `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (.aab) for Google Play
```bash
flutter build appbundle --release
```
*Output:* `build/app/outputs/bundle/release/app-release.aab`

---

## 🌐 Remote Repository

- **GitHub Remote**: `git@github.com:Eman2024956/radio_tv_online.git`
- **Default Branch**: `main`

To push updates:
```bash
git push origin main
```

---

## ⚖️ Copyright & License

```
Copyright © 2026 Radio & TV Online. All Rights Reserved.
```

- **Attribution**: Live radio directory metadata is provided by the open community at [Radio-Browser.info](https://www.radio-browser.info/). Live TV streaming metadata is powered by global IPTV open databases.
