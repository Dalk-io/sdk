A SDK to add a real time chat easily.

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
dalk_sdk: ^1.0.0
```

And run: 
```
pub get
```

or for Flutter
```
flutter pub get
```

### Setup

```dart
import 'package:dalk_sdk/sdk.dart';

main() async {
  final currentUser = User(id: 'userId', name: 'userName'); 
  final sdk = DalkSdk('myProjectId', currentUser, (userId) {
    // get user information from webservice, database... and return the corresponding User
  });
  
  await sdk.connect();
}
```

### Manage conversations

```dart
import 'package:dalk_sdk/sdk.dart';

main() async {
  // after setup, you can retrieve the list of conversations of the user
  final conversations = await sdk.getConversations();
  
  // get real time events when new conversations are created
  sdk.newConversation.listen((Conversation conversation) {
    // this get called each time a new conversation is created to let you know new ones
  });

}
```

### Manage a single conversation

```dart
import 'package:dalk_sdk/sdk.dart';

main() async {
  // after setup, you can retrieve a specific conversation of the user by his id
  final conversation = await sdk.getConversation('conversationId');
  
  // get real time events when new message arrived or the status of a message change
  conversation.onMessagesEvent.listen((Message message) {
    // this get called each time a new message arrived or a message status has changed
  });
  
  // you can set custom subject and avatar (group chat only)
  await conversation.setOptions(
    subject: 'subject',
    avatar: 'urlOfTheAvatar',
  );
  
}
```

### Manage message

```dart
import 'package:dalk_sdk/sdk.dart';

main() async {
  // after setup, you can retrieve a specific conversation of the user by his id
  final conversation = await sdk.getConversation('conversationId');
  
  // you can load or refresh messages like this:
  await conversation.loadMessages();
  // messages available in conversation.messages
  
  // send new message to the conversation
  await conversation.sendMessage('my message');

  // set message as read
  await conversation.setMessageAsSeen('myMessageId');

}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/Dalk-io/sdk/issues
