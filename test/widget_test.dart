import 'package:flutter_test/flutter_test.dart';
import 'package:lg_controller/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const LGControllerApp());

    // Verify the app title is displayed
    expect(find.text('Liquid Galaxy Control'), findsOneWidget);
  });
}
