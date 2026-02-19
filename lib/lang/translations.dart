import 'language_model.dart';
import 'language_service.dart';

// Global instance of LanguageService
LanguageService? _languageService;

// Initialize the language service
void initLanguageService(LanguageService service) {
  _languageService = service;
}

// Get the current language service instance
LanguageService get languageService => _languageService!;

// Translation helper functions
class T {
  // Get translation for a key
  static String get(String key) {
    return _languageService?.translate(key) ?? key;
  }

  // Get translation with fallback
  static String getWithFallback(String key, String fallback) {
    return _languageService?.translateWithFallback(key, fallback) ?? fallback;
  }

  // Get current language
  static Language get currentLanguage =>
      _languageService?.currentLanguage ??
      LanguageData.supportedLanguages.first;

  // Get current language code
  static String get currentLanguageCode =>
      _languageService?.currentLanguageCode ?? 'en';

  // Get current language name
  static String get currentLanguageName =>
      _languageService?.currentLanguageName ?? 'English';

  // Get current language native name
  static String get currentLanguageNativeName =>
      _languageService?.currentLanguageNativeName ?? 'English';

  // Get current language flag
  static String get currentLanguageFlag =>
      _languageService?.currentLanguageFlag ?? '🇺🇸';

  // Check if current language is English
  static bool get isEnglish => _languageService?.isEnglish ?? true;

  // Check if current language is Khmer
  static bool get isKhmer => _languageService?.isKhmer ?? false;

  // Get all supported languages
  static List<Language> get supportedLanguages =>
      _languageService?.supportedLanguages ?? LanguageData.supportedLanguages;

  // Get language names for UI
  static List<String> get languageNames =>
      _languageService?.languageNames ?? LanguageData.getLanguageNames();

  // Get language native names for UI
  static List<String> get languageNativeNames =>
      _languageService?.languageNativeNames ??
      LanguageData.getLanguageNativeNames();

  // Get language codes
  static List<String> get languageCodes =>
      _languageService?.languageCodes ?? LanguageData.getLanguageCodes();

  // Change language
  static Future<void> changeLanguage(String languageCode) async {
    await _languageService?.changeLanguage(languageCode);
  }

  // Change language by name
  static Future<void> changeLanguageByName(String languageName) async {
    await _languageService?.changeLanguageByName(languageName);
  }
}

// Common translation keys
class TranslationKeys {
  // Profile related
  static const String profile = 'profile';
  static const String editProfile = 'edit_profile';
  static const String language = 'language';
  static const String logout = 'logout';
  static const String bio = 'bio';
  static const String about = 'about';
  static const String email = 'email';
  static const String phone = 'phone';
  static const String links = 'links';
  static const String addLinks = 'add_links';

  // Language selection
  static const String chooseLanguage = 'choose_language';
  static const String cancel = 'cancel';
  static const String languageChanged = 'language_changed';

  // Loading and errors
  static const String loadingProfile = 'loading_profile';
  static const String errorLoadingProfile = 'error_loading_profile';
  static const String retry = 'retry';

  // Logout
  static const String logoutConfirmation = 'logout_confirmation';
  static const String logoutSuccess = 'logout_success';
  static const String sessionExpired = 'session_expired';
  static const String authTokenNotFound = 'auth_token_not_found';
  static const String failedToLoadProfile = 'failed_to_load_profile';
  static const String errorLoadingProfileDesc = 'error_loading_profile_desc';

  // Bio content
  static const String heyThere = 'hey_there';
  static const String myselfFahim = 'myself_fahim';

  // Cart related
  static const String myCart = 'my_cart';
  static const String yourCartIsEmpty = 'your_cart_is_empty';
  static const String addCoffeeToCart = 'add_coffee_to_cart';
  static const String browseCoffee = 'browse_coffee';
  static const String qty = 'qty';
  static const String cart = 'cart';
  static const String discount = 'discount';
  static const String shipping = 'shipping';
  static const String total = 'total';
  static const String orderNow = 'order_now';
  static const String proceedingToCheckout = 'proceeding_to_checkout';
  static const String selectPaymentMethod = 'select_payment_method';
  static const String creditCard = 'credit_card';
  static const String bankTransfer = 'bank_transfer';
  static const String cashOnDelivery = 'cash_on_delivery';
  static const String paymentMethodSelected = 'payment_method_selected';
  static const String paymentMethods = 'payment_methods';
  static const String abaPay = 'aba_pay';
  static const String abaPayDesc = 'aba_pay_desc';
  static const String wing = 'wing';
  static const String wingDesc = 'wing_desc';
  static const String creditCardDesc = 'credit_card_desc';
  static const String bankTransferDesc = 'bank_transfer_desc';
  static const String cashOnDeliveryDesc = 'cash_on_delivery_desc';
  static const String selectPaymentTiming = 'select_payment_timing';
  static const String selectedPaymentMethod = 'selected_payment_method';
  static const String payNow = 'pay_now';
  static const String payNowDesc = 'pay_now_desc';
  static const String payInShop = 'pay_in_shop';
  static const String payInShopDesc = 'pay_in_shop_desc';
  static const String back = 'back';
  static const String orderPlacedSuccessfully = 'order_placed_successfully';
  static const String paymentMethod = 'payment_method';
  static const String paymentTiming = 'payment_timing';
  static const String orderNumber = 'order_number';
  static const String orderNumberLabel = 'order_number_label';
  static const String orderCreationFailed = 'order_creation_failed';
  static const String userNotAuthenticated = 'user_not_authenticated';
  static const String cartCleared = 'cart_cleared';
  static const String loadingProducts = 'loading_products';
  static const String noProductsAvailable = 'no_products_available';
  static const String checkBackLater = 'check_back_later';
  // Favorites related
  static const String favorites = 'favorites';
  static const String recipes = 'recipes';
  static const String noFavoritesYet = 'no_favorites_yet';
  static const String startAddingFavorites = 'start_adding_favorites';
  static const String ingredients = 'ingredients';
  static const String shareRecipe = 'share_recipe';
  static const String editRecipe = 'edit_recipe';
  static const String removeFromFavorites = 'remove_from_favorites';
  static const String recipeShared = 'recipe_shared';
  static const String editRecipeTapped = 'edit_recipe_tapped';

