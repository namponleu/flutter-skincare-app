class Language {
  final String code;
  final String name;
  final String nativeName;
  final String flag;
  final Map<String, String> translations;

  const Language({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.translations,
  });

  @override
  String toString() => name;
}

class LanguageData {
  static const List<Language> supportedLanguages = [
    Language(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flag: '🇺🇸',
      translations: {
        'profile': 'Profile',
        'edit_profile': 'Edit Profile',
        'language': 'Language',
        'logout': 'Logout',
        'bio': 'Bio',
        'about': 'About',
        'email': 'Email',
        'phone': 'Phone',
        'links': 'Links',
        'add_links': 'Add Links',
        'choose_language': 'Choose Language',
        'cancel': 'Cancel',
        'loading_profile': 'Loading profile...',
        'error_loading_profile': 'Error Loading Profile',
        'retry': 'Retry',
        'logout_confirmation': 'Are you sure you want to logout?',
        'logout_success': 'Logged out successfully',
        'session_expired': 'Session expired. Please login again.',
        'auth_token_not_found': 'Authentication token not found',
        'failed_to_load_profile': 'Failed to load profile',
        'error_loading_profile_desc': 'Error loading profile:',
        'hey_there': 'Hey there!',
        'myself_fahim':
            'Myself Fahim. I am a UI/UX designer. I love design and read books.',

        // Cart related
        'my_cart': 'My Cart',
        'your_cart_is_empty': 'Your cart is empty',
        'add_coffee_to_cart': 'Add some skin care products to get started!',
        'browse_coffee': 'Browse Products',
        'qty': 'Qty',
        'cart': 'Cart',
        'discount': 'Discount',
        'shipping': 'Shipping',
        'total': 'Total',
        'order_now': 'Order Now',
        'proceeding_to_checkout': 'Proceeding to checkout...',
        'select_payment_method': 'Select Payment Method',
        'credit_card': 'Credit Card',
        'bank_transfer': 'Bank Transfer',
        'cash_on_delivery': 'Cash on Delivery',
        'payment_method_selected': 'Payment method selected',
        'payment_methods': 'Payment Methods',
        'aba_pay': 'ABA Pay',
        'aba_pay_desc': 'Pay with ABA Bank',
        'wing': 'WING',
        'wing_desc': 'Pay with WING',
        'credit_card_desc': 'Pay with credit/debit card',
        'bank_transfer_desc': 'Direct bank transfer',
        'cash_on_delivery_desc': 'Pay when you receive',
        'select_payment_timing': 'Select Payment Timing',
        'selected_payment_method': 'Selected Payment Method',
        'pay_now': 'Pay Now',
        'pay_now_desc': 'Complete payment immediately',
        'pay_in_shop': 'Pay in Shop',
        'pay_in_shop_desc': 'Pay when you visit the shop',
        'back': 'Back',
        'order_placed_successfully': 'Order placed successfully!',
        'payment_method': 'Payment Method',
        'payment_timing': 'Payment Timing',
        'order_number': 'Order Number',
        'order_creation_failed': 'Failed to create order',
        'user_not_authenticated': 'User not authenticated',
        'cart_cleared': 'Cart has been cleared',
        'loading_products': 'Loading products...',
        'no_products_available': 'No products available',
        'check_back_later': 'Check back later for new products',

        // Favorites related
        'favorites': 'Favorites',
        'recipes': 'recipes',
        'no_favorites_yet': 'No favorites yet',
        'start_adding_favorites': 'Start adding your favorite recipes!',
        'ingredients': 'ingredients',
        'share_recipe': 'Share Recipe',
        'edit_recipe': 'Edit Recipe',
        'remove_from_favorites': 'Remove from Favorites',
        'recipe_shared': 'Recipe shared!',
        'edit_recipe_tapped': 'Edit recipe tapped!',

        // Home screen related
        'search_coffee': 'Search Products...',
        'special_offers': 'Special Offers',
        'see_all': 'See All',
        'categories': 'Categories',
        'shop_by_categories': 'Shop by Categories',
        'notifications_clicked': 'Notifications clicked!',
        'filter_clicked': 'Filter clicked!',
        'see_all_clicked': 'See All clicked!',
        'added_to_cart': 'added to cart!',
        'already_in_cart': 'is already in your cart!',
        'added_to_favorites': 'added to favorites!',
        'removed_from_favorites': 'removed from favorites!',

        // Recipe options
        'recipe_options': 'Recipe Options',

        // Bottom navigation
        'home': 'Home',

        // Skin care detail screen
        'coffee_detail': 'Product Detail',
        'description': 'Description',
        'read_more': 'Read More',
        'read_less': 'Read Less',
        'cup_size': 'Size',
        'sugar_level': 'Intensity',
        'less': 'Light',
        'half': 'Medium',
        'normal': 'Normal',
        'extra': 'Strong',
        'order_type': 'Order Type',
        'delivery': 'Delivery',
        'pick_up': 'Pick up',
        'special_instructions': 'Special Instructions',
        'special_instructions_hint': 'Lorem ipsum dolor sit amet.',
        'add_to_cart': 'Add to Cart',

        // Signin screen
        'sign_in': 'Sign In',
        'username': 'Username',
        'email_label': 'Email',
        'phone_label': 'Phone',
        'password': 'Password',
        'login_with': 'Login with',
        'or_continue_with': 'Or continue with',
        'dont_have_account': "Don't have an account? ",
        'sign_up': 'Sign Up',
        'already_logged_in': 'Already Logged In',
        'already_logged_in_message':
            'You are already logged in. Redirecting to home screen...',
        'signed_in_successfully': 'Signed in successfully!',
        'login_failed': 'Login failed',
        'network_error': 'Network error',
        'error': 'Error',
        'ok': 'OK',
        'login_with_email': 'Login with Email',
        'login_with_phone': 'Login with Phone',
        'login_with_username': 'Login with Username',

        // Language selection
        'select_language': 'Select Language',
        'khmer': 'ខ្មែរ',
        'english': 'English',
        'language_changed': 'Language changed to',

        // Signup screen
        'create_account': 'Create account',
        'your_name': 'Your name',
        'your_email': 'Your email',
        'your_phone_number': 'Your phone number',
        'register_with': 'Register with',
        'register_with_email': 'Register with Email',
        'register_with_phone': 'Register with Phone',
        'password_validation_message':
            'The password must be at least 8 characters long and contain at least 1 number',
        'i_have_read_and_agree': 'I have read and agree to the ',
        'terms_and_conditions': 'Terms & Conditions',
        'and': 'and',
        'privacy_policy': 'Privacy Policy',
        'already_have_account': 'Already have an account? ',
        'account_created_successfully': 'Account created successfully!',
        'registration_failed': 'Registration failed',
        'social_login': 'Social Login',
        'continue_with_google': 'Continue with Google',
        'continue_with_facebook': 'Continue with Facebook',
        'user_role': 'User Role',
        'customer': 'Customer',
        'admin': 'Admin',
        'staff': 'Staff',

        // OTP related
        'normal_signup': 'Normal Signup',
        'signup_with_phone': 'Signup with Phone',
        'get_otp': 'Get OTP',
        'sending_otp': 'Sending OTP...',
        'enter_otp_code': 'Enter OTP Code',
        'otp_sent_successfully': 'OTP sent successfully',
        'failed_to_send_otp': 'Failed to send OTP',
        'invalid_otp': 'Invalid OTP code',
        'please_enter_phone_number': 'Please enter phone number',
        'click_get_otp_first': 'Click "Get OTP" first',

        // Messages related
        'messages': 'Messages',
        'no_messages': 'No messages yet',

        // Order History related
        'order_history': 'Order History',
        'history': 'History',
        'my_orders': 'My Orders',
        'no_orders_yet': 'No orders yet',
        'start_shopping': 'Start shopping to see your orders here',
        'order_details': 'Order Details',
        'order_number_label': 'Order #',
        'order_date': 'Order Date',
        'order_status': 'Order Status',
        'pending': 'Pending',
        'processing': 'Processing',
        'delivered': 'Delivered',
        'cancelled': 'Cancelled',
        'reorder': 'Reorder',
        'download_receipt': 'Download Receipt',

        'close': 'Close',
      },
    ),
    Language(
      code: 'kh',
      name: 'Khmer',
      nativeName: 'ខ្មែរ',
      flag: '🇰🇭',
      translations: {
        'profile': 'ប្រវត្តិរូប',
        'edit_profile': 'កែប្រែប្រវត្តិរូប',
        'language': 'ភាសា',
        'logout': 'ចាកចេញ',
        'bio': 'ជីវប្រវត្តិ',
        'about': 'អំពី',
        'email': 'អ៊ីមែល',
        'phone': 'លេខទូរស័ព្ទ',
        'links': 'តំណភ្ជាប់',
        'add_links': 'បន្ថែមតំណភ្ជាប់',
        'choose_language': 'ជ្រើសរើសភាសា',
        'cancel': 'បោះបង់',
        'loading_profile': 'កំពុងផ្ទុកប្រវត្តិរូប...',
        'error_loading_profile': 'កំហុសក្នុងការផ្ទុកប្រវត្តិរូប',
        'retry': 'ព្យាយាមម្តងទៀត',
        'logout_confirmation': 'តើអ្នកប្រាកដជាចង់ចាកចេញមែនទេ?',
        'logout_success': 'បានចាកចេញដោយជោគជ័យ',
        'session_expired': 'វិញ្ញាបនបត្រផុតកំណត់។ សូមចូលម្តងទៀត។',
        'auth_token_not_found': 'រកមិនឃើញវិញ្ញាបនបត្រផ្ទៀងផ្ទាត់',
        'failed_to_load_profile': 'បរាជ័យក្នុងការផ្ទុកប្រវត្តិរូប',
        'error_loading_profile_desc': 'កំហុសក្នុងការផ្ទុកប្រវត្តិរូប:',
        'hey_there': 'សួស្តី!',
        'myself_fahim':
            'ខ្ញុំឈ្មោះហ្វាហ៊ីម។ ខ្ញុំជាអ្នករចនា UI/UX។ ខ្ញុំចូលចិត្តរចនា និងអានសៀវភៅ។',

        // Cart related
        'my_cart': 'រទេះរបស់ខ្ញុំ',
        'your_cart_is_empty': 'រទេះរបស់អ្នកគឺទទេ',
        'add_coffee_to_cart': 'បន្ថែមផលិតផលថែទាំស្បែកដើម្បីចាប់ផ្តើម!',
        'browse_coffee': 'រុករកផលិតផល',
        'qty': 'បរិមាណ',
        'cart': 'រទេះ',
        'discount': 'បញ្ចុះតម្លៃ',
        'shipping': 'ការដឹកជញ្ជូន',
        'total': 'សរុប',
        'order_now': 'ដាក់កម្មង់ឥឡូវនេះ',
        'proceeding_to_checkout': 'កំពុងបន្តទៅការដាក់កម្មង់...',
        'select_payment_method': 'ជ្រើសរើសវិធីសាស្ត្រទូទាត់ប្រាក់',
        'credit_card': 'កាតឥណទាន',
        'bank_transfer': 'ការផ្ទេរតាមធនាគារ',
        'cash_on_delivery': 'ប្រាក់ពេលទទួល',
        'payment_method_selected': 'វិធីសាស្ត្រទូទាត់ប្រាក់ត្រូវបានជ្រើសរើស',
        'payment_methods': 'វិធីសាស្ត្រទូទាត់ប្រាក់',
        'aba_pay': 'ABA Pay',
        'aba_pay_desc': 'ទូទាត់ប្រាក់តាមរយៈ ABA Bank',
        'wing': 'WING',
        'wing_desc': 'ទូទាត់ប្រាក់តាមរយៈ WING',
        'credit_card_desc': 'ទូទាត់ប្រាក់ជាមួយកាតឥណទាន/ឥណវិក',
        'bank_transfer_desc': 'ការផ្ទេរតាមរយៈធនាគារដោយផ្ទាល់',
        'cash_on_delivery_desc': 'ទូទាត់ប្រាក់ពេលអ្នកទទួលបាន',
        'select_payment_timing': 'ជ្រើសរើសពេលវេលាទូទាត់ប្រាក់',
        'selected_payment_method': 'វិធីសាស្ត្រទូទាត់ប្រាក់ដែលបានជ្រើសរើស',
        'pay_now': 'ទូទាត់ប្រាក់ឥឡូវនេះ',
        'pay_now_desc': 'បញ្ចប់ការទូទាត់ប្រាក់ភ្លាមៗ',
        'pay_in_shop': 'ទូទាត់ប្រាក់នៅក្នុងហាង',
        'pay_in_shop_desc': 'ទូទាត់ប្រាក់ពេលអ្នកទៅហាង',
        'back': 'ត្រឡប់ក្រោយ',
        'order_placed_successfully': 'ការដាក់កម្មង់បានជោគជ័យ!',
        'payment_method': 'វិធីសាស្ត្រទូទាត់ប្រាក់',
        'payment_timing': 'ពេលវិធីសាស្ត្រទូទាត់ប្រាក់',
        'order_number': 'លេខការកម្មង់',
        'order_creation_failed': 'បរាជ័យក្នុងការបង្កើតការកម្មង់',
        'user_not_authenticated': 'អ្នកប្រើប្រាស់មិនបានចូលគណនីរួចហើយ',
        'cart_cleared': 'រទេះបានបាត់បង់ដោយជោគជ័យ!',
        'loading_products': 'កំពុងផ្ទុកផលិតផល...',
        'no_products_available': 'គ្មានផលិតផលដែលអាចប្រើបាន',
        'check_back_later': 'ពិនិត្យមើលពេលក្រោយសម្រាប់ផលិតផលថ្មី',

        // Favorites related
        'favorites': 'ចំណូលចិត្ត',
        'recipes': 'រូបមន្ត',
        'no_favorites_yet': 'មិនទាន់មានចំណូលចិត្តនៅឡើយទេ',
        'start_adding_favorites': 'ចាប់ផ្តើមបន្ថែមរូបមន្តដែលអ្នកចូលចិត្ត!',
        'ingredients': 'គ្រឿងផ្សំ',
        'share_recipe': 'ចែករំលែករូបមន្ត',
        'edit_recipe': 'កែប្រែរូបមន្ត',
        'remove_from_favorites': 'ដកចេញពីចំណូលចិត្ត',
        'recipe_shared': 'រូបមន្តត្រូវបានចែករំលែក!',
        'edit_recipe_tapped': 'កែប្រែរូបមន្តត្រូវបានចុច!',

        // Home screen related
        'search_coffee': 'ស្វែងរកផលិតផល...',
        'special_offers': 'ការផ្តល់ជូនពិសេស',
        'see_all': 'មើលទាំងអស់',
        'categories': 'ប្រភេទ',
        'shop_by_categories': 'ទំនិញតាមប្រភេទ',
        'notifications_clicked': 'ការជូនដំណឹងត្រូវបានចុច!',
        'filter_clicked': 'តម្រងត្រូវបានចុច!',
        'see_all_clicked': 'មើលទាំងអស់ត្រូវបានចុច!',
        'added_to_cart': 'ត្រូវបានបន្ថែមទៅរទេះ!',
        'already_in_cart': 'មាននៅក្នុងរទេះរបស់អ្នកហើយ!',
        'added_to_favorites': 'ត្រូវបានបន្ថែមទៅចំណូលចិត្ត!',
        'removed_from_favorites': 'ត្រូវបានដកចេញពីចំណូលចិត្ត!',

        // Recipe options
        'recipe_options': 'ជម្រើសរូបមន្ត',

        // Bottom navigation
        'home': 'ទំព៍រដើម',

        // Skin care detail screen
        'coffee_detail': 'ព័ត៌មានលម្អិតផលិតផល',
        'description': 'ការពិពណ៌នា',
        'read_more': 'អានបន្ថែម',
        'read_less': 'អានតិចជាង',
        'cup_size': 'ទំហំ',
        'sugar_level': 'កម្រិត',
        'less': 'ស្រាល',
        'half': 'មធ្យម',
        'normal': 'ធម្មតា',
        'extra': 'ខ្លាំង',
        'order_type': 'ប្រភេទការកម្មង់',
        'delivery': 'ការដឹកជញ្ជូន',
        'pick_up': 'យកដោយខ្លួនឯង',
        'special_instructions': 'ការណែនាំពិសេស',
        'special_instructions_hint': 'Lorem ipsum dolor sit amet.',
        'add_to_cart': 'បន្ថែមទៅរទេះ',

        // Signin screen
        'sign_in': 'ចូលគណនី',
        'username': 'ឈ្មោះអ្នកប្រើប្រាស់',
        'email_label': 'អ៊ីម៉ែល',
        'phone_label': 'ទូរសព្ទ',
        'password': 'ពាក្យសម្ងាត់',
        'login_with': 'ចូលគណនីជាមួយ',
        'login_with_email': 'ចូលគណនីជាមួយអ៊ីម៉ែល',
        'login_with_phone': 'ចូលគណនីជាមួយទូរសព្ទ',
        'login_with_username': 'ចូលគណនីជាមួយឈ្មោះអ្នកប្រើប្រាស់',
        'or_continue_with': 'ឬបន្តជាមួយ',
        'dont_have_account': 'មិនមានគណនីមែនទេ? ',
        'sign_up': 'ចុះឈ្មោះ',
        'already_logged_in': 'បានចូលគណនីរួចហើយ',
        'already_logged_in_message':
            'អ្នកបានចូលគណនីរួចហើយ។ កំពុងបញ្ជូនបន្តទៅទំព័រដើម...',
        'signed_in_successfully': 'បានចូលគណនីដោយជោគជ័យ!',
        'login_failed': 'ការចូលគណនីបរាជ័យ',
        'network_error': 'កំហុសបណ្តាញ',
        'error': 'កំហុស',
        'ok': 'យល់ព្រម',

        // Language selection
        'select_language': 'ជ្រើសរើសភាសា',
        'khmer': 'ខ្មែរ',
        'english': 'អង់គ្លេស',
        'language_changed': 'ភាសាបានប្តូរទៅ',

        // Signup screen
        'create_account': 'បង្កើតគណនី',
        'your_name': 'ឈ្មោះរបស់អ្នក',
        'your_email': 'អ៊ីម៉ែលរបស់អ្នក',
        'your_phone_number': 'លេខទូរស័ព្ទរបស់អ្នក',
        'register_with': 'ចុះឈ្មោះជាមួយ',
        'register_with_email': 'ចុះឈ្មោះជាមួយអ៊ីម៉ែល',
        'register_with_phone': 'ចុះឈ្មោះជាមួយទូរសព្ទ',
        'password_validation_message':
            'ពាក្យសម្ងាត់ត្រូវតែមានយ៉ាងតិច 8 តួអក្សរ និងមានយ៉ាងតិច 1 លេខ',
        'i_have_read_and_agree': 'ខ្ញុំបានអាន និងយល់ស្របជាមួយ ',
        'terms_and_conditions': 'លក្ខខណ្ឌ និងលក្ខណៈសម្បត្តិ',
        'and': 'និង',
        'privacy_policy': 'គោលការណ៍ភាពឯកជន',
        'already_have_account': 'មានគណនីរួចហើយមែនទេ? ',
        'account_created_successfully': 'គណនីត្រូវបានបង្កើតដោយជោគជ័យ!',
        'registration_failed': 'ការចុះឈ្មោះបរាជ័យ',
        'social_login': 'ការចូលគណនីសង្គម',
        'continue_with_google': 'បន្តជាមួយ Google',
        'continue_with_facebook': 'បន្តជាមួយ Facebook',
        'user_role': 'តួនាទីអ្នកប្រើប្រាស់',
        'customer': 'អតិថិជន',
        'admin': 'អ្នកគ្រប់គ្រង',
        'staff': 'បុគ្គលិក',

        // OTP related
        'normal_signup': 'ចុះឈ្មោះធម្មតា',
        'signup_with_phone': 'ចុះឈ្មោះជាមួយទូរសព្ទ',
        'get_otp': 'ទទួលលេខកូដ OTP',
        'sending_otp': 'កំពុងផ្ញើ OTP...',
        'enter_otp_code': 'បញ្ចូលលេខកូដ OTP',
        'otp_sent_successfully': 'បានផ្ញើ OTP ដោយជោគជ័យ',
        'failed_to_send_otp': 'បរាជ័យក្នុងការផ្ញើ OTP',
        'invalid_otp': 'លេខកូដ OTP មិនត្រឹមត្រូវ',
        'please_enter_phone_number': 'សូមបញ្ចូលលេខទូរសព្ទ',
        'click_get_otp_first': 'សូមចុច "ទទួលលេខកូដ OTP" ជាមុន',

        // Messages related
        'messages': 'សារ',
        'no_messages': 'មិនទាន់មានសារនៅឡើយទេ',

        // Order History related
        'order_history': 'ប្រវត្តិការកម្មង់',
        'history': 'ប្រវត្តិ',
        'my_orders': 'ការកម្មង់របស់ខ្ញុំ',
        'no_orders_yet': 'មិនទាន់មានការកម្មង់នៅឡើយទេ',
        'start_shopping': 'ចាប់ផ្តើមទិញដើម្បីមើលការកម្មង់របស់អ្នកនៅទីនេះ',
        'order_details': 'ព័ត៌មានលម្អិតការកម្មង់',
        'order_number_label': 'លេខការកម្មង់',
        'order_date': 'កាលបរិច្ឆេទការកម្មង់',
        'order_status': 'ស្ថានភាពការកម្មង់',
        'pending': 'កំពុងរង់ចាំ',
        'processing': 'កំពុងដំណើរការ',
        'delivered': 'បានដឹកជញ្ជូន',
        'cancelled': 'បានបោះបង់',
        'reorder': 'កម្មង់ម្តងទៀត',
        'download_receipt': 'ទាញយកបង្កាន់ដៃ',

        'close': 'បិទ',
      },
    ),
  ];

  static Language getLanguageByCode(String code) {
    return supportedLanguages.firstWhere(
      (lang) => lang.code == code,
      orElse: () => supportedLanguages.first, // Default to English
    );
  }

  static Language getLanguageByName(String name) {
    return supportedLanguages.firstWhere(
      (lang) => lang.name == name || lang.nativeName == name,
      orElse: () => supportedLanguages.first, // Default to English
    );
  }

  static List<String> getLanguageNames() {
    return supportedLanguages.map((lang) => lang.name).toList();
  }

  static List<String> getLanguageNativeNames() {
    return supportedLanguages.map((lang) => lang.nativeName).toList();
  }

  static List<String> getLanguageCodes() {
    return supportedLanguages.map((lang) => lang.code).toList();
  }
}
