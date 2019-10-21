import 'dart:async';

import 'package:state_queue/state_queue.dart';
import 'package:pedantic/pedantic.dart';
import 'package:test/test.dart';

class _TestBloc extends StateQueue<int> {
  _TestBloc() : super(0);

  void setState(int n) {
    run((state) async* {
      yield n;
    });
  }

  void divideStateBy(int n) {
    run((state) async* {
      yield state ~/ n;
    });
  }
}

void main() {
  test('Continues with next `run` after error', () async {
    final completer = Completer<int>();
    var log = '';

    unawaited(
      // running this in a zone in order to be able to surpress the error logging to the console
      runZoned<Future<void>>(
        () async {
          final bloc = _TestBloc()
            ..setState(100)
            ..divideStateBy(0)
            ..divideStateBy(2);

          await bloc.runQueuedTasksToCompletion();

          completer.complete(bloc.value);
        },
        zoneSpecification: ZoneSpecification(
          print: (_, __, ___, text) {
            log += text;
          },
        ),
      ),
    );

    expect(
      await completer.future,
      50,
    );
    expect(log.contains('IntegerDivisionByZeroException'), true);
  });
}
