# Performance & Architecture Audit — Raff

**Date:** 2026-11-27  
**Scope:** `lib/` (generated l10n excluded), 186 Dart files, ~15.6k app LOC; 137 tests at audit time, 214 after P1/P2 parts 1–6.  
**Method:** six parallel read-only audits (data/N+1, rendering, dead code, architecture/layers, lifecycle, heap retention) plus manual verification; P1/P2 workstreams with post-phase reviews.  
**Status:** Phase 0, P1, and P2 parts 1–6 are implemented and verified — `flutter analyze` clean, all **214 tests pass**, debug APK builds, `flutter gen-l10n` and `flutter pub get` completed. Remaining items are deliberate, documented deferrals. This file is the source of truth for all findings.

## Phase 0 outcome (verified 2026-11-27)

- Implemented by four parallel subagents with disjoint file ownership; reviewed and integrated centrally.
- `flutter analyze`: **No issues found**.
- `flutter test`: **137/137 passed**.
- `flutter gen-l10n`: regenerated; 16 unused keys removed (including four found during review), `retry` kept and wired into `ErrorView`.
- `flutter pub get`: removed 3 dependencies and their transitive packages; Linux plugin registrant updated.
- Test updated: `test/widgets/widgets_test.dart` now asserts the localized `Retry` label instead of the old hardcoded Arabic string.
- Corrections to the original dead-code audit:
  - `AddressEntity.copyWith` is **not dead** — address tests use it; restored.
  - `CartItemEntity.copyWith` is **not dead** — a cart data-source test uses it; retained.
  - Root `BlocProvider`s are lazy; only Hive boxes are eager at startup (as noted in O1).
  - `memCacheWidth` benefit is devicePixelRatio-dependent; order/checkout/search thumbnails and the gallery are the clearest wins.

## Work parts / status

| Part | Scope | Status |
|---|---|---|
| 1 | UX correctness: error/loading states, confirmation recovery, session bank card, search dedupe, unread dot, back fallback, localized server fallback | **Done** |
| 2 | Retention/cache: orders cap, disk image cache logout, cache invalidation generation | **Done** |
| 3 | Persistence/maintainability: compact cart/favorite storage, split checkout + track screens | **Done** |
| 4 | Remaining large-screen splits: account, product details info | **Done** |
| 5 | State architecture: sealed Orders/Notifications states; reduce impossible states | **Done** |
| 6 | QA/closure: route tests, debug APK build, final analysis/tests, documented deferrals | **Done** |
| 7 | Deferred architectural items: Dio `CancelToken`, lazy Hive boxes, normalized product store, feature-cycle cleanup, ProductCard consolidation, logout in-flight guard | Deferred |

## Priority legend

| Tag | Meaning |
|---|---|
| **P0** | Quick win, implemented first (hours of work) |
| **P1** | Short-term, high-value follow-up (days) |
| **P2** | Structural / larger refactor (weeks) |

Severity: **High** = visible cost or data/privacy risk today; **Medium** = cost grows with usage; **Low** = cleanup/maintainability.

---

## Master issue register

> The **Phase** column is the planned/implemented phase. P0 and P1 are complete; the **P1 outcome** and **P2 backlog** sections below record what actually shipped and what remains. Items marked P1 in the tables but not listed as shipped in the P1 outcome are follow-ups tracked there.

### N — N+1, data, and network

| ID | Sev | Issue | Evidence | Fix | Phase |
|---|---|---|---|---|---|
| N1 | High | A second `HomeCubit` loads categories + products on every products/details/search route; products route also duplicates the exact `products?limit=10` request | `core/router/app_router.dart:46,104,125,136`; `catalog/presentation/cubit/home_cubit.dart:18-21` | One app-scoped HomeCubit or split categories/featured-products; no HomeCubit creation in routes | **P0** |
| N2 | High | Cart/favorites re-decode the whole Hive box after every mutation; full product JSON (description/images) is stored per row | `cart/data/datasources/cart_local_data_source.dart:24-29,58-76`; `cart/data/repositories/cart_repository_impl.dart:36,49,61`; `favorites/data/datasources/favorites_local_data_source.dart:20-25,33-39`; `cart/data/models/cart_item_model.dart:48-65`; `favorites/data/models/favorite_product_model.dart:55-68` | In-memory map; compact rows; update one entry; serialize mutations | P1 |
| N3 | High | `markAllRead` is an N+1 read-modify-write loop; mark-read/add also re-decode the whole box | `notifications/data/datasources/notifications_local_data_source.dart:55-67,42-51,34-39` | One `putAll`/transaction; update cubit in memory | P1 |
| N4 | Medium | Address reads use `box.keys` + `box.get(key)` per item; `_clearDefault` awaits a write per address; every mutation re-reads all | `addresses/data/datasources/addresses_local_data_source.dart:24-38,79-94,41-77` | Read `box.values` once; store default ID separately; batch writes | P1 |
| N5 | High | Orders are fully decoded/sorted at startup/first screen and every 30 s during tracking | `orders/data/datasources/orders_local_data_source.dart:18-25`; `orders/presentation/screens/track_order_screen.dart:26-41`; `orders/presentation/cubit/orders_cubit.dart:14-29` | Refresh derived status in memory; targeted order query; no `loading` on silent refresh; pause offscreen/backgrounded | P1 |
| N6 | Medium | Catalog repository has no cache or in-flight de-duplication; repeated details/category requests; no request cancellation | `catalog/data/repositories/catalog_repository_impl.dart:15-74`; all cubits lack `CancelToken` | TTL/LRU cache + in-flight future map + `CancelToken`/generation tokens | P1 |
| N7 | Low | Cached user JSON is decoded from SharedPreferences inside `build` (home header, account, checkout bank card) | `catalog/presentation/widgets/home/home_header.dart:26`; `account/presentation/screens/account_screen.dart:34`; `checkout/presentation/screens/checkout_screen.dart:515`; `auth/data/datasources/auth_local_data_source.dart:38-42` | Session/user cubit, decoded once | P1 |
| N8 | Low | Notifications seed a promo record during first load | `notifications/presentation/cubit/notifications_cubit.dart:40-51` | Static UI seed or explicit migration, not in load path | P2 |

