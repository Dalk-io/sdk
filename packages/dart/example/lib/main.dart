import 'package:dalk/app.dart';

void main() {
  Flavor.current = Flavor(Env.prod);
  launch();
}
