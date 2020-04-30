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

typedef OnConversationTap = void Function(Conversation conversation);

class ConversationListView extends HookWidget {
  final OnConversationTap onTap;

  const ConversationListView({Key key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<DalkStore>(context);

    useEffect(() {
      store.fetchConversations();
      return null;
    }, const []);

    return Observer(
      builder: (context) {
        if (store.conversationsLoadState == null || store.lastFetchedConversations == null && store.conversationsLoadState.status == FutureStatus.pending) {
          return Center(child: CircularProgressIndicator());
        }

        if (store.conversationsLoadState.status == FutureStatus.rejected) {
          return Center(child: Text(store.conversationsLoadState.error.toString()));
        }

        return RefreshIndicator(
          child: InfiniteListView.separated(
            physics: AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final conv = store.lastFetchedConversations[index];
              return conv.isOneToOne
                  ? OneToOneListTile(
                      conversation: conv,
                      onTap: onTap,
                    )
                  : GroupListTile(
                      conversation: conv,
                      onTap: onTap,
                    );
            },
            nextData: () {
              //load next data page
            },
            itemCount: store.lastFetchedConversations.length,
            hasNext: false,
            separatorBuilder: (context, index) => Divider(height: 1),
          ),
          onRefresh: () => store.fetchConversations(),
        );
      },
    );
  }
}

class OneToOneListTile extends StatelessWidget with AvatarBuilder {
  final Conversation conversation;
  final bool isSelected;
  final void Function(Conversation conversation) onTap;

  const OneToOneListTile({Key key, @required this.conversation, @required this.onTap, this.isSelected = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: isSelected,
      leading: getAvatar(conversation.partner),
      title: Text(conversation.title),
      onTap: () {
        onTap(conversation);
      },
    );
  }
}

class GroupListTile extends StatelessWidget {
  final Conversation conversation;
  final bool isSelected;
  final void Function(Conversation conversation) onTap;

  const GroupListTile({Key key, @required this.conversation, @required this.onTap, this.isSelected = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: isSelected,
      leading: conversation.avatar == null
          ? CircleAvatar(backgroundColor: context.theme.primaryColor, child: Icon(Icons.group))
          : CircleAvatar(
              child: Image.network(conversation.avatar),
            ),
      title: Text(conversation.title),
      onTap: () {
        onTap(conversation);
      },
    );
  }
}

class ConversationChat extends HookWidget with AvatarBuilder {
  final Conversation conversation;

  const ConversationChat({Key key, @required this.conversation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<DalkStore>(context);

    useEffect(() {
      store.setCurrentConversation(conversation);
      return null;
    }, [conversation]);

    return StreamBuilder<void>(
      stream: conversation.onMessagesEvent,
      builder: (context, snapshot) {
        return DashChat(
          inverted: false,
          sendOnEnter: true,
          textInputAction: TextInputAction.send,
          onSend: (text) => conversation.sendMessage(message: text.text),
          avatarBuilder: (chatUser) => getAvatar(User(id: chatUser.uid, name: chatUser.name, avatar: chatUser.avatar)),
          user: ChatUser(uid: store.me.id, name: store.me.name),
          messageTimeBuilder: (time, [message]) {
            final chatMessage = message as DalkChatMessage;
            return ChatTimeContainer(time: time, message: chatMessage);
          },
          messages: conversation.messages.map((message) {
            final status = message.status;
            return DalkChatMessage(
              text: message.text,
              createdAt: message.createdAt,
              id: message.id,
              status: status,
              user: _getChatUser(conversation.users.firstWhere((user) => message.senderId == user.id)),
            );
          }).toList(growable: false),
        );
      },
    );
  }

  ChatUser _getChatUser(User user) {
    return ChatUser(uid: user.id, name: user.name, avatar: user.avatar);
  }
}

class DalkChatMessage extends ChatMessage {
  final MessageStatus status;

  DalkChatMessage({
    String id,
    @required String text,
    @required ChatUser user,
    String image,
    String video,
    DateTime createdAt,
    this.status,
  }) : super(
    id: id,
    text: text,
    user: user,
    image: image,
    video: video,
    createdAt: createdAt,
  );
}

class ChatTimeContainer extends HookWidget {
  final DalkChatMessage message;
  final String time;

  const ChatTimeContainer({Key key, this.message, this.time}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final talkStore = Provider.of<DalkStore>(context);
    useEffect(() {
      talkStore.setMessageAsSeen(message.id);
      return null;
    }, const []);

    return Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(time, style: Theme.of(context).textTheme.caption),
              if (message.user.uid == talkStore.me.id) Container(width: 10),
              if (message.user.uid == talkStore.me.id)
                SizedBox(
                  width: 10,
                  height: 10,
                  child: _getStatus(),
                )
            ],
          ),
        );
  }

  Widget _getStatus() {
    switch (message.status) {
      case MessageStatus.ongoing:
        return CircularProgressIndicator(backgroundColor: Colors.grey);
      case MessageStatus.sent:
        return Icon(Icons.done, color: Colors.black45, size: 15);
      case MessageStatus.received:
        return Icon(Icons.done_all, color: Colors.black45, size: 15);
      case MessageStatus.seen:
        return Icon(Icons.done_all, color: Colors.white, size: 15);
      case MessageStatus.error:
        return Icon(Icons.error_outline, color: Colors.redAccent, size: 15);
    }

    return Container();
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
