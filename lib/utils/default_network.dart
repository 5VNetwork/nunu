import 'package:flutter/material.dart';
import 'package:nunu/utils/android_host_api.g.dart';
import 'package:nunu/utils/logger.dart';

class DefaultNetworkMonitor with ChangeNotifier implements AndroidFlutterApi {
  bool? isPhysical;

  DefaultNetworkMonitor({AndroidHostApi? androidHostApi}) {
    AndroidFlutterApi.setUp(this);
    androidHostApi?.startBindToDefaultNetwork();
  }

  @override
  void defaultNetworkChanged(bool isPhysical) {
    logger.d('defaultNetworkChanged: isPhysical: $isPhysical');
    this.isPhysical = isPhysical;
    notifyListeners();
  }
}
