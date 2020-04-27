import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'conversation.dart';
part 'sdk_base.freezed.dart';

/// User object representation
class User {
  /// identifier of the user
  final String id;

  /// name of the user
  final String name;

  /// avatar of the user as URL
  final String avatar;

  User({
    @required this.id,
    @required this.name,
    this.avatar,
  });

  factory User._fromBackend(Map<String, dynamic> data) {
    return User(
      id: data['id'],
      name: data['name'] ?? 'unknown',
      avatar: data['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is User && runtimeType == other.runtimeType && id == other.id && name == other.name && avatar == other.avatar;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ avatar.hashCode;

  @override
  String toString() {
    return 'User{id: $id, name: $name, avatar: $avatar}';
  }
}

/// Dalk Sdk class that allow you to manage a chat for a user.
class DalkSdk {
  /// Project id on your Dalk account, check it to get it
  final String projectId;

  /// [User] representing the current connected chat user
  final User me;

  /// Signature to use to secure the connection
  /// If you have enable this feature on your dashboard it is mandatory
  /// to provide a signature to allow connection to the chat
  /// {@tool snippet}
  ///
  /// For example to generate a signature in dart :
  ///
  /// ```dart
  /// final me = User(id: 'myUserId', name: 'Name');
  /// final userId = me.id;
  /// final secret = 'MY_CUSTOM_SECRET'; // can be found on your dashboard, shouldn't be share/put in public/distributed code!
  /// final signature = sha512.convert(utf8.encode('$userId$secret}')).toString();
  /// _talkSdk = DalkSdk('MY_PROJECT_ID', me, signature: signature);
  /// ```
  /// {@end-tool}
  final String signature;

  final Map<String, User> _usersCache = {};
  final Map<String, Conversation> _conversations = {};
  bool _isDevMode = false;
  bool _isMocked = false;
  int _connectionRetries = 0;
  final int _maxConnectionRetries = 20;
  bool _shouldReconnect = true;
  final Logger _logger = Logger('DalkSdk');
  final StreamController<Conversation> _newConversation = StreamController.broadcast();
  Peer _peer;

  /// [Stream] of new [Conversation] to be alerted when a new one is available
  Stream<Conversation> get newConversation => _newConversation.stream;

  /// Creates a new [DalkSdk] that allow you to manage a chat for a user.
  ///
  /// The [projectId] is used to setup the sdk for your account, if you don't have one please check https://dalk.io. Can't be null.
  ///
  /// [me] represent the current user of the chat, can't be null.
  ///
  /// [signature] is used to secure the connection to the chat if you've enable the feature on your dashboard
  DalkSdk(this.projectId, this.me, {this.signature}) {
    _usersCache[me.id] = me;
  }

  /// @nodoc
  @visibleForTesting
  void mock(Peer peer) {
    _peer = peer;
    _shouldReconnect = false;
    _isMocked = true;
  }

  /// @nodoc
  void enableDevMode() {
    _isDevMode = true;
  }

  Future<void> _connectAndReconnect() {
    final completer = Completer();
    final retry = () {
      if (_shouldReconnect && completer.isCompleted && _connectionRetries <= _maxConnectionRetries) {
        _logger.warning('reconnect peer');
        _connectionRetries++;
        Timer(Duration(seconds: _connectionRetries * 1), connect);
      }
    };

    _peer.listen().then((value) => retry()).catchError((err, stack) {
      retry();
      if (!completer.isCompleted) {
        _logger.severe('Can\'t connect to server with $err', err, stack);
        if (err is WebSocketChannelException && err.message.contains('was not upgraded to websocket')) {
          completer.completeError(DalkSdkException._('WRONG_PROJECT_ID', 'project id doesn\'t look good, please check on your dashboard'));
        } else {
          completer.completeError(ServerException._('500', 'error when calling the server', err));
        }
      }
    });

    //let's assume connexion is ok as we don't have any errors
    Timer(Duration(milliseconds: 500), () {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    return completer.future;
  }

  /// Disconnect from the server, you'll not receive anymore events
  /// and will not be able to retrieve/send chat objects
  Future<void> disconnect() {
    _shouldReconnect = false;
    return (_peer?.isClosed ?? true) ? Future.value(null) : _peer?.close()?.catchError((err) {});
  }

  Future<void> _connect() async {
    if (!_isMocked) {
      final scheme = _isDevMode ? 'ws' : 'wss';
      final host = _isDevMode ? 'dev.api.dalk.io' : 'api.dalk.io';
      final port = _isDevMode ? 443 : null;

      final uri = Uri(
        scheme: scheme,
        host: host,
        port: port,
        path: '/v1/projects/$projectId/ws',
      );
      _logger.info(uri);
      _peer = Peer(WebSocketChannel.connect(uri).cast<String>(), onUnhandledError: (err, stack) {
        _logger.severe('onUnhandledError $err', err, stack);
      });
    }

    _peer.registerFallback((parameters) {
      _logger.info('fallback ignored: ${parameters.value}');
    });

    await _connectAndReconnect();

    await _peer.sendRequest('registerUser', {
      'id': me.id,
      'name': me.name,
      'avatar': me.avatar,
      if (signature != null) 'signature': signature,
    });
    _logger.info('registerUser success');

    _peer.registerMethod('onConversationCreated', (parameters) async {
      final conv = parameters.value;
      _logger.info('onConversationCreated ${parameters.value}');
      final conversation = await _createConversationFromData(conv);
      _newConversation.add(conversation);
    });

    _conversations.values.forEach((conv) {
      (conv as _ConversationImpl)._resetPeer(_peer);
      _registerMethodForConversation(conv.id);
    });
  }

  /// Connect the SDK to the server to start receiving realtime event and declare the current user ([me]) online
  ///
  Future<void> connect() async {
    await disconnect();
    if (!_isMocked) {
      _connectionRetries = 0;
      _shouldReconnect = true;
    }
    await _connect();
  }

  void _registerMethodForConversation(String id) {
    try {
      _peer.registerMethod('receiveMessage$id', _forwardIncomingMessage);
    } catch (ex) {
      //method already registered, ignore error
    }
    try {
      _peer.registerMethod('updateMessageStatus$id', _forwardMessageUpdate);
    } catch (ex) {
      //method already registered, ignore error
    }
  }

  void _forwardMessageUpdate(Parameters parameters) {
    _logger.info('updateMessageStatus ${parameters.value}');
    (_conversations[parameters.method.replaceAll('updateMessageStatus', '')] as _ConversationImpl)?._messageUpdate(parameters.value);
  }

  void _forwardIncomingMessage(Parameters parameters) {
    _logger.info('receiveMessage ${parameters.value}');
    (_conversations[parameters.method.replaceAll('receiveMessage', '')] as _ConversationImpl)?._incomingMessage(parameters.value);
  }

  Future<Conversation> _createConversationFromData(Map conv) async {
    final messages = (conv['messages'] as List ?? []).map((message) => _Message.fromBackend(message)).cast<Message>().toList();
    final conversation = _ConversationImpl._(
      id: conv['id'],
      subject: conv['subject'],
      avatar: conv['avatar'],
      messages: messages,
      isGroup: conv['isGroup'] ?? false,
      logger: _logger,
      users: conv['users'].cast<Map<String, dynamic>>().map((data) => User._fromBackend(data)).toList().cast<User>(),
      admins: conv['admins']?.cast<Map<String, dynamic>>()?.map((data) => User._fromBackend(data))?.toList()?.cast<User>(),
      currentUser: me,
      peer: _peer,
    );
    _conversations[conversation.id] = conversation;
    _registerMethodForConversation(conversation.id);
    return conversation;
  }

  /// Create a one to one conversation between [me] and the given [User]
  ///
  /// [user] [User] to talk to
  ///
  /// [conversationId] optional custom conversation id
  ///
  /// Returns the created [Conversation]
  ///
  /// Throws [ServerException] if something went wrong server side
  ///
  /// Throws [ConnectionClosedException] if sdk is no more connected to the server
  ///
  /// See also:
  /// * [createGroupConversation] to create group conversations
  /// * [User] dalk sdk user object representation
  /// * [Conversation]  dalk sdk conversation object representation
  /// * [ServerException]  dalk server exception
  Future<Conversation> createOneToOneConversation(User user, {String conversationId}) async {
    if (_peer.isClosed) {
      throw ConnectionClosedException._();
    }
    _usersCache[user.id] = user;
    try {
      final result = await _peer.sendRequest('getOrCreateConversation', {
        'id': conversationId ?? '${me.id}${user.id}',
        'users': [user.toJson()],
        'isGroup': false,
      });
      _logger.info('createConversation result $result');
      return await _createConversationFromData(result);
    } on RpcException catch (ex, stack) {
      _logger.severe('$ex', ex, stack);
      throw ServerException._('SERVER_ERROR_${ex.code}', ex.message, ex.data);
    }
  }

  /// Create a group conversation between [me] and the given users ([User])
  ///
  /// [users] list of [User] to talk to
  ///
  /// [conversationId] optional custom conversation id
  ///
  /// [subject] optional custom subject of the conversation
  ///
  /// [avatar] optional custom avatar as URL of the conversation
  ///
  /// Returns the created [Conversation]
  ///
  /// Throws [ServerException] if something went wrong server side
  ///
  /// Throws [ConnectionClosedException] if sdk is no more connected to the server
  ///
  /// See also:
  /// * [createOneToOneConversation] to create one to one conversation
  /// * [User] dalk sdk user object representation
  /// * [Conversation]  dalk sdk conversation object representation
  Future<Conversation> createGroupConversation(
    List<User> users, {
    String conversationId,
    String subject,
    String avatar,
  }) async {
    if (_peer.isClosed) {
      throw ConnectionClosedException._();
    }
    users.forEach((user) => _usersCache[user.id] = user);
    try {
      final result = await _peer.sendRequest('getOrCreateConversation', {
        'id': conversationId ?? users.map((user) => user.id).join(),
        'users': users.map((user) => user.toJson()).toList(),
        if (subject != null) 'subject': subject,
        if (avatar != null) 'avatar': avatar,
        'isGroup': true,
      });
      _logger.info('createConversation result $result');
      return await _createConversationFromData(result);
    } on RpcException catch (ex, stack) {
      _logger.severe('$ex', ex, stack);
      throw ServerException._('SERVER_ERROR_${ex.code}', ex.message, ex.data);
    }
  }

  /// Returns the list of [Conversation] of the current user ([me])
  ///
  /// Throws [ServerException] if something went wrong server side
  ///
  /// Throws [ConnectionClosedException] if sdk is no more connected to the server
  ///
  /// See also:
  /// * [Conversation]  dalk sdk conversation object representation
  Future<List<Conversation>> getConversations() async {
    if (_peer.isClosed) {
      throw ConnectionClosedException._();
    }
    try {
      final result = await _peer.sendRequest('getConversations');
      _logger.info('getConversations result $result');

      for (var conv in result) {
        final conversation = await _createConversationFromData(conv);
        if (_conversations[conversation.id] == null) {
          _conversations[conversation.id] = conversation;
        } else {
          (_conversations[conversation.id] as _ConversationImpl)._updateFrom(conversation);
        }
      }

      final sortedList = _conversations.values.toList(growable: false);
      sortedList.sort((conv1, conv2) {
        if (conv1.messages.isEmpty || conv2.messages.isEmpty) {
          return 1;
        }
        return conv2.messages.last.createdAt.compareTo(conv1.messages.last.createdAt);
      });
      return sortedList;
    } on RpcException catch (ex, stack) {
      _logger.severe('$ex', ex, stack);
      throw ServerException._('SERVER_ERROR_${ex.code}', ex.message, ex.data);
    }
  }

  /// Retrieves a single [Conversation] by his id
  ///
  /// Returns the wanted [Conversation] or null if the conversation
  ///
  /// Throws [ServerException] if something went wrong server side
  ///
  /// Throws [ConnectionClosedException] if sdk is no more connected to the server
  ///
  /// [conversationId] conversation id to retrieve
  Future<Conversation> getConversation(String conversationId) async {
    if (_peer.isClosed) {
      throw ConnectionClosedException._();
    }
    try {
      if (_conversations[conversationId] == null) {
        final result = await _peer.sendRequest('getConversationDetail', {'id': conversationId});
        _logger.info('getConversationDetail result $result');
        return await _createConversationFromData(result);
      } else {
        return _conversations[conversationId];
      }
    } on RpcException catch (ex, stack) {
      _logger.severe('$ex', ex, stack);
      if (ex.code == 404) {
        return null;
      } else {
        throw ServerException._('SERVER_ERROR_${ex.code}', ex.message, ex.data);
      }
    }
  }
}

/// [Exception] that can be thrown by the SDK when it's not connect to the backend
///
/// To fix this you can wait for the SDK to reconnect automatically to the backend or call [DalkSdk.connect] method
///
/// See also:
/// * [DalkSdkException] witch is the base exception class of the sdk
class ConnectionClosedException extends DalkSdkException {
  const ConnectionClosedException._() : super._('CONNECTION_CLOSED', 'Connection closed, use connect first');

  @override
  String toString() {
    return 'ConnectionClosedException{code: $code, message: $message}';
  }
}

/// Default [Exception] that can be thrown by the SDK
///
/// [code] give you the type of exception that append
///
/// [message] give you a meaningful description of the exception
class DalkSdkException implements Exception {
  final String code;
  final String message;

  const DalkSdkException._(this.code, this.message);

  @override
  String toString() {
    return 'DalkSdkException{code: $code, message: $message}';
  }
}

/// Server [Exception] that can be thrown by the SDK
///
/// [code] give you the type of exception that append
///
/// [message] give you a meaningful description of the exception
///
/// [data] give you the context of that exception
/// See also:
/// * [DalkSdkException] witch is the base exception class of the sdk
class ServerException extends DalkSdkException {
  final dynamic data;

  const ServerException._(String code, String message, this.data) : super._(code, message);

  @override
  String toString() {
    return 'ServerException{code: $code, message: $message}, data: $data}';
  }
}
