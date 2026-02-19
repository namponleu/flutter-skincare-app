import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'signin_screen.dart';
import '../api_url.dart';
import '../lang/index.dart';
import '../constants/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _id = '';
  String _username = '';
  String _phone = '';
  String _email = '';
  String _name = '';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Get auth token from local storage
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        setState(() {
          _errorMessage = T.get(TranslationKeys.authTokenNotFound);
          _isLoading = false;
        });
        return;
      }

      // Call profile API
      final response = await http.get(
        Uri.parse(ApiUrl.profileUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final userData = responseData['data'];
          setState(() {
            _id = userData['id']?.toString() ?? '';
            _username = userData['username'] ?? 'User';
            _phone = userData['tel'] ?? '+8850123456789';
            _email = userData['email'] ?? 'xxx@gmail.com';
            _name = userData['name'] ?? _username;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage =
                responseData['message'] ??
                T.get(TranslationKeys.failedToLoadProfile);
            _isLoading = false;
          });
        }
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        setState(() {
          _errorMessage = T.get(TranslationKeys.sessionExpired);
          _isLoading = false;
        });

        // Clear local data and redirect to login
        await prefs.clear();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const SigninScreen()),
            (route) => false,
          );
        }
      } else {
        setState(() {
          _errorMessage =
              '${T.get(TranslationKeys.failedToLoadProfile)}. Status: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '${T.get(TranslationKeys.errorLoadingProfileDesc)} $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.logout, color: Colors.red, size: 24),
              const SizedBox(width: 8),
              Text(
                T.get(TranslationKeys.logout),
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            T.get(TranslationKeys.logoutConfirmation),
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      try {
        // Get auth token from local storage
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');

        if (token != null) {
          // Call logout API
          final response = await http.post(
            Uri.parse(ApiUrl.logoutUrl),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          );

          if (response.statusCode == 200) {
            final responseData = jsonDecode(response.body);
            if (responseData['success'] == true) {
              // Show success message
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      responseData['message'] ??
                          T.get(TranslationKeys.logoutSuccess),
                    ),
                    backgroundColor: AppColors.brand,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            }
          } else {
            // Log the error but continue with logout
            print(
              'Logout API error: ${response.statusCode} - ${response.body}',
            );
          }
        }
      } catch (e) {
        // Log the error but continue with logout
        print('Logout API error: $e');
      }

      // Clear local data regardless of API response
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Navigate to signin screen
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SigninScreen()),
          (route) => false,
        );
      }
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.language, color: AppColors.brandDark, size: 24),
              const SizedBox(width: 8),
              Text(
                T.get(TranslationKeys.chooseLanguage),
                style: const TextStyle(
                  color: AppColors.brandDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: T.supportedLanguages.map((language) {
              return ListTile(
                leading: Text(
                  language.flag,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(
                  language.nativeName != language.name
                      ? '${language.nativeName} (${language.name})'
                      : language.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: T.currentLanguageCode == language.code
                    ? const Icon(
                        Icons.check_circle,
                        color: Color(0xFF2E7D32),
                        size: 20,
                      )
                    : null,
                onTap: () async {
                  await T.changeLanguage(language.code);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${T.get(TranslationKeys.languageChanged)} ${language.nativeName != language.name ? '${language.nativeName} (${language.name})' : language.name}',
                      ),
                      backgroundColor: AppColors.brand,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                T.get(TranslationKeys.cancel),
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        if (_isLoading) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: AppColors.brandDark),
                    const SizedBox(height: 16),
                    Text(
                      T.get(TranslationKeys.loadingProfile),
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (_errorMessage != null) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        T.get(TranslationKeys.errorLoadingProfile),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadUserData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandDark,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: Text(T.get(TranslationKeys.retry)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // Profile Header Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Profile Picture
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/profile_pokemon.png',
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback to icon if image fails to load
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Name - Show real name if available, otherwise username
                      Text(
                        _name.isNotEmpty ? _name : _username,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // Edit Profile Button
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              T.get(TranslationKeys.editProfile),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadUserData,
                    color: AppColors.brandDark,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bio Section
                          Text(
                            T.get(TranslationKeys.bio),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            T.get(TranslationKeys.myselfFahim),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Contact and Information Section
                          _buildInfoItem(
                            icon: Icons.email,
                            label: T.get(TranslationKeys.email),
                            value: _email,
                          ),

                          const SizedBox(height: 20),

                          _buildInfoItem(
                            icon: Icons.info,
                            label: T.get(TranslationKeys.about),
                            value: T.get(TranslationKeys.heyThere),
                          ),

                          const SizedBox(height: 20),

                          _buildInfoItem(
                            icon: Icons.phone,
                            label: T.get(TranslationKeys.phone),
                            value: _phone,
                          ),

                          const SizedBox(height: 20),

                          _buildInfoItem(
                            icon: Icons.link,
                            label: T.get(TranslationKeys.links),
                            value: T.get(TranslationKeys.addLinks),
                            valueColor: AppColors.brand,
                          ),

                          const SizedBox(height: 32),

                          // Language Section
                          GestureDetector(
                            onTap: _showLanguageDialog,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.grey.shade200,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.language,
                                    size: 20,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    T.get(TranslationKeys.language),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      Text(
                                        T.currentLanguage.nativeName !=
                                                T.currentLanguage.name
                                            ? '${T.currentLanguage.nativeName} (${T.currentLanguage.name})'
                                            : T.currentLanguage.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Logout Section
                          GestureDetector(
                            onTap: _logout,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.grey.shade200,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.logout,
                                    size: 20,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    T.get(TranslationKeys.logout),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 16, color: valueColor ?? Colors.grey),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
