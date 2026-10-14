import 'package:adaptive/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows startup error screen when initialization fails', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp(startupError: 'test startup failure'));

    expect(find.text('Could not start the app'), findsOneWidget);
    expect(find.text('test startup failure'), findsOneWidget);
  });
}
