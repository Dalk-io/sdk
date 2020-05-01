part of 'sdk_base.dart';

/// status of a [Message]
///
/// * sent: message has been successfully sent to the server
/// * received: message has been successfully received by the user
/// * seen: message has been seen by the user
/// * ongoing: message is been sent to the server
/// * error: message was not sent to the server
///
/// See also:
/// * [Message] message object of the sdk
/// * [UserMessageStatus] to have the message status per user on the conversation
enum MessageStatus {
  sent,
  received,
  seen,
  ongoing,
  error,
}

MessageStatus _statusFromBackend(String value) {
  if (value == 'seen') {
    return MessageStatus.seen;
  }
  if (value == 'received') {
    return MessageStatus.received;
  }
  return MessageStatus.sent;
}

String _statusToBackend(MessageStatus value) {
  switch (value) {
    case MessageStatus.sent:
      return 'sent';
    case MessageStatus.received:
      return 'received';
    case MessageStatus.seen:
      return 'seen';
    case MessageStatus.ongoing:
      return 'ongoing';
    case MessageStatus.error:
      return 'error';
  }
  return null;
}

/// user status of a [Message], can be useful in group conversation
/// if you want to check the message status per user
///
/// See also:
/// * [Message] message object of the sdk
/// * [MessageStatus] to see the different status of a message
class UserMessageStatus {
  /// [User] identifier concerned by this status
  final String userId;

  /// status of the message for the given user id
  final MessageStatus status;

  UserMessageStatus._(this.userId, this.status);

  factory UserMessageStatus._fromBackend(Map<String, dynamic> data) {
    return UserMessageStatus._(
      data['userId'],
      _statusFromBackend(data['status']),
    );
  }
}

/// Message object representation
///
/// See also:
/// * [MessageStatus] to see the different status of a message
/// * [UserMessageStatus] to have the message status per user on the conversation
abstract class Message {
  /// identifier of the message
  String get id;

  /// [User] identifier of the message
  String get senderId;

  /// content of the message
  String get text;

  /// date when the message was created
  DateTime get createdAt;

  /// date when the message was updated, null if never updated
  DateTime get updatedAt;

  /// status of the message
  MessageStatus get status;

  /// contains the status of the message specific to each users in the conversation
  List<UserMessageStatus> get statusDetails;

  /// contains custom metadata you need related to a message, empty by default
  Map<String, dynamic> get metadata;
}

@freezed
abstract class _Message with _$_Message implements Message {
  const factory _Message._(
    String id,
    String senderId,
    @nullable String text,
    DateTime createdAt,
    @nullable DateTime updatedAt,
    MessageStatus status,
    List<UserMessageStatus> statusDetails,
    Map<String, dynamic> metadata,
  ) = __Message;

  static _Message fromBackend(Map<String, dynamic> data) {
    final userStatus = (data['statusDetails'] as List)?.map((status) => UserMessageStatus._fromBackend(status))?.cast<UserMessageStatus>()?.toList() ?? [];
    return _Message._(
      data['id'],
      data['senderId'],
      data['text'],
      DateTime.parse(data['createdAt']),
      data['updatedAt'] == null ? null : DateTime.parse(data['updatedAt']),
      _statusFromBackend(data['status']),
      userStatus,
      data['metadata'] ?? {},
    );
  }
}

/// Conversation object representation abstract
abstract class Conversation {
  /// identifier of the conversation
  String get id;

  /// subject of this conversation
  /// Can be customized by [setOptions] for group conversation
  String get subject;

  /// avatar of this conversation as an URL
  /// Can be customized by [setOptions] for group conversation
  String get avatar;

  /// current [User]
  User get currentUser;

  /// list of [User] in this conversation
  List<User> get users;

  /// list of [User] with admin role on this conversation
  List<User> get admins;

  /// list of [Message] of this conversation
  List<Message> get messages;

