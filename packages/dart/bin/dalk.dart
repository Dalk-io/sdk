import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dalk_sdk/sdk.dart';

void main(List<String> arguments) {
  exitCode = 0; // presume success

  var runner = CommandRunner('dalk', 'Chat CLI management')..addCommand(SendCommand())..addCommand(ListenCommand());

  runner.argParser
    ..addOption('project', abbr: 'p', help: 'Your project id, find it on your dalk dashboard')
    ..addOption('user', abbr: 'u', help: 'User id to register')
    ..addOption('signature', abbr: 's', help: 'Signature to secure the connection', defaultsTo: null);

  runner.run(arguments);
}

class SendCommand extends Command with DalkSdkSetup {
  @override
  String get description => 'Send a message to a conversation';

  @override
  String get name => 'send';

  SendCommand() {
    argParser.addOption('conversation', abbr: 'c');
  }

  @override
  Future<void> run() async {
    await setupDalkSdk();
    final String convId = argResults['conversation'];

    if (convId == null || convId.isEmpty) {
      exitCode = 2;
      usageException('conversation id must be provided, use --conversation');
    }

    final conversation = await sdk.getConversation(convId);
    print(argResults.rest);
    if (conversation == null) {
      stderr.writeln('conversation not found, check your conversation id: $convId');
      exit(2);
    } else {
      await conversation.sendMessage(argResults.rest.first);
    }
  }
}

class ListenCommand extends Command with DalkSdkSetup {
  @override
  String get description => 'Listen a conversation for incomming messages';

  @override
  String get name => 'listen';

  ListenCommand() {
    argParser.addOption('conversation', abbr: 'c');
  }

  @override
  Future<void> run() async {
    await setupDalkSdk();
    final String convId = argResults['conversation'];

    final conversation = await sdk.getConversation(convId);
    if (conversation == null) {
      stderr.writeln('conversation not found, check your conversation id: $convId');
      exit(2);
    } else {
      conversation.onMessagesEvent.listen((message) {
        stdout.writeln(message);
      });
    }
  }
}

mixin DalkSdkSetup on Command {
  DalkSdk sdk;

  Future<void> setupDalkSdk() async {
    final String projectId = globalResults['project'];
    final String signature = globalResults['signature'];
    final String userId = globalResults['user'];

    if (projectId == null || projectId.isEmpty) {
      exitCode = 2;
      usageException('project id must be provided, use --project');
    }

    if (userId == null || userId.isEmpty) {
      exitCode = 2;
      usageException('user id must be provided, use --user');
    }

    sdk = DalkSdk(projectId, User(id: userId, name: 'CLI'), signature: signature);

    await sdk.connect();
  }
}
