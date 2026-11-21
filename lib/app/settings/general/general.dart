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
import 'package:tm/common.dart';
import 'package:tm/protos/vx/tun/tun.pb.dart';
import 'package:tm/x_controller.dart';
import 'package:nunu/l10n/app_localizations.dart';
import 'package:nunu/main.dart';
import 'package:nunu/pref_helper.dart';
import 'package:nunu/utils/logger.dart';
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
        child: ListView(
          children: [
            const ThemeModeSetting(),
            if (admobEnabled) const OfferRewardedExtensionSetting(),
            const Divider(),
            const Padding(
              padding: EdgeInsets.only(
                top: 10,
                bottom: 10,
                left: 16,
                right: 16,
              ),
              child: Tun46Setting(),
            ),
          ],
        ),
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

class OfferRewardedExtensionSetting extends StatefulWidget {
  const OfferRewardedExtensionSetting({super.key});

  @override
  State<OfferRewardedExtensionSetting> createState() =>
      _OfferRewardedExtensionSettingState();
}

class _OfferRewardedExtensionSettingState
    extends State<OfferRewardedExtensionSetting> {
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    _enabled = context.read<SharedPreferences>().offerRewardedExtension;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      secondary: const Icon(Icons.slow_motion_video_rounded),
      title: Text(
        l10n.offerRewardedExtension,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      subtitle: Text(l10n.offerRewardedExtensionDesc),
      value: _enabled,
      onChanged: (value) {
        context.read<SharedPreferences>().setOfferRewardedExtension(value);
        setState(() => _enabled = value);
      },
    );
  }
}

class Tun46Setting extends StatefulWidget {
  const Tun46Setting({super.key});

  @override
  State<Tun46Setting> createState() => _Tun46SettingState();
}

class _Tun46SettingState extends State<Tun46Setting> {
  late TunConfig_TUN46Setting _tun46Setting;

  @override
  void initState() {
    super.initState();
    var setting = context.read<SharedPreferences>().tun46Setting;
    if (Platform.isAndroid && setting == TunConfig_TUN46Setting.DYNAMIC) {
      setting = TunConfig_TUN46Setting.FOUR_ONLY;
      context.read<SharedPreferences>().setTun46Setting(setting);
    }
    _tun46Setting = setting;
  }

  Future<void> _onSelected(TunConfig_TUN46Setting? value) async {
    if (value == null || value == _tun46Setting) return;
    setState(() => _tun46Setting = value);
    context.read<SharedPreferences>().setTun46Setting(value);
    final xController = context.read<XController>();
    try {
      await xController.restart();
    } catch (e) {
      logger.e('setTun46Setting error', error: e);
      await xController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final entries = <DropdownMenuEntry<TunConfig_TUN46Setting>>[
      DropdownMenuEntry(
        value: TunConfig_TUN46Setting.FOUR_ONLY,
        label: l10n.tun46SettingIpv4Only,
      ),
      DropdownMenuEntry(
        value: TunConfig_TUN46Setting.BOTH,
        label: l10n.tun46SettingIpv4AndIpv6,
      ),
      if (!Platform.isAndroid)
        DropdownMenuEntry(
          value: TunConfig_TUN46Setting.DYNAMIC,
          label: l10n.dependsOnDefaultNic,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.tunIpv6Settings,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const Gap(10),
        DropdownMenu<TunConfig_TUN46Setting>(
          key: ValueKey(_tun46Setting),
          initialSelection: _tun46Setting,
          requestFocusOnTap: false,
          dropdownMenuEntries: entries,
          onSelected: _onSelected,
        ),
        if (_tun46Setting == TunConfig_TUN46Setting.DYNAMIC) ...[
          const Gap(10),
          Text(
            l10n.dependsOnDefaultNicDesc,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
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
