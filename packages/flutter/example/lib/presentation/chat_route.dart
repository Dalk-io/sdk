import 'package:dalk/stores/dalk_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dalk_sdk/flutter_dalk_sdk.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatelessWidget {
  static const route = '/chat';
  final bool headless;

  const ChatScreen({Key key, this.headless = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final talkStore = Provider.of<DalkStore>(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Observer(
          builder: (context) {
            final conv = talkStore.currentConversation;

            if (conv == null) {
              return Container();
            }

            return Scaffold(
              appBar: headless
                  ? null
                  : AppBar(
                      title: Text(conv == null
                          ? 'Loading'
                          : (conv.isOneToOne ? conv.partner.name : (conv.subject ?? conv.partners.map((user) => user.name).join(', ')))),
                    ),
              primary: !headless,
              body: Observer(builder: (context) => ConversationChat(conversation: talkStore.currentConversation)),
            );
          },
        );
      },
    );
  }

}
