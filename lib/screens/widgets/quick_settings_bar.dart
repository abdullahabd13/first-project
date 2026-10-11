import 'package:flutter/material.dart';
import '../../services/app_settings_service.dart';

class QuickSettingsBar extends StatelessWidget {
  final bool isCompact;
  final Color? iconColor;
  final Color? backgroundColor;

  const QuickSettingsBar({
    super.key,
    this.isCompact = false,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettingsService(),
      builder: (context, _) {
        final settings = AppSettingsService();
        final isDark = settings.isDarkMode;
        final isAr = settings.isArabic;

        final resolvedBg = backgroundColor ??
            (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2F0EC));
        final resolvedIconColor = iconColor ??
            (isDark ? const Color(0xFF9EE4C2) : const Color(0xFF1E513B));

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: resolvedBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFBFE5D3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Theme toggle button
              Tooltip(
                message: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => settings.toggleTheme(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                          size: 16,
                          color: resolvedIconColor,
                        ),
                        if (!isCompact) ...[
                          const SizedBox(width: 4),
                          Text(
                            isDark ? 'Light' : 'Dark',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: resolvedIconColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              Container(
                height: 12,
                width: 1,
                color: (isDark ? Colors.white24 : Colors.black12),
                margin: const EdgeInsets.symmetric(horizontal: 2),
              ),

              // Language toggle button
              Tooltip(
                message: isAr ? 'Switch to English' : 'التحويل إلى العربية',
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => settings.toggleLanguage(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.language_rounded,
                          size: 16,
                          color: resolvedIconColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isAr ? 'EN' : 'عربي',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: resolvedIconColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
