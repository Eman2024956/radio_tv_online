import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_translations.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';
import '../screens/help_screen.dart';
import '../screens/developer_profile_screen.dart';

class AppDrawer extends StatelessWidget {
  final Function(int tabIndex)? onNavigateToTab;

  const AppDrawer({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    final tr = AppTranslations.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return Drawer(
      backgroundColor: AppTheme.scaffoldOf(context),
      child: SafeArea(
        child: Column(
          children: [
            // App Branding Header Card
            Container(
              margin: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryCyan, AppTheme.secondaryPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryCyan.withAlpha(45),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withAlpha(60),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.cell_tower_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr.appName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tr.appSubtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Menu Options
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                children: [
                  // Main Navigation Items
                  _buildMenuItem(
                    context: context,
                    icon: Icons.home_rounded,
                    iconColor: AppTheme.primaryCyan,
                    title: tr.menuHomeMain,
                    onTap: () {
                      Navigator.pop(context);
                      onNavigateToTab?.call(0);
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.live_tv_rounded,
                    iconColor: Colors.redAccent,
                    title: tr.navLiveTv,
                    onTap: () {
                      Navigator.pop(context);
                      onNavigateToTab?.call(1);
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.public_rounded,
                    iconColor: AppTheme.secondaryPurple,
                    title: tr.navCountries,
                    onTap: () {
                      Navigator.pop(context);
                      onNavigateToTab?.call(2);
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.search_rounded,
                    iconColor: AppTheme.accentAmber,
                    title: tr.navSearch,
                    onTap: () {
                      Navigator.pop(context);
                      onNavigateToTab?.call(3);
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.favorite_rounded,
                    iconColor: AppTheme.accentCoral,
                    title: tr.navFavorites,
                    onTap: () {
                      Navigator.pop(context);
                      onNavigateToTab?.call(4);
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.download_done_rounded,
                    iconColor: AppTheme.accentEmerald,
                    title: tr.navDownloads,
                    onTap: () {
                      Navigator.pop(context);
                      onNavigateToTab?.call(5);
                    },
                  ),

                  const Divider(height: 18, thickness: 0.8),

                  // Documentation & Developer Section
                  _buildMenuItem(
                    context: context,
                    icon: Icons.menu_book_rounded,
                    iconColor: AppTheme.primaryCyan,
                    title: tr.menuHelpDocs,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HelpScreen()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.verified_user_rounded,
                    iconColor: AppTheme.accentAmber,
                    title: tr.menuDevProfile,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DeveloperProfileScreen()),
                      );
                    },
                  ),

                  const Divider(height: 18, thickness: 0.8),

                  // Quick Toggles Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      tr.quickToggles,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: AppTheme.textMutedOf(context),
                      ),
                    ),
                  ),

                  // Dark Mode Toggle Switch
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColorOf(context),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.borderOf(context)),
                    ),
                    child: SwitchListTile(
                      value: themeProvider.isDarkMode,
                      secondary: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: (themeProvider.isDarkMode
                                  ? AppTheme.accentAmber
                                  : AppTheme.secondaryPurple)
                              .withAlpha(35),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          themeProvider.isDarkMode
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          color: themeProvider.isDarkMode
                              ? AppTheme.accentAmber
                              : AppTheme.secondaryPurple,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        tr.darkModeToggle,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryOf(context),
                        ),
                      ),
                      subtitle: Text(
                        tr.darkModeSubtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMutedOf(context),
                        ),
                      ),
                      activeTrackColor: AppTheme.primaryCyan,
                      onChanged: (val) {
                        themeProvider.toggleTheme();
                      },
                    ),
                  ),

                  // Translating (Language) Toggle Switch
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColorOf(context),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.borderOf(context)),
                    ),
                    child: SwitchListTile(
                      value: localeProvider.isArabic,
                      secondary: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryCyan.withAlpha(35),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.translate_rounded,
                          color: AppTheme.primaryCyan,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        tr.translateToggle,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryOf(context),
                        ),
                      ),
                      subtitle: Text(
                        localeProvider.isArabic ? 'اللغة العربية (العراق/عالمي)' : 'English (Global)',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMutedOf(context),
                        ),
                      ),
                      activeTrackColor: AppTheme.primaryCyan,
                      onChanged: (val) {
                        localeProvider.toggleLanguage();
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Footer Copyright
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.borderOf(context))),
              ),
              child: Column(
                children: [
                  Text(
                    tr.developerCopyright,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: AppTheme.textMutedOf(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tr.appVersion,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.primaryCyan,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2.5),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        dense: true,
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withAlpha(30),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryOf(context),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          size: 18,
          color: AppTheme.textMutedOf(context),
        ),
        onTap: onTap,
      ),
    );
  }
}