### O — Runtime overhead, startup, persistence

| ID | Sev | Issue | Evidence | Fix | Phase |
|---|---|---|---|---|---|
| O1 | High | Five non-lazy Hive boxes opened serially before `runApp`; all values loaded into memory and never closed | `core/di/injection.dart:153-163,199-203,226-230,242-246`; `main.dart:15-28` | Lazy boxes; defer opens; `Future.wait` if eager | P1 |
| O2 | High | Checkout fires three persistence writes without awaiting, then navigates; order entity/pricing built in the widget | `checkout/presentation/screens/checkout_screen.dart:228-281` | `CheckoutCubit`/`PlaceOrderUseCase`; await and navigate on success | P1 |
| O3 | High | Track order polls every 30 s and rebuilds the whole tracking page plus offstage Orders/Account subscriptions | `track_order_screen.dart:26-41,54-80`; `account_screen.dart:167-199,282-324` | In-memory derive; lifecycle/route-aware polling; targeted selectors | P1 |
| O4 | Medium | Pagination appends with list copies and no cap/dedupe; entire lists are in `Equatable.props` | `products_cubit.dart:50-56`; `search_cubit.dart:70-76`; `products_state.dart:47-53`; `search_state.dart:47-53` | Cap/window pages, dedupe by ID, revision counter instead of full-list props | P2 |
| O5 | Medium | Notifications and orders grow forever with no delete/cap; rendered eagerly | `notifications/data/datasources/notifications_local_data_source.dart:37`; `orders/data/datasources/orders_local_data_source.dart:18-31`; `notifications_screen.dart:51-72` | Retention cap/archival; lazy list | P1 |
| O6 | Medium | `ProductDetails` → related product uses `push`, stacking pages and per-page cubits/data | `product_details_screen.dart:203-206`; `app_router.dart:113-129` | `pushReplacement`/`go` between products; shared catalog cache | P1 |
| O7 | Low | Eager `ListView(children:)` in cart/notifications; per-tile `DateFormat`/`NumberFormat`; RegExp/ThemeData rebuilt | `cart_screen.dart:178-235`; `notifications_screen.dart:51-72,135`; `orders_screen.dart:117,188,268`; `app_theme.dart:9-37`; `product_details_info_section.dart:56-59`; `address_entity.dart:22-25` | `ListView.builder`; cached formatters/themes/regexes | **P0** |
| O8 | Low | Debug Dio logs request/response bodies, including login passwords | `core/network/dio_clint.dart:19-22` | Disable body logging | **P0** |
| O9 | Low | After checkout, `context.go(orderConfirmation)` replaces the stack, disposing the shell and all tab state; returning home recreates the shell (HomeCubit data now survives at app scope, so no home refetch) | `checkout_screen.dart:280`; `order_confirmation_screen.dart:146` | Preserve shell or intentionally recreate; consider `push`/nested route | P2 |
| O10 | Low | Artificial 1.5 s splash delay inside provider creation | `splash/presentation/screens/splash_screen.dart:22-28` | Remove or cancel; call after first frame | P2 |

### R — Renders and rebuilds

| ID | Sev | Issue | Evidence | Fix | Phase |
|---|---|---|---|---|---|
| R1 | High | Product details page rebuilds fully on each gallery swipe and on color/quantity `setState`; info section recompiles a RegExp | `product_details_screen.dart:46,90-135`; `product_details_cubit.dart:23-29`; `product_details_info_section.dart:56-59` | Local page index/ValueNotifier; split sections; `BlocSelector` | P1 |
| R2 | High | Products screen sorts/filters the whole catalog in `build`; header/filter/grid rebuild together | `products_screen.dart:76-94,126-130` | Move sort/filter into cubit/state; `buildWhen`/selectors | P1 |
| R3 | High | Home banner swipe calls `setState` and rebuilds the whole Home page (header, categories, both rails, images) | `home_screen.dart:53,96-107` | Carousel owns its index; indicator-only `ValueListenableBuilder` | P1 |
| R4 | High | Cart rebuilds every tile, summary, and bottom bar on each quantity change; eager rows; repeated list folds | `cart_screen.dart:67,178-235`; `cart_state.dart:25-44` | `ListView.builder`; per-row selector; precomputed totals | **P0** (list) / P1 (selectors) |
| R5 | Medium | Per-card double `BlocBuilder` + linear `isFavorite`/`isInCart` scans; search favorites builder wraps whole scroll view | `home_screen.dart:232-270`; `products_screen.dart:235-256`; `search_results_grid.dart:30-60`; `favorites_screen.dart:90-131`; `favorites_state.dart:18-19`; `cart_state.dart:46-47` | Sets computed once at list level; keyed cards; selectors | **P0** |
| R6 | Medium | Notifications/orders/account broad subscriptions; repeated filtered-list getters; offstage `IndexedStack` branches rebuild | `notifications_screen.dart:26-49`; `notifications_state.dart:18-24`; `orders_screen.dart:41,60`; `orders_state.dart:18-32`; `account_screen.dart:167-199,282-324`; `app_router.dart:44-91` | `BlocSelector` for counts; memoized partitions | P1 |
| R7 | Medium | OTP countdown rebuilds the whole screen every second (60 rebuilds) | `otp_screen.dart:41-55` | Extract countdown widget; absolute deadline | P1 |
| R8 | Low | App-wide settings rebuild `MaterialApp.router`; ThemeData getters rebuild full themes | `app.dart:14-25`; `app_theme.dart:9-37` | `static final` themes; narrower rebuild | **P0** (themes) |
| R9 | Low | No `RepaintBoundary`, missing keys in some lists, tiny `shrinkWrap` list | product cards/grids; `search_popular_section.dart:47-50` | Boundaries/keys; replace tiny shrinkWrap list with Column | P2 |
| R10 | Low | `HomeBannerCarousel` allocates banner records/gradient per build; OTP creates borders per build | `home_banner_carousel.dart:22-59`; `otp_screen.dart:79-211` | Precompute configs/styles | P2 |

