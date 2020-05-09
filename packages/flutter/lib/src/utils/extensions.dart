import 'package:dalk_sdk/sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dalk_sdk/src/utils/localization.dart';

extension ConversationExtension on Conversation {
  String get title {
    if (isOneToOne) {
      return partner.name;
    }
    if (subject == null) {
      return partners.map((item) => item.name).join(', ');
    }
    return subject;
  }
}

extension BuildContextExtension on BuildContext {
  /// shortcut to get theme data
  ThemeData get theme => Theme.of(this);

  /// shortcut to get textTheme
  TextTheme get textTheme => theme.textTheme;

  /// shortcut to localization
  DalkLocalization get dalkLocalization => DalkLocalization.of(this);
}
