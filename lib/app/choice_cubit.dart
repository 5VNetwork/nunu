import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nunu/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tm/common.dart';
import 'package:tm/protos/vx/outbound/outbound.pb.dart';
import 'package:tm/x_controller.dart';
import 'package:tm/xapi_client.dart';
import 'package:nunu/auth/auth_bloc.dart';
import 'package:nunu/auth/user.dart';
import 'package:nunu/l10n/app_localizations.dart';
import 'package:nunu/pref_helper.dart';
import 'package:tm/default.dart';
import 'package:equatable/equatable.dart';

class Choice extends Equatable {
  final String country;
  // when country is auto, this is the actual country that the user is connected to
  final String? realtimeCountry;
  final DefaultRouteMode routeMode;

  Choice({
    required this.country,
    this.realtimeCountry,
    required this.routeMode,
  });

  @override
  List<Object?> get props => [country, realtimeCountry, routeMode];

  Choice copyWith({
    String? country,
    ValueGetter<String?>? realtimeCountry,
    DefaultRouteMode? routeMode,
  }) {
    return Choice(
      routeMode: routeMode ?? this.routeMode,
      country: country ?? this.country,
      realtimeCountry: realtimeCountry != null
          ? realtimeCountry()
          : this.realtimeCountry,
    );
  }
}

class ChoiceCubit extends Cubit<Choice> {
  ChoiceCubit({
    required SharedPreferences pref,
    required FlutterSecureStorage storage,
    required XApiClient xApiClient,
    required XController xController,
    required AuthRepo authRepo,
  }) : _pref = pref,
       _storage = storage,
       _xApiClient = xApiClient,
       _xController = xController,
       _authRepo = authRepo,
       super(Choice(country: _getCountry(pref), routeMode: pref.routingMode)) {}

  final SharedPreferences _pref;
  final XController _xController;
  final FlutterSecureStorage _storage;
  final XApiClient _xApiClient;
  final AuthRepo _authRepo;
  StreamSubscription<XStatus>? _statusSubscription;

  Future<void> changeCountry(String country) async {
    if (country == state.country) {
      return;
    }
    _pref.setSelectedCountry(country);
    emit(state.copyWith(country: country));
    try {
      await _xController.countryChange(country);
    } catch (e) {
      dialog("抱歉，无法切换国家: $e");
    }
  }

  Future<void> changeRouteMode(DefaultRouteMode routeMode) async {
    _pref.setRoutingMode(routeMode);
    emit(state.copyWith(routeMode: routeMode));
    await _xController.routingModeChange(routeMode);
  }

  @override
  Future<void> close() async {
    _statusSubscription?.cancel();
    await super.close();
    return;
  }

  Completer<void>? _completer;
}

class NodesSecureStorage {
  final String country;
  final List<OutboundHandlerConfig>? handlers;

  NodesSecureStorage({required this.country, this.handlers});

  /// Convert Choice to JSON map
  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'handlers': handlers?.map((handler) {
        // Serialize protobuf message as base64-encoded string
        final bytes = handler.writeToBuffer();
        return base64Encode(bytes);
      }).toList(),
    };
  }

  /// Create Choice from JSON map
  factory NodesSecureStorage.fromJson(Map<String, dynamic> json) {
    return NodesSecureStorage(
      country: json['country'] as String,
      handlers: json['handlers'] != null
          ? (json['handlers'] as List<dynamic>).map((item) {
              // Deserialize base64-encoded protobuf message
              final bytes = base64Decode(item as String);
              return OutboundHandlerConfig.fromBuffer(bytes);
            }).toList()
          : null,
    );
  }

  /// Convert Choice to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Create Choice from JSON string
  factory NodesSecureStorage.fromJsonString(String jsonString) {
    return NodesSecureStorage.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }
}

String _getCountry(SharedPreferences pref) {
  return pref.selectedCountry;
}

Future<NodesSecureStorage?> _getNodesSecureStorage(
  FlutterSecureStorage storage,
) async {
  final s = await storage.read(key: 'nodes_secure_storage');
  if (s == null) {
    return null;
  }
  return NodesSecureStorage.fromJsonString(s);
}

Future<void> _saveNodesSecureStorage(
  FlutterSecureStorage storage,
  NodesSecureStorage nodesSecureStorage,
) async {
  await storage.write(
    key: 'nodes_secure_storage',
    value: nodesSecureStorage.toJsonString(),
  );
}

extension XStatusExtension on XStatus {
  String localizedString(BuildContext context) {
    switch (this) {
      case XStatus.disconnected:
        return AppLocalizations.of(context)!.disconnected;
      case XStatus.connecting:
        return AppLocalizations.of(context)!.connecting;
      case XStatus.connected:
        return AppLocalizations.of(context)!.connected;
      case XStatus.disconnecting:
        return AppLocalizations.of(context)!.disconnecting;
      case XStatus.reconnecting:
        return AppLocalizations.of(context)!.reconnecting;
      case XStatus.unknown:
        return AppLocalizations.of(context)!.unknown;
      case XStatus.preparing:
        return AppLocalizations.of(context)!.preparing;
    }
  }
}