### A — Architecture and layers

| ID | Sev | Issue | Evidence | Fix | Phase |
|---|---|---|---|---|---|
| A1 | High | Presentation imports the data layer and calls `sl<...>()` in `build`; Search uses `SharedPreferences` directly | `account_screen.dart:15,34,152`; `home_header.dart:11,26`; `checkout_screen.dart:7,515`; `search_screen.dart:22,55,71,76` | Session/user cubit; move persistence behind abstractions; ban locator in build | P1 |
| A2 | High | Checkout orchestration/persistence lives in the widget | `checkout_screen.dart:228-281` | `CheckoutCubit`/use case | P1 |
| A3 | Medium | Pricing/discount/shipping and order-status rules duplicated outside domain | `cart_state.dart:27-44`; `checkout_totals.dart:22-41`; `cart_cubit.dart:157-168`; `orders_cubit.dart:51-68`; `track_order_screen.dart:97-107` | Domain pricing/status value objects/use cases | P2 |
| A4 | Medium | 25 pure pass-through use cases (~396 lines) + 25 DI entries; no domain logic | `lib/features/*/domain/usecases/*`; `core/di/injection.dart` | Remove or make use cases meaningful | P2 |
| A5 | Medium | Two state conventions: sealed catalog states vs enum + nullable failure/list states | `cart_state.dart:5-15`; `home_state.dart`; `products_state.dart` | Sealed async state or one convention | P2 |
| A6 | Medium | Feature cycles: catalog ↔ cart/favorites; core router imports CartCubit; no product single source of truth | `main_shell.dart:5-6`; `cart_item_tile.dart:6`; `favorites_screen.dart:9-16`; `home_screen.dart:22-26`; six states hold full `ProductEntity` copies | Shared product/card module; normalized product store; compact cart/favorites | P2 |
| A7 | Medium | Error mapping duplicated 4×; interceptor’s typed Failure never consumed; register discards server message | `error_interceptor.dart:7-31`; `login_repository_impl.dart:25-44`; `register_repository_impl.dart:32-52`; `catalog_repository_impl.dart:76-96` | One `FailureMapper`; fix register message; remove or consume interceptor | **P0** (register) / P2 (mapper) |
| A8 | Medium | No router auth guard; confirmation depends on non-serializable `extra` | `app_router.dart:30-163`; `order_confirmation_screen.dart:25` | Session cubit + redirect; order ID route param and fetch | P2 |
| A9 | Medium | DI scope implicit: app cubits registered as factories but manually provided at root; dead root LoginCubit | `main.dart:32-39`; `injection.dart:89-150`; `login_screen.dart:22-24` | Explicit app-scoped registrations; remove dead provider | **P0** (dead provider) / P2 (scope) |
| A10 | Low | `ProductsSuccess.copyWith` drops `paginationFailure`; partial home failure hidden | `products_state.dart:33-45`; `home_cubit.dart:28-38`; `notifications_cubit.dart:28-36` | Explicit clear/preserve flags; model partial failure | **P0** (copyWith) / P2 (partial failure) |

### M — Memory, lifecycle, leaks

