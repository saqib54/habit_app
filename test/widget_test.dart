import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_app/main.dart';
import 'package:habit_app/signup_screen.dart'; // This imports HabitApp

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app using HabitApp instead of MyApp
    await tester.pumpWidget(const HabitApp());

    // Verify the app launches
    expect(find.byType(MaterialApp), findsOneWidget);

    // Since your home is SignupScreen, check for that
    expect(find.byType(SignupScreen), findsOneWidget);
  });
}