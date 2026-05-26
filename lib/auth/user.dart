import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_common/util/jwt.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_common/util/net.dart';
import 'package:nunu/common/common.dart';
import 'package:nunu/utils/logger.dart';

enum SubscriptionPlan {
  free,
  air,
  pro;

  String get name => switch (this) {
    free => 'Free',
    air => 'Air',
    pro => 'Pro',
  };

  int get data => 1024 * 1024 * 1024;

  static SubscriptionPlan fromString(String plan) {
    return switch (plan) {
      'free' => free,
      'air' => air,
      'pro' => pro,
      _ => free,
    };
  }
}

enum SubscriptionSource {
  stripe,
  playStore,
  appStore,
  others;

  String get name => switch (this) {
    stripe => 'Stripe',
    playStore => 'Play Store',
    appStore => 'App Store',
    others => 'Others',
  };
}

class User extends Equatable {
  const User({required this.id, required this.email});
  final String id;
  final String email;

  User copyWith({String? id, String? email}) {
    return User(id: id ?? this.id, email: email ?? this.email);
  }

  @override
  List<Object?> get props => [id, email];
}

extension UserExtension on Session {
  User get toUser {
    // Decode the access token to get custom claims
    final claims = decodeJwt(accessToken);
    logger.d('JWT claims: $claims');

    // Extract the 'pro' claim from JWT
    return User(id: user.id, email: user.email!);
  }
}