| ID | Sev | Issue | Evidence | Fix | Phase |
|---|---|---|---|---|---|
| M1 | High | Logout clears only the cached user; root cubits, Hive boxes, and image cache keep previous user data | `account_screen.dart:148-155`; `auth_local_data_source.dart:31-35`; `main.dart:33-39` | Session-scoped state; clear boxes/cubits/image cache; router redirect | P1 |
| M2 | High | Non-lazy Hive boxes fully in RAM for process lifetime; root cubits never closed; no caps | `injection.dart:153-246`; `main.dart:28-42`; `notifications_local_data_source.dart:37`; `orders_local_data_source.dart:18-31` | Lazy boxes; session scope; retention caps | P1 |
| M3 | High | Full-resolution image decoding everywhere; no cache manager/limits | 8 `CachedNetworkImage` sites; no `memCacheWidth`/`CacheManager` | Set decode/disk sizes | **P0** |
| M4 | Medium | Stacked product-detail pages retain pages/cubits/products/image listeners | `product_details_screen.dart:203-206`; `app_router.dart:113-129` | `pushReplacement`/`go`; shared cache | P1 |
| M5 | Medium | `IndexedStack` keeps all visited tabs mounted; offstage rebuilds | `app_router.dart:44-91` | Selectors; consider resetting heavy branches | P2 |
| M6 | Low | Login/Register/Splash/Onboarding cubits can emit after close; splash delay uncancellable | `login_cubit.dart:10-21`; `register_cubit.dart:10-31`; `splash_cubit.dart:10-25`; `onboarding_cubit.dart:10-19`; `splash_screen.dart:22-28` | `isClosed` guards; cancellable delay | **P0** (guards) |
| M7 | Low | SnackBar action and modal sheet capture transient `BuildContext`; debug logs retain bodies | `cart_helper.dart:43-48`; `address_form_sheet.dart:20-31`; `dio_clint.dart:19-22` | Capture navigation key/cubit callback; disable body logs | **P0** (logs) / P2 |
| M8 | Low | Ranges: recent searches are capped, but notification/order/favorite/pagination collections are not | `search_screen.dart:65-68` vs. N2/O4/O5 | Caps/archival | P1 |

### D — Dead code and unused surface

| ID | Item | Evidence | Action | Phase |
|---|---|---|---|---|
| D1 | `AddButton` widget + file | `core/widgets/add_button.dart`; zero importers | Delete | **P0** |
| D2 | `AddressEntity.copyWith`, `CartItemEntity.copyWith` | **Both are used by tests** (`addresses_test.dart`, `cart_local_data_source_test.dart` fixtures) — originally reported as dead | Keep; not production-dead, but test-only surface | — |
| D3 | `CartCubit.isInCart` wrapper | zero callers | Delete | **P0** |
| D4 | `paginationFailure` fields written but never read | products/search states | Render retry UI | **P0** |
| D5 | `AppButton.isText` | zero `isText:` args | Delete branch | **P0** |
| D6 | `AppAppBar` unused `customSubtitle`, `leading`, `titleSpacing`, `showBackButton`; title always supplied | 7 call sites pass only title/subtitle/actions/showBackButton:true | Simplify API/update call sites | **P0** |
| D7 | `AppBackButton.onPressed`, `AppTextField.prefix` | never supplied | Delete | **P0** |
| D8 | `ProductsHeader.cartCount` + badge | never supplied | Delete | **P0** |
| D9 | 6 unused `AppColors` tokens | `star`, `bezel`, `darkStage`, `darkHero`, `darkHeroInk`, `darkHeroSecondary` | Delete | **P0** |
| D10 | 2 unused `AppTextStyles` | `buttonSecondary`, `navigationLabel` | Delete | **P0** |
| D11 | 17 unused l10n keys found (16 removed; `retry` kept) | `appTitle`, `errorServer`, `splashTapToContinue`, `homeTitle`, `featuredProducts`, `searchProductsPrompt`, `addedToCartMessage`, `addedToFavorites`, `ordersSubtitle`, `addressesSubtitle`, `pointsMessage`, `editButton`, plus later-found `loading`, `categories`, `productDetails`, `description`; `retry` wired into ErrorView | Remove 16; keep/wire `retry` | **P0** |
| D12 | 3 unused dependencies | `cupertino_icons`, `flutter_screenutil_plus`, `flutter_secure_storage` | Remove from pubspec | **P0** |
| D13 | 2 unused font weights | ReadexPro ExtraLight/Light; no w200/w300 | Entries and asset files removed | **P0** |
| D14 | Register discarded expression | `register_repository_impl.dart:42-45` | Use server message | **P0** |
| D15 | Root `LoginCubit` provider | `main.dart:32`; screen creates its own | Remove root provider | **P0** |
| D16 | `FavoritesCubit.isFavorite` / repository/local `isFavorite` | tests only / repository unused | Remove or keep for tests | P2 |
| D17 | `UserEntity.fullName`, `CartItemModel.fromEntity` | tests only | Use or delete | P2 |
| D18 | `OrdersState.failure`, `NotificationsState.failure` | written, never read by UI | Add error UI or remove | P2 |
| D19 | `LoginSuccess.user`, `RegisterSuccess.user`, `_rememberMe` | stored but unused | Remove/implement | P2 |
| D20 | Route strings hardcoded; `AppRoutes.trackOrder` bypassed | splash/confirmation/orders/notifications | Add route helpers | P2 |
| D21 | Duplicate widgets/utilities | `ProductCard` vs `ProductGridCard`; empty views; summary rows; category cards; error mapping; product mapping | Consolidate | P2 |
| D22 | No-op actions | `addCard` checkout:467; OTP incomplete callback | Disable/hide or implement | **P0** (OTP) / P2 |

---

## Detailed notes (highest-impact items)

### 1. Duplicate home/catalog fetches (N1)
- Root cause: route builders create `HomeCubit` per route; `loadHomeData()` always fetches categories + 10 products.
- Concrete cost: product details = 3 GETs; products route = duplicate `products?limit=10&skip=0`; search = 2 GETs.
- Phase 0 fix: one root-provided `HomeCubit`; routes no longer create it.
- P1: repository TTL cache + in-flight coalescing removes repeated requests; generation guards prevent stale results.
- Remaining (P2): split into `CategoriesCubit`/`FeaturedProductsCubit` to avoid fetching the unused half on a cold `/products` entry.

