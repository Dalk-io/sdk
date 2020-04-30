
import 'dart:async';

import 'package:dalk_sdk/sdk.dart';
import 'package:mobx/mobx.dart';

part 'dalk_store.g.dart';

class DalkStore = _DalkStore with _$DalkStore;


abstract class _DalkStore with Store {
  DalkSdk _client;

  User get me => _client.me;

  @observable
  ObservableFuture<void> conversationsLoadState;

  @observable
  ObservableFuture<void> currentConversationLoadState;

  @observable
  Conversation currentConversation;

  @observable
  ObservableList<Conversation> lastFetchedConversations;

  StreamSubscription _newConversationSubscription;

  _DalkStore();

  @action
  void setCurrentConversation(Conversation conversation) {
    currentConversation = conversation;
  }

  @action
  Future<void> setConversationOptions(Conversation conversation, String subject) async {
    await conversation.setOptions(subject: subject);
  }

  Future<void> setMessageAsSeen(String messageId) async {
    await currentConversation.setMessageAsSeen(messageId);
  }

  @action
  void changeSdk(DalkSdk sdk) {
    if(sdk.me == _client?.me) {
      _client = sdk;
    } else {
      lastFetchedConversations = null;
      conversationsLoadState = null;
      currentConversation = null;
      _client = sdk;
    }
    _newConversationSubscription?.cancel();
    _newConversationSubscription = _client.newConversation.listen((conversation) {
      if (lastFetchedConversations == null) {
        lastFetchedConversations = ObservableList.of([conversation]);
      } else if (lastFetchedConversations.firstWhere((conv) => conv.id == conversation.id, orElse: () => null) == null) {
        lastFetchedConversations.add(conversation);
      }
    });
  }

  void dispose() {
    _newConversationSubscription?.cancel();
  }

  @action
  Future<void> fetchConversations() => conversationsLoadState = ObservableFuture(_fetchConversations());

  @action
  Future<void> fetchMessages(String conversationId) => currentConversationLoadState = ObservableFuture(_fetchMessages(conversationId));

  Future<void> _fetchConversations() async {
    final result = await _client.getConversations();
    lastFetchedConversations = ObservableList.of(result);
  }

  Future<Conversation> _fetchMessages(String conversationId) async {
    final result = await _client.getConversation(conversationId);
    currentConversation = result;
    return result;
  }
}
