import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nunu/l10n/app_localizations.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:nunu/app/settings/setting.dart';
import 'package:nunu/main.dart';

const String email = 'nunujiasuqi@proton.me';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? getAdaptiveAppBar(
              context,
              Text(AppLocalizations.of(context)!.contactUs),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.contactUsSummary),
            const SizedBox(height: 10),
            Row(
              children: [
                const Chip(label: Text(email)),
                IconButton(
                  onPressed: () {
                    Pasteboard.writeText(email);
                    rootScaffoldMessengerKey.currentState?.showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context)!.copiedToClipboard,
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy),
                ),
                // IconButton(
                //   onPressed: () {
                //     final Uri emailLaunchUri = Uri(
                //       scheme: 'mailto',
                //       path: email,
                //     );
                //     launchUrl(emailLaunchUri);
                //   },
                //   icon: const Icon(Icons.email_outlined),
                // ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                // OutlinedButton.icon(
                //   onPressed: () {
                //     launchUrl(Uri.parse('https://x.com/Nunu'));
                //   },
                //   icon: Image.asset(
                //     'assets/icons/x_logo_white.png',
                //     width: 16,
                //     height: 16,
                //   ),
                //   label: Text(' X'),
                // ),
                // const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    launchUrl(Uri.parse('https://t.me/nunujiasuqi'));
                  },
                  icon: Image.asset(
                    'assets/icons/telegram_icon.png',
                    width: 20,
                    height: 20,
                  ),
                  label: Text(AppLocalizations.of(context)!.telegram),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(AppLocalizations.of(context)!.contactUsFreely),
            const SizedBox(height: 10),
            Text(AppLocalizations.of(context)!.bugAreWelcome),
          ],
        ),
      ),
    );
  }
}