### 2. Whole-box local storage mutations (N2/N3/N4)
- Cart mutates: decode full product, write JSON, then decode all cart rows again.
- Favorites: same; stores full description/images for every heart.
- Notifications `markAllRead`: N reads + N awaited writes + full re-decode.
- Addresses `_clearDefault`: full scan + awaited writes; `getAddresses` uses `box.get` per key.
- P1 fix: in-memory caches, one/few-key writes, `putAll` for bulk marks/defaults, notification cap.
- Remaining: compact row serialization (full product JSON) and lazy Hive boxes.

### 3. Startup and memory retention (O1/M2)
- `setUpGetIt()` awaits path_provider + `Hive.init` + 5 non-lazy `openBox` calls before `runApp`.
- Root providers are lazy (correction to earlier assumption), so orders/notifications load on first use — but their boxes are already fully in memory.
- P1 fix: `SessionCleaner` clears all user boxes, auth, recent searches, and the image cache; AccountScreen resets the app-scoped cubits.
- Remaining: Hive boxes are opened in parallel but are still non-lazy; lazy box opening is P2.

### 4. Image memory (M3)
- All 8 image call sites decode source resolution. DummyJSON sample: thumbnails 300×300 (~0.36 MB decoded), gallery `1.webp` 1000×1000 (~4 MB decoded).
- Order/checkout thumbnails are 44 logical px; gallery is 350 logical px.
- Benefit of `memCacheWidth` depends on devicePixelRatio, but capping order/cart/search/gallery decodes and setting disk sizes is still worthwhile.
- Phase 0 fix: `memCacheWidth` + `maxWidthDiskCache` on every site.
- P1: logout now clears the Flutter image cache.
- Remaining: shared image widget and a custom disk `CacheManager`.

### 5. Checkout consistency (O2/A2)
- Order/notification/cart writes are unawaited; confirmation precedes persistence; failures invisible; no transaction.
- Order ID/pricing/stock were decided in the widget.
- P1 fix: `CheckoutCubit` constructs/persists the order first, awaits it, runs side effects best-effort, shows errors, syncs cubits even if the screen unmounts, and uses collision-safe IDs.
- Remaining: stock validation at checkout is still not a domain rule.

### 6. Rebuild scope (R1–R6)
- Details: whole page under one builder; image swipe emits whole product state.
- Products: sort/filter in `build`.
- Home: banner `setState` rebuilds all.
- Cart: eager rows + repeated folds.
- Per-card double builders + linear membership checks.
- P1 fixed banner/gallery ownership, moved sort/filter into ProductsCubit, and added shell/account count selectors.
- Remaining: detail color/quantity still rebuilds the page; broad notifications/order subscriptions remain.

### 7. Async races and dead pagination failures (A10/O4)
- `loadMore` captures pre-await state and can overwrite a new query/category.
- `paginationFailure` was written but never rendered.
- Phase 0 fixed copyWith + retry UI; P1 added generation tokens and cache coalescing. Full Dio `CancelToken` threading remains P2.

### 8. Architecture boundaries (A1/A6/A7)
- Presentation → data imports and locator calls in build.
- Catalog ↔ cart/favorites cycles.
- No normalized product store.
- Duplicated Dio/product mapping; dead interceptor payload.
- Phase 0 fixed register message + debug logging; structural work remains.

---

## Healthy areas (keep them)

- Domain layer has no Flutter/Hive/Dio/SharedPreferences imports; data layer does not import presentation.
- Repository contracts return domain entities; use cases consistently return `Either<Failure, T>`.
- Catalog pagination uses `limit`/`skip`, computes `hasMore`, and guards duplicate load-more calls.
- `HomeCubit` parallelizes its two requests with `Future.wait`.
- Catalog/favorites/orders lists use lazy builders/slivers on their main screens.
- Search debounce (500 ms) is canceled in `close`; OTP/track timers are canceled; scroll listeners removed; controllers/focus nodes disposed.
- No `StreamSubscription`, `StreamController`, Hive `watch/listen`, `OverlayEntry`, or `AnimationController` leaks found.
- Recent searches are capped at 8.
- DI has no duplicate registrations; named Hive boxes are correctly scoped.
- `flutter analyze` is clean; 214 tests exist.

---

## Phase 0 implementation checklist

- [x] Single app-scoped HomeCubit; no route-level HomeCubit creation
- [x] Remove dead root LoginCubit provider
- [x] Set-based favorite/cart membership at list level
- [x] Pagination failure state preserved and rendered with retry
- [x] `memCacheWidth`/`maxWidthDiskCache` on all CachedNetworkImage sites
- [x] Cached `ThemeData` (`static final`)
- [x] Hoisted RegExps; `AddressEntity.copyWith` retained because tests use it (audit correction)
- [x] Cached `DateFormat`/`NumberFormat`
- [x] Lazy `ListView.builder` for cart and notifications
- [x] AppAppBar dead API removed + call sites updated
- [x] OTP disabled button instead of no-op callback
- [x] Delete `AddButton`; remove dead params/fields/methods/tokens
- [x] Remove 16 unused l10n keys; wire `retry` into `ErrorView`
- [x] Remove 3 unused deps and 2 unused font weights
- [x] Fix register server-message extraction
- [x] Disable Dio body logging
- [x] `isClosed` guards in Login/Register/Splash/Onboarding/Notifications cubits
- [x] `flutter gen-l10n` after ARB edits
- [x] `flutter pub get` after pubspec edits
- [x] `flutter analyze` (no issues)
- [x] `flutter test` (137/137 passed)

