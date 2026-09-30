import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nunu/common/common.dart';
import 'package:nunu/pref_helper.dart';
import 'package:nunu/utils/logger.dart';

const appStoreId = '6790730070';
const microsoftStoreId = '9N9HJP6DB31L';

/// Prompts for an App Store / Play Store / Microsoft Store review after the
/// user has had the app installed for a while.
///
/// Uses the platform-native in-app review UI when available. Store quotas still
/// apply, so [requestReview] may be a no-op even when we call it.
class ReviewPrompt {
  ReviewPrompt(this._pref, {InAppReview? inAppReview})
    : _inAppReview = inAppReview ?? InAppReview.instance;

  final SharedPreferences _pref;
  final InAppReview _inAppReview;

  static const minDaysSinceFirstOpen = 3;

  static bool _requestInFlight = false;

  /// Call once at app start so install age can be measured, then maybe prompt.
  void onAppOpen() {
    ensureFirstOpenRecorded();
    maybeRequestReview();
  }

  /// Call once at app start so install age can be measured.
  void ensureFirstOpenRecorded() {
    if (_pref.firstOpenAt != null) return;

    // Existing installs already past onboarding: skip the waiting period so a
    // review can appear on the next eligible open after update.
    if (_pref.hasShownWelcome) {
      _pref.setFirstOpenAt(
        DateTime.now().subtract(const Duration(days: minDaysSinceFirstOpen)),
      );
    } else {
      _pref.setFirstOpenAt(DateTime.now());
    }
  }

  bool _isEligible() {
    if (_pref.lastReviewPromptAt != null) return false;

    final firstOpen = _pref.firstOpenAt;
    if (firstOpen == null) return false;
    if (DateTime.now().difference(firstOpen).inDays < minDaysSinceFirstOpen) {
      return false;
    }

    return true;
  }

  Future<void> maybeRequestReview() async {
    if (_requestInFlight) return;
    if (!_isEligible()) return;

    _requestInFlight = true;
    try {
      // Record the attempt even if the OS suppresses the dialog, so we never
      // ask again from our side.
      _pref.setLastReviewPromptAt(DateTime.now());

      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
        logger.d('Requested in-app review');
      } else {
        logger.d('In-app review unavailable');
      }
    } catch (e, stackTrace) {
      logger.e(
        'Failed to request in-app review',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _requestInFlight = false;
    }
  }

  /// Settings "Rate Nunu" button: native review dialog, or store listing.
  Future<void> openReviewOrStoreListing() async {
    try {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
      } else {
        await _inAppReview.openStoreListing(
          appStoreId: appStoreId,
          microsoftStoreId: isWinStore ? microsoftStoreId : null,
        );
      }
    } catch (e, stackTrace) {
      logger.e(
        'Failed to open review / store listing',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
