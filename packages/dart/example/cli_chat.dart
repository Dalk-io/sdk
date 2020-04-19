import 'dart:io';

import 'package:dalk_sdk/sdk.dart';

const String _ansiEscape = '\x1b[';

void main(List<String> arguments) async {
  final myId = arguments.first;
  final otherId = arguments.last;

  final me = User(id: myId, name: 'Jimmy');
  final other = User(id: otherId, name: 'Kev');
  Conversation conversation;

  final sdk = DalkSdk('dalk_dev_test_project', me);

  sdk.newConversation.listen((newConversation) async {
    print('conversation created: $newConversation');
    conversation = await sdk.getConversation(newConversation.id);
    conversation.onMessagesEvent.listen((message) => print('new message event'));
  });

  var response = await sdk.connect();
  print('registration: ok');

  final prevLineMode = stdin.lineMode;
  final prevEchoMode = stdin.echoMode;
  stdin.lineMode = false;
  stdin.echoMode = false;
  for (var i = 0; i < 30; i++) {
    // Make room for the options first.
    stdout.writeln();
  }

  while (true) {
    for (var i = 0; i < 30; i += 1) {
      final humanIndex = i + 1;
      stdout.writeln(humanIndex);
    }
    stdout.write('$_ansiEscape${30}A');
    final firstEscape = stdin.readByteSync();
    print(firstEscape);
    if (firstEscape == 27) {
      // escape was pressed, quit
      break;
    }
  }

  stdin.lineMode = prevLineMode;
  stdin.echoMode = prevEchoMode;
}