### Review follow-ups (after Phase 0 review)

- **Fixed:** pagination retry now clears the previous pagination error when the retry starts, so spinner and error do not render together.
- **Fixed:** removed four additional unused l10n keys found during review (`loading`, `categories`, `productDetails`, `description`).
- **Fixed:** README tech-stack table no longer lists removed packages.
- **Deferred (P2):** register/login/catalog server-error fallbacks are hardcoded Arabic. Centralize through `FailureMessage`/`errorServer` so English UI does not show Arabic.
- **Deferred (P2):** always-back `AppAppBar` is inert on `go`-based paths (`OTP` after register, `Orders` after confirmation). Normal push paths are fine; consider `push` or a home fallback.
- **Accepted:** gallery `memCacheWidth: 900` is a deliberate cap for a near-full-width 350 px-tall gallery; very high-DPR devices may see mild softness.
- **Deferred (P2):** a cold entry directly to `/products` before Home has loaded still makes the root lazy `HomeCubit` request categories (the duplicate product request is now coalesced by the repository cache). Current navigation enters via Home first; splitting the cubit closes this edge case.
- **Note:** new files `docs/PERFORMANCE_AUDIT.md` and `lib/core/utils/app_formatters.dart` are untracked until the changes are committed/staged.

## P1 outcome (verified 2026-11-27)

- Implemented by five parallel subagents with disjoint file ownership; DI/session/checkout integration completed centrally, then hardened from a post-P1 review.
- `flutter analyze`: **No issues found**; `flutter test`: **169/169 passed** (32 new tests), including a DI graph smoke test that resolves the session, session cleaner and checkout cubit.
- Catalog (N6, O4):
  - TTL cache + in-flight coalescing in `CatalogRepositoryImpl` (categories 5m, lists 60s, search 30s, details 2m; failures not cached).
  - Generation guards in Home, Products, Search, and ProductDetails cubits; stale load-more cannot overwrite a new query/category.
  - Pagination dedupes by ID, caps retention at 200, tracks raw API skip, and stops `hasMore` at the cap.
  - Sort/filter moved into `ProductsCubit`; `filtersRevision` ensures chips rebuild even when the visible list is unchanged.
- Storage (N2, N3, N4, O1):
  - All five local data sources now cache decoded lists and update cache + one/few keys per mutation.
  - `markAllRead` and address default clearing use `putAll`; notifications are capped at 100 newest with `deleteAll`.
  - Added `clearAll()` to every user-data source; box opening is parallelized with `Future.wait`.
- Checkout (O2, A2):
  - New `CheckoutCubit` builds/persists the order first, then runs notification/cart side effects best-effort.
  - Failure never clears the cart; success syncs Cart/Orders/Notifications cubits before navigation; submit is guarded and shows an error SnackBar.
- Orders (N5, O3):
  - `ensureLoaded`, silent `refreshStatuses`, and `reset` added.
  - Tracking no longer re-reads Hive every 30s; polling is lifecycle- and route-aware, silent, and stops at delivered/cancelled.
  - New orders are visible immediately after checkout via cubit sync.
- Session/logout (M1, M2, A1, A7):
  - `SessionCubit` is the single source of truth, restored before `runApp`; GoRouter redirects unauthenticated users and preserves the intended deep-link destination via `?from=`.
  - Login/Register/Onboarding update the shared session; HomeHeader/Account read it instead of the data source.
  - `SessionCleaner` clears all user data, recent searches, auth, and the Flutter image cache. AccountScreen resets the app-scoped cubits.
  - Corrupt cached user JSON is ignored rather than blocking startup.
- Rebuild scoping (R1–R6):
  - Home banner and product-details gallery own their controllers/indexes; swipes no longer rebuild the page.
  - Shell cart badge uses `BlocSelector<int>`; account stats use count selectors; product filters are no longer computed in `build`.
- Post-review fixes:
  - Logout now also clears recent searches (`RECENT_SEARCH_QUERIES`) and attempts every store even if one fails.
  - Order IDs use microseconds+base36 instead of a 100-second residue cycle, preventing silent overwrite.
  - Corrupt cached user data is ignored, so `session.restore()` cannot block startup.
  - Pull-to-refresh invalidates the catalog cache (`InvalidateCatalogCacheUseCase`).
  - Checkout captures app-scoped cubits before awaiting, syncs them even if the screen unmounts, and reloads the cart from storage instead of blindly resetting it.
  - Catalog cache is size-capped at 64 entries per map and prunes expired entries on insert.
  - Notification retention is enforced on first read as well as on add.
  - Track-order timer stays alive while the route is covered and skips work until visible, so it resumes without a rebuild.
  - Deep links are preserved through login; authenticated users are redirected away from login/register; OTP requires an allowed session.
- Remaining P1 follow-ups:
  - Dio `CancelToken` was not threaded through the layers; generation guards + cache coalescing cover correctness. Full cancellation remains P2.
  - Hive boxes are opened in parallel but are still non-lazy; lazy box opening remains P2.
  - Orders are not archived/capped; only notifications are capped. Orders stay because deleting purchase history is destructive (they are still cleared on logout).
  - Checkout `_BankCard` still reads cached user JSON directly; HomeHeader/Account were migrated to `SessionCubit`.
  - Track polling wakes every 30s while covered but performs no storage work; the visible UI can be up to 30s stale after returning.
  - Logout does not cancel an in-flight checkout write; a late write could repopulate cleared data. Hive writes are fast; a write-generation guard is P2.

