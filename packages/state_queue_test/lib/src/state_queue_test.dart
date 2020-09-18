import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:state_queue/state_queue.dart';
import 'package:test/test.dart' as test;

@isTest
void blocTest<B extends StateQueue<State>, State>(
  String description, {
  @required B Function() build,
  FutureOr<void> Function(B bloc) act,
  Iterable<State> expect,
}) {
  test.test(description, () async {
    await runBlocTest<B, State>(
      build: build,
      act: act,
      expect: expect,
    );
  });
}

@visibleForTesting
Future<void> runBlocTest<B extends StateQueue<State>, State>({
  @required B Function() build,
  FutureOr<void> Function(B bloc) act,
  Iterable<State> expect,
}) async {
  final collectStates = expect != null;

  final states = <State>[];

  final bloc = build();

  void collectState() {
    states.add(bloc.value);
  }

  if (collectStates) {
    bloc.addListener(collectState);
  }

  if (collectStates) {
    states.add(bloc.value);
  }

  if (act != null) {
    await act(bloc);
  }

  // ignore: invalid_use_of_visible_for_testing_member
  await bloc.runQueuedTasksToCompletion();

  if (collectStates) {
    bloc.removeListener(collectState);
  }

  bloc.dispose();

  test.expect(states, expect);
}