  /// Returns true if this conversation has been created as a one to one conversation, false otherwise
  bool get isOneToOne;

  /// Returns true if this conversation has been created as a group conversation, false otherwise
  bool get isGroup;

  /// Returns the [User] who participate to this conversation with [currentUser]
  ///
  /// Throws [DalkSdkException] with UNSUPPORTED_OPERATION if used on group conversation
  ///
  /// Throws [DalkSdkException] with PARTNER_NOT_FOUND if no partner is found
  User get partner;

  /// Returns a list of [User] who participate to this conversation with [currentUser]
  List<User> get partners;

  /// Returns a [Stream] of [Message] to get realtime events about messages of this conversation
  ///
  /// See also:
  /// * [Message] message object representation
  Stream<Message> get onMessagesEvent;

  /// This method let you load or refresh the list of [Message] of the conversation
  /// It will update [messages]
  ///
  /// Throws [ServerException] if something went wrong server side
  ///
  /// Throws [ConnectionClosedException] if sdk is no more connected to the server
  Future<void> loadMessages();

  /// This method let you send a message to the current conversation
  /// It will trigger some events in [onMessagesEvent]
  ///
  /// [message] is the text to send, optional
  /// [metadata] is the custom data you can associate to this message, optional
  ///
  /// Throws [ServerException] if something went wrong server side
  ///
  /// Throws [ConnectionClosedException] if sdk is no more connected to the server
  Future<void> sendMessage({String message, Map<String, dynamic> metadata});

  /// This method let you update a sent message on the current conversation
  /// It will trigger some events in [onMessagesEvent]
  ///
  /// [id] is the message identifier to update, required
  /// [message] is the text to send, optional, can be updated only by his sender
  /// [metadata] is the custom data you can associate to this message, optional, can be updated by all participants
  ///
  /// Throws [ServerException] if something went wrong server side
  ///
  /// Throws [ConnectionClosedException] if sdk is no more connected to the server
  Future<void> updateMessage(String id, {String message, Map<String, dynamic> metadata});

  /// This method let you notify the server that the message as been seen by the user
  ///
  /// [messageId] is the message identifier to set as status [MessageStatus.seen]
  ///
  /// Throws [ServerException] if something went wrong server side
  ///
  /// Throws [ConnectionClosedException] if sdk is no more connected to the server
  ///
  /// See also:
  /// * [MessageStatus] to see the different status of a message
  Future<void> setMessageAsSeen(String messageId);

  /// @nodoc
  Future<void> addParticipant(User user);

  /// @nodoc
  Future<void> removeParticipant(User user);

  /// This method let you specify custom subject and avatar of the conversation
  /// It will update [subject] and [avatar] if successful
  ///
  /// Throws [ServerException] if something went wrong server side
  ///
  /// Throws [ConnectionClosedException] if sdk is no more connected to the server
  ///
  /// Throws [DalkSdkException] with UNSUPPORTED_OPERATION if used on one to one conversation
  Future<void> setOptions({String subject, String avatar});
}

class _ConversationImpl implements Conversation {
  @override
  final String id;
  String _subject;
  String _avatar;
  final Logger _logger;
  @override
  final User currentUser;
  @override
  final List<User> users;
  @override
  final List<User> admins = [];
  @override
  final List<Message> messages;
  final StreamController<Message> _messageEvent = StreamController.broadcast();
  final bool _isGroup;
  Peer _peer;

  _ConversationImpl._({
    @required this.id,
    @required this.currentUser,
    @required this.users,
    @required List<User> admins,
    @required Peer peer,
    List<Message> messages,
    bool isGroup,
    String subject,
    String avatar,
    Logger logger,
  })  : this.messages = messages ?? [],
        _isGroup = isGroup,
        _subject = subject,
        _logger = logger,
        _avatar = avatar {
    this.admins.addAll(admins);
    _resetPeer(peer);
    messages.forEach((message) {
      if (message.status == MessageStatus.sent) {
        _setMessageStatus(message.id, MessageStatus.received);
      }
    });
  }

