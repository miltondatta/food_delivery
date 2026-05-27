import 'package:flutter_test/flutter_test.dart';
import 'package:luick/app/luick_app.dart';

void main() {
  testWidgets('Luick shell renders foundation status', (tester) async {
    await tester.pumpWidget(const LuickApp());

    expect(find.text('luick'), findsOneWidget);
    expect(find.text('Luick delivery foundation'), findsOneWidget);
    expect(find.text('Flutter native shell'), findsOneWidget);
    expect(find.text('Supabase config'), findsOneWidget);
  });
}
