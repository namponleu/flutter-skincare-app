import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:skincare/item/array_item.dart';
import 'package:skincare/lang/language_service.dart';
import 'package:skincare/models/banner.dart';
import 'package:skincare/models/skincare_product.dart';
import 'package:skincare/providers/favorite_provider.dart';
import 'package:skincare/screens/home_screen.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    testWidgets('Renders HomeScreen with categories, products, and banners', (
      WidgetTester tester,
    ) async {
      // Prepare mockdata
      ArrayItem.categories = ['All', 'Skincare', 'Makeup'];
      ArrayItem.products = [
        SkinCareProduct(
          id: 1,
          name: 'Face Cream',
          description: 'It is for face',
          price: 10,
          image: '',
          rate: 5.0,
          category: 'Skincare',
          isActive: true,
        ),
        SkinCareProduct(
          id: 2,
          name: 'Lipstick',
          description: 'It is for lipstick',
          price: 15,
          image: '',
          rate: 5.0,
          category: 'Makeup',
          isActive: true,
        ),
      ];

      // For banners
      final banners = [
        BannerModel(
          id: 1,
          imageUrl: 'assets/images/banner1.png',
          status: true,
        ),
        BannerModel(
          id: 2,
          imageUrl: 'assets/images/banner2.png',
          status: true,
        ),
      ];

      // Wrapp HomeScreen with providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => FavoriteProvider()),
            ChangeNotifierProvider(create: (_) => LanguageService()),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      // Allow async calls (like initState) to complete
      await tester.pumpAndSettle();

      // Check if search bar is present
      expect(find.byType(TextField), findsOneWidget);

      // Check categories section
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Skincare'), findsOneWidget);
      expect(find.text('Makeup'), findsOneWidget);

      // Check product grid shows at least 1 product
      expect(find.text('Face Cream'), findsOneWidget);

      // Check banners exist (CarounselSlider renders Image widgets)
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('Search filters products correctly', (
      WidgetTester tester,
    ) async {
      // Prepare data
      ArrayItem.categories = ['All', 'Skincare'];
      ArrayItem.products = [
        SkinCareProduct(
          id: 1,
          name: 'Face Cream',
          description: 'It is for face',
          price: 10,
          image: '',
          category: 'Skincare',
          rate: 5,
          isActive: true,
        ),
      ];

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => FavoriteProvider()),
            ChangeNotifierProvider(create: (_) => LanguageService()),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Type in search field
      await tester.enterText(find.byType(TextField), 'Face');
      await tester.pumpAndSettle();

      // Product should still be visible
      expect(find.text('Face Cream'), findsOneWidget);

      // Type something not matching
      await tester.enterText(find.byType(TextField), 'Lipstick');
      await tester.pumpAndSettle();

      // Product should be not visible
      expect(find.text('Face Cream'), findsNothing);
      expect(find.text('No products is available'), findsOneWidget);
    });

    testWidgets('Tap on category filters products', (
      WidgetTester tester,
    ) async {
      ArrayItem.categories = ['All', 'Skincare', 'Makeup'];
      ArrayItem.products = [
        SkinCareProduct(
          id: 1,
          name: 'Face Cream',
          description: 'It is for face',
          price: 10,
          image: '',
          category: 'Skincare',
          rate: 5,
        ),
        SkinCareProduct(
          id: 2,
          name: 'Lipstick',
          description: 'It is for lipstick',
          price: 10,
          image: '',
          category: 'Makeup',
          rate: 5,
        ),
      ];

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => FavoriteProvider()),
            ChangeNotifierProvider(create: (_) => LanguageService()),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Makeup category
      await tester.tap(find.text('Makeup'));
      await tester.pumpAndSettle();

      // Only Lipstick should be visible
      expect(find.text('Lipstick'), findsOneWidget);
      expect(find.text('Face Cream'), findsNothing);
    });
  });
}
