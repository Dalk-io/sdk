@JS()
/// experimental feature to build dalk.io SDK to JS library
library dalk_sdk_js;

import 'dart:html';

import 'package:dalk_sdk/src/sdk_base.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart';

@JS()
class Promise<T> {
  external Promise(void Function(void Function(T result) resolve, Function reject) executor);

  external Promise then(void Function(T result) onFulfilled, [Function onRejected]);
}

/// for NodeJS but we can't be compatible until https://github.com/dart-lang/web_socket_channel/issues/107
@JS()
external _Exports get exports;

@JS()
class _Exports {}

/// @nodoc
void main() {
  DalkSdk sdk;
  final users = <String, User>{};
  var conversations = <Conversation>[];
  setProperty(window, 'DalkSdkCreate', allowInterop((projectId, user, signature) {
    sdk = DalkSdk(projectId, user, signature: signature);
    return sdk;
  }));

  setProperty(
      window,
      'dalkConnect',
      allowInterop(() => Promise<bool>(allowInterop((resolve, reject) {
            sdk.connect().then(resolve).catchError(reject);
          }))));

  setProperty(
      window,
      'dalkGetConversations',
      allowInterop(() => Promise<List>(allowInterop((resolve, reject) {
            sdk.getConversations().then((data) {
              conversations = data;
              resolve(conversations);
            }).catchError(reject);
          }))));

  setProperty(
      window,
      'dalkGetConversation',
      allowInterop((String convId) => Promise(allowInterop((resolve, reject) {
            sdk.getConversation(convId).then(resolve).catchError(reject);
          }))));

  setProperty(
      window,
      'dalkCreateOneToOneConversation',
      allowInterop((User user, String conversationId) => Promise(allowInterop((resolve, reject) {
            sdk.createOneToOneConversation(user, conversationId: conversationId).then(resolve).catchError(reject);
          }))));

  setProperty(
      window,
      'dalkCreateGroupConversation',
      allowInterop((List<User> users, String conversationId, String subject, String avatar) => Promise(allowInterop((resolve, reject) {
            sdk.createGroupConversation(users, conversationId: conversationId, avatar: avatar, subject: subject).then(resolve).catchError(reject);
          }))));

  setProperty(
      window,
      'dalkDisconnect',
      allowInterop(() => Promise<void>(allowInterop((resolve, reject) {
            sdk.disconnect().then(resolve).catchError(reject);
          }))));

  setProperty(
      window,
      'dalkSendMessage',
      allowInterop((String conversationId, String message, Map<String, dynamic> metadata) => Promise<void>(allowInterop((resolve, reject) {
            conversations.firstWhere((conv) => conv.id == conversationId, orElse: () => null)?.sendMessage(message: message, metadata: metadata)?.then(resolve)?.catchError(reject);
          }))));

  setProperty(
      window,
      'dalkSetMessageAsSeen',
      allowInterop((String conversationId, String messageId) => Promise<void>(allowInterop((resolve, reject) {
            conversations.firstWhere((conv) => conv.id == conversationId, orElse: () => null)?.setMessageAsSeen(messageId)?.then(resolve)?.catchError(reject);
          }))));

  setProperty(
      window,
      'dalkLoadMessages',
      allowInterop((String conversationId, String messageId) => Promise<void>(allowInterop((resolve, reject) {
            final conv = conversations.firstWhere((conv) => conv.id == conversationId, orElse: () => null);
            conv?.loadMessages()?.then((_) => resolve(conv.messages))?.catchError(reject);
          }))));

  setProperty(
      window,
      'dalkSetOptions',
      allowInterop((String conversationId, String subject, String avatar) => Promise<void>(allowInterop((resolve, reject) {
            final conv = conversations.firstWhere((conv) => conv.id == conversationId, orElse: () => null);
            conv?.setOptions(subject: subject, avatar: avatar)?.then(resolve)?.catchError(reject);
          }))));

  setProperty(window, 'DalkUser', allowInterop((id, name, avatar) {
    users[id] = User(id: id, name: name, avatar: avatar);
    return users[id];
  }));
}
