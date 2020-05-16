import 'dart:math';

import 'package:dalk_sdk/sdk.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dalk_sdk/src/store/dalk_store.dart';
import 'package:flutter_dalk_sdk/src/utils/extensions.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:infinite_widgets/infinite_widgets.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';

part 'presentation/actions.dart';
part 'presentation/conversation.dart';
part 'presentation/conversation_list.dart';

/// Base widget to initialize Dalk SDK, it will provide the raw Dalk SDK to the UI components
class DalkChat extends StatelessWidget {
  final DalkSdk client;
  final Widget child;
  final bool _needToSetup;

  /// Creates a new [DalkChat] that allow you to initialize the SDK for UI components.
  ///
  /// [client] is the raw Dalk SDK to use, it should already be initialized and connected
  ///
  /// [child] is the child widget
  const DalkChat.existing(
      {Key key, @required this.client, @required this.child})
      : _needToSetup = false, super(key: key);


  /// Creates a new [DalkChat] that allow you to initialize the SDK for UI components.
  ///
  /// [projectKey] is the Dalk project key to use, you can find it on your dashboard
  ///
  /// [user] is the Dalk User currently connected
  ///
  /// [signature] is used to secure the connection to the chat if you've enable the feature on your dashboard
  ///
  /// [child] is the child widget
  DalkChat({
    Key key,
    @required String projectKey,
    @required this.child,
    @required User user,
    String signature,
  })  : client = DalkSdk(projectKey, user, signature: signature),
        _needToSetup = true,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: client,
      child: ProxyProvider0(
        child: Builder(builder: (context) => child),
        create: (context) => DalkStore(_needToSetup)..changeSdk(client),
        lazy: true,
        update: (BuildContext context, DalkStore previous) {
          final sdk = Provider.of<DalkSdk>(context);
          return previous..changeSdk(sdk);
        },
      ),
    );
  }
}

/// Mixin to allow quick creation of an avatar widget
mixin AvatarBuilder {

  /// Use the avatar of the user if present, or use the first letter of user's name
  /// [user] to use to create the avatar widget
  Widget getAvatar(User user) {
    if (user.avatar == null) {
      return CircleAvatar(
        child: Text(user.name[0].toUpperCase()),
      );
    } else {
      return CircleAvatar(
        backgroundImage: NetworkImage(user.avatar),
        backgroundColor: Colors.transparent,
      );
    }
  }
}
