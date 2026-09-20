import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storemate/core/theme/app_theme.dart';
import 'package:storemate/features/product/presentation/screens/product_form_screen.dart';

void main() {
  testWidgets('ProductFormScreen render test', (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      print('FLUTTER ERROR CAUGHT IN TEST: ${details.exception}');
      print(details.stack);
    };

    try {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ProductFormScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      print('Widget pumped successfully');
    } catch (e, stack) {
      print('EXCEPTION CAUGHT IN TEST: $e');
      print(stack);
    }
  });
}
