import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/main.dart';

void main() {
  testWidgets('ProManage app builds the landing page', (WidgetTester tester) async {
    await tester.pumpWidget(const ProManageApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('ProManage'), findsWidgets);
  });
}
