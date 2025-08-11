import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../services/localization_service.dart';

class LocalizedText extends StatelessWidget {
  final String textKey;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  const LocalizedText(
    this.textKey, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settingsService, child) {
        final text = LocalizationService.getText(
          textKey,
          settingsService.currentLanguage.code,
        );
        
        return Text(
          text,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          softWrap: softWrap,
          textDirection: LocalizationService.isRTL(settingsService.currentLanguage.code)
              ? TextDirection.rtl
              : TextDirection.ltr,
        );
      },
    );
  }
}

class LocalizedString {
  final String textKey;
  
  const LocalizedString(this.textKey);
  
  String get(BuildContext context) {
    final settingsService = Provider.of<SettingsService>(context, listen: false);
    return LocalizationService.getText(textKey, settingsService.currentLanguage.code);
  }
  
  static String of(BuildContext context, String key) {
    final settingsService = Provider.of<SettingsService>(context, listen: false);
    return LocalizationService.getText(key, settingsService.currentLanguage.code);
  }
}

// Extension for easy access to localized strings
extension LocalizationContext on BuildContext {
  String tr(String key) {
    final settingsService = Provider.of<SettingsService>(this, listen: false);
    return LocalizationService.getText(key, settingsService.currentLanguage.code);
  }
  
  bool get isRTL {
    final settingsService = Provider.of<SettingsService>(this, listen: false);
    return LocalizationService.isRTL(settingsService.currentLanguage.code);
  }
  
  String get currentLanguageCode {
    final settingsService = Provider.of<SettingsService>(this, listen: false);
    return settingsService.currentLanguage.code;
  }
}

// Custom AppBar that handles RTL
class LocalizedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleTextKey;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;

  const LocalizedAppBar({
    super.key,
    required this.titleTextKey,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settingsService, child) {
        final isRTL = LocalizationService.isRTL(settingsService.currentLanguage.code);
        
        return AppBar(
          title: LocalizedText(titleTextKey),
          actions: isRTL ? (leading != null ? [leading!] : null) : actions,
          leading: isRTL ? (actions?.isNotEmpty == true ? actions!.first : null) : leading,
          automaticallyImplyLeading: automaticallyImplyLeading,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: elevation,
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}