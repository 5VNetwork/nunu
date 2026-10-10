import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:nunu/auth/user.dart';
import 'package:nunu/common/common.dart';
import 'package:nunu/main.dart';
import 'package:nunu/utils/logger.dart';
import 'package:flutter_common/auth/auth_provider.dart';
import 'package:retry/retry.dart';
import 'package:tm/activate.dart';

const webClientId =
    "952575395446-83mgm25olhkcqqm00el2ctv65m7dkpbk.apps.googleusercontent.com";

final iosClientId = debug
    ? "952575395446-8gumjqa4av8akh8cralh8ug8kb2dckci.apps.googleusercontent.com"
    : appFlavor == "staging"
    ? "952575395446-2738klk0hmj1mq9mli50lf1u6gkcmcvi.apps.googleusercontent.com"
    : "952575395446-dts29lpnn4gnn9dbgu2aule8ja6ba7sn.apps.googleusercontent.com";

class AuthRepo extends ChangeNotifier {
  AuthRepo(this._authProvider, FlutterSecureStorage storage) {
    _userSubscription = _authProvider.sessionStreams.listen((session) {
      _user = session?.toUser;
      notifyListeners();
      if (session != null) {
        unawaited(registerUserDevice(supabase, storage));
      }
    });
  }

  User? get user => _user;
  User? _user;

  void setTestUser() {
    _user = const User(id: 'test', email: 'test@test.com');
    _userProfile = const UserProfile(
      id: 'test',
      email: 'test@test.com',
      limitedDataUsed: 1024 * 1024 * 1024 * 3,
    );
    notifyListeners();
    // after 5 minutes, set the user to unauthenticated
    Future.delayed(const Duration(minutes: 5), () {
      _user = null;
      _userProfile = null;
      notifyListeners();
    });
  }

  Future<void> refreshUser() async {
    await _authProvider.refreshUser();
  }

  final AuthProvider _authProvider;
  late final StreamSubscription<Session?> _userSubscription;
  late String deviceToken;

  Future<String?> getAccessToken() async {
    return _authProvider.currentSession?.accessToken;
  }

  UserProfile? get userProfile => _userProfile;
  UserProfile? _userProfile;

  Future<UserProfile?> fetchProfile() async {
    if (_user == null) {
      return null;
    }
    final token = await getValidAccessToken();
    if (token == null) {
      return null;
    }

    try {
      final data = await _fetchProfileJson(token: token);
      final profile = UserProfile.fromJson(data);
      _userProfile = profile;
      return profile;
    } catch (e, stackTrace) {
      logger.e('Error fetching profile', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Returns a non-expired access token, refreshing the Supabase session
  /// when the current one is expired or about to expire.
  Future<String?> getValidAccessToken() async {
    var session = _authProvider.currentSession;
    if (session == null) {
      return null;
    }
    // Refresh a bit before the actual expiry to avoid races with the server.
    const skewSeconds = 60;
    final expiresAt = session.expiresAt;
    final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final needsRefresh =
        session.isExpired ||
        (expiresAt != null && expiresAt - nowSeconds <= skewSeconds);
    if (needsRefresh) {
      try {
        logger?.i('Refreshing Supabase session');
        await _authProvider.refreshUser();
        session = _authProvider.currentSession;
      } catch (e) {
        logger?.e('Failed to refresh Supabase session', error: e);
        return null;
      }
    }
    return session?.accessToken;
  }

  Future<Map<String, dynamic>> _fetchProfileJson({
    required String token,
  }) async {
    final response = await supabase.functions.invoke(
      'get-profile',
      headers: {
        'Authorization': 'Bearer $token',
        'User-Agent': 'UmiVPN/$version',
      },
    );
    if (response.status != 200 || response.data == null) {
      throw Exception(
        'get-profile failed: ${response.status} ${response.data}',
      );
    }

    return Map<String, dynamic>.from(response.data as Map);
  }

  @override
  void dispose() {
    _userSubscription.cancel();
    return super.dispose();
  }
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.limitedDataUsed,
  });

  final String id;
  final String email;
  final int limitedDataUsed;

  /// Remaining limited-platform quota in bytes.
  int get remainingData => limitedDataUsed;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final limitedDataUsed = json['limited_data_used'];
    return UserProfile(
      id: json['user_id'] as String,
      email: json['email'] as String,
      limitedDataUsed: limitedDataUsed is int
          ? limitedDataUsed
          : int.parse(limitedDataUsed.toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'email': email,
      'limited_data_used': limitedDataUsed,
    };
  }
}
