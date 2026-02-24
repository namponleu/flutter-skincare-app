import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'lang/index.dart';
import 'constants/app_colors.dart';
import 'package:skincare/providers/cart_provider.dart';
import 'package:skincare/providers/favorite_provider.dart';

void main() {
  runApp(const SkinCareApp());
}

class SkinCareApp extends StatelessWidget {
  const SkinCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // language service (already exists)
        ChangeNotifierProvider(
          create: (context) {
            final languageService = LanguageService();
            initLanguageService(languageService);
            return languageService;
          },
        ),

        // Cart state - accessible anywhere in the app
        ChangeNotifierProvider(create: (_) => CartProvider()),

        // Favorite stata - loads persisted favorites on creation
        ChangeNotifierProvider(
          create: (_) => FavoriteProvider()..loadFavorites(),
        ),
      ],
      child: MaterialApp(
        title: 'Glowbabe Shop',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.brand, // Pink brand color
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home:
            const SplashScreen(), // Show splash screen and check authentication
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
