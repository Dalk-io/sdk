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

class DalkChat extends StatelessWidget {
  final DalkSdk client;
  final Widget child;

  const DalkChat({Key key, @required this.client, @required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: client,
      child: ProxyProvider0(
        child: Builder(builder: (context) => child),
        create: (context) => DalkStore()..changeSdk(client),
        lazy: true,
        update: (BuildContext context, DalkStore previous) {
          final sdk = Provider.of<DalkSdk>(context);
          return previous..changeSdk(sdk);
        },
      ),
    );
  }
}

mixin AvatarBuilder {
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
