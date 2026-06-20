import 'dart:ffi';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_common/services/auto_update.dart';
import 'package:flutter_common/widgets/progress.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:tm/common.dart';
import 'package:tm/private.dart';
import 'package:tm/x_controller.dart';
import 'package:nunu/app/settings/general/general.dart';
import 'package:nunu/common/common.dart';
import 'package:nunu/l10n/app_localizations.dart';
import 'package:nunu/app/settings/account.dart';
import 'package:nunu/app/settings/contact.dart';
import 'package:nunu/app/settings/open_source_software_notice_screen.dart';
import 'package:nunu/app/settings/privacy.dart';
import 'package:nunu/auth/auth_bloc.dart';
import 'package:nunu/auth/user.dart';
import 'package:nunu/main.dart';
import 'package:nunu/pref_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:nunu/utils/debug.dart';
import 'package:nunu/utils/logger.dart';
import 'package:nunu/utils/path.dart';
import 'package:nunu/widgets/pro_icon.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:flutter_common/widgets/app_bar.dart';
import 'package:tm_windows/tm_windows_bindings_generated.dart';
import 'package:nunu/theme.dart';

final InAppReview inAppReview = InAppReview.instance;

enum SettingGroup {
  account,
  preferences,
  about,
  ads;

  String? label(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case SettingGroup.account:
        return l10n.account.toUpperCase();
      case SettingGroup.preferences:
        return l10n.general.toUpperCase();
      case SettingGroup.about:
        return l10n.about.toUpperCase();
      case SettingGroup.ads:
        return '推广';
    }
  }
}

enum SettingItem {
  account(
    icon: Icon(Icons.person_rounded),
    pathSegment: 'account',
    group: SettingGroup.account,
  ),
  general(
    icon: Icon(Icons.tune_rounded),
    pathSegment: 'general',
    group: SettingGroup.preferences,
  ),
  privacyPolicy(
    icon: Icon(Icons.shield_outlined),
    pathSegment: 'privacy',
    group: SettingGroup.about,
  ),
  contactUs(
    icon: Icon(Icons.mail_outline_rounded),
    pathSegment: 'contactUs',
    group: SettingGroup.about,
  ),
  openSourceSoftwareNotice(
    icon: Icon(Icons.code_rounded),
    pathSegment: 'openSourceSoftwareNotice',
    group: SettingGroup.about,
  ),
  ads(
    icon: Icon(Icons.campaign_outlined),
    pathSegment: 'ads',
    group: SettingGroup.about,
  );

  final Widget icon;
  final String pathSegment;
  final SettingGroup group;

  const SettingItem({
    required this.icon,
    required this.pathSegment,
    required this.group,
  });

  static SettingItem? fromPathSegment(String pathSegment) {
    for (final se in SettingItem.values) {
      if (se.pathSegment == pathSegment) {
        return se;
      }
    }
    return null;
  }

  static SettingItem? fromFullPath(String fullPath) {
    for (final se in SettingItem.values) {
      if (fullPath.startsWith('/setting/${se.pathSegment}')) {
        return se;
      }
    }
    return null;
  }

  Widget title(BuildContext context) {
    switch (this) {
      case SettingItem.account:
        return Text(AppLocalizations.of(context)!.account);
      case SettingItem.general:
        return Text(AppLocalizations.of(context)!.general);
      case SettingItem.privacyPolicy:
        return Text(AppLocalizations.of(context)!.privacyPolicy);
      case SettingItem.contactUs:
        return Text(AppLocalizations.of(context)!.contactUs);
      case SettingItem.openSourceSoftwareNotice:
        return Text(AppLocalizations.of(context)!.openSourceSoftwareNotice);
      case SettingItem.ads:
        return Text('推广');
    }
  }

  Widget? subtitle(BuildContext context) {
    switch (this) {
      case SettingItem.account:
        return null;
      case SettingItem.general:
        return null;
      case SettingItem.privacyPolicy:
        return null;
      case SettingItem.contactUs:
        return null;
      case SettingItem.openSourceSoftwareNotice:
        return null;
      case SettingItem.ads:
        return null;
    }
  }
}

