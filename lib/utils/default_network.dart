import 'package:flutter/material.dart';
import 'package:nunu/utils/android_host_api.g.dart';
import 'package:nunu/utils/darwin_host_api.g.dart';
import 'package:nunu/utils/logger.dart';

/// Monitors the default network path and reports whether it is a physical
/// interface (wifi/cellular/ethernet) or a tunnel (VPN). Works on Android
/// (ConnectivityManager) and iOS/macOS (NWPathMonitor).
class DefaultNetworkMonitor with ChangeNotifier
    implements AndroidFlutterApi, DarwinNetworkFlutterApi {
  bool? isPhysical;

  DefaultNetworkMonitor({
    AndroidHostApi? androidHostApi,
    DarwinHostApi? darwinHostApi,
  }) {
    if (androidHostApi != null) {
      AndroidFlutterApi.setUp(this);
      androidHostApi.startBindToDefaultNetwork();
    }
    if (darwinHostApi != null) {
      DarwinNetworkFlutterApi.setUp(this);
      darwinHostApi.startMonitorDefaultNetwork();
    }
  }

  @override
  void defaultNetworkChanged(bool isPhysical) {
    logger.d('defaultNetworkChanged: isPhysical: $isPhysical');
    this.isPhysical = isPhysical;
    notifyListeners();
  }
}
