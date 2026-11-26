import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Raff'**
  String get appTitle;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out'**
  String get errorTimeout;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Server error'**
  String get errorServer;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get errorUnknown;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get navCategories;

  /// No description provided for @navCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get navCart;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// No description provided for @navAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get navAccount;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Everything your home needs, on one shelf'**
  String get splashTagline;

  /// No description provided for @splashTapToContinue.
  ///
  /// In en, this message translates to:
  /// **'Tap to continue'**
  String get splashTapToContinue;

  /// No description provided for @onbSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onbSkip;

  /// No description provided for @onbNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onbNext;

  /// No description provided for @onbStart.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onbStart;

  /// No description provided for @onbGuest.
  ///
  /// In en, this message translates to:
  /// **'Browse as guest'**
  String get onbGuest;

  /// No description provided for @onb1Title.
  ///
  /// In en, this message translates to:
  /// **'Pieces that make a home'**
  String get onb1Title;

  /// No description provided for @onb1Body.
  ///
  /// In en, this message translates to:
  /// **'Ceramics, wood and linen from local makers, chosen to last you for years.'**
  String get onb1Body;

  /// No description provided for @onb2Title.
  ///
  /// In en, this message translates to:
  /// **'Delivered to your door'**
  String get onb2Title;

  /// No description provided for @onb2Body.
  ///
  /// In en, this message translates to:
  /// **'We deliver in 2-4 business days, free on orders over SAR 200.'**
  String get onb2Body;

  /// No description provided for @onb3Title.
  ///
  /// In en, this message translates to:
  /// **'Hassle-free returns'**
  String get onb3Title;

  /// No description provided for @onb3Body.
  ///
  /// In en, this message translates to:
  /// **'Piece not right? Return it within 14 days for a full refund.'**
  String get onb3Body;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to follow your orders and wishlist.'**
  String get loginSubtitle;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get mobileNumber;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginButton;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orDivider;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'New to Raff?'**
  String get dontHaveAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account in less than a minute.'**
  String get registerSubtitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Sarah Al-Otaibi'**
  String get fullNameHint;

  /// No description provided for @emailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get emailOptional;

  /// No description provided for @passwordMinHint.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get passwordMinHint;

  /// No description provided for @passwordHelper.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters including a number.'**
  String get passwordHelper;

  /// No description provided for @agreeTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms & Conditions and Privacy Policy'**
  String get agreeTerms;

  /// No description provided for @acceptTermsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please accept the terms & conditions to continue'**
  String get acceptTermsRequired;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Raff'**
  String get homeTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a product...'**
  String get searchHint;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @featuredProducts.
  ///
  /// In en, this message translates to:
  /// **'Featured Products'**
  String get featuredProducts;

  /// No description provided for @allProducts.
  ///
  /// In en, this message translates to:
  /// **'All Products'**
  String get allProducts;

  /// No description provided for @searchProductsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Type a product name to search'**
  String get searchProductsPrompt;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No matching products found'**
  String get noResultsFound;

  /// No description provided for @productDetails.
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get productDetails;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get inStock;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brand;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @deliverTo.
  ///
  /// In en, this message translates to:
  /// **'Deliver to'**
  String get deliverTo;

  /// No description provided for @selectDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Select delivery address'**
  String get selectDeliveryAddress;

  /// No description provided for @banner1Tag.
  ///
  /// In en, this message translates to:
  /// **'Winter Collection'**
  String get banner1Tag;

  /// No description provided for @banner1Title.
  ///
  /// In en, this message translates to:
  /// **'Warmth of\nLong\nEvenings'**
  String get banner1Title;

  /// No description provided for @banner2Tag.
  ///
  /// In en, this message translates to:
  /// **'Season Offers'**
  String get banner2Tag;

  /// No description provided for @banner2Title.
  ///
  /// In en, this message translates to:
  /// **'Warm\nTouches for\nEvery Corner'**
  String get banner2Title;

  /// No description provided for @shopNow.
  ///
  /// In en, this message translates to:
  /// **'Shop now'**
  String get shopNow;

  /// No description provided for @newArrivals.
  ///
  /// In en, this message translates to:
  /// **'New Arrivals'**
  String get newArrivals;

  /// No description provided for @freeShippingTitle.
  ///
  /// In en, this message translates to:
  /// **'Free shipping over SAR 200'**
  String get freeShippingTitle;

  /// No description provided for @freeShippingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delivered in 2-4 business days'**
  String get freeShippingSubtitle;

  /// No description provided for @bestSellers.
  ///
  /// In en, this message translates to:
  /// **'Best Sellers'**
  String get bestSellers;

  /// No description provided for @newBadge.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newBadge;

  /// No description provided for @currencySar.
  ///
  /// In en, this message translates to:
  /// **'SAR'**
  String get currencySar;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @sortPopular.
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get sortPopular;

  /// No description provided for @sortPriceLow.
  ///
  /// In en, this message translates to:
  /// **'Price: Low to High'**
  String get sortPriceLow;

  /// No description provided for @sortPriceHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: High to Low'**
  String get sortPriceHigh;

  /// No description provided for @sortRating.
  ///
  /// In en, this message translates to:
  /// **'Highest Rated'**
  String get sortRating;

  /// No description provided for @discountLabel.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get discountLabel;

  /// No description provided for @productUnit.
  ///
  /// In en, this message translates to:
  /// **'products'**
  String get productUnit;

  /// No description provided for @discountsOnly.
  ///
  /// In en, this message translates to:
  /// **'Discounts only'**
  String get discountsOnly;

  /// No description provided for @priceRange.
  ///
  /// In en, this message translates to:
  /// **'Price range'**
  String get priceRange;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get recentSearches;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @mostSearched.
  ///
  /// In en, this message translates to:
  /// **'Most searched'**
  String get mostSearched;

  /// No description provided for @vatIncluded.
  ///
  /// In en, this message translates to:
  /// **'Price includes VAT'**
  String get vatIncluded;

  /// No description provided for @colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorLabel;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @deliveryDaysTitle.
  ///
  /// In en, this message translates to:
  /// **'2-4 days delivery'**
  String get deliveryDaysTitle;

  /// No description provided for @freeOver200.
  ///
  /// In en, this message translates to:
  /// **'Free over SAR 200'**
  String get freeOver200;

  /// No description provided for @freeReturnTitle.
  ///
  /// In en, this message translates to:
  /// **'Free return'**
  String get freeReturnTitle;

  /// No description provided for @within14Days.
  ///
  /// In en, this message translates to:
  /// **'Within 14 days'**
  String get within14Days;

  /// No description provided for @aboutProduct.
  ///
  /// In en, this message translates to:
  /// **'About product'**
  String get aboutProduct;

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// No description provided for @ratingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Ratings'**
  String get ratingsTitle;

  /// No description provided for @ratingUnit.
  ///
  /// In en, this message translates to:
  /// **'ratings'**
  String get ratingUnit;

  /// No description provided for @youMayAlsoLike.
  ///
  /// In en, this message translates to:
  /// **'You may also like'**
  String get youMayAlsoLike;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @addedToCartMessage.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get addedToCartMessage;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @pieceUnit.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get pieceUnit;

  /// No description provided for @emptyFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your wishlist is empty'**
  String get emptyFavoritesTitle;

  /// No description provided for @emptyFavoritesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on any product to save it here\nand track its price.'**
  String get emptyFavoritesSubtitle;

  /// No description provided for @startShopping.
  ///
  /// In en, this message translates to:
  /// **'Start shopping'**
  String get startShopping;

  /// No description provided for @removedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get removedFromFavorites;

  /// No description provided for @addedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get addedToFavorites;

  /// No description provided for @freeShippingUnlocked.
  ///
  /// In en, this message translates to:
  /// **'You unlocked free shipping'**
  String get freeShippingUnlocked;

  /// No description provided for @addMoreForFreeShipping.
  ///
  /// In en, this message translates to:
  /// **'Add SAR {amount} for free shipping'**
  String addMoreForFreeShipping(Object amount);

  /// No description provided for @promoCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Promo code'**
  String get promoCodeHint;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @promoCodeHelper.
  ///
  /// In en, this message translates to:
  /// **'Try code RAFF10 for 10% off.'**
  String get promoCodeHelper;

  /// No description provided for @invalidPromoCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid promo code'**
  String get invalidPromoCode;

  /// No description provided for @promoApplied.
  ///
  /// In en, this message translates to:
  /// **'10% discount applied'**
  String get promoApplied;

  /// No description provided for @subtotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotalLabel;

  /// No description provided for @shippingLabel.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get shippingLabel;

  /// No description provided for @freeLabel.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get freeLabel;

  /// No description provided for @discountRowLabel.
  ///
  /// In en, this message translates to:
  /// **'Discount (10%)'**
  String get discountRowLabel;

  /// No description provided for @checkoutButton.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutButton;

  /// No description provided for @removedFromCart.
  ///
  /// In en, this message translates to:
  /// **'Removed from cart'**
  String get removedFromCart;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get addedToCart;

  /// No description provided for @viewCart.
  ///
  /// In en, this message translates to:
  /// **'View cart'**
  String get viewCart;

  /// No description provided for @emptyCartTitle.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get emptyCartTitle;

  /// No description provided for @emptyCartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t added any items yet.\nBrowse our collection and pick your favorites.'**
  String get emptyCartSubtitle;

  /// No description provided for @guestUser.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guestUser;

  /// No description provided for @statOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get statOrders;

  /// No description provided for @statFavorites.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get statFavorites;

  /// No description provided for @statPoints.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get statPoints;

  /// No description provided for @myAccount.
  ///
  /// In en, this message translates to:
  /// **'My account'**
  String get myAccount;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My orders'**
  String get myOrders;

  /// No description provided for @ordersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track and review your orders'**
  String get ordersSubtitle;

  /// No description provided for @addresses.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get addresses;

  /// No description provided for @addressesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your delivery addresses'**
  String get addressesSubtitle;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment methods'**
  String get paymentMethods;

  /// No description provided for @paymentMethodsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Apple Pay and cards'**
  String get paymentMethodsSubtitle;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help center'**
  String get helpCenter;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logoutTitle;

  /// No description provided for @logoutMessage.
  ///
  /// In en, this message translates to:
  /// **'You will need to log in again to place new orders.'**
  String get logoutMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get appVersion;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @pointsMessage.
  ///
  /// In en, this message translates to:
  /// **'Collect points with every order'**
  String get pointsMessage;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @addAddress.
  ///
  /// In en, this message translates to:
  /// **'Add a new address'**
  String get addAddress;

  /// No description provided for @editAddress.
  ///
  /// In en, this message translates to:
  /// **'Edit address'**
  String get editAddress;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address type'**
  String get addressLabel;

  /// No description provided for @labelHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get labelHome;

  /// No description provided for @labelWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get labelWork;

  /// No description provided for @labelOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get labelOther;

  /// No description provided for @addressDetails.
  ///
  /// In en, this message translates to:
  /// **'Address details'**
  String get addressDetails;

  /// No description provided for @addressDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Street, building, apartment, district'**
  String get addressDetailsHint;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @setAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as default'**
  String get setAsDefault;

  /// No description provided for @defaultBadge.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultBadge;

  /// No description provided for @saveAddress.
  ///
  /// In en, this message translates to:
  /// **'Save address'**
  String get saveAddress;

  /// No description provided for @addressSaved.
  ///
  /// In en, this message translates to:
  /// **'Address saved'**
  String get addressSaved;

  /// No description provided for @addressDeleted.
  ///
  /// In en, this message translates to:
  /// **'Address deleted'**
  String get addressDeleted;

  /// No description provided for @emptyAddressesTitle.
  ///
  /// In en, this message translates to:
  /// **'No addresses yet'**
  String get emptyAddressesTitle;

  /// No description provided for @emptyAddressesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first address for a faster checkout'**
  String get emptyAddressesSubtitle;

  /// No description provided for @checkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutTitle;

  /// No description provided for @stepAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get stepAddress;

  /// No description provided for @stepDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get stepDelivery;

  /// No description provided for @stepPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get stepPayment;

  /// No description provided for @stepReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get stepReview;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place order'**
  String get placeOrder;

  /// No description provided for @whereDeliver.
  ///
  /// In en, this message translates to:
  /// **'Where should we deliver?'**
  String get whereDeliver;

  /// No description provided for @howDeliver.
  ///
  /// In en, this message translates to:
  /// **'Delivery method'**
  String get howDeliver;

  /// No description provided for @deliveryStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard delivery'**
  String get deliveryStandard;

  /// No description provided for @deliveryStandardSub.
  ///
  /// In en, this message translates to:
  /// **'Within 3-5 days'**
  String get deliveryStandardSub;

  /// No description provided for @deliveryExpress.
  ///
  /// In en, this message translates to:
  /// **'Express delivery'**
  String get deliveryExpress;

  /// No description provided for @deliveryExpressSub.
  ///
  /// In en, this message translates to:
  /// **'Within 1-2 days'**
  String get deliveryExpressSub;

  /// No description provided for @deliveryPickup.
  ///
  /// In en, this message translates to:
  /// **'Store pickup'**
  String get deliveryPickup;

  /// No description provided for @deliveryPickupSub.
  ///
  /// In en, this message translates to:
  /// **'Ready within 24 hours'**
  String get deliveryPickupSub;

  /// No description provided for @courierNote.
  ///
  /// In en, this message translates to:
  /// **'Note for the courier'**
  String get courierNote;

  /// No description provided for @courierNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get courierNoteHint;

  /// No description provided for @howPay.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get howPay;

  /// No description provided for @payAppleSub.
  ///
  /// In en, this message translates to:
  /// **'Fast and secure payment'**
  String get payAppleSub;

  /// No description provided for @payCard.
  ///
  /// In en, this message translates to:
  /// **'Bank card'**
  String get payCard;

  /// No description provided for @paySplit.
  ///
  /// In en, this message translates to:
  /// **'Split into 4 payments'**
  String get paySplit;

  /// No description provided for @paySplitSub.
  ///
  /// In en, this message translates to:
  /// **'no interest'**
  String get paySplitSub;

  /// No description provided for @payCod.
  ///
  /// In en, this message translates to:
  /// **'Cash on delivery'**
  String get payCod;

  /// No description provided for @payCodSub.
  ///
  /// In en, this message translates to:
  /// **'An extra fee applies'**
  String get payCodSub;

  /// No description provided for @securePay.
  ///
  /// In en, this message translates to:
  /// **'All payments are encrypted and secure'**
  String get securePay;

  /// No description provided for @reviewOrder.
  ///
  /// In en, this message translates to:
  /// **'Review your order'**
  String get reviewOrder;

  /// No description provided for @editButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editButton;

  /// No description provided for @orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order placed!'**
  String get orderPlaced;

  /// No description provided for @orderPlacedSub.
  ///
  /// In en, this message translates to:
  /// **'We will keep you updated on your order'**
  String get orderPlacedSub;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order number'**
  String get orderNumber;

  /// No description provided for @eta.
  ///
  /// In en, this message translates to:
  /// **'Expected delivery'**
  String get eta;

  /// No description provided for @etaValue.
  ///
  /// In en, this message translates to:
  /// **'3-5 days'**
  String get etaValue;

  /// No description provided for @trackOrder.
  ///
  /// In en, this message translates to:
  /// **'Track order'**
  String get trackOrder;

  /// No description provided for @continueShopping.
  ///
  /// In en, this message translates to:
  /// **'Continue shopping'**
  String get continueShopping;

  /// No description provided for @codFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'COD fee'**
  String get codFeeLabel;

  /// No description provided for @itemsLabel.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get itemsLabel;

  /// No description provided for @currentTab.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get currentTab;

  /// No description provided for @pastTab.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get pastTab;

  /// No description provided for @statusPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order placed'**
  String get statusPlaced;

  /// No description provided for @statusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmed;

  /// No description provided for @statusShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get statusShipped;

  /// No description provided for @statusOut.
  ///
  /// In en, this message translates to:
  /// **'Out for delivery'**
  String get statusOut;

  /// No description provided for @statusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDelivered;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @emptyOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get emptyOrdersTitle;

  /// No description provided for @emptyOrdersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your orders will appear here'**
  String get emptyOrdersSubtitle;

  /// No description provided for @orderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Order not found'**
  String get orderNotFound;

  /// No description provided for @deliveredOn.
  ///
  /// In en, this message translates to:
  /// **'Delivered on'**
  String get deliveredOn;

  /// No description provided for @pendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingLabel;

  /// No description provided for @shipTo.
  ///
  /// In en, this message translates to:
  /// **'Delivery address'**
  String get shipTo;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String itemsCount(int count);

  /// No description provided for @notifOrderPlacedTitle.
  ///
  /// In en, this message translates to:
  /// **'Order received'**
  String get notifOrderPlacedTitle;

  /// No description provided for @notifOrderPlacedBody.
  ///
  /// In en, this message translates to:
  /// **'We are preparing your order now'**
  String get notifOrderPlacedBody;

  /// No description provided for @notifPromoTitle.
  ///
  /// In en, this message translates to:
  /// **'10% off'**
  String get notifPromoTitle;

  /// No description provided for @notifPromoBody.
  ///
  /// In en, this message translates to:
  /// **'Use code RAFF10 on your next order'**
  String get notifPromoBody;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// No description provided for @earlierLabel.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get earlierLabel;

  /// No description provided for @emptyNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get emptyNotificationsTitle;

  /// No description provided for @emptyNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Order updates and offers will appear here'**
  String get emptyNotificationsSubtitle;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get otpTitle;

  /// No description provided for @otpHead.
  ///
  /// In en, this message translates to:
  /// **'Enter the verification code'**
  String get otpHead;

  /// No description provided for @otpSub.
  ///
  /// In en, this message translates to:
  /// **'We sent a 4-digit code to confirm your number'**
  String get otpSub;

  /// No description provided for @otpMockHint.
  ///
  /// In en, this message translates to:
  /// **'Any 4 digits work in this demo'**
  String get otpMockHint;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in'**
  String get resendIn;

  /// No description provided for @resendNow.
  ///
  /// In en, this message translates to:
  /// **'Resend now'**
  String get resendNow;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @otpSent.
  ///
  /// In en, this message translates to:
  /// **'A new code was sent'**
  String get otpSent;

  /// No description provided for @addCard.
  ///
  /// In en, this message translates to:
  /// **'Add a new card'**
  String get addCard;

  /// No description provided for @changeButton.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeButton;

  /// No description provided for @pointsMsg.
  ///
  /// In en, this message translates to:
  /// **'Earn 1 point for every SAR 10'**
  String get pointsMsg;

  /// No description provided for @savedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} saved'**
  String savedCount(String count);

  /// No description provided for @ordersOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 order on the way} other{{count} orders on the way}}'**
  String ordersOnTheWay(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