  @override
  String get subject => _subject;

  @override
  String get avatar => _avatar;

  @override
  bool get isOneToOne => !_isGroup;

  @override
  bool get isGroup => _isGroup;

  @override
  User get partner {
    if (isOneToOne) {
      for (final user in users) {
        if (user.id != currentUser.id) {
          return user;
        }
      }
    } else {
      throw DalkSdkException._('UNSUPPORTED_OPERATION', 'Can\'t get partner on group conv, use partners');
    }
    throw DalkSdkException._('PARTNER_NOT_FOUND', 'partner not found');
  }

  @override
  List<User> get partners {
    final partners = <User>[];
    for (final user in users) {
      if (user.id != currentUser.id) {
        partners.add(user);
      }
    }
    return partners;
  }

  @override
  Stream<Message> get onMessagesEvent => _messageEvent.stream;

  void _resetPeer(Peer peer) {
    _peer = peer;
  }

  void _messageUpdate(Map<String, dynamic> data) {
    final message = _Message.fromBackend(data);

    final existingIndex = messages.indexWhere((m) => m.id == message.id && message.id != null);
    if (existingIndex == -1) {
      messages.add(message);
    } else {
      messages[existingIndex] = message;
    }
    _messageEvent.add(message);
  }

  void _incomingMessage(Map<String, dynamic> data) async {
    var message = _Message.fromBackend(data);
    if (message.status == MessageStatus.sent) {
      await _setMessageStatus(message.id, MessageStatus.received).catchError((err, stack) {
        //ignore errors
      });
      message = message.copyWith(status: MessageStatus.received);
    }

    final existingIndex = messages.indexWhere((m) => m.id == message.id && message.id != null);
    if (existingIndex == -1) {
      messages.add(message);
    } else {
      messages[existingIndex] = message;
    }
    _messageEvent.add(message);
  }

  void _updateFrom(Conversation conversation) {
    _subject = conversation.subject;
    _avatar = conversation.avatar;
  }

  @override
  Future<void> setMessageAsSeen(String messageId) async {
    if (_peer.isClosed) {
      throw ConnectionClosedException._();
    }
    final existingIndex = messages.indexWhere((m) => m.id == messageId);
    if (existingIndex != -1 && messages[existingIndex].status != MessageStatus.seen && messages[existingIndex].senderId != currentUser.id) {
      messages[existingIndex] = (messages[existingIndex] as _Message).copyWith(status: MessageStatus.seen);
      _logger.info('set $messageId as seen, ${messages[existingIndex]}');
      await _setMessageStatus(messageId, MessageStatus.seen);
      _messageEvent.add(messages[existingIndex]);
    }
  }

  Future<void> _setMessageStatus(String messageId, MessageStatus status) async {
    if (!messageId.startsWith('temporary_')) {
      try {
        await _peer.sendRequest('updateMessageStatus', {'id': messageId, 'status': _statusToBackend(status)});
        _logger.info('updateMessageStatus $messageId $status');
      } on RpcException catch (ex, stack) {
        _logger.severe('$ex', ex, stack);
        throw ServerException._('SERVER_ERROR_${ex.code}', ex.message, ex.data);
      }
    }
  }

  @override
  Future<void> sendMessage({String message, Map<String, dynamic> metadata}) async {
    if (_peer.isClosed) {
      throw ConnectionClosedException._();
    }
    try {
      final date = DateTime.now();
      final messageData =
          _Message._('temporary_${date.millisecondsSinceEpoch}', currentUser.id, message, date, null, MessageStatus.ongoing, [], metadata ?? {});
      messages.add(messageData);
      _messageEvent.add(messageData);
      final result = await _peer.sendRequest('sendMessage', {
        'conversationId': id,
        if (message != null) 'text': message,
        if (metadata != null) 'metadata': metadata,
      });
      _logger.info('sendMessage result $result');
      final existingIndex = messages.indexWhere((m) => m.id == messageData.id);
      messages[existingIndex] = _Message.fromBackend(result);
      _messageEvent.add(messages[existingIndex]);
    } on RpcException catch (ex, stack) {
      _logger.severe('$ex', ex, stack);
      throw ServerException._('SERVER_ERROR_${ex.code}', ex.message, ex.data);
    }
  }

