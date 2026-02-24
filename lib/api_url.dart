class ApiUrl {
  // Base URL for the API
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL', // api_base_url input from the terminal when build for production
    // defaultValue: 'http://127.0.0.1:8000/api'
    defaultValue: 'http://10.0.2.2:8000/api', // this is for run with emmulator device
  );
  
  // static const String baseUrl = 'http://127.0.0.1:8000/api';

  // API Endpoints
  static const String register = '/register';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String profile = '/profile';
  static const String updateProfile = '/update-profile';
  static const String orders = '/orders';
  static const String productCategories = '/products/categories';
  static const String products = '/products';
  static const String banners = '/banners';
  static const String messages = '/messages';
  static const String sendOtp = '/send-otp';
  static const String verifyOtp = '/verify-otp';

  // Full URLs for convenience
  static const String registerUrl = '$baseUrl$register';
  static const String loginUrl = '$baseUrl$login';
  static const String profileUrl = '$baseUrl$profile';
  static const String logoutUrl = '$baseUrl$logout';
  static const String updateProfileUrl = '$baseUrl$updateProfile';
  static const String ordersUrl = '$baseUrl$orders';
  static const String productCategoriesUrl = '$baseUrl$productCategories';
  static const String productsUrl = '$baseUrl$products';
  static const String bannersUrl = '$baseUrl$banners';
  static const String messagesUrl = '$baseUrl$messages';
  static const String sendOtpUrl = '$baseUrl$sendOtp';
  static const String verifyOtpUrl = '$baseUrl$verifyOtp';
  static String getMessagesUrl(int userId) => '$baseUrl$messages/$userId';
}