  // Home screen related
  static const String searchCoffee = 'search_coffee';
  static const String specialOffers = 'special_offers';
  static const String seeAll = 'see_all';
  static const String categories = 'categories';
  static const String shopByCategories = 'shop_by_categories';
  static const String notificationsClicked = 'notifications_clicked';
  static const String filterClicked = 'filter_clicked';
  static const String seeAllClicked = 'see_all_clicked';
  static const String addedToCart = 'added_to_cart';
  static const String alreadyInCart = 'already_in_cart';
  static const String addedToFavorites = 'added_to_favorites';
  static const String removedFromFavorites = 'removed_from_favorites';

  // Recipe options
  static const String recipeOptions = 'recipe_options';

  // Bottom navigation
  static const String home = 'home';

  // Coffee detail screen
  static const String coffeeDetail = 'coffee_detail';
  static const String description = 'description';
  static const String readMore = 'read_more';
  static const String readLess = 'read_less';
  static const String cupSize = 'cup_size';
  static const String sugarLevel = 'sugar_level';
  static const String less = 'less';
  static const String half = 'half';
  static const String normal = 'normal';
  static const String extra = 'extra';
  static const String orderType = 'order_type';
  static const String delivery = 'delivery';
  static const String pickUp = 'pick_up';
  static const String specialInstructions = 'special_instructions';
  static const String specialInstructionsHint = 'special_instructions_hint';
  static const String addToCart = 'add_to_cart';

  // Signin screen
  static const String signIn = 'sign_in';
  static const String username = 'username';
  static const String emailLabel = 'email_label';
  static const String phoneLabel = 'phone_label';
  static const String password = 'password';
  static const String loginWith = 'login_with';
  static const String orContinueWith = 'or_continue_with';
  static const String dontHaveAccount = 'dont_have_account';
  static const String signUp = 'sign_up';
  static const String alreadyLoggedIn = 'already_logged_in';
  static const String alreadyLoggedInMessage = 'already_logged_in_message';
  static const String signedInSuccessfully = 'signed_in_successfully';
  static const String loginFailed = 'login_failed';
  static const String networkError = 'network_error';
  static const String error = 'error';
  static const String ok = 'ok';
  static const String loginWithEmail = 'login_with_email';
  static const String loginWithPhone = 'login_with_phone';
  static const String loginWithUsername = 'login_with_username';

  // Language selection
  static const String selectLanguage = 'select_language';
  static const String khmer = 'khmer';
  static const String english = 'english';

  // Signup screen
  static const String createAccount = 'create_account';
  static const String yourName = 'your_name';
  static const String yourEmail = 'your_email';
  static const String yourPhoneNumber = 'your_phone_number';
  static const String registerWith = 'register_with';
  static const String registerWithEmail = 'register_with_email';
  static const String registerWithPhone = 'register_with_phone';
  static const String passwordValidationMessage = 'password_validation_message';
  static const String iHaveReadAndAgree = 'i_have_read_and_agree';
  static const String termsAndConditions = 'terms_and_conditions';
  static const String and = 'and';
  static const String privacyPolicy = 'privacy_policy';
  static const String alreadyHaveAccount = 'already_have_account';
  static const String accountCreatedSuccessfully =
      'account_created_successfully';
  static const String registrationFailed = 'registration_failed';
  static const String socialLogin = 'social_login';
  static const String continueWithGoogle = 'continue_with_google';
  static const String continueWithFacebook = 'continue_with_facebook';
  static const String userRole = 'user_role';
  static const String customer = 'customer';
  static const String admin = 'admin';
  static const String staff = 'staff';

  // OTP related
  static const String normalSignup = 'normal_signup';
  static const String signupWithPhone = 'signup_with_phone';
  static const String getOtp = 'get_otp';
  static const String sendingOtp = 'sending_otp';
  static const String enterOtpCode = 'enter_otp_code';
  static const String otpSentSuccessfully = 'otp_sent_successfully';
  static const String failedToSendOtp = 'failed_to_send_otp';
  static const String invalidOtp = 'invalid_otp';
  static const String pleaseEnterPhoneNumber = 'please_enter_phone_number';
  static const String clickGetOtpFirst = 'click_get_otp_first';

  // Messages related
  static const String messages = 'messages';
  static const String noMessages = 'no_messages';

  // Order History related
  static const String orderHistory = 'order_history';
  static const String history = 'history';
  static const String myOrders = 'my_orders';
  static const String noOrdersYet = 'no_orders_yet';
  static const String startShopping = 'start_shopping';
  static const String orderDetails = 'order_details';
  static const String orderDate = 'order_date';
  static const String orderStatus = 'order_status';
  static const String pending = 'pending';
  static const String processing = 'processing';
  static const String delivered = 'delivered';
  static const String cancelled = 'cancelled';
  static const String reorder = 'reorder';
  static const String downloadReceipt = 'download_receipt';

  // Common
  static const String close = 'close';
}
