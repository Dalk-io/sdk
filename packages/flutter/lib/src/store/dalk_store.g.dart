// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dalk_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$DalkStore on _DalkStore, Store {
  final _$conversationsLoadStateAtom =
      Atom(name: '_DalkStore.conversationsLoadState');

  @override
  ObservableFuture<void> get conversationsLoadState {
    _$conversationsLoadStateAtom.context
        .enforceReadPolicy(_$conversationsLoadStateAtom);
    _$conversationsLoadStateAtom.reportObserved();
    return super.conversationsLoadState;
  }

  @override
  set conversationsLoadState(ObservableFuture<void> value) {
    _$conversationsLoadStateAtom.context.conditionallyRunInAction(() {
      super.conversationsLoadState = value;
      _$conversationsLoadStateAtom.reportChanged();
    }, _$conversationsLoadStateAtom,
        name: '${_$conversationsLoadStateAtom.name}_set');
  }

  final _$currentConversationLoadStateAtom =
      Atom(name: '_DalkStore.currentConversationLoadState');

  @override
  ObservableFuture<void> get currentConversationLoadState {
    _$currentConversationLoadStateAtom.context
        .enforceReadPolicy(_$currentConversationLoadStateAtom);
    _$currentConversationLoadStateAtom.reportObserved();
    return super.currentConversationLoadState;
  }

  @override
  set currentConversationLoadState(ObservableFuture<void> value) {
    _$currentConversationLoadStateAtom.context.conditionallyRunInAction(() {
      super.currentConversationLoadState = value;
      _$currentConversationLoadStateAtom.reportChanged();
    }, _$currentConversationLoadStateAtom,
        name: '${_$currentConversationLoadStateAtom.name}_set');
  }

  final _$currentConversationAtom =
      Atom(name: '_DalkStore.currentConversation');

  @override
  Conversation get currentConversation {
    _$currentConversationAtom.context
        .enforceReadPolicy(_$currentConversationAtom);
    _$currentConversationAtom.reportObserved();
    return super.currentConversation;
  }

  @override
  set currentConversation(Conversation value) {
    _$currentConversationAtom.context.conditionallyRunInAction(() {
      super.currentConversation = value;
      _$currentConversationAtom.reportChanged();
    }, _$currentConversationAtom,
        name: '${_$currentConversationAtom.name}_set');
  }

  final _$lastFetchedConversationsAtom =
      Atom(name: '_DalkStore.lastFetchedConversations');

  @override
  ObservableList<Conversation> get lastFetchedConversations {
    _$lastFetchedConversationsAtom.context
        .enforceReadPolicy(_$lastFetchedConversationsAtom);
    _$lastFetchedConversationsAtom.reportObserved();
    return super.lastFetchedConversations;
  }

  @override
  set lastFetchedConversations(ObservableList<Conversation> value) {
    _$lastFetchedConversationsAtom.context.conditionallyRunInAction(() {
      super.lastFetchedConversations = value;
      _$lastFetchedConversationsAtom.reportChanged();
    }, _$lastFetchedConversationsAtom,
        name: '${_$lastFetchedConversationsAtom.name}_set');
  }

  final _$setConversationOptionsAsyncAction =
      AsyncAction('setConversationOptions');

  @override
  Future<void> setConversationOptions(
      Conversation conversation, String subject) {
    return _$setConversationOptionsAsyncAction
        .run(() => super.setConversationOptions(conversation, subject));
  }

  final _$_DalkStoreActionController = ActionController(name: '_DalkStore');

  @override
  void setCurrentConversation(Conversation conversation) {
    final _$actionInfo = _$_DalkStoreActionController.startAction();
    try {
      return super.setCurrentConversation(conversation);
    } finally {
      _$_DalkStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void changeSdk(DalkSdk sdk) {
    final _$actionInfo = _$_DalkStoreActionController.startAction();
    try {
      return super.changeSdk(sdk);
    } finally {
      _$_DalkStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  Future<void> fetchConversations({bool force = false}) {
    final _$actionInfo = _$_DalkStoreActionController.startAction();
    try {
      return super.fetchConversations(force: force);
    } finally {
      _$_DalkStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  Future<void> fetchMessages(String conversationId) {
    final _$actionInfo = _$_DalkStoreActionController.startAction();
    try {
      return super.fetchMessages(conversationId);
    } finally {
      _$_DalkStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    final string =
        'conversationsLoadState: ${conversationsLoadState.toString()},currentConversationLoadState: ${currentConversationLoadState.toString()},currentConversation: ${currentConversation.toString()},lastFetchedConversations: ${lastFetchedConversations.toString()}';
    return '{$string}';
  }
}