## Part 6 (QA/closure) outcome (verified 2026-11-28)

- `flutter analyze`: **No issues found**; `flutter test`: **214/214 passed**.
- `flutter build apk --debug`: **succeeded** (`build/app/outputs/flutter-apk/app-debug.apk`).
- Added route tests for order-confirmation/track helper encoding and path templates.
- No device/emulator visual QA or real-device profiling was performed; that remains a manual follow-up.

### Deliberate deferrals (with rationale)

- **Dio `CancelToken`:** generation guards + repository cache already prevent stale UI and duplicate requests; threading a cancellation abstraction through domain/repository/use-case/data-source adds coupling for a modest network/battery win. Revisit with the async data-layer work.
- **Lazy Hive boxes:** boxes open in parallel now. Fully lazy boxes require async/lazy data-source contracts (orders/notifications are sync `Either` today) and would be a large redesign; startup already has a splash.
- **Normalized product store:** compact cart/favorite persistence + 200-item/100-notification caps mitigate the main growth; a normalized store would touch every product consumer and is high-risk without device QA.
- **Feature cycles / shared product cards:** catalog↔cart/favorites imports and card duplication are maintainability issues, not runtime defects; deferred to avoid a cross-feature rewrite.
- **ProductCard/ProductGridCard consolidation:** the two cards intentionally differ in badge/layout; merging risks design regressions without visual QA.
- **Logout in-flight checkout write:** logout is only reachable from the Account tab while checkout is a separate route; the race is an edge case. A write-generation/delete-order transaction is the correct future fix.
- **Notifications mutation failure UX:** sealed state shows a full error and drops the visible list after a failed mark-read; a future `refreshingWithData` state can preserve context.
- **Auth screens:** login/register remain ~365/395 lines; extraction is cosmetic.

## Part 5 (sealed states) outcome (verified 2026-11-28)

- `flutter analyze`: **No issues found**; `flutter test`: **211/211 passed**.
- Notifications: `NotificationsStatus`/nullable fields replaced by `NotificationsInitial`, `NotificationsLoading`, `NotificationsSuccess(list)`, `NotificationsFailure(failure)`. Screen uses an exhaustive switch; HomeHeader still reads `unreadCount` via the base getter.
- Orders: `OrdersStatus`/nullable fields replaced by `OrdersInitial`, `OrdersLoading`, `OrdersSuccess(list)`, `OrdersFailure(failure)`. Success owns `currentOrders`/`pastOrders`/`orderById`; base getters keep account counters safe.
- Cubits rewritten to pattern-match and emit only legal states; `ensureLoaded`/silent `refreshStatuses`/`reset` preserved.
- Tests cover state getters, ensureLoaded retry/skip, silent refresh, reset, and failure states.
- Trade-off: mutation/refresh failures now replace the visible list with a full-screen error (no stale-list-with-error state). If desired, a later design can add an explicit `refreshingWithData` state.

## Part 4 (remaining screen splits) outcome (verified 2026-11-28)

- `flutter analyze`: **No issues found**; `flutter test`: **194/194 passed**.
- Account screen split **487 → 171** lines; extracted `StatsRow`, `StatBox`, `GroupLabel`, `AccountTiles`, `TilesCard`, `PreferencesCard`, `DesignSwitch` into `account/presentation/widgets/`. Session/logout logic unchanged.
- Product details info split **473 → 219** lines; extracted description, specs, color swatches, quantity stepper, info tiles into `catalog/presentation/widgets/details/info/`. Public constructor and RegExp behavior unchanged.
- Remaining large files: auth screens (login/register ~365/395 lines) and a few feature widgets; no behavior impact.
- Remaining P2: sealed states, feature cycles/shared cards, ProductCard consolidation, normalized product store, CancelToken, lazy Hive boxes, logout in-flight guard, manual QA.

## Part 3 (persistence/maintainability) outcome (verified 2026-11-28)

- `flutter analyze`: **No issues found**; `flutter test`: **194/194 passed**.
- Cart/favorite persistence is compact: `ProductMapper.toSummaryJson` stores only the fields their UI needs, omitting `description` and `images`. Legacy entries still decode; no migration required. Tests assert compact keys, round-trip fields, and real-Hive reloads.
- `checkout_screen.dart` split from **837 → 295** lines. Extracted address/delivery/payment/review/bank-card/step-title widgets into `checkout/presentation/widgets/`, with behavior/layout unchanged.
- `track_order_screen.dart` split from **574 → 172** lines. Extracted ETA/items/ship-to/cancelled/timeline widgets into `orders/presentation/widgets/`, polling/state logic unchanged.
- Remaining large files: account (~487), product details info (~473), auth screens.
- Remaining P2: normalized product store, sealed states, feature cycles/shared cards, ProductCard consolidation, CancelToken, lazy Hive boxes, logout in-flight guard, manual QA.

## Part 2 (retention/cache hardening) outcome (verified 2026-11-28)

