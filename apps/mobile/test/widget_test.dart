import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:litera_ai_mobile/app/app.dart';

void main() {
  testWidgets('renders LITERA-AI app shell', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: LiteraAiApp()));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
