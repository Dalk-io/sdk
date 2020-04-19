import 'package:dalk_sdk/sdk.dart';
import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:json_rpc_2/src/peer.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class PeerMock extends Mock implements Peer {}

void main() {
  DalkSdk sdk;
  PeerMock peer;
  Conversation conversation;
  final convId = 'test';
  final me = User(id: 'meId', name: 'me', avatar: 'avatar');
  final other = User(id: 'id', name: 'other', avatar: 'OtherAvatar');
  final other2 = User(id: 'id2', name: 'other2', avatar: 'OtherAvatar2');

  setUp(() async {
    sdk = DalkSdk('myProjectId', me);
    peer = PeerMock();
    sdk.mock(peer);

    when(peer.isClosed).thenReturn(false);
    when(peer.sendRequest('getConversationDetail', any)).thenAnswer(
      (realInvocation) => Future.value({
        'id': convId,
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
      }),
    );
    conversation = await sdk.getConversation(convId);
    verify(peer.sendRequest('getConversationDetail', any));
    verify(peer.isClosed);
  });

  tearDown(() async {
    await sdk.disconnect();
  });

  test('sendMessage should send data to Peer and dipatch message as ongoing', () async {
    reset(peer);
    when(peer.isClosed).thenReturn(false);

    when(peer.sendRequest('sendMessage', any)).thenAnswer(
      (realInvocation) => Future.value(
        {
          'id': 'myMessageId',
          'senderId': 'meId',
          'text': 'message',
          'timestamp': '2020-04-08T16:26:36.346841Z',
          'status': 'sent',
          'statusDetails': [
            {
              'userId': 'id',
              'status': 'sent',
            },
          ],
        },
      ),
    );

    var messageReceived = 0;
    conversation.onMessagesEvent.take(2).listen(
          expectAsync1((Message message) {
            if (messageReceived == 0) {
              expect(message.id, contains('temporary_'));
              expect(message.text, 'message');
              expect(message.senderId, 'meId');
              expect(message.status, MessageStatus.ongoing);
              expect(conversation.messages.length, 2);
            } else {
              expect(message.id, 'myMessageId');
              expect(message.text, 'message');
              expect(message.senderId, 'meId');
              expect(message.status, MessageStatus.sent);
              expect(conversation.messages.length, 2); //still 2 message as the temporary one is replaced
              expect(conversation.messages.first.id, 'messageId');
              expect(conversation.messages.last.id, 'myMessageId');
            }
            messageReceived++;
          }, count: 2),
        );

    await conversation.sendMessage('message');

    verify(peer.isClosed);
    expect(verify(peer.sendRequest('sendMessage', captureAny)).captured.single, {
      'conversationId': convId,
      'text': 'message',
    });

    verifyNoMoreInteractions(peer);
  });

  test('setConversationOptions should send correct data to Peer and change local data', () async {
    reset(peer);
    when(peer.isClosed).thenReturn(false);
    when(peer.sendRequest('setConversationOptions', any)).thenAnswer((realInvocation) => Future.value(true));

    expect(conversation.subject, 'subject');
    expect(conversation.avatar, 'avatar');

    await conversation.setOptions(
      subject: 'updatedSubject',
      avatar: 'updatedAvatar',
    );

    expect(conversation.subject, 'updatedSubject');
    expect(conversation.avatar, 'updatedAvatar');

    verify(peer.isClosed);
    expect(verify(peer.sendRequest('setConversationOptions', captureAny)).captured.single, {
      'conversationId': convId,
      'subject': 'updatedSubject',
      'avatar': 'updatedAvatar',
    });
    verifyNoMoreInteractions(peer);
  });

  test('setMessageAsSeen should send data to Peer and dipatch message as seen', () async {
    reset(peer);
    when(peer.isClosed).thenReturn(false);
    when(peer.sendRequest('updateMessageStatus', any)).thenAnswer((realInvocation) => Future.value(true));

    expect(conversation.messages.first.status, MessageStatus.received);
    await conversation.setMessageAsSeen('messageId');
    expect(conversation.messages.first.status, MessageStatus.seen);

    verify(peer.isClosed);
    expect(verify(peer.sendRequest('updateMessageStatus', captureAny)).captured.single, {
      'id': 'messageId',
      'status': 'seen',
    });

    verifyNoMoreInteractions(peer);
  });

  test('loadMessages should send data to Peer and dipatch messages', () async {
    reset(peer);
    when(peer.isClosed).thenReturn(false);
    when(peer.sendRequest('getMessages', any)).thenAnswer(
      (realInvocation) => Future.value(
        [
          {
            'id': 'messageId',
            'senderId': 'senderId',
            'text': 'text',
            'timestamp': '2020-04-08T16:26:36.346841Z',
            'status': 'sent',
          },
          {
            'id': 'myMessageId',
            'senderId': 'meId',
            'text': 'message',
            'timestamp': '2020-04-08T16:26:36.346841Z',
            'status': 'sent',
          },
        ],
      ),
    );

    expect(conversation.messages.length, 1);
    await conversation.loadMessages();
    expect(conversation.messages.length, 2);
    expect(conversation.messages.first.id, 'messageId');
    expect(conversation.messages.last.id, 'myMessageId');

    verify(peer.isClosed);
    expect(verify(peer.sendRequest('getMessages', captureAny)).captured.single, {
      'conversationId': convId,
    });

    verifyNoMoreInteractions(peer);
  });

  test('receiveMessageConvId should trigger a new message event', () {
    final callback = verify(peer.registerMethod('receiveMessage$convId', captureAny)).captured.single;
    when(peer.sendRequest('updateMessageStatus', {'id': 'myNewMessageId', 'status': 'received'})).thenAnswer((_) => Future.value(null));
    expect(conversation.messages.length, 1);

    conversation.onMessagesEvent.take(1).listen(
      expectAsync1((Message message) {
        expect(message.id, 'myNewMessageId');
        expect(message.text, 'message');
        expect(message.senderId, 'id');
        expect(message.status, MessageStatus.received);
        expect(conversation.messages.length, 2);

        verify(peer.sendRequest('updateMessageStatus', {'id': 'myNewMessageId', 'status': 'received'}));
      }),
    );

    callback(
      Parameters(
        'receiveMessage$convId',
        {
          'id': 'myNewMessageId',
          'senderId': 'id',
          'text': 'message',
          'timestamp': '2020-04-08T16:26:36.346841Z',
          'status': 'sent',
          'statusDetails': [
            {
              'userId': 'id',
              'status': 'sent',
            },
          ],
        },
      ),
    );

  });

  test('updateMessageStatusConvId should trigger a new message event', () {
    final callback = verify(peer.registerMethod('updateMessageStatus$convId', captureAny)).captured.single;
    verify(peer.registerMethod('receiveMessage$convId', any));

    expect(conversation.messages.length, 1);
    expect(conversation.messages.first.status, MessageStatus.received);

    conversation.onMessagesEvent.take(1).listen(
      expectAsync1((Message message) {
        expect(message.id, 'messageId');
        expect(message.text, 'message');
        expect(message.senderId, 'id');
        expect(message.status, MessageStatus.seen);
        expect(conversation.messages.length, 1);
      }),
    );

    callback(
      Parameters(
        'updateMessageStatus$convId',
        {
          'id': 'messageId',
          'senderId': 'id',
          'text': 'message',
          'timestamp': '2020-04-08T16:26:36.346841Z',
          'status': 'seen',
          'statusDetails': [
            {
              'userId': 'id',
              'status': 'seen',
            },
          ],
        },
      ),
    );
    verifyNoMoreInteractions(peer);
    expect(conversation.messages.length, 1);
    expect(conversation.messages.first.status, MessageStatus.seen);
  });
}
