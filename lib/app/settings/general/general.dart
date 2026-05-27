import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/util/country.dart';
import 'package:flutter_common/widgets/app_bar.dart';
import 'package:gap/gap.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nunu/app/settings/general/country.dart';
import 'package:nunu/common/common.dart';
import 'package:tm/ads/start_ad.dart';
import 'package:nunu/l10n/app_localizations.dart';
import 'package:nunu/main.dart';
import 'package:nunu/pref_helper.dart';
import 'package:flutter_common/services/auto_update.dart';
import 'package:flutter_common/widgets/progress.dart';
import 'package:country/country.dart';

class GeneralSettingPage extends StatelessWidget {
  const GeneralSettingPage({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? adaptiveClosableAppBar(
              context,
              title: AppLocalizations.of(context)!.general,
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.only(top: 8, right: 8),
        child: ListView(children: [const ThemeModeSetting()]),
      ),
    );
  }
}

String _countryLabel(BuildContext context, SharedPreferences pref) {
  final selectedCountry = pref.userCountry;
  if (selectedCountry == null || selectedCountry.isEmpty) {
    return AppLocalizations.of(context)!.auto;
  }
  return getLocalizedCountryName(context, selectedCountry);
}

class ThemeModeSetting extends StatefulWidget {
  const ThemeModeSetting({super.key});

  @override
  State<ThemeModeSetting> createState() => _ThemeModeSettingState();
}

class _ThemeModeSettingState extends State<ThemeModeSetting> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = context.read<SharedPreferences>().themeMode;
  }

  String _label(BuildContext context, ThemeMode mode) {
    final l10n = AppLocalizations.of(context)!;
    return switch (mode) {
      ThemeMode.light => l10n.light,
      ThemeMode.dark => l10n.dark,
      ThemeMode.system => l10n.system,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      leading: Icon(
        _themeMode == ThemeMode.light
            ? Icons.light_mode_rounded
            : Icons.dark_mode_rounded,
      ),
      title: Text(l10n.themeMode, style: Theme.of(context).textTheme.bodyLarge),
      subtitle: Text(_label(context, _themeMode)),
      trailing: const Icon(Icons.keyboard_arrow_right_rounded),
      onTap: () {
        showModalBottomSheet<void>(
          context: context,
          builder: (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final mode in ThemeMode.values)
                  ListTile(
                    leading: Icon(
                      switch (mode) {
                        ThemeMode.light => Icons.light_mode_rounded,
                        ThemeMode.dark => Icons.dark_mode_rounded,
                        ThemeMode.system => Icons.brightness_auto_rounded,
                      },
                      color: _themeMode == mode
                          ? Theme.of(ctx).colorScheme.primary
                          : null,
                    ),
                    title: Text(
                      _label(context, mode),
                      style: TextStyle(
                        fontWeight: _themeMode == mode
                            ? FontWeight.w700
                            : FontWeight.normal,
                        color: _themeMode == mode
                            ? Theme.of(ctx).colorScheme.primary
                            : null,
                      ),
                    ),
                    trailing: _themeMode == mode
                        ? Icon(
                            Icons.check_rounded,
                            color: Theme.of(ctx).colorScheme.primary,
                          )
                        : null,
                    onTap: () {
                      context.read<SharedPreferences>().setThemeMode(mode);
                      App.of(context)?.setThemeMode(mode);
                      setState(() => _themeMode = mode);
                      Navigator.pop(ctx);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// class StartOnBootSetting extends StatefulWidget {
//   const StartOnBootSetting({super.key});

//   @override
//   State<StartOnBootSetting> createState() => _StartOnBootSettingState();
// }

// class _StartOnBootSettingState extends State<StartOnBootSetting> {
//   bool _startOnBoot = false;

//   @override
//   void initState() {
//     super.initState();
//     _startOnBoot = context.read<SharedPreferences>().startOnBoot;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Text(
//               AppLocalizations.of(context)!.startOnBoot,
//               style: Theme.of(context).textTheme.bodyLarge,
//             ),
//             Expanded(child: SizedBox()),
//             Switch(
//               value: _startOnBoot,
//               onChanged: (value) async {
//                 context.read<SharedPreferences>().setStartOnBoot(value);
//                 setState(() {
//                   _startOnBoot = value;
//                 });
//                 if (value) {
//                   await launchAtStartup.enable();
//                 } else {
//                   await launchAtStartup.disable();
//                 }
//               },
//             ),
//           ],
//         ),
//         const Gap(10),
//         Text(
//           AppLocalizations.of(context)!.startOnBootDesc,
//           style: Theme.of(context).textTheme.bodySmall!.copyWith(
//             color: Theme.of(context).colorScheme.onSurfaceVariant,
//           ),
//         ),
//       ],
//     );
//   }
// }

class AlwaysOnSetting extends StatefulWidget {
  const AlwaysOnSetting({super.key});

  @override
  State<AlwaysOnSetting> createState() => _AlwaysOnSettingState();
}

class _AlwaysOnSettingState extends State<AlwaysOnSetting> {
  bool _alwaysOn = false;

  @override
  void initState() {
    super.initState();
    _alwaysOn = context.read<SharedPreferences>().alwaysOn;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppLocalizations.of(context)!.alwaysOn,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Expanded(child: SizedBox()),
            Switch(
              value: _alwaysOn,
              onChanged: (value) {
                context.read<SharedPreferences>().setAlwaysOn(value);
                setState(() {
                  _alwaysOn = !_alwaysOn;
                });
              },
            ),
          ],
        ),
        const Gap(10),
        Text(
          AppLocalizations.of(context)!.alwaysOnDesc,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
