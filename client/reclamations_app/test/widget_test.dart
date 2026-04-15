import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:reclamations_app/main.dart';

void main() {
  testWidgets('affiche l ecran de connexion au lancement', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Se connecter'), findsWidgets);
  });
}
