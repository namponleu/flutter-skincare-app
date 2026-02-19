import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'lang/index.dart';
import 'constants/app_colors.dart';

void main() {
  runApp(const SkinCareApp());
}

class SkinCareApp extends StatelessWidget {
  const SkinCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final languageService = LanguageService();
        initLanguageService(languageService);
        return languageService;
      },
      child: MaterialApp(
        title: 'Skin Care',
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
