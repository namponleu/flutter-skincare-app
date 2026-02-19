import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'signup_screen.dart';
import '../api_url.dart';
import '../lang/index.dart';
import '../constants/app_colors.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Login method: 'normal' or 'phone'
  String _loginMethod = 'normal';

  // OTP related
  bool _otpSent = false;
  bool _isSendingOtp = false;
  String? _otpSessionId;

  @override
  void initState() {
    super.initState();
    // Initialize with empty values
    _identifierController.text = "";
    _passwordController.text = "";
    _otpController.text = "";

    // Add listeners to trigger validation updates
    _identifierController.addListener(() {
      setState(() {});
    });
    _passwordController.addListener(() {
      setState(() {});
    });
    _otpController.addListener(() {
      setState(() {});
    });

    // Check if user is already logged in locally
    _checkLocalAuthStatus();
  }

  Future<void> _checkLocalAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final hasToken = prefs.getString('auth_token') != null;

    if (isLoggedIn && hasToken) {
      // User is already logged in locally, show message and redirect
      if (mounted) {
        _showInfoDialog(
          T.get(TranslationKeys.alreadyLoggedIn),
          T.get(TranslationKeys.alreadyLoggedInMessage),
          () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        );
      }
    }
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    // For both normal and phone login, just need identifier and password
    return _identifierController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty;
  }

  String _getLoginFieldName() {
    // Try to detect if input is email or phone
    final input = _identifierController.text.trim();
    if (input.contains('@')) {
      return 'email';
    } else if (RegExp(r'^[0-9]+$').hasMatch(input)) {
      return 'tel';
    } else {
      // Default to username
      return 'username';
    }
  }

  // Send OTP to phone number
  Future<void> _sendOtp() async {
    if (_identifierController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(T.get(TranslationKeys.pleaseEnterPhoneNumber)),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSendingOtp = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final phoneNumber = _identifierController.text.trim();
      print('📱 Sending OTP to: $phoneNumber');

      final response = await http.post(
        Uri.parse(ApiUrl.sendOtpUrl),
        headers: headers,
        body: jsonEncode({'tel': phoneNumber}),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['success'] == true) {
        setState(() {
          _otpSent = true;
          _otpSessionId =
              responseData['data']?['session_id'] ??
              responseData['data']?['otp_session_id'];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              responseData['message'] ??
                  T.get(TranslationKeys.otpSentSuccessfully),
            ),
            backgroundColor: AppColors.brand,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        String errorMessage = T.get(TranslationKeys.failedToSendOtp);
        if (responseData['message'] != null) {
          errorMessage = responseData['message'];
        } else if (responseData['errors'] != null) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          errorMessage = errors.values.first.toString();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      print('❌ Exception in _sendOtp: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${T.get(TranslationKeys.networkError)}: ${e.toString()}',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      setState(() {
        _isSendingOtp = false;
      });
    }
  }

  Future<void> _loginUser() async {
    if (!_isFormValid()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> loginData;

      if (_loginMethod == 'phone') {
        // Phone login: use tel field + password + login_method indicator
        loginData = {
          'tel': _identifierController.text.trim(),
          'password': _passwordController.text,
          'login_method': 'phone', // Tell API this is phone login
        };
      } else {
        // Normal login: use detected field (username/email/tel) + password + login_method indicator
        final loginField = _getLoginFieldName();
        loginData = {
          loginField: _identifierController.text.trim(),
          'password': _passwordController.text,
          'login_method': 'normal', // Tell API this is normal login
        };
      }

      print('🔐 Login method: $_loginMethod');
      print('📝 Login data: $loginData');
      print('🌐 Login URL: ${ApiUrl.loginUrl}');

      final response = await http.post(
        Uri.parse(ApiUrl.loginUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(loginData),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        print('❌ Failed to parse response: $e');
        _showErrorDialog(
          'Invalid response from server: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}',
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Accept both 200 and 201 as success status codes
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          responseData['success'] == true) {
        // Extract data from the API response structure first
        final data = responseData['data'];
        if (data == null) {
          throw Exception('No data field in response');
        }

        final token = data['access_token'] ?? data['token'];
        final userData = data['user'] ?? data;
        final alreadyLoggedIn = data['already_logged_in'] ?? false;

        // Show success message from API
        final message =
            responseData['message'] ??
            T.get(TranslationKeys.signedInSuccessfully);
        final backgroundColor = alreadyLoggedIn
            ? Colors.orange
            : AppColors.brand;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: backgroundColor,
            duration: Duration(seconds: alreadyLoggedIn ? 3 : 2),
          ),
        );

        if (token == null) {
          throw Exception('Missing access_token or token in response');
        }

        // Handle userData - it might be a Map or the data itself
        Map<String, dynamic> userDataMap;
        if (userData is Map<String, dynamic>) {
          userDataMap = userData;
        } else {
          // If userData is not a map, use the data object itself
          userDataMap = data as Map<String, dynamic>;
        }

        await _saveUserData(token.toString(), userDataMap);

        // Navigate to home screen after a short delay
        print('Login successful, navigating to home screen in 1 second...');
        Future.delayed(const Duration(seconds: 1), () {
          print('Navigating to home screen now...');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        });
      } else {
        // Login failed
        String errorMessage = T.get(TranslationKeys.loginFailed);
        if (responseData['errors'] != null) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          // Collect all error messages
          final List<String> errorMessages = [];
          errors.forEach((key, value) {
            if (value is List) {
              errorMessages.addAll(value.map((e) => e.toString()));
            } else {
              errorMessages.add(value.toString());
            }
          });
          errorMessage = errorMessages.join('\n');
        } else if (responseData['message'] != null) {
          errorMessage = responseData['message'];
        }

        print('❌ Login failed: $errorMessage');
        print('❌ Full response: ${response.body}');

        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      // Network or other error
      _showErrorDialog(
        '${T.get(TranslationKeys.networkError)}: ${e.toString()}',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Save user data to local storage (including role)
  Future<void> _saveUserData(
    String token,
    Map<String, dynamic> userData,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_id', userData['id']?.toString() ?? '0');
    await prefs.setString('username', userData['username'] ?? 'User');
    await prefs.setString('phone', userData['tel'] ?? '');
    await prefs.setString('email', userData['email'] ?? '');

    // Store user role (Admin, Staff, Customer)
    final userType = userData['user_type'] ?? 'customer';
    await prefs.setString('user_type', userType.toString().toLowerCase());

    await prefs.setBool('isLoggedIn', true);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 24),
              const SizedBox(width: 8),
              Text(
                T.get(TranslationKeys.error),
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                T.get(TranslationKeys.ok),
                style: const TextStyle(
                  color: AppColors.brand,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showInfoDialog(String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button to close
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.brand, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.brand,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm(); // Execute the callback after closing dialog
              },
              child: Text(
                T.get(TranslationKeys.ok),
                style: const TextStyle(
                  color: AppColors.brand,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
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
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title - centered
                  Center(
                    child: Text(
                      T.get(TranslationKeys.signIn),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Login Method Selection
                  _buildLoginMethodSelector(),

                  const SizedBox(height: 24),

                  // Username/Email/Phone input field
                  _buildIdentifierField(),

                  const SizedBox(height: 20),

                  // Password input field
                  _buildPasswordField(),

                  const SizedBox(height: 40),

                  // Sign In button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isFormValid() && !_isLoading
                          ? _loginUser
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brand,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              T.get(TranslationKeys.signIn),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Language Selection
                  Center(
                    child: Column(
                      children: [
                        Text(
                          T.get(TranslationKeys.selectLanguage),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLanguageOption(
                              '🇰🇭',
                              T.get(TranslationKeys.khmer),
                              'kh',
                            ),
                            const SizedBox(width: 20),
                            _buildLanguageOption(
                              '🇬🇧',
                              T.get(TranslationKeys.english),
                              'en',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Don't have account
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          T.get(TranslationKeys.dontHaveAccount),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Navigate to signup screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignupScreen(),
                              ),
                            );
                          },
                          child: Text(
                            T.get(TranslationKeys.signUp),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIdentifierField() {
    // Change label based on login method
    final String label;
    final IconData icon;
    final TextInputType keyboardType;

    if (_loginMethod == 'phone') {
      label = T.get(TranslationKeys.yourPhoneNumber);
      icon = Icons.phone_outlined;
      keyboardType = TextInputType.phone;
    } else {
      // Normal login: username/email/phone
      label = T.get(TranslationKeys.username);
      icon = Icons.person_outline;
      keyboardType = TextInputType.text;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _identifierController,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: label,
            prefixIcon: Icon(icon, color: Colors.grey.shade600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.brand),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          T.get(TranslationKeys.password),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            hintText: T.get(TranslationKeys.password),
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey.shade600,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.brand),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginMethodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _loginMethod = 'normal';
                  _otpSent = false;
                  _otpController.clear();
                  _otpSessionId = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _loginMethod == 'normal'
                      ? AppColors.brand
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    T.get(TranslationKeys.signIn),
                    style: TextStyle(
                      color: _loginMethod == 'normal'
                          ? Colors.white
                          : Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _loginMethod = 'phone';
                  _otpSent = false;
                  _otpController.clear();
                  _otpSessionId = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _loginMethod == 'phone'
                      ? AppColors.brand
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    T.get(TranslationKeys.loginWithPhone),
                    style: TextStyle(
                      color: _loginMethod == 'phone'
                          ? Colors.white
                          : Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Get OTP Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _identifierController.text.isNotEmpty && !_isSendingOtp
                ? _sendOtp
                : null,
            icon: _isSendingOtp
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.brand,
                      ),
                    ),
                  )
                : const Icon(Icons.sms_outlined, size: 20),
            label: Text(
              _isSendingOtp
                  ? T.get(TranslationKeys.sendingOtp)
                  : T.get(TranslationKeys.getOtp),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: _identifierController.text.isNotEmpty && !_isSendingOtp
                    ? AppColors.brand
                    : Colors.grey.shade300,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        // OTP Input Field (always visible, enabled after OTP is sent)
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              T.get(TranslationKeys.enterOtpCode),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _otpSent ? Colors.black87 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              enabled: _otpSent,
              decoration: InputDecoration(
                hintText: _otpSent
                    ? T.get(TranslationKeys.enterOtpCode)
                    : T.get(TranslationKeys.clickGetOtpFirst),
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: _otpSent ? Colors.grey.shade600 : Colors.grey.shade400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.brand),
                ),
                filled: true,
                fillColor: _otpSent
                    ? Colors.grey.shade50
                    : Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLanguageOption(
    String flag,
    String languageName,
    String languageCode,
  ) {
    return GestureDetector(
      onTap: () async {
        await T.changeLanguage(languageCode);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${T.get('language_changed')} $languageName'),
            backgroundColor: AppColors.brand,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: T.currentLanguageCode == languageCode
                ? AppColors.brand
                : Colors.grey.shade300,
            width: T.currentLanguageCode == languageCode ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: T.currentLanguageCode == languageCode
              ? AppColors.brand.withOpacity(0.1)
              : Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              languageName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: T.currentLanguageCode == languageCode
                    ? AppColors.brand
                    : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
