part of '../flutter_dalk_sdk.dart';

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
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(context.dalkLocalization?.anErrorOccurred ?? store.conversationsLoadState.error.toString()),
                  RaisedButton(
                    onPressed: () {
                      store.conversationsLoadState = null;
                      store.fetchConversations();
                    },
                    child: Text(context.dalkLocalization?.retryButton ?? 'Retry'),
                  ),
                ],
              ),
            ),
          );
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

mixin _ConversationListTile {
  Widget getSubtitle(Conversation conversation) {
    return conversation.messages.isEmpty
        ? null
        : StreamBuilder(
      stream: conversation.onMessagesEvent,
      builder: (context, snapshot) {
        final message = conversation.messages.last;
        return Text(
          message.text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontWeight:
              (message.senderId != conversation.currentUser.id && message.status != MessageStatus.seen) ? FontWeight.bold : FontWeight.normal),
        );
      },
    );
  }
}

class OneToOneListTile extends StatelessWidget with AvatarBuilder, _ConversationListTile {
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
      subtitle: getSubtitle(conversation),
      onTap: () {
        onTap(conversation);
      },
    );
  }
}

class GroupListTile extends StatelessWidget with _ConversationListTile {
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
      subtitle: getSubtitle(conversation),
      onTap: () {
        onTap(conversation);
      },
    );
  }
}
