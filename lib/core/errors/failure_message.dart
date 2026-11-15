import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'failures.dart';

extension FailureMessage on Failure {
  String message(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return switch (this) {
      NetworkFailure() => l10n.errorNetwork,
      TimeoutFailure() => l10n.errorTimeout,
      ServerFailure(message: final apiMessage) => apiMessage,
      _ => l10n.errorUnknown,
    };
  }
}
