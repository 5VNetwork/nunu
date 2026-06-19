import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tm/common.dart';
import 'package:tm/private.dart';
import 'package:tm/x_controller.dart';
import 'package:tm/status_cubit.dart';
import 'package:nunu/app/choice_cubit.dart';
import 'package:nunu/app/control.dart';
import 'package:nunu/app/settings/general/country.dart';
import 'package:nunu/app/share_dialog.dart';
import 'package:nunu/auth/auth_bloc.dart';
import 'package:nunu/auth/user.dart';
import 'package:flutter_common/util/net.dart';
import 'package:tm/ads/ad_click_guard.dart';
import 'package:tm/ads/home_ad_provider.dart';
import 'package:nunu/common/common.dart';
import 'package:nunu/l10n/app_localizations.dart';
import 'package:nunu/main.dart';
import 'package:nunu/pref_helper.dart';
import 'package:nunu/utils/default_network.dart';
import 'package:flutter_common/common.dart';
import 'package:flutter_common/util/country.dart';
import 'package:country/country.dart';
import 'package:nunu/theme.dart';
import 'package:tm/default.dart';
import 'package:tm/ads/banner_ad.dart';

part 'inbound_mode_selector.dart';
part 'home_button.dart';
part 'home_country_selector.dart';

class VpnHomePage extends StatefulWidget {
  const VpnHomePage({super.key});

  @override
  State<VpnHomePage> createState() => _VpnHomePageState();
}

class _VpnHomePageState extends State<VpnHomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    final pref = context.read<SharedPreferences>();
    if (Platform.isAndroid && !pref.hasShownVpnServiceInfo) {
      pref.setHasShownVpnServiceInfo(true);
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            final theme = Theme.of(context);
            final l10n = AppLocalizations.of(context)!;
            return AlertDialog(
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.shield,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text('VPN Service'),
                ],
              ),
              content: Text(
                'Nunu利用VPNService使您的上网体验更加稳定。在使用VPNService的过程中，我们会根据您的IP地址来为您提供最优服务器，我们不会分享或储存您的IP地址。',
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.pop(),
                    child: Text(l10n.okay),
                  ),
                ),
              ],
            );
          },
        );
      });
    } else if (pref.userCountry == null) {
      // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      //   Navigator.of(context).push(CupertinoPageRoute(
      //       builder: (context) => const CountrySelectionPage(
      //             firstLaunch: true,
      //           )));
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final shareButton = IconButton(
      tooltip: '分享',
      icon: Icon(Icons.ios_share_rounded, color: colorScheme.primary),
      onPressed: () => showShareDialog(context),
    );
    final settingButton = Row(
      children: [
        // Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: IconButton(
        //     onPressed: () {
        //       _scaffoldKey.currentState?.openDrawer();
        //     },
        //     icon: Icon(
        //       Icons.tune_rounded,
        //       color: colorScheme.onSurface.withOpacity(0.87),
        //     ),
        //     tooltip: AppLocalizations.of(context)!.advanced,
        //   ),
        // ),
        IconButton(
          icon: Icon(
            Icons.ac_unit_rounded,
            color: colorScheme.onSurface.withOpacity(0.87),
          ),
          onPressed: () {
            context.go('/setting');
          },
        ),

        SizedBox(width: 8),
      ],
    );
    final title = Text(
      "努努加速器",
      style: textTheme.titleMedium?.copyWith(
        letterSpacing: 1,
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colorScheme.bgColor,
      drawer: ControlDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Platform.isMacOS ? null : settingButton,
        // leadingWidth: desktopPlatform ? 148 : 168,
        title: /* desktopPlatform
            ? ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 24),
                child: MoveWindow(child: title),
              )
            : */
            title,
        centerTitle: true,
        // flexibleSpace: desktopPlatform
        //     ? MoveWindow(child: Container(color: Colors.transparent))
        //     : null,
        actions: [
          Padding(
            padding: Platform.isMacOS
                ? const EdgeInsets.only(right: 0)
                : const EdgeInsets.symmetric(horizontal: 4),
            child: shareButton,
          ),
          // if (Platform.isWindows || Platform.isLinux)
          //   Padding(
          //     padding: const EdgeInsets.all(8.0),
          //     child: IconButton(
          //       onPressed: () async {
          //         await windowManager.hide();
          //       },
          //       icon: Icon(
          //         Icons.remove_rounded,
          //         color: colorScheme.onSurface.withOpacity(0.87),
          //       ),
          //     ),
          //   ),
          if (Platform.isMacOS)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: settingButton,
            ),
        ],
      ),
      body: SafeArea(
        child: Consumer<AuthRepo>(
          builder: (context, authRepo, child) {
            if (!isProduction()) {
              return Stack(
                children: [
                  _HomeBody(),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: HandlersBeingUsed(),
                  ),
                ],
              );
            }
            return const _HomeBody();
          },
        ),
      ),
    );
  }
}

class HandlersBeingUsed extends StatelessWidget {
  const HandlersBeingUsed({super.key});

  @override
  Widget build(BuildContext context) {
    final handlers = context.watch<XController>().handlers;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: handlers
          .map((handler) => Text(handler, style: TextStyle(fontSize: 8)))
          .toList(),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.bgColor,
            colorScheme.bgGradientEnd,
            colorScheme.bgSecondary.withValues(alpha: 0.6),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: Column(
        children: [
          const Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: HomeButton(),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Consumer<AuthRepo>(
                  builder: (context, authRepo, child) {
                    if (authRepo.user == null) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: ChangeNotifierProvider(
                              create: (context) => HomeAdProvider(
                                defaultNetworkMonitor: context
                                    .read<DefaultNetworkMonitor>(),
                                xController: context.read<XController>(),
                                adClickGuard: context.read<AdProt>(),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CountrySelector(),
                                  const SizedBox(height: 24),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: colorScheme.borderMedium,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: SizedBox(
                                          height: 150,
                                          child: const BannerAdWidget(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
