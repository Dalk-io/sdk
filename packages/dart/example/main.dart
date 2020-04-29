import 'dart:convert';
import 'dart:io';

import 'package:dalk_sdk/sdk.dart';

void main(List<String> arguments) async {
  final myId = arguments.first;
  final otherId = arguments[1];
  final projectId = arguments.last;

  final me = User(id: myId, name: 'Jimmy');
  final other = User(id: otherId, name: 'Kev');
  Conversation conversation;

  final sdk = DalkSdk(projectId, me);

  sdk.newConversation.listen((newConversation) async {
    print('conversation created: $newConversation');
    conversation = await sdk.getConversation(newConversation.id);
    conversation.onMessagesEvent.listen((message) => print('new message event'));
  });

  await sdk.connect();
  print('registration: ok');

  stdin.transform(utf8.decoder).transform(LineSplitter()).listen((line) async {
    if (line == 'create conversation') {
      print('$line with $myId and $otherId');
      conversation = await sdk.createOneToOneConversation(other);
      conversation.onMessagesEvent.listen((message) => print('new message: $message'));
      print('conversationId: $conversation');
    } else if (line.startsWith('create conversation')) {
      print('$line with $myId and $otherId');
      conversation = await sdk.createOneToOneConversation(User(id: otherId, name: 'Kev'), conversationId: line.replaceAll('create conversation', '').trim());
      conversation.onMessagesEvent.listen((message) => print('new message: $message'));
      print('conversationId: $conversation');
    } else if (line == 'get conversations') {
      print('$line');
      final conversations = await sdk.getConversations();
      print('conversation: $conversations');
    } else if (line.startsWith('get details')) {
      print('$line');
      conversation = await sdk.getConversation(line.replaceAll('get details', '').trim());
      conversation.onMessagesEvent.listen((message) => print('new message $message'));
      print('conversation: $conversation');
    } else {
      print('send $line to ${conversation.id}');
      await conversation.sendMessage(message: line);
    }
  });
}
