part of '../flutter_dalk_sdk.dart';

/// Enum to know the location of the [DalkChatFloatingActionButton]
///
/// See also:
/// [DalkChatFloatingActionButton] chat on floating button action
enum ActionButtonLocation { left, center, right }

class _PopupChat extends StatelessWidget {
  final List<Widget> actions;
  final List<User> users;
  final String conversationId;

  const _PopupChat({Key key, this.actions = const [], this.users, this.conversationId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final talkStore = Provider.of<DalkStore>(context);
    return Material(
      child: Observer(
        builder: (context) {
          Widget child;
          if (talkStore.currentConversation == null ||
              talkStore.currentConversationLoadState?.status == FutureStatus.pending) {
            child = Center(child: CircularProgressIndicator());
          } else if (talkStore.currentConversationLoadState?.status == FutureStatus.rejected) {
            child = Center(child: Text(context.dalkLocalization?.anErrorOccurred ?? talkStore.conversationsLoadState.error.toString()));
          } else {
            child = ConversationChat(conversation: talkStore.currentConversation);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AppBar(
                title: Text(talkStore.currentConversation.title),
                primary: false,
                actions: actions,
              ),
              Expanded(child: child)
            ],
          );
        },
      ),
    );
  }
}

/// Widget to show a chat popup to manage real time support
///
/// See also:
/// [ActionButtonLocation] to see possible location
/// [DalkChatAction] to have a simple button equivalent
class DalkChatFloatingActionButton extends HookWidget {
  final Radius popupBorderRadius;
  final ActionButtonLocation location;
  final bool enabled;
  final User user;
  final String conversationId;

  /// Create a new [DalkChatFloatingActionButton] to show a chat popup to manage real time support
  ///
  /// [user] user to open a conversation with, example the support user
  ///
  /// [conversationId] force the conversationId to a given one, optional
  ///
  /// [popupBorderRadius] border radius for the chat popup, optional, default to 10
  ///
  /// [enabled] boolean to enable/disable the floating button, optional, default to true
  ///
  /// [location] location of the floating button, used to position the chat popup, optional, default to ActionButtonLocation.right
  ///
  /// See also:
  /// [User] Dalk user representation
  /// [ActionButtonLocation] to see possible location
  /// [DalkChatAction] to have a simple button equivalent
  const DalkChatFloatingActionButton({
    Key key,
    @required this.user,
    this.popupBorderRadius = const Radius.circular(10),
    this.location = ActionButtonLocation.right,
    this.conversationId,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chatVisible = useState<OverlayEntry>(null);
    final talkStore = Provider.of<DalkStore>(context);
    useEffect(() {
      talkStore.getOrCreateConversation(user, conversationId);
      return null;
    }, [user, conversationId]);

    return FloatingActionButton(
      onPressed: enabled
          ? () {
              if (chatVisible.value == null) {
                chatVisible.value = _showChat(context);
              } else {
                chatVisible.value.remove();
                chatVisible.value = null;
              }
            }
          : null,
      child: Icon(chatVisible.value == null ? Icons.chat : Icons.close),
    );
  }

  OverlayEntry _showChat(BuildContext context) {
    RenderBox renderBox = context.findRenderObject();
    final radius = popupBorderRadius;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenWith = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final width = min(screenWith * .8, 500.0);
    final height = min(screenHeight * .8, 650.0);

    double left;
    double top;
    Point anchor;
    final double nipSize = 20;

    if (location == ActionButtonLocation.center) {
      left = screenWith / 2 - width / 2;
      top = offset.dy - size.height / 2 - height;
      anchor = Point(screenWith / 2 - nipSize / 2, offset.dy - nipSize * 2);
    } else if (location == ActionButtonLocation.left) {
      left = offset.dx;
      top = offset.dy - size.height / 2 - height;
      anchor = Point(offset.dx + nipSize / 2, offset.dy - nipSize * 2);
    } else {
      left = offset.dx - width + size.width;
      top = offset.dy - size.height / 2 - height;
      anchor = Point(offset.dx + nipSize / 2, offset.dy - nipSize * 2);
    }

    OverlayEntry entry = OverlayEntry(
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned(
              left: anchor.x,
              top: anchor.y,
              width: nipSize,
              height: nipSize,
              child: Transform.rotate(
                angle: 40,
                child: Container(
                  width: nipSize,
                  height: nipSize,
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              left: left,
              top: top,
              width: width,
              height: height,
              child: CustomPaint(
                willChange: false,
                painter: _BubblePainter(
                  color: Colors.black,
                  elevation: 2,
                  radius: radius,
                  anchor: anchor,
                  topNip: false,
                  shadowColor: Colors.black,
                ),
                child: ClipRRect(
                  child: _PopupChat(),
                  borderRadius: BorderRadius.all(radius),
                ),
              ),
            ),
          ],
        );
      },
    );
    Overlay.of(context).insert(entry);
    return entry;
  }
}

