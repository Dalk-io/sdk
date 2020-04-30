// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dalk_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$DalkStore on _DalkStore, Store {
  final _$dalkSdkAtom = Atom(name: '_DalkStore.dalkSdk');

  @override
  DalkSdk get dalkSdk {
    _$dalkSdkAtom.context.enforceReadPolicy(_$dalkSdkAtom);
    _$dalkSdkAtom.reportObserved();
    return super.dalkSdk;
  }

  @override
  set dalkSdk(DalkSdk value) {
    _$dalkSdkAtom.context.conditionallyRunInAction(() {
      super.dalkSdk = value;
      _$dalkSdkAtom.reportChanged();
    }, _$dalkSdkAtom, name: '${_$dalkSdkAtom.name}_set');
  }

  final _$meAtom = Atom(name: '_DalkStore.me');

  @override
  User get me {
    _$meAtom.context.enforceReadPolicy(_$meAtom);
    _$meAtom.reportObserved();
    return super.me;
  }

  @override
  set me(User value) {
    _$meAtom.context.conditionallyRunInAction(() {
      super.me = value;
      _$meAtom.reportChanged();
    }, _$meAtom, name: '${_$meAtom.name}_set');
  }

  final _$usersAtom = Atom(name: '_DalkStore.users');

  @override
  ObservableList<User> get users {
    _$usersAtom.context.enforceReadPolicy(_$usersAtom);
    _$usersAtom.reportObserved();
    return super.users;
  }

  @override
  set users(ObservableList<User> value) {
    _$usersAtom.context.conditionallyRunInAction(() {
      super.users = value;
      _$usersAtom.reportChanged();
    }, _$usersAtom, name: '${_$usersAtom.name}_set');
  }

  final _$selectedUsersForGroupAtom =
      Atom(name: '_DalkStore.selectedUsersForGroup');

  @override
  ObservableList<User> get selectedUsersForGroup {
    _$selectedUsersForGroupAtom.context
        .enforceReadPolicy(_$selectedUsersForGroupAtom);
    _$selectedUsersForGroupAtom.reportObserved();
    return super.selectedUsersForGroup;
  }

  @override
  set selectedUsersForGroup(ObservableList<User> value) {
    _$selectedUsersForGroupAtom.context.conditionallyRunInAction(() {
      super.selectedUsersForGroup = value;
      _$selectedUsersForGroupAtom.reportChanged();
    }, _$selectedUsersForGroupAtom,
        name: '${_$selectedUsersForGroupAtom.name}_set');
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

  final _$createGroupConversationAsyncAction =
      AsyncAction('createGroupConversation');

  @override
  Future<void> createGroupConversation() {
    return _$createGroupConversationAsyncAction
        .run(() => super.createGroupConversation());
  }

  final _$setupAsyncAction = AsyncAction('setup');

  @override
  Future<void> setup(String id, String name, String avatar) {
    return _$setupAsyncAction.run(() => super.setup(id, name, avatar));
  }

  final _$logoutAsyncAction = AsyncAction('logout');

  @override
  Future<void> logout() {
    return _$logoutAsyncAction.run(() => super.logout());
  }

  final _$createConversationAsyncAction = AsyncAction('createConversation');

  @override
  Future<void> createConversation(User user) {
    return _$createConversationAsyncAction
        .run(() => super.createConversation(user));
  }

  final _$loadConversationAsyncAction = AsyncAction('loadConversation');

  @override
  Future<void> loadConversation(String convId) {
    return _$loadConversationAsyncAction
        .run(() => super.loadConversation(convId));
  }

  final _$_DalkStoreActionController = ActionController(name: '_DalkStore');

  @override
  void selectUserForGroup(User user) {
    final _$actionInfo = _$_DalkStoreActionController.startAction();
    try {
      return super.selectUserForGroup(user);
    } finally {
      _$_DalkStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    final string =
        'dalkSdk: ${dalkSdk.toString()},me: ${me.toString()},users: ${users.toString()},selectedUsersForGroup: ${selectedUsersForGroup.toString()},currentConversation: ${currentConversation.toString()}';
    return '{$string}';
  }
}