  @override
  Future<void> updateMessage(String id, {String message, Map<String, dynamic> metadata}) async {
    if (_peer.isClosed) {
      throw ConnectionClosedException._();
    }
    try {
      final existingIndex = messages.indexWhere((m) => m.id == id);
      if (existingIndex == -1) {
        return;
      }
      final date = DateTime.now();
      final temporaryMessage = (messages[existingIndex] as _Message).copyWith(
        text: message,
        metadata: metadata ?? {},
        status: MessageStatus.ongoing,
        updatedAt: date,
      );
      messages[existingIndex] = temporaryMessage;
      _messageEvent.add(temporaryMessage);
      final result = await _peer.sendRequest('updateMessage', {
        'messageId': id,
        if (message != null) 'text': message,
        if (metadata != null) 'metadata': metadata,
      });
      _logger.info('updateMessage result $result');

      messages[existingIndex] = _Message.fromBackend(result);
      _messageEvent.add(messages[existingIndex]);
    } on RpcException catch (ex, stack) {
      _logger.severe('$ex', ex, stack);
      throw ServerException._('SERVER_ERROR_${ex.code}', ex.message, ex.data);
    }
  }

  @override
  Future<void> loadMessages() async {
    if (_peer.isClosed) {
      throw ConnectionClosedException._();
    }
    try {
      final result = await _peer.sendRequest('getMessages', {'conversationId': id});
      messages.clear(); //fixme, do proper merge of messages once pagination is done
      final messageList = (result as List).map((message) => _Message.fromBackend(message)).cast<Message>().toList();
      messages.addAll(messageList);
    } on RpcException catch (ex, stack) {
      _logger.severe('$ex', ex, stack);
      throw ServerException._('SERVER_ERROR_${ex.code}', ex.message, ex.data);
    }
  }

  @override
  Future<void> addParticipant(User user) async {
    if (_peer.isClosed) {
      throw ConnectionClosedException._();
    }
    final alreadyAdded = users.firstWhere((u) => u.id == user.id, orElse: () => null) != null;
    if (!alreadyAdded) {
      //TODO finish check errors
      await _peer.sendRequest('addParticipant', {'conversationId': id, 'user': user.id});
      users.add(user);
    }
  }

  @override
  Future<void> removeParticipant(User user) async {
    if (_peer.isClosed) {
      throw ConnectionClosedException._();
    }
    //TODO finish check errors
    await _peer.sendRequest('removeParticipant', {'conversationId': id, 'user': user.id});
    users.remove(user);
  }

  @override
  Future<void> setOptions({String subject, String avatar}) async {
    if (_peer.isClosed) {
      throw ConnectionClosedException._();
    }
    if (isOneToOne) {
      throw DalkSdkException._('UNSUPPORTED_OPERATION', 'setOptions is supported for group chat only');
    }
    try {
      await _peer.sendRequest('setConversationOptions', {
        'conversationId': id,
        if (subject != null) 'subject': subject,
        if (avatar != null) 'avatar': avatar,
      });
      _subject = subject;
      _avatar = avatar;
    } on RpcException catch (ex, stack) {
      _logger.severe('$ex', ex, stack);
      throw ServerException._('SERVER_ERROR_${ex.code}', ex.message, ex.data);
    }
  }

  @override
  String toString() {
    return 'Conversation{id: $id, subject: $subject, avatar: $avatar, users: $users, admins: $admins, messages: $messages}';
  }
}
