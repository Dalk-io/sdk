import 'package:dalk/app.dart';
import 'package:dalk/presentation/conversations_route.dart';
import 'package:dalk/presentation/dialogs.dart';
import 'package:dalk/presentation/setup_route.dart';
import 'package:dalk/stores/dalk_store.dart';
import 'package:dalk/stores/login_store.dart';
import 'package:dalk_sdk/sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dalk_sdk/flutter_dalk_sdk.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

final _chatSupportUser = const User(
    id: 'supportUserId',
    name: 'Support',
    avatar: 'https://spng.pinpng.com/pngs/s/399-3992717_registered-trademark-symbol-transparent-customer-support-icon-free.png');

class ActionsScreen extends HookWidget {
  static const route = '/actions';

  @override
  Widget build(BuildContext context) {
    final floatingPosition = useState(ActionButtonLocation.right);

    var floatingActionButtonLocation = FloatingActionButtonLocation.endFloat;
    if (floatingPosition.value == ActionButtonLocation.center) floatingActionButtonLocation = FloatingActionButtonLocation.centerFloat;
    if (floatingPosition.value == ActionButtonLocation.left) floatingActionButtonLocation = StartFloatFloatingActionButtonLocation();

    return Scaffold(
      appBar: AppBar(
        title: Text('Action Dalk example'),
        leading: IconButton(
          icon: Icon(Icons.power_settings_new),
          tooltip: 'Logout',
          onPressed: () async {
            final loginStore = Provider.of<LoginStore>(context, listen: false);
            final talkStore = Provider.of<DalkStore>(context, listen: false);

            final success = await showConfirmDialog(context, 'Logout', 'Do you really want to log out ?') ?? false;
            if (success) {
              await showWaitingDialog(
                context,
                () async {
                  await loginStore.logout();
                  await talkStore.logout();
                },
                onSuccess: () => Navigator.of(context)?.pushReplacementNamed(SetupScreen.route),
              );
            }
          },
        ),
        actions: <Widget>[
          DalkChatAction(user: _chatSupportUser),
          PopupMenuButton<ExampleChoice>(
            onSelected: (selected) {
              Navigator.of(context).pushReplacementNamed(selected.route);
            },
            itemBuilder: (BuildContext context) {
              return choices.where((item) => item.route != route).map((ExampleChoice choice) {
                return PopupMenuItem<ExampleChoice>(
                  value: choice,
                  child: Text(choice.title),
                );
              }).toList();
            },
          ),
        ],
      ),
      floatingActionButtonLocation: floatingActionButtonLocation,
      floatingActionButton: DalkChatFloatingActionButton(user: _chatSupportUser, location: floatingPosition.value),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text('My custom app content here.\n\nClick the floating button or the app bar chat action to show support popup'),
            ),
            Align(child: Text('Floating button position:', style: Theme.of(context).textTheme.caption), alignment: Alignment.centerLeft),
            DropdownButton(
              isExpanded: true,
              value: floatingPosition.value,
              items: ActionButtonLocation.values
                  .map(
                    (e) => DropdownMenuItem(
                      child: Text(e.toString()),
                      value: e,
                    ),
                  )
                  .toList(growable: false),
              onChanged: (selected) {
                floatingPosition.value = selected;
              },
            ),
          ],
        ),
      ),
    );
  }
}
