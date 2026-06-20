// Copyright (C) 2026 5V Network LLC <5vnetwork@proton.me>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'package:ads/ad.dart';
import 'package:ads/ads_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/util/download.dart';
import 'package:nunu/main.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:nunu/app/settings/setting.dart';
import 'package:nunu/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PromotionPage extends StatelessWidget {
  const PromotionPage({super.key, this.showAppBar = true});
  final bool showAppBar;
  @override
  Widget build(BuildContext context) {
    final adsProvider = AdsProvider(
      adsDirectory: join(resourceDirectory.path, 'ads'),
      sharedPreferences: context.read<SharedPreferences>(),
      downloadFunction: directDownloadToFile,
    );
    return Scaffold(
      appBar: showAppBar
          ? getAdaptiveAppBar(
              context,
              Text(AppLocalizations.of(context)!.promote),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LayoutBuilder(
          builder: (ctx, c) {
            return FutureBuilder<List<Ad>>(
              future: adsProvider.fetchAllAds(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length + 1,
                  itemBuilder: (context, index) {
                    if (index == snapshot.data!.length) {
                      return const AdWantedCard();
                    }
                    print(snapshot.data![index].toJson());
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AdWidget(
                        ad: snapshot.data![index],
                        maxHeight: c.maxHeight - 50,
                        maxWidth: c.maxWidth,
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
