import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sign_in_with_apple/src/widgets/is_sign_in_with_apple_available.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

void main() {
  setUp(() {
    SignInWithApple.channel.setMockMethodCallHandler(null);
  });

  testWidgets(
    'Should render widget if Sign in with Apple is enabled',
    (tester) async {
      var calls = 0;

      SignInWithApple.channel.setMockMethodCallHandler((call) async {
        calls++;

        if (call.method == 'isAvailable') {
          return true;
        }

        throw UnimplementedError();
      });

      await tester.runAsync(() async {
        await tester.pumpWidget(
          IsSignInWithAppleAvailable.internal(
            isAvailableFuture: SignInWithApple.isAvailable(),
            child: Container(
              height: 20,
              width: 20,
            ),
          ),
        );

        await tester.pump();
      });

      expect(
        find.byType(Container),
        findsOneWidget,
      );

      expect(calls, 1);
    },
  );

  testWidgets(
    'Should render the fallback if Sign in with Apple is not available',
    (tester) async {
      var calls = 0;

      SignInWithApple.channel.setMockMethodCallHandler((call) async {
        calls++;

        if (call.method == 'isAvailable') {
          return false;
        }

        throw UnimplementedError();
      });

      await tester.runAsync(() async {
        await tester.pumpWidget(
          IsSignInWithAppleAvailable.internal(
            isAvailableFuture: SignInWithApple.isAvailable(),
            child: Builder(
              builder: (context) {
                /// This would crash if we would ever render this
                return null;
              },
            ),
            fallback: Container(
              height: 20,
              width: 20,
            ),
          ),
        );

        await tester.pump();
      });

      expect(
        find.byType(Container),
        findsOneWidget,
      );

      expect(calls, 1);
    },
  );
}
