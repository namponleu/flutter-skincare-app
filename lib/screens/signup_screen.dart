import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'signin_screen.dart';
import '../api_url.dart';
import '../lang/index.dart';
import '../constants/app_colors.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isPasswordValid = false;
  bool _isTermsAccepted = false;
  bool _isLoading = false;

  // Signup method: 'normal' or 'phone'
  String _signupMethod = 'normal';

  // OTP related
  bool _otpSent = false;
  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;
  String? _otpSessionId; // Store session ID from OTP response

  @override
  void initState() {
    super.initState();
    // Initialize with empty values
    _nameController.text = "";
    _phoneController.text = "";
    _passwordController.text = "";
    _otpController.text = "";

    _checkPasswordValidity();
    _isTermsAccepted = true; // Pre-checked as shown in image

    _nameController.addListener(_checkPasswordValidity);
    _phoneController.addListener(_checkPasswordValidity);
    _passwordController.addListener(_checkPasswordValidity);
    _otpController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _checkPasswordValidity() {
    setState(() {
      _isPasswordValid =
          _passwordController.text.length >= 8 &&
          RegExp(r'\d').hasMatch(_passwordController.text);
    });
  }

  bool _isFormValid() {
    if (_signupMethod == 'phone') {
      // For phone OTP signup, need phone, password, OTP, and terms accepted
      return _phoneController.text.isNotEmpty &&
          _isPasswordValid &&
          _otpSent &&
          _otpController.text.isNotEmpty &&
          _isTermsAccepted;
    } else {
      // For normal signup, need name, phone, password, and terms accepted
      return _nameController.text.isNotEmpty &&
          _phoneController.text.isNotEmpty &&
          _isPasswordValid &&
          _isTermsAccepted;
    }
  }

  // Send OTP to phone number
  Future<void> _sendOtp() async {
    if (_phoneController.text.isEmpty) {
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
      // Get auth token if available (for authenticated users)
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      // Prepare headers
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Add Authorization header if token exists
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final phoneNumber = _phoneController.text.trim();
      print('📱 Sending OTP to: $phoneNumber');
      print('🔑 Has token: ${token != null && token.isNotEmpty}');
      print('🌐 URL: ${ApiUrl.sendOtpUrl}');

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

        print('✅ OTP sent successfully. Session ID: $_otpSessionId');

        // Extract OTP code from response if available (for testing when SMS not configured)
        final otpCode = responseData['data']?['otp'];

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

        // Show OTP code in popup if available (for testing)
        if (otpCode != null) {
          _showOtpDialog(otpCode.toString(), _otpSessionId ?? '');
        }
      } else if (response.statusCode == 401) {
        // Unauthorized - token required
        print('❌ 401 Unauthorized - Authentication required');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              responseData['message'] ??
                  'Authentication required. Please login first.',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
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
        print('❌ Error: $errorMessage');
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

  // Verify OTP
  Future<bool> _verifyOtp() async {
    if (_otpController.text.isEmpty || _otpSessionId == null) {
      return false;
    }

    setState(() {
      _isVerifyingOtp = true;
    });

    try {
      // Get auth token if available (for authenticated users)
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      // Prepare headers
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Add Authorization header if token exists
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      print('Verifying OTP for: ${_phoneController.text.trim()}');
      print('OTP: ${_otpController.text.trim()}');
      print('Session ID: $_otpSessionId');

      final response = await http.post(
        Uri.parse(ApiUrl.verifyOtpUrl),
        headers: headers,
        body: jsonEncode({
          'tel': _phoneController.text.trim(),
          'otp': _otpController.text.trim(),
          'session_id': _otpSessionId,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return true;
      } else if (response.statusCode == 401) {
        // Unauthorized - token required
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              responseData['message'] ??
                  'Authentication required. Please login first.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      } else {
        String errorMessage = T.get(TranslationKeys.invalidOtp);
        if (responseData['message'] != null) {
          errorMessage = responseData['message'];
        } else if (responseData['errors'] != null) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          if (errors['otp'] != null) {
            errorMessage = errors['otp'].toString();
          } else {
            errorMessage = errors.values.first.toString();
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${T.get(TranslationKeys.networkError)}: ${e.toString()}',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    } finally {
      setState(() {
        _isVerifyingOtp = false;
      });
    }
  }

  Future<void> _registerUser() async {
    if (!_isFormValid()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // If phone OTP signup, verify OTP first
      if (_signupMethod == 'phone') {
        final isOtpValid = await _verifyOtp();
        if (!isOtpValid) {
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // Prepare registration data
      final Map<String, dynamic> registrationData = {};

      if (_signupMethod == 'normal') {
        // Normal signup: username and tel are separate fields
        // username comes from name input field (text, NOT phone number)
        registrationData['username'] = _nameController.text.trim();
        // name field is required by backend
        registrationData['name'] = _nameController.text.trim();
        // tel is separate from username
        registrationData['tel'] = _phoneController.text.trim();
        // user_type: use "customer" (backend doesn't accept "user")
        registrationData['user_type'] = 'customer';
        // Don't send registration_method (will be NULL in database)
        registrationData['password'] = _passwordController.text;
        registrationData['terms_accepted'] = _isTermsAccepted ? 1 : 0;
      } else {
        // Phone OTP signup: username = tel (phone number)
        registrationData['tel'] = _phoneController.text.trim();
        registrationData['user_type'] =
            'customer'; // Keep customer for phone OTP
        registrationData['username'] = _phoneController.text
            .trim(); // username = tel
        registrationData['password'] = _passwordController.text;
        registrationData['otp'] = _otpController.text.trim();
        registrationData['session_id'] = _otpSessionId;
        registrationData['terms_accepted'] = _isTermsAccepted ? 1 : 0;
      }

      print('📝 Registration data: $registrationData');
      print('🌐 Register URL: ${ApiUrl.registerUrl}');

      final response = await http.post(
        Uri.parse(ApiUrl.registerUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(registrationData),
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
        // Registration successful
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              responseData['message'] ??
                  T.get(TranslationKeys.accountCreatedSuccessfully),
            ),
            backgroundColor: AppColors.brand,
          ),
        );

        // Store token and user data locally
        if (responseData['data'] != null) {
          final data = responseData['data'] as Map<String, dynamic>;
          final token = data['access_token'] ?? data['token'];
          final user = data['user'] ?? data;

          if (token != null) {
            await _saveUserData(token.toString(), user as Map<String, dynamic>);
          }
        }

        // Navigate to home screen after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        });
      } else {
        // Registration failed
        String errorMessage = T.get(TranslationKeys.registrationFailed);
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

        print('❌ Registration failed: $errorMessage');
        print('❌ Full response: ${response.body}');

        // Show error as popup dialog
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

  // Show OTP code in popup dialog
  void _showOtpDialog(String otpCode, String sessionId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.sms_outlined, color: AppColors.brand, size: 24),
              const SizedBox(width: 8),
              Text(
                'OTP Code',
                style: const TextStyle(
                  color: AppColors.brand,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your OTP code is:',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.brand.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.brand, width: 2),
                ),
                child: Center(
                  child: Text(
                    otpCode,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brand,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ),
              if (sessionId.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Session ID:',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  sessionId,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
              const SizedBox(height: 12),
              const Text(
                'Note: This OTP is shown because SMS service is not configured.',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Auto-fill OTP code
                _otpController.text = otpCode;
              },
              child: Text(
                'Copy & Close',
                style: const TextStyle(
                  color: AppColors.brand,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                T.get(TranslationKeys.ok),
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  // Save user data to local storage (including role)
  Future<void> _saveUserData(
    String token,
    Map<String, dynamic> userData,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_id', userData['id'].toString());
    await prefs.setString('username', userData['username'] ?? '');
    await prefs.setString('phone', userData['tel'] ?? '');
    await prefs.setString('email', userData['email'] ?? '');

    // Store user role (Admin, Staff, Customer)
    final userType = userData['user_type'] ?? 'customer';
    await prefs.setString('user_type', userType.toString().toLowerCase());

    await prefs.setBool('isLoggedIn', true);
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
                  // Back button
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, size: 24),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),

                  const SizedBox(height: 20),

                  // Title
                  Center(
                    child: Text(
                      T.get(TranslationKeys.createAccount),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Signup Method Selection
                  _buildSignupMethodSelector(),

                  const SizedBox(height: 24),

                  // Name input field (only for normal signup)
                  if (_signupMethod == 'normal') ...[
                    _buildInputField(
                      controller: _nameController,
                      label: T.get(TranslationKeys.yourName),
                      icon: Icons.person_outline,
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Phone input field
                  _buildInputField(
                    controller: _phoneController,
                    label: T.get(TranslationKeys.yourPhoneNumber),
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 20),

                  // Password input field (for both signup methods)
                  _buildPasswordField(),
                  const SizedBox(height: 16),
                  // Password validation
                  if (_passwordController.text.isNotEmpty)
                    _buildValidationItem(
                      isValid: _isPasswordValid,
                      text: T.get(TranslationKeys.passwordValidationMessage),
                    ),
                  const SizedBox(height: 16),

                  // OTP section (only for phone signup)
                  if (_signupMethod == 'phone') ...[
                    _buildOtpSection(),
                    const SizedBox(height: 20),
                  ],

                  // Terms and conditions
                  _buildValidationItem(
                    isValid: _isTermsAccepted,
                    text: T.get(TranslationKeys.iHaveReadAndAgree),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Handle Terms & Conditions tap
                          },
                          child: Text(
                            T.get(TranslationKeys.termsAndConditions),
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(' ${T.get(TranslationKeys.and)} '),
                        GestureDetector(
                          onTap: () {
                            // Handle Privacy Policy tap
                          },
                          child: Text(
                            T.get(TranslationKeys.privacyPolicy),
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Sign Up button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isFormValid() && !_isLoading
                          ? _registerUser
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
                              T.get(TranslationKeys.signUp),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Already have account
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          T.get(TranslationKeys.alreadyHaveAccount),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Navigate to sign in screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SigninScreen(),
                              ),
                            );
                          },
                          child: Text(
                            T.get(TranslationKeys.signIn),
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

  Widget _buildSignupMethodSelector() {
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
                  _signupMethod = 'normal';
                  _otpSent = false;
                  _otpController.clear();
                  _otpSessionId = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _signupMethod == 'normal'
                      ? AppColors.brand
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    T.get(TranslationKeys.normalSignup),
                    style: TextStyle(
                      color: _signupMethod == 'normal'
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
                  _signupMethod = 'phone';
                  _otpSent = false;
                  _otpController.clear();
                  _otpSessionId = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _signupMethod == 'phone'
                      ? AppColors.brand
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    T.get(TranslationKeys.signupWithPhone),
                    style: TextStyle(
                      color: _signupMethod == 'phone'
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
            onPressed: _phoneController.text.isNotEmpty && !_isSendingOtp
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
                color: _phoneController.text.isNotEmpty && !_isSendingOtp
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
        _buildInputField(
          controller: _otpController,
          label: T.get(TranslationKeys.enterOtpCode),
          icon: Icons.lock_outline,
          keyboardType: TextInputType.number,
          enabled: _otpSent, // Only enable after OTP is sent
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: enabled ? Colors.black87 : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: enabled ? label : T.get(TranslationKeys.clickGetOtpFirst),
            prefixIcon: Icon(
              icon,
              color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
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
            fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
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

  Widget _buildValidationItem({
    required bool isValid,
    required String text,
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.circle_outlined,
          color: isValid ? AppColors.brand : Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 12,
                    color: isValid ? AppColors.brandDark : Colors.grey.shade600,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ],
    );
  }
}
