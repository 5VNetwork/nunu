import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:nunu/auth/user.dart';
import 'package:nunu/common/common.dart';
import 'package:nunu/main.dart';
import 'package:nunu/utils/logger.dart';
import 'package:flutter_common/auth/auth_provider.dart';
import 'package:retry/retry.dart';

const webClientId =
    "952575395446-83mgm25olhkcqqm00el2ctv65m7dkpbk.apps.googleusercontent.com";

final iosClientId = debug
    ? "952575395446-8gumjqa4av8akh8cralh8ug8kb2dckci.apps.googleusercontent.com"
    : appFlavor == "staging"
    ? "952575395446-2738klk0hmj1mq9mli50lf1u6gkcmcvi.apps.googleusercontent.com"
    : "952575395446-dts29lpnn4gnn9dbgu2aule8ja6ba7sn.apps.googleusercontent.com";

class AuthRepo extends ChangeNotifier {
  AuthRepo(this._authProvider) {
    _userSubscription = _authProvider.sessionStreams.listen((user) {
      _user = user?.toUser;
      notifyListeners();
    });
  }

  User? get user => _user;
  User? _user;

  void setTestUser() {
    _user = const User(id: 'test', email: 'test@test.com');
    notifyListeners();
    // after 5 minutes, set the user to unauthenticated
    Future.delayed(const Duration(minutes: 5), () {
      _user = null;
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
    this.stripeCustomerId,
  });

  final String id;
  final String email;
  final String? stripeCustomerId;

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    return DateTime.tryParse(value.toString());
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email};
  }
}