const String websiteUrl = 'https://www.nunu.monster';

class CompactSettingScreen extends StatelessWidget {
  const CompactSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthRepo>().user;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final groups = <SettingGroup, List<SettingItem>>{};
    for (final item in SettingItem.values) {
      groups.putIfAbsent(item.group, () => []).add(item);
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: adaptiveClosableAppBar(
        context,
        title: AppLocalizations.of(context)!.settings,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withValues(alpha: isDark ? 0.08 : 0.10),
              colorScheme.bgColor,
              colorScheme.bgColor,
            ],
            stops: const [0.0, 0.35, 1.0],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _ProfileHeader(user: user),
              const Gap(20),
              ...groups.entries.expand(
                (entry) => [
                  _SectionLabel(text: entry.key.label(context)!),
                  const Gap(8),
                  _SettingsCard(items: entry.value),
                  const Gap(20),
                ],
              ),
              _BottomActions(user: user),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final email = user?.email ?? '';
    final initial = email.isNotEmpty ? email[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: isDark ? 0.18 : 0.14),
            colorScheme.primaryContainer.withValues(
              alpha: isDark ? 0.35 : 0.55,
            ),
          ],
        ),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.iceGlow.withValues(alpha: isDark ? 0.20 : 0.12),
            blurRadius: 24,
            spreadRadius: -8,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colorScheme.primary, colorScheme.secondary],
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: email.isEmpty
                ? Icon(
                    Icons.ac_unit_rounded,
                    color: colorScheme.onPrimary,
                    size: 28,
                  )
                : Text(
                    initial,
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (email.isNotEmpty)
                  AutoSizeText(
                    email,
                    maxLines: 1,
                    minFontSize: 12,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  )
                else
                  Text(
                    AppLocalizations.of(context)!.account,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                const Gap(6),
                _PlanBadge(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.ac_unit_rounded, size: 12, color: colorScheme.primary),
          const Gap(4),
          Text(
            'Free',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.items});
  final List<SettingItem> items;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.borderLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _SettingsTile(item: items[i]),
            if (i < items.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 64),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: colorScheme.borderLight,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.item});
  final SettingItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final iconWidget = item.icon;
    final iconData = iconWidget is Icon ? iconWidget.icon : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go('/setting/${item.pathSegment}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.18),
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(iconData, size: 20, color: colorScheme.primary),
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DefaultTextStyle(
                      style: theme.textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      child: item.title(context),
                    ),
                    if (item.subtitle(context) != null) ...[
                      const Gap(2),
                      DefaultTextStyle(
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        child: item.subtitle(context)!,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.user});
  final User? user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.public_rounded,
                label: l10n.website,
                onTap: () => launchUrl(Uri.parse(websiteUrl)),
              ),
            ),
            const Gap(10),
            Expanded(
              child: _ActionButton(
                icon: Icons.rate_review_outlined,
                label: l10n.rateApp,
                onTap: () async {
                  if (await inAppReview.isAvailable()) {
                    inAppReview.requestReview();
                  } else {
                    inAppReview.openStoreListing(
                      appStoreId: '',
                      microsoftStoreId: '',
                    );
                  }
                },
              ),
            ),
          ],
        ),
        if (Platform.isWindows && isWinStore) ...[
          const Gap(10),
          const RemoveWindowsServiceButton(),
        ],
        ...getPrivateBottomButtons(context, user),
        const Gap(16),
        if (autoUpdateSupported) ...[
          Center(child: const CheckUpdateButton()),
          const Gap(4),
        ],
        const Version(),
        if (!isProduction())
          ElevatedButton(
            onPressed: () {
              throw StateError('This is test exception');
            },
            child: const Text('Verify Sentry Setup'),
          ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surface.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorScheme.borderLight),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: colorScheme.primary),
              const Gap(8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Version extends StatelessWidget {
  const Version({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.hasError) {
          return const SizedBox();
        } else {
          final packageInfo = snapshot.data!;
          return StatefulBuilder(
            builder: (context, setState) {
              int tapCount = 0;
              return GestureDetector(
                onTapDown: isProduction()
                    ? null
                    : (details) {
                        tapCount++;
                        if (tapCount == 10) {
                          context.read<AuthRepo>().setTestUser();
                        }
                      },
                child: Center(
                  child: Text(
                    'Version: ${packageInfo.version} (${packageInfo.buildNumber})',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}

AppBar getAdaptiveAppBar(BuildContext context, Widget? title) {
  return AppBar(
    automaticallyImplyLeading: Platform.isMacOS ? false : true,
    title: title,
    actions: [
      if (Platform.isMacOS)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
    ],
  );
}

class RemoveWindowsServiceButton extends StatefulWidget {
  const RemoveWindowsServiceButton({super.key});

  @override
  State<RemoveWindowsServiceButton> createState() =>
      _RemoveWindowsServiceButtonState();
}

class _RemoveWindowsServiceButtonState
    extends State<RemoveWindowsServiceButton> {
  bool _busy = false;

  /// Uninstalls the Windows Store Umi background service (`umi`). Requires admin.
  Future<void> removeWindowsService() async {
    if (!isRunningAsAdmin) {
      snack(rootLocalizations()?.removeWindowsServiceRequiresAdmin);
      return;
    }
    try {
      final tmWindowsBindings = TmWindowsBindings(
        DynamicLibrary.open(getDllPath()),
      );
      const serviceName = "nunu";
      final serviceNamePtr = serviceName.toNativeUtf8();
      try {
        final resultPtr = tmWindowsBindings.RemoveService(
          serviceNamePtr.cast<Char>(),
        );
        final result = resultPtr.cast<Utf8>().toDartString();
        tmWindowsBindings.FreeString(resultPtr);
        if (result != "") {
          snack(result);
          return;
        }
        snack(rootLocalizations()?.windowsServiceRemoved);
      } finally {
        calloc.free(serviceNamePtr);
      }
    } catch (e, st) {
      logger.e('removeWindowsService', error: e, stackTrace: st);
      snack(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return OutlinedButton.icon(
      onPressed: _busy
          ? null
          : () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(l10n.removeWindowsServiceConfirmTitle),
                  content: Text(l10n.removeWindowsServiceConfirmMessage),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: Text(l10n.removeWindowsServiceConfirm),
                    ),
                  ],
                ),
              );
              if (confirmed != true || !context.mounted) {
                return;
              }
              setState(() => _busy = true);
              try {
                await removeWindowsService();
              } finally {
                if (mounted) {
                  setState(() => _busy = false);
                }
              }
            },
      icon: _busy
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : const Icon(Icons.delete_outline_rounded),
      label: Text(l10n.removeWindowsService),
    );
  }
}

class CheckUpdateButton extends StatefulWidget {
  const CheckUpdateButton({super.key});

  @override
  State<CheckUpdateButton> createState() => _CheckUpdateButtonState();
}

class _CheckUpdateButtonState extends State<CheckUpdateButton> {
  bool _checkingUpdate = false;
  bool _downloadingUpdate = false;
  String? _version;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        setState(() {
          _checkingUpdate = true;
        });
        try {
          final autoUpdateService = context.read<AutoUpdateService>();
          final release = await autoUpdateService.getLatestRelease();
          if (release != null) {
            setState(() {
              _checkingUpdate = false;
              _downloadingUpdate = true;
              _version = release.version;
            });
            await autoUpdateService.updateToRelease(release);
          } else {
            snack(AppLocalizations.of(context)!.noNewVersion);
          }
        } catch (e, stackTrace) {
          logger.e('Error checking update', error: e, stackTrace: stackTrace);
          snack(e.toString());
        } finally {
          setState(() {
            _downloadingUpdate = false;
            _checkingUpdate = false;
            _version = null;
          });
        }
      },
      child: _checkingUpdate
          ? smallCircularProgressIndicator()
          : Text(
              _downloadingUpdate
                  ? AppLocalizations.of(context)!.downloading(_version ?? '')
                  : AppLocalizations.of(context)!.checkUpdate,
            ),
    );
  }
}
