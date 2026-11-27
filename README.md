<div align="center">

# Raff | رف

**تطبيق تسوّق متكامل بواجهة عربية، مبني بـ Flutter**

An Arabic-first (RTL) e-commerce app built with Flutter, clean architecture and Bloc.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.13+-0175C2?logo=dart&logoColor=white)
![State](https://img.shields.io/badge/State-flutter__bloc-1f6feb)
![Architecture](https://img.shields.io/badge/Architecture-Clean-2ea44f)
![Tests](https://img.shields.io/badge/tests-214%20passing-2ea44f)
![Platforms](https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Linux-lightgrey)

</div>

---

## Overview

Raff is a mobile shopping app with a full purchase flow: browse products, search, fill a cart, check out in steps, and track the order. The UI is Arabic first with full RTL support, English is available too, and light and dark themes are both supported.

Product data comes from the public [DummyJSON](https://dummyjson.com/) API. Everything the user creates (cart, favorites, addresses, orders, notifications) is stored locally on the device with Hive, so the app works as a complete demo without a custom backend.

The screens follow a design prototype: [raff-prototype.pages.dev](https://raff-prototype.pages.dev/).

## Features

- **Onboarding and auth**: first-launch onboarding, login and register, an OTP verification step, and a guest mode.
- **Home**: banner carousel, category shelf, product sections, and a header that shows the default delivery address.
- **Search**: live search with a 500 ms debounce (typing fast only searches the last text) and paginated results.
- **Catalog**: products by category, product details with colors, quantity, discount badge and reviews.
- **Cart**: quantity controls with stock limits, promo code `RAFF10` (10% off), and free shipping above 200.
- **Checkout**: four steps (address, delivery, payment, review) with delivery options, cash on delivery fee, and a live order summary.
- **Addresses**: add, edit, delete, and choose a default address. The default is shared with the home header and checkout.
- **Orders and tracking**: order history split into current and past, and a tracking timeline whose status moves forward with time.
- **Favorites**: toggle from any product card, saved locally.
- **Notifications**: order and promo notifications with read and unread state.
- **Account**: profile, stats, language switch, dark mode switch, and logout.
- **Localization**: Arabic and English through `flutter gen-l10n`, with RTL layout.
- **Theming**: light and dark themes built from one set of design tokens.

## Tech stack

| Area | Packages |
| --- | --- |
| Framework | Flutter, Dart 3.13+ |
| State management | `flutter_bloc`, `bloc`, `equatable` |
| Navigation | `go_router` |
| Networking | `dio` with an error interceptor that maps errors to typed failures |
| Local storage | `hive_ce`, `shared_preferences` |
| Dependency injection | `get_it` |
| Functional error handling | `dartz` (`Either<Failure, T>`) |
| UI | `gap`, `cached_network_image`, `flutter_svg`, Readex Pro font |
| Localization | `flutter_localizations`, `intl` |
| Testing | `flutter_test`, `mocktail`, `bloc_test` |

## Architecture

Each feature is split into three layers. The domain layer does not depend on Flutter or on any data source.

```
presentation  (screens, widgets, cubits)
      |
   domain     (entities, repository contracts, use cases)
      |
     data     (models, data sources, repository implementations)
```

- Use cases return `Either<Failure, T>`, so the UI handles errors without try/catch.
- Cubits expose a single state class with `copyWith` and a status enum.
- Dependencies are registered in one place, `core/di/injection.dart`.
- Order status is derived from the time since the order was created, instead of being stored and forgotten.

### Project structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── di/            # get_it registration
│   ├── errors/        # Failure types and localized messages
│   ├── l10n/          # arb files and generated localizations
│   ├── network/       # Dio client, error interceptor, API constants
│   ├── router/        # go_router config, routes, main shell
│   ├── storage/       # preferences service
│   ├── theme/         # colors, text styles, light and dark themes
│   └── widgets/       # shared widgets (buttons, fields, empty and error views)
└── features/
    ├── splash/  onboarding/  auth/  settings/
    ├── catalog/       # home, categories, search, product details
    ├── cart/  checkout/  orders/
    ├── addresses/  favorites/  notifications/  account/
    └── <feature>/
        ├── data/          # models, datasources, repositories
        ├── domain/        # entities, repositories, usecases
        └── presentation/  # cubit, screens, widgets

test/
├── helpers/           # fixtures, fake Dio adapter, temp Hive box, pumpApp
├── core/
├── features/          # mirrors lib/features
└── widgets/
```

## Getting started

**Requirements:** Flutter with Dart 3.13 or newer. Check with `flutter --version`.

```bash
git clone https://github.com/MohamedRamadan222/raff_ecommerce_app.git
cd raff_ecommerce_app

flutter pub get
flutter gen-l10n
flutter run
```

The generated localization files are already in the repo, so `flutter gen-l10n` only matters after you edit an `.arb` file in `lib/core/l10n/`.

### Try it

- Log in with a [DummyJSON user](https://dummyjson.com/users), for example `emilys` / `emilyspass`, or continue as a guest.
- Use the promo code `RAFF10` in the cart.
- Place an order and open it from the Orders tab to watch the tracking status move.

## Testing

```bash
flutter test                        # run everything
flutter test test/features/cart     # one feature
flutter test --coverage             # writes coverage/lcov.info
```

The suite has **214 tests** and needs no device or internet.

| What | How |
| --- | --- |
| Cubits | `bloc_test`: order of states, debounce in search, status derived from time in orders |
| Business rules | cart totals, free shipping, `RAFF10`, checkout fees |
| Repositories | mocked data sources, Dio errors mapped to `Failure` types |
| Remote data source | real `Dio` with a fake HTTP adapter: paths, query params, JSON parsing |
| Local data sources | real Hive boxes in a temp folder: stock limits, default address, corrupted entries |
| Models | `toJson` and `fromJson` round trips, defaults |
| Widgets | status badge (EN, AR, dark), stepper, option card, banners, empty and error views |

Static analysis: `flutter analyze` reports no errors or warnings. The remaining infos are `deprecated_member_use` notices from `material.dart`.

## Design

The UI is implemented from the Raff design prototype: [raff-prototype.pages.dev](https://raff-prototype.pages.dev/). Colors, spacing, and component sizes are kept as close to it as Flutter allows, in both light and dark mode.

Product images and data come from [DummyJSON](https://dummyjson.com/). Payment is a UI demo only, no real payment is made.

## Author

**Mohamed Ramadan** · Flutter developer
GitHub: [@MohamedRamadan222](https://github.com/MohamedRamadan222)
