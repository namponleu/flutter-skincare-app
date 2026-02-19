// Example: How to add a new language (e.g., French)
// 
// 1. Add the new language to the supportedLanguages list in language_model.dart:
//
// Language(
//   code: 'fr',
//   name: 'French',
//   nativeName: 'Français',
//   flag: '🇫🇷',
//   translations: {
//     'profile': 'Profil',
//     'edit_profile': 'Modifier le profil',
//     'language': 'Langue',
//     'logout': 'Se déconnecter',
//     'bio': 'Biographie',
//     'about': 'À propos',
//     'email': 'E-mail',
//     'phone': 'Téléphone',
//     'links': 'Liens',
//     'add_links': 'Ajouter des liens',
//     'choose_language': 'Choisir la langue',
//     'cancel': 'Annuler',
//     'language_changed': 'Langue changée en',
//     'loading_profile': 'Chargement du profil...',
//     'error_loading_profile': 'Erreur lors du chargement du profil',
//     'retry': 'Réessayer',
//     'logout_confirmation': 'Êtes-vous sûr de vouloir vous déconnecter?',
//     'logout_success': 'Déconnexion réussie',
//     'session_expired': 'Session expirée. Veuillez vous reconnecter.',
//     'auth_token_not_found': 'Jeton d\'authentification introuvable',
//     'failed_to_load_profile': 'Échec du chargement du profil',
//     'error_loading_profile_desc': 'Erreur lors du chargement du profil:',
//     'hey_there': 'Salut!',
//     'myself_fahim': 'Je m\'appelle Fahim. Je suis designer UI/UX. J\'aime le design et lire des livres.',
//   },
// ),
//
// 2. The language will automatically appear in:
//    - Language selection dialog
//    - All translation calls
//    - Language service methods
//
// 3. No other code changes needed!
//    - UI automatically updates
//    - Translations work immediately
//    - Language persistence works
//    - All screens support the new language
//
// 4. Benefits of this system:
//    - Easy to add new languages
//    - Centralized translation management
//    - Type-safe translation keys
//    - Automatic UI updates
//    - Persistent language selection
//    - Fallback to English if translation missing
//
// 5. Usage in any screen:
//    - Import: import '../lang/index.dart';
//    - Use: T.get(TranslationKeys.profile)
//    - Change: await T.changeLanguage('fr')
//    - Check: T.isFrench
//
// That's it! The new language is fully integrated. 