part of '../flutter_dalk_sdk.dart';

class ConversationChat extends HookWidget with AvatarBuilder {
  final Conversation conversation;
  final double width;
  final double height;

  const ConversationChat({Key key, @required this.conversation, this.width, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<DalkStore>(context);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        store.setCurrentConversation(conversation);
      });
      return null;
    }, [conversation]);

    return StreamBuilder<void>(
      stream: conversation.onMessagesEvent,
      builder: (context, snapshot) {
        return DashChat(
          inverted: false,
          sendOnEnter: true,
          width: width,
          height: height,
          textInputAction: TextInputAction.send,
          onSend: (text) => conversation.sendMessage(message: text.text),
          avatarBuilder: (chatUser) => getAvatar(User(id: chatUser.uid, name: chatUser.name, avatar: chatUser.avatar)),
          user: ChatUser(uid: store.me.id, name: store.me.name),
          messageTimeBuilder: (time, [message]) {
            final chatMessage = message as _DalkChatMessage;
            return _ChatTimeContainer(time: time, message: chatMessage);
          },
          messages: conversation.messages.map((message) {
            final status = message.status;
            return _DalkChatMessage(
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

class _DalkChatMessage extends ChatMessage {
  final MessageStatus status;

  _DalkChatMessage({
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

class _ChatTimeContainer extends HookWidget {
  final _DalkChatMessage message;
  final String time;

  const _ChatTimeContainer({Key key, this.message, this.time}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final talkStore = Provider.of<DalkStore>(context);
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        talkStore.setMessageAsSeen(message.id);
      });
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
