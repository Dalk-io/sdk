An SDK to add a real time chat easily with pre-defined UI components.

## Features

- Realtime events for conversations and messages
- Conversations in one to one 
- Message status, sent, received, seen  
- Group conversations
- Custom subject and avatar for group conversations  

## Usage

### Installation

Add this to your package's pubspec.yaml file:

```yaml
flutter_dalk_sdk: ^1.0.0
dalk_sdk: ^1.0.0
```

And run: 
```
flutter pub get
```

### Setup

```dart
import 'package:dalk_sdk/sdk.dart';
import 'package:flutter_dalk_sdk/flutter_dalk_sdk.dart';

main() async {
  final currentUser = User(id: 'userId', name: 'userName'); 
  final sdk = DalkSdk('myProjectId', currentUser, (userId) {
    // get user information from webservice, database... and return the corresponding User
  });
  
  await sdk.connect();
  runApp(
   DalkChat.existing(
        client: sdk,
        child: MaterialApp(
          title: 'Dalk.io demo',
          theme: ThemeData(
            primarySwatch: Colors.green,
          ),
          localizationsDelegates: [DalkLocalizationDelegate()],
          ...
        ),
      ),
  );
}
```

### Show conversation list

```dart

ConversationListView(
    onTap: (conv) {
      showWaitingDialog(context, () => talkStore.loadConversation(conv.id), onSuccess: () async {
        await Navigator.of(context).pushNamed(ChatScreen.route);
      });
    },
);

```

### Show a real time conversation

```dart

ConversationChat(conversation: talkStore.currentConversation);

```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/Dalk-io/sdk/issues
