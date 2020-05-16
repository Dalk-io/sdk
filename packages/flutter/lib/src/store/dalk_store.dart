
import 'dart:async';

import 'package:dalk_sdk/sdk.dart';
import 'package:mobx/mobx.dart';

part 'dalk_store.g.dart';

class DalkStore = _DalkStore with _$DalkStore;


abstract class _DalkStore with Store {
  DalkSdk _client;
  final bool _needToSetup;

  User get me => _client.me;

  @observable
  ObservableFuture<void> conversationsLoadState;

  @observable
  ObservableFuture<void> currentConversationLoadState;

  @observable
  Conversation currentConversation;

  @observable
  ObservableList<Conversation> lastFetchedConversations;

  StreamSubscription _conversationsEventsSubscription;

  _DalkStore(this._needToSetup);

  @action
  void setCurrentConversation(Conversation conversation) {
    currentConversation = conversation;
  }

  @action
  Future<void> setConversationOptions(Conversation conversation, String subject) async {
    await conversation.setOptions(subject: subject);
  }

  @action
  Future<void> getOrCreateConversation(User user, String conversationId) async {
    currentConversation = null;
    currentConversationLoadState = null;
    final conversation = await _client.createOneToOneConversation(user, conversationId: conversationId);
    await _fetchMessages(conversation.id);
  }

  Future<void> setMessageAsSeen(String messageId) async {
    await currentConversation.setMessageAsSeen(messageId);
  }

  @action
  Future<void> changeSdk(DalkSdk sdk) async {
    if(sdk.me == _client?.me) {
      _client = sdk;
    } else {
      lastFetchedConversations = null;
      conversationsLoadState = null;
      currentConversation = null;
      _client = sdk;
    }

    if (_needToSetup) {
      await _client.connect();
    }

    await _conversationsEventsSubscription?.cancel();
    _conversationsEventsSubscription = _client.conversationsEvents.listen((_) async {
        lastFetchedConversations = ObservableList.of(await sdk.getConversations());
    });
  }

  void dispose() {
    _conversationsEventsSubscription?.cancel();
  }

  @action
  Future<void> fetchConversations({bool force = false}) => conversationsLoadState = ObservableFuture(_fetchConversations(force:force));

  @action
  Future<void> fetchMessages(String conversationId) => currentConversationLoadState = ObservableFuture(_fetchMessages(conversationId));

  Future<void> _fetchConversations({bool force = false}) async {
    final result = await _client.getConversations(force: force);
    lastFetchedConversations = ObservableList.of(result);
  }

  Future<Conversation> _fetchMessages(String conversationId) async {
    final result = await _client.getConversation(conversationId);
    currentConversation = result;
    await currentConversation.loadMessages();
    return result;
  }
}