- `flutter analyze`: **No issues found**; `flutter test`: **187/187 passed**.
- Orders retain at most 200 newest records; overflow is removed from cache immediately and deleted from Hive in one fire-and-forget call whose errors are ignored.
- Logout now also clears the on-disk image cache through `AppImageCache.manager.emptyCache()`; the callback is optional/injectable, so unit tests and future alternative caches stay simple. Disk-cache failures cannot abort logout.
- Catalog cache invalidation is generation-safe: invalidation clears caches + in-flight maps, pre-invalidation requests cannot write stale cache entries, and an old request cannot evict a newer in-flight request.
- Tests added for order retention, disk-cache success/failure/null, cache invalidation, and stale in-flight results.
- Remaining: lazy Hive boxes and logout in-flight checkout-write guard.

## Part 1 (UX hardening) outcome (verified 2026-11-28)

- `flutter analyze`: **No issues found**; `flutter test`: **181/181 passed**; l10n regenerated.
- Orders and Notifications now render real loading/failure states with retry instead of looking empty.
- Order Confirmation distinguishes loading, storage failure (retry), and genuinely missing order.
- Checkout bank card reads `SessionCubit` instead of the auth data source.
- Home unread dot is conditional on `NotificationsCubit.unreadCount` instead of always visible.
- Recent-search persistence is deduped per query, so pagination no longer rewrites it.
- Back button on `go`-based root paths falls back to home instead of doing nothing.
- Empty server messages now fall back to localized `errorServer` (EN/AR).
- Remaining: notification dot appears only after notifications are first loaded (intentional, avoids startup work).

## P2 batch 1 outcome (verified 2026-11-27)

- Implemented by two parallel workstreams; compatibility shim removed after integration.
- `flutter analyze`: **No issues found**; `flutter test`: **181/181 passed**.
- Domain rules:
  - `CartPricing` value object owns subtotal/discount/shipping/total and free-shipping thresholds.
  - `PromoCodePolicy` owns `RAFF10`, normalization, validation, and discount rate.
  - `CheckoutTotals` moved to checkout/domain and now depends on `CartPricing`, not presentation `CartState`.
  - `OrderStatusPolicy` is the single source for stage offsets/derivation; OrdersCubit and TrackOrder use it.
- Order navigation:
  - Order confirmation is `/order-confirmation/:id`; screen reads the path parameter and fetches from `OrdersCubit`, so deep links/relaunch work without `extra`.
  - Checkout uses `pushReplacement` to confirmation, preserving the shell underneath.
  - `AppRoutes.orderConfirmationFor` and `trackOrderFor` replace hardcoded paths in Checkout, Orders, Notifications, and Confirmation.
- Consolidation:
  - `FailureMapper` centralizes Dio → Failure mapping; repositories and `ErrorInterceptor` use it.
  - `ProductMapper` centralizes product JSON parse/serialize for Product/Favorite/Cart models.
  - `AppImageCache` uses the package's default manager (200 objects / 30 days), applied to all 8 image sites. A custom cache key (`raffImageCache`) left the Linux cache empty and images never resolved, so it was reverted to the working default manager; the existing default image cache is reused.
  - `SummaryRow` shared by cart/checkout summaries; `CartEmptyView`/`FavoritesEmptyView` replaced by `EmptyView` and deleted.
- Remaining P2:
  1. Normalized product store + compact cart/favorite persistence.
  2. Sealed async states; remove enum+nullable impossible states.
  3. Break catalog ↔ cart/favorites cycles; decouple shell badge; shared product card controls.
  4. Split large screens (checkout, track, details info, account).
  5. Full `ProductCard`/`ProductGridCard` consolidation.
  6. Thread Dio `CancelToken` through layers (generation guards + cache coalescing currently cover correctness).
  7. Lazy Hive boxes; orders archival/cap; checkout `_BankCard` session migration; logout in-flight write guard.

## Verification commands

```bash
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
```

Manual checks after Phase 0:
- Product details should no longer fire extra categories/products requests.
- Products route should no longer duplicate `products?limit=10`.
- Pagination error should show a retry row.
- Images should appear identical but with bounded decode sizes.
- Cart/notifications should scroll lazily.
- Login/Register can be abandoned mid-request without `StateError` (watch console).

Manual checks after P1:
- Cold start opens Hive boxes concurrently; no serial five-box delay in logs.
- Repeated categories/details calls hit the repository cache or share one in-flight request.
- Rapid category/query changes never render the older response last.
- Cart quantity taps perform one write and no whole-box re-read.
- Checkout failure keeps the cart and stays on the review step with an error.
- Checkout success shows the new order immediately in Orders/Track.
- Track Order stays idle in the background and does no Hive reads every 30s.
- Logout clears badges, cart, favorites, addresses, orders, notifications, recent searches and redirects to login.
- Home banner swipe rebuilds only the carousel; gallery swipe rebuilds only the gallery.
- Pull-to-refresh on Home/Products hits the network instead of returning cached data.
- Deep link to a protected route → login → returns to the intended route.
- A corrupt cached user entry still lets the app start at onboarding/login.

Manual checks after P2 batch 1:
- Order confirmation works after a cold start/deep link using only the order id.
- Confirmation back stack leaves the shell/tab state intact (`pushReplacement`).
- Changing the promo code or shipping method produces identical totals in cart/checkout/order.
- Track timeline and order status use one timing policy.
- All product images use the shared 200-object/30-day cache manager.
- Cart/favorites empty screens and cart/checkout summary rows still match the design after shared-widget migration.
