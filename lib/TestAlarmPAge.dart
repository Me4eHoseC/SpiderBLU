import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Model with ChangeNotifier {
  final ValueNotifier<int> alarmCounter = ValueNotifier(0);
}

class AlarmCounterPage extends StatefulWidget {
  AlarmCounterPage({super.key});

  @override
  State createState() => _AlarmCounterPage();

  Model model = Model();

  void alarmReceived() {
    var value = model.alarmCounter.value;
    model.alarmCounter.value = value + 1;
    print(model.alarmCounter.value);
  }
}

class _AlarmCounterPage extends State<AlarmCounterPage>
    with TickerProviderStateMixin {
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Provider<Model>(
        create: (context) => widget.model,
        child: Consumer<Model>(
          builder: (context, value, child) {
            return ValueListenableProvider<int>.value(
              value: value.alarmCounter,
              child: AlarmCounterPage(),
            );
          },
        ),
      ),
    );
  }
}
