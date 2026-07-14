import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/utils/darwin_host_api.g.dart',
    dartOptions: DartOptions(),
    swiftOut: 'darwin/Messages.g.swift',
    swiftOptions: SwiftOptions(),
  ),
)
@HostApi()
abstract class DarwinHostApi {
  String appGroupPath();
  @async
  void startXApiServer(Uint8List config);
  @async
  void redirectStdErr(String path);
  Uint8List generateTls();
  void setupShutdownNotification();
  void startMonitorDefaultNetwork();
}

@FlutterApi()
abstract class DarwinFlutterApi {
  void onSystemWillShutdown();
  void onSystemWillRestart();
  void onSystemWillSleep();
}

/// Separate from [DarwinFlutterApi] because each FlutterApi can only have one
/// handler set up on the Dart side, and DarwinFlutterApi is handled by
/// SystemShutdownNotifier.
@FlutterApi()
abstract class DarwinNetworkFlutterApi {
  void defaultNetworkChanged(bool isPhysical);
}

// class SplitTunnelSettings {
//   SplitTunnelSettings({this.blackList, this.whiteList});
//   List<String>? blackList;
//   List<String>? whiteList;
// }
