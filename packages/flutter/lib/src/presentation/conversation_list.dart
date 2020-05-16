part of '../flutter_dalk_sdk.dart';

/// Callback when on conversation is tapped, it receive a [Conversation] object
///
/// See also:
/// * [Conversation] to know useful stuff about conversation
typedef OnConversationTap = void Function(Conversation conversation);

/// Widget to show the list of conversation of the connected user
///
/// See also:
/// * [User] instance of the connected user
class ConversationListView extends HookWidget {
  final OnConversationTap onTap;

  /// Creates a new [ConversationListView] that allow to see list of user conversations
  ///
  /// [onTap] is the callback called when a conversation is tapped
  ///
  /// See also:
  /// * [Conversation] to know useful stuff about conversation
  /// * [OnConversationTap] signature of the [onTap] callback
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
                key: ValueKey(conv.id),
                conversation: conv,
                onTap: onTap,
              )
                  : GroupListTile(
                key: ValueKey(conv.id),
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
          onRefresh: () => store.fetchConversations(force: true),
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

/// Widget to show the one to one conversation summary
///
/// See also:
/// * [GroupListTile] equivalent of this widget but for group conversation
/// * [Conversation] to know useful stuff about conversation
class OneToOneListTile extends StatelessWidget with AvatarBuilder, _ConversationListTile {
  final Conversation conversation;
  final bool isSelected;
  final OnConversationTap onTap;

  /// Create a new [OneToOneListTile] to show the group conversation summary
  ///
  /// [conversation] to take information from
  ///
  /// [isSelected] default to false, on responsive layout you might want to highlight the selected conversation
  ///
  /// [onTap] is the callback called when a conversation is tapped
  ///
  /// See also:
  /// * [GroupListTile] equivalent of this widget but for group conversation
  /// * [Conversation] to know useful stuff about conversation
  /// * [OnConversationTap] signature of the [onTap] callback
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

/// Widget to show the group conversation summary
///
/// See also:
/// * [OneToOneListTile] equivalent of this widget but for one to one conversation
/// * [Conversation] to know useful stuff about conversation
class GroupListTile extends StatelessWidget with _ConversationListTile {
  final Conversation conversation;
  final bool isSelected;
  final OnConversationTap onTap;

  /// Create a new [GroupListTile] to show the group conversation summary
  ///
  /// [conversation] to take information from
  ///
  /// [isSelected] default to false, on responsive layout you might want to highlight the selected conversation
  ///
  /// [onTap] is the callback called when a conversation is tapped
  ///
  /// See also:
  /// * [OneToOneListTile] equivalent of this widget but for one to one conversation
  /// * [Conversation] to know useful stuff about conversation
  /// * [OnConversationTap] signature of the [onTap] callback
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
