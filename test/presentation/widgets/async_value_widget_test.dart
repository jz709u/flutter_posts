import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_demo/presentation/widgets/async_value_widget.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('AsyncValueWidget', () {
    testWidgets('shows CircularProgressIndicator while loading',
        (tester) async {
      await tester.pumpWidget(
        _wrap(AsyncValueWidget<String>(
          value: const AsyncValue.loading(),
          data: (v) => Text(v),
        )),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('shows error text on failure', (tester) async {
      await tester.pumpWidget(
        _wrap(AsyncValueWidget<String>(
          value: AsyncValue.error('something went wrong', StackTrace.empty),
          data: (v) => Text(v),
        )),
      );

      expect(find.textContaining('something went wrong'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('calls data builder and renders value', (tester) async {
      await tester.pumpWidget(
        _wrap(AsyncValueWidget<String>(
          value: const AsyncValue.data('hello world'),
          data: (v) => Text(v),
        )),
      );

      expect(find.text('hello world'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('rebuilds when value transitions loading → data',
        (tester) async {
      AsyncValue<String> value = const AsyncValue.loading();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (_, setState) => Column(
                children: [
                  AsyncValueWidget<String>(
                    value: value,
                    data: (v) => Text(v),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        setState(() => value = const AsyncValue.data('loaded')),
                    child: const Text('trigger'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(find.text('trigger'));
      await tester.pump();

      expect(find.text('loaded'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
