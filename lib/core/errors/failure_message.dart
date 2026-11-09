import 'package:flutter/material.dart';
import 'package:raff_app/core/errors/failures.dart';
import 'package:raff_app/core/l10n/app_localizations.dart';

extension FailureMessage on Failure {
  String message(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return switch (this) {
      NetworkFailure() => l10n.errorNetwork,
      TimeoutFailure() => l10n.errorTimeout,
      ServerFailure() => l10n.errorServer,
      _ => l10n.errorUnknown,
    };
  }
}
