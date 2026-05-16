import 'package:flutter_test/flutter_test.dart';
import 'package:outreach_app/main.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const OutreachApp());
    await tester.pump();
    expect(find.text('Outreach Follow-ups'), findsOneWidget);
  });
}
