import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_common/common.dart';

final desktopPlatforms =
    Platform.isMacOS || Platform.isWindows || Platform.isLinux;

const androidPackageNme = appFlavor == 'staging'
    ? 'monster.nunu.wqeeer.staging'
    : appFlavor == 'dev'
    ? 'monster.nunu.wqeeer.dev'
    : 'monster.nunu.wqeeer';

final supabaseUrl = debug
    ? const String.fromEnvironment('SUPABASE_URL')
    : 'https://wbxbxgrqcshsqfwzigqx.supabase.co';
final supabaseApiKey = debug
    ? 'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH'
    : 'sb_publishable_0CxfB8FwtJDw0PcL9nB6Bw_Hlfd7gmr';

const staging = bool.fromEnvironment('STAGING');
final debug =
    (Platform.isAndroid && appFlavor == 'dev') ||
    (applePlatform && appFlavor == null) ||
    (appFlavor == null && kDebugMode && !staging);

const websiteUrl = 'https://www.nunu.monster';
const privacyPolicyUrl = 'https://www.nunu.monster/privacy';
const termOfServiceUrl = 'https://www.nunu.monster/terms';

const logKey = String.fromEnvironment('LOG_KEY', defaultValue: '1234567890');

final useStripe =
    Platform.isWindows ||
    (Platform.isAndroid && appFlavor != 'production') ||
    appFlavor == "pkg" ||
    Platform.isLinux;

final androidNonStore = Platform.isAndroid && appFlavor != 'production';
const isWinStore = bool.fromEnvironment('STORE');
final autoUpdateSupported = false;
// androidNonStore || (Platform.isWindows && !isWinStore) || Platform.isLinux;

bool isProduction() {
  if (Platform.isWindows || Platform.isLinux) {
    return kReleaseMode;
  }
  return (appFlavor == "production" ||
          appFlavor == "pkg" ||
          appFlavor == "apk") &&
      kReleaseMode;
}

List<int> generateUniqueNumbers(int count, {int min = 1, int max = 100}) {
  final random = Random();
  final Set<int> numbers = {};

  while (numbers.length < count) {
    numbers.add(min + random.nextInt(max - min + 1));
  }

  return numbers.toList();
}

final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
final numericRegExp = RegExp(r'^\d+$');
const isPkg = appFlavor == 'pkg';
