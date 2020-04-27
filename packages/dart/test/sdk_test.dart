import 'package:dalk_sdk/sdk.dart';
import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:json_rpc_2/src/peer.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class PeerMock extends Mock implements Peer {}

void main() {
  DalkSdk sdk;
  final me = User(id: 'meId', name: 'me', avatar: 'avatar');
  final other = User(id: 'id', name: 'other', avatar: 'OtherAvatar');
  final other2 = User(id: 'id2', name: 'other2', avatar: 'OtherAvatar2');

  setUp(() {
    sdk = DalkSdk('myProjectId', me);
  });

  tearDown(() async {
    await sdk.disconnect();
  });

  test('connect should setup Peer and realtime callbacks', () async {
    final peer = PeerMock();
    sdk.mock(peer);

    when(peer.sendRequest('registerUser', any)).thenAnswer((realInvocation) => Future.value(null));
    when(peer.listen()).thenAnswer((realInvocation) => Future.delayed(Duration(milliseconds: 10)));

    await sdk.connect();

    expect(verify(peer.sendRequest('registerUser', captureAny)).captured.single, {
      'id': me.id,
      'name': me.name,
      'avatar': me.avatar,
    });

    verify(peer.registerFallback(any));
    verify(peer.listen());
    verify(peer.isClosed);
    verify(peer.registerMethod('onConversationCreated', any));
    verifyNoMoreInteractions(peer);
  });

  test('onConversationCreated should trigger a new conversation event', () async {
    final peer = PeerMock();
    sdk.mock(peer);

    when(peer.isClosed).thenReturn(false);
    when(peer.sendRequest('registerUser', any)).thenAnswer((realInvocation) => Future.value(null));
    when(peer.listen()).thenAnswer((realInvocation) => Future.delayed(Duration(milliseconds: 10)));

    await sdk.connect();

    final callback = verify(peer.registerMethod('onConversationCreated', captureAny)).captured.single;

    callback(Parameters('onConversationCreated', {
      'id': 'test',
      'users': [me.toJson(), other.toJson()],
      'admins': [me.toJson()],
      'subject': 'subject',
      'avatar': 'avatar',
      'message': [],
    }));

    await expectLater(sdk.newConversation.take(1), emits((Conversation newConversation) {
      return newConversation.id == 'test' &&
          newConversation.subject == 'subject' &&
          newConversation.avatar == 'avatar' &&
          newConversation.users.first == me &&
          newConversation.users.last == other &&
          newConversation.admins.first == me;
    }));
  });

  test('createOneToOneConversation should send correct data to PEER and return a conversation object', () async {
    final peer = PeerMock();
    sdk.mock(peer);

    when(peer.isClosed).thenReturn(false);
    when(peer.sendRequest('getOrCreateConversation', any)).thenAnswer((realInvocation) => Future.value({
          'id': 'test',
          'users': [me.toJson(), other.toJson()],
          'admins': [me.toJson()]
        }));

    final conversation = await sdk.createOneToOneConversation(other, conversationId: 'test');

    expect(verify(peer.sendRequest('getOrCreateConversation', captureAny)).captured.single, {
      'id': 'test',
      'users': [other.toJson()],
      'isGroup': false,
    });

    expect(conversation.id, 'test');
    expect(conversation.isOneToOne, isTrue);
    expect(conversation.isGroup, isFalse);
    expect(conversation.partner, other);
    expect(conversation.currentUser, me);
    expect(conversation.users.length, 2);
    expect(conversation.users.first, me);
    expect(conversation.users.last, other);
    expect(conversation.admins.length, 1);
    expect(conversation.admins.first, me);
    expect(conversation.avatar, isNull);
    expect(conversation.subject, isNull);
    expect(conversation.messages.length, 0);
  });

  test('createGroupConversation should send correct data to PEER and return a conversation object', () async {
    final peer = PeerMock();
    sdk.mock(peer);

    when(peer.isClosed).thenReturn(false);
    when(peer.sendRequest('getOrCreateConversation', any)).thenAnswer((realInvocation) => Future.value({
          'id': 'test',
          'avatar': 'avatar',
          'subject': 'subject',
          'users': [me.toJson(), other.toJson(), other2.toJson()],
          'admins': [me.toJson()],
          'isGroup': true,
        }));

    final conversation = await sdk.createGroupConversation(
      [other, other2],
      conversationId: 'test',
      avatar: 'avatar',
      subject: 'subject',
    );

    expect(verify(peer.sendRequest('getOrCreateConversation', captureAny)).captured.single, {
      'id': 'test',
      'avatar': 'avatar',
      'subject': 'subject',
      'users': [other.toJson(), other2.toJson()],
      'isGroup': true,
    });

    expect(conversation.id, 'test');
    expect(conversation.isOneToOne, isFalse);
    expect(conversation.isGroup, isTrue);
    expect(conversation.partners, [other, other2]);
    expect(conversation.currentUser, me);
    expect(conversation.users.length, 3);
    expect(conversation.users.first, me);
    expect(conversation.users[1], other);
    expect(conversation.users[2], other2);
    expect(conversation.admins.length, 1);
    expect(conversation.admins.first, me);
    expect(conversation.avatar, 'avatar');
    expect(conversation.subject, 'subject');
    expect(conversation.messages.length, 0);
  });

  test('getConversations should send correct data to PEER and return a list of conversations', () async {
    final peer = PeerMock();
    sdk.mock(peer);

    when(peer.isClosed).thenReturn(false);
    when(peer.sendRequest('getConversations', any)).thenAnswer(
      (realInvocation) => Future.value([
        {
          'id': 'test',
          'avatar': 'avatar',
          'subject': 'subject',
          'users': [me.toJson(), other.toJson(), other2.toJson()],
          'isGroup': true,
          'admins': [me.toJson()],
          'messages': [
            {
              'id': 'messageId',
              'senderId': 'senderId',
              'text': 'text',
              'timestamp': '2020-04-08T16:26:36.346841Z',
              'status': 'received',
              'statusDetails': [
                {
                  'userId': 'id',
                  'status': 'received',
                },
                {
                  'userId': 'id2',
                  'status': 'seen',
                }
              ],
            }
          ],
        }
      ]),
    );

    final conversations = await sdk.getConversations();
    final conversation = conversations.first;

    verify(peer.sendRequest('getConversations', isNull));

    expect(conversation.id, 'test');
    expect(conversation.isOneToOne, isFalse);
    expect(conversation.isGroup, isTrue);
    expect(conversation.partners, [other, other2]);
    expect(conversation.currentUser, me);
    expect(conversation.users.length, 3);
    expect(conversation.users.first, me);
    expect(conversation.users[1], other);
    expect(conversation.users[2], other2);
    expect(conversation.admins.length, 1);
    expect(conversation.admins.first, me);
    expect(conversation.avatar, 'avatar');
    expect(conversation.subject, 'subject');
    expect(conversation.messages.length, 1);
    expect(conversation.messages.first.id, 'messageId');
    expect(conversation.messages.first.senderId, 'senderId');
    expect(conversation.messages.first.text, 'text');
    expect(conversation.messages.first.createdAt, isNotNull);
    expect(conversation.messages.first.status, MessageStatus.received);
    expect(conversation.messages.first.statusDetails.first.status, MessageStatus.received);
    expect(conversation.messages.first.statusDetails.first.userId, other.id);
    expect(conversation.messages.first.statusDetails.last.status, MessageStatus.seen);
    expect(conversation.messages.first.statusDetails.last.userId, other2.id);
  });

  test('getConversationDetail should send correct data to PEER and return a conversation object', () async {
    final peer = PeerMock();
    sdk.mock(peer);

    when(peer.isClosed).thenReturn(false);
    when(peer.sendRequest('getConversationDetail', any)).thenAnswer(
      (realInvocation) => Future.value({
        'id': 'test',
        'avatar': 'avatar',
        'subject': 'subject',
        'isGroup': true,
        'users': [me.toJson(), other.toJson(), other2.toJson()],
        'admins': [me.toJson()],
        'messages': [
          {
            'id': 'messageId',
            'senderId': 'senderId',
            'text': 'text',
            'timestamp': '2020-04-08T16:26:36.346841Z',
            'status': 'received',
            'statusDetails': [
              {
                'userId': 'id',
                'status': 'received',
              },
              {
                'userId': 'id2',
                'status': 'seen',
              }
            ],
          }
        ],
      }),
    );

    final conversation = await sdk.getConversation('test');

    expect(verify(peer.sendRequest('getConversationDetail', captureAny)).captured.single, {
      'id': 'test',
    });

    expect(conversation.id, 'test');
    expect(conversation.isOneToOne, isFalse);
    expect(conversation.isGroup, isTrue);
    expect(conversation.partners, [other, other2]);
    expect(conversation.currentUser, me);
    expect(conversation.users.length, 3);
    expect(conversation.users.first, me);
    expect(conversation.users[1], other);
    expect(conversation.users[2], other2);
    expect(conversation.admins.length, 1);
    expect(conversation.admins.first, me);
    expect(conversation.avatar, 'avatar');
    expect(conversation.subject, 'subject');
    expect(conversation.messages.length, 1);
    expect(conversation.messages.first.id, 'messageId');
    expect(conversation.messages.first.senderId, 'senderId');
    expect(conversation.messages.first.text, 'text');
    expect(conversation.messages.first.createdAt, isNotNull);
    expect(conversation.messages.first.status, MessageStatus.received);
    expect(conversation.messages.first.statusDetails.first.status, MessageStatus.received);
    expect(conversation.messages.first.statusDetails.first.userId, other.id);
    expect(conversation.messages.first.statusDetails.last.status, MessageStatus.seen);
    expect(conversation.messages.first.statusDetails.last.userId, other2.id);
  });
}
