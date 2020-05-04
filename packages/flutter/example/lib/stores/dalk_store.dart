import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:dalk/app.dart';
import 'package:dalk/remote_config/remote_config_interface.dart';
import 'package:dalk_sdk/sdk.dart';
import 'package:mobx/mobx.dart';

part 'dalk_store.g.dart';

class DalkStore = _DalkStore with _$DalkStore;

abstract class _DalkStore with Store {
  @observable
  DalkSdk dalkSdk;
  @observable
  User me;
  @observable
  ObservableList<User> users = ObservableList.of([]);
  @observable
  ObservableList<User> selectedUsersForGroup = ObservableList.of([]);
  @observable
  Conversation currentConversation;
  StreamSubscription _firestoreSubscription;

  @action
  void selectUserForGroup(User user) {
    if (selectedUsersForGroup.contains(user)) {
      selectedUsersForGroup.remove(user);
    } else {
      selectedUsersForGroup.add(user);
    }
  }

  @action
  Future<void> createGroupConversation() async {
    currentConversation = await dalkSdk.createGroupConversation(selectedUsersForGroup);
    selectedUsersForGroup.clear();
  }

  @action
  Future<void> setup(String id, String name, String avatar) async {
    me = User(id: id, name: name ?? 'User$id', avatar: avatar);
    await dalkSdk?.disconnect();

    final remoteConfig = await FirebaseRemoteConfigPlatformInterface.getInstance();
    if (remoteConfig != null) {
      await remoteConfig.fetch(expiration: Duration(seconds: 10));
      await remoteConfig.activateFetched();

      final prefix = Flavor.current.prefix;

      final secret = remoteConfig.getString('${prefix}projectSecret');
      final _signature = sha512.convert(utf8.encode('$id$secret')).toString();

      if (secret == null) {
        throw Exception('remote config not setup');
      }

      dalkSdk = DalkSdk(remoteConfig.getString('${prefix}projectId'), me, signature: _signature);
      if (Flavor.current.env == Env.staging) {
        dalkSdk.enableStagingMode();
      }
      if (Flavor.current.env == Env.dev) {
        dalkSdk.enableDevMode();
      }
      users.add(me);

      _firestoreSubscription = Firestore.instance.collection('users').snapshots().listen(
        (data) {
          users.clear();
          users.addAll(data.documents.map((user) {
            return User(id: user['id'], name: user['name'], avatar: user['avatar']);
          }));
        },
        onError: print
      );
      await dalkSdk.connect();
    }
  }

  @action
  Future<void> logout() async {
    await dalkSdk.disconnect();
    me = null;
    currentConversation = null;
  }

  @action
  Future<void> createConversation(User user) async {
    currentConversation = await dalkSdk.createOneToOneConversation(user);
  }

  @action
  Future<void> loadConversation(String convId) async {
    currentConversation = null;
    final conv = await dalkSdk.getConversation(convId);
    await conv?.loadMessages(); //currentConversation may be null if it doesn't exist backend side
    currentConversation = conv;
  }

  void dispose() {
    _firestoreSubscription.cancel();
  }
}