/// Widget to show a chat popup to manage real time support
///
/// See also:
/// [DalkChatFloatingActionButton] to have a floating button equivalent
class DalkChatAction extends HookWidget {
  final Radius popupBorderRadius;
  final bool enabled;
  final User user;
  final String conversationId;

  /// Create a new [DalkChatFloatingActionButton] to show a chat popup to manage real time support
  ///
  /// [user] user to open a conversation with, example the support user
  ///
  /// [conversationId] force the conversationId to a given one, optional
  ///
  /// [popupBorderRadius] border radius for the chat popup, optional, default to 10
  ///
  /// [enabled] boolean to enable/disable the floating button, optional, default to true
  ///
  /// See also:
  /// [DalkChatFloatingActionButton] to have a floating button equivalent
  DalkChatAction({
    Key key,
    this.popupBorderRadius = const Radius.circular(10),
    @required this.user,
    this.conversationId,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chatVisible = useState(false);
    final talkStore = Provider.of<DalkStore>(context);
    useEffect(() {
      talkStore.getOrCreateConversation(user, conversationId);
      return null;
    }, [user, conversationId]);
    return IconButton(
      onPressed: enabled && !chatVisible.value
          ? () {
              chatVisible.value = true;
              _showChat(context, chatVisible);
            }
          : null,
      icon: Icon(Icons.chat),
    );
  }

  void _showChat(BuildContext context, ValueNotifier<bool> chatVisible) {
    RenderBox renderBox = context.findRenderObject();
    final radius = popupBorderRadius;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final width = min(MediaQuery.of(context).size.width * .8, 500.0);
    final height = min(MediaQuery.of(context).size.height * .8, 650.0);

    double left;
    double top;
    bool topNip;
    Point anchor;
    final double nipWidth = 20;
    final double nipHeight = 0;

    if (offset.dy < MediaQuery.of(context).size.height / 2) {
      left = offset.dx - width + size.width;
      top = offset.dy + size.height;
      topNip = true;
      anchor = Point(offset.dx + nipWidth / 2, offset.dy + size.height - 5);
    } else {
      left = offset.dx - width + size.width;
      top = offset.dy - size.height / 2 - height;
      topNip = false;
      anchor = Point(offset.dx + nipWidth / 2, offset.dy - nipWidth - 15);
    }
    if (offset.dx < MediaQuery.of(context).size.width / 2) {
      left = offset.dx;
    }

    OverlayEntry entry;
    entry = OverlayEntry(
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned(
              left: anchor.x,
              top: anchor.y,
              width: nipWidth,
              height: nipWidth,
              child: Transform.rotate(
                angle: 40,
                child: Material(
                  color: Colors.black,
                  elevation: 2,
                  child: Container(
                    width: nipWidth,
                    height: nipHeight,
                  ),
                ),
              ),
            ),
            Positioned(
              left: left,
              top: top,
              width: width,
              height: height,
              child: CustomPaint(
                painter: _BubblePainter(
                  color: Colors.black,
                  elevation: 2,
                  anchor: anchor,
                  topNip: topNip,
                  radius: radius,
                  shadowColor: Colors.black,
                ),
                child: ClipRRect(
                  child: _PopupChat(
                    actions: <Widget>[IconButton(onPressed: () {
                      chatVisible.value = false;
                      entry.remove();
                    }, icon: Icon(Icons.close))],
                  ),
                  borderRadius: BorderRadius.all(radius),
                ),
              ),
            ),
          ],
        );
      },
    );
    Overlay.of(context).insert(entry);
  }
}

class _BubblePainter extends CustomPainter {
  final Color color;
  final double elevation;
  final Color shadowColor;
  final Radius radius;
  final bool topNip;
  final Point anchor;

  _BubblePainter({
    this.color,
    this.anchor,
    this.radius,
    this.topNip = false,
    this.elevation,
    this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke;
    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final shadowPath = Path();
    shadowPath.addRRect(RRect.fromLTRBR(0, 0, size.width, size.height, radius));

    if (elevation != 0.0) {
      canvas.drawShadow(shadowPath, shadowColor, elevation, false);
    }
    final rectPath = Path();
    rectPath.addRRect(RRect.fromLTRBR(0, 0, size.width, size.height, radius));

    canvas.drawPath(rectPath, bgPaint);
    canvas.drawPath(rectPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}
