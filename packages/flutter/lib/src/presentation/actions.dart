part of '../flutter_dalk_sdk.dart';

enum ActionButtonLocation { left, center, right }

class _PopupChat extends StatelessWidget {
  final List<Widget> actions;

  const _PopupChat({Key key, this.actions = const []}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final talkStore = Provider.of<DalkStore>(context);
    return Material(
      child: Observer(
        builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppBar(
              title: Text(talkStore.currentConversation.title),
              primary: false,
              actions: actions,
            ),
            Expanded(
              child: ConversationChat(
                conversation: talkStore.currentConversation,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DalkChatFloatingActionButton extends HookWidget {
  final Radius popupBorderRadius;
  final ActionButtonLocation location;
  final bool enabled;

  const DalkChatFloatingActionButton({Key key, this.popupBorderRadius = const Radius.circular(10), this.location, this.enabled = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chatVisible = useState<OverlayEntry>(null);
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
                painter: BubblePainter(
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

class DalkChatAction extends HookWidget {
  final Radius popupBorderRadius;

  DalkChatAction({Key key, this.popupBorderRadius = const Radius.circular(10)}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        _showChat(context);
      },
      icon: Icon(Icons.chat),
    );
  }

  void _showChat(BuildContext context) {
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
                painter: BubblePainter(
                  color: Colors.black,
                  elevation: 2,
                  anchor: anchor,
                  topNip: topNip,
                  radius: radius,
                  shadowColor: Colors.black,
                ),
                child: ClipRRect(
                  child: _PopupChat(
                    actions: <Widget>[IconButton(onPressed: () => entry.remove(), icon: Icon(Icons.close))],
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

class BubblePainter extends CustomPainter {
  final Color color;
  final double elevation;
  final Color shadowColor;
  final Radius radius;
  final bool topNip;
  final Point anchor;

  BubblePainter({
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
