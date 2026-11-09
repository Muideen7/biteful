<div align="center">

<img src="assets/brand/icon_1024.png" width="108" alt="Dishly Flutter food delivery app icon" />

# Dishly: Flutter Food Delivery App Template

**Good food, delivered fast.**

A premium **Flutter food delivery app UI** for **iOS and Android**.<br />
Animated splash with a hand-drawn delivery rider, a sign-in screen that stays alive while you type,<br />
search, promo banners, categories, deals, restaurants, a fly-to-cart animation, checkout,<br />
live order tracking, editable profile and addresses, and dark mode.

<br />

[![Website](https://img.shields.io/badge/website-flutterzip.com-41671B?style=for-the-badge&logo=googlechrome&logoColor=white)](https://flutterzip.com)
[![Instagram](https://img.shields.io/badge/instagram-@flutter__zip-41671B?style=for-the-badge&logo=instagram&logoColor=white)](https://instagram.com/flutter_zip)

<br />

![Flutter](https://img.shields.io/badge/Flutter-3.38-41671B?style=flat-square&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.5+-41671B?style=flat-square&logo=dart&logoColor=white)
![Platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20Android-5F6B52?style=flat-square)
![State](https://img.shields.io/badge/state-Riverpod-5F6B52?style=flat-square)
![Tests](https://img.shields.io/badge/tests-89%20passing-4E7A22?style=flat-square)

<br />

<img src="docs/hero.png" alt="Dishly Flutter food delivery app screens: sign in, home with promo banner and categories, popular restaurants, dish sheet, cart and dark mode" />

</div>

<br />

## Contents

- [Highlights](#highlights)
- [Screens](#screens)
- [Try the demo](#try-the-demo)
- [Getting started](#getting-started)
- [Make it yours](#make-it-yours)
- [Connect a backend](#connect-a-backend)
- [Project structure](#project-structure)
- [How it is built](#how-it-is-built)
- [Testing](#testing)
- [Made by FlutterZip](#made-by-flutterzip)
- [Credits](#credits)
- [License](#license)

<br />

## Highlights

- **A delivery rider drawn entirely in code.** One `CustomPainter` with every moving part as a parameter:
  wheels that turn, a body that bobs, speed lines, exhaust puffs, and a waving arm with a phone and
  twinkling sparkles. The same drawing powers the splash, the sign-in header, the promo banner, the
  order-placed sheet and the app icon.
- **A splash that is one timeline.** The rider drives in and brakes, the wordmark rises letter by letter,
  the tagline settles, then the rider pulls away while the wordmark blurs out. The first screen mounts
  underneath before the drive-out, so its heavy first build never swallows the animation.
- **Sign in that never goes still.** The green header keeps moving while you type: the rider waves,
  sparkles twinkle and soft light drifts across it. The rider's wheels break the header's edge, so the
  form reads as a card cut into the scene. On sign in, the header morphs into Home's header.
- **Home in the classic food app order:** promo banners, Categories, Order again, Deals for you,
  Popular restaurants near you, Fast delivery, and a Best Sellers grid that the categories filter.
- **Fly to cart.** Tap + and the dish lifts off its own image, arcs to the Cart tab with two fading
  ghosts behind it, and lands with a squash of the cart icon and a tick of the badge.
- **Search** for dishes and restaurants as you type, ranked by how well the name matches, with recent
  searches you can remove and popular categories when the box is empty.
- **Orders you can follow.** My orders splits what is on its way from the past. An order's status
  (Preparing, On the way, Delivered) is read off the clock, never stored, and its page shows the rider
  riding toward your door, every step with its time, the address, the items and the receipt.
  Reorder puts a whole past order back in the cart.
- **Pages open inside their tab.** A restaurant, an order or search keeps the navigation bar, so the
  cart is always there to fly into. Tap the tab again to go back to its start.
- **A working basket.** Quantities, swipe to remove with undo, deals with minimum spends that say how
  much more you need, delivery fees from the restaurants in the basket, checkout, and the order joining
  Order again.
- **Light and dark mode** from one set of tokens, reduce-motion respected everywhere.

<br />

## Screens

| Screen | What it does |
|---|---|
| Splash | Rider drives in, wordmark and tagline rise, rider drives off. Waits for the data before leaving. |
| Sign in / Sign up | Live header, validated fields, Keep me signed in, Forgot password sheet, Google and Apple, Sign up mode with a name field and terms. |
| Home | Pinned green header with address and notifications, banner carousel, every section above, pull to refresh, loading and error states. |
| Dish sheet | Big render, rating, calories, time, description, save, quantity, add to cart. |
| Restaurant | Header with its dishes, rating, delivery time, distance and fee, then its menu. |
| Saved | Dishes you hearted. Empty state when there are none. |
| Cart | Lines with steppers, swipe to remove, promo, totals, checkout and the order-placed sheet. |
| Offers | Every deal with its terms, applied or not. |
| Search | Live results for restaurants and dishes, recent searches, popular categories, empty result. |
| My orders | Live orders and past orders, Track and Reorder. |
| Order | Live tracker, steps with times, address, items, receipt, pinned Reorder. |
| Profile | Edit name, email and phone, My orders, addresses, theme, reset demo data, sign out. |
| Addresses | Choose where to deliver, add, edit, swipe to remove with undo. |

<br />

## Try the demo

- Sign in with **any** email and a password of 6 characters or more. You are signed in as the demo
  person, Olympicson.
- To see the wrong-password state, use the password **`wrongpass`**.
- Pick **Salads** in Categories to see an empty category.
- Apply **TREAT30** with a small basket to see a deal that needs a bigger order.
- Order **DL-48213** is live for the first twenty minutes after install: watch it go from Preparing to
  On the way to Delivered under Profile > My orders.
- Profile > **Reset demo data** returns the app to a first launch, and the live order starts again.

<br />

## Getting started

```bash
git clone https://github.com/flutterzip/dishly.git
cd dishly
flutter pub get
flutter run
```

Skip every deliberate wait (the splash included) for screenshots and automation:

```bash
flutter run --dart-define=timingScale=0
```

<br />

## Make it yours

| To change | Edit |
|---|---|
| The app name and tagline | `lib/config/app_brand.dart` (seed copy uses `{app}`, substituted at load) |
| Colours, light and dark | `lib/config/palette.dart` |
| Durations and curves | `lib/config/motion.dart` |
| Simulated network waits | `lib/config/app_timing.dart` |
| Menu, restaurants, deals, banners, the demo person | `assets/data/*.json`, one file per entity |
| Food art | `assets/images/food/`, referenced by file name from the JSON |
| The rider | `lib/widgets/rider/rider_painter.dart` |
| The app icon | `flutter test tool/make_icon_test.dart && python3 tool/make_icons.py` |

<br />

## Connect a backend

Every screen gets its data from four repositories, and the whole choice of where data comes from is one
file: `lib/providers/core_providers.dart`.

| Repository | What it serves | File |
|---|---|---|
| `CatalogRepository` | categories, dishes, restaurants, deals, banners | `lib/services/catalog_repository.dart` |
| `AuthRepository` | sign in, sign up, Google and Apple, password reset | `lib/services/auth_repository.dart` |
| `AccountRepository` | profile, addresses, notifications | `lib/services/account_repository.dart` |
| `OrderRepository` | order history, placing an order | `lib/services/order_repository.dart` |

To move to your API or database:

1. Fill in the `Remote...` class sketched at the bottom of each repository file.
2. Return it from the matching provider in `core_providers.dart` instead of the `Local...` / `Demo...` one.

That is all. You do not need to touch any `fromJson`: each model has exactly one, in `lib/models/`, and
the seed files in `assets/data/` already use the JSON shapes an API would send, so the same parsing
serves both. No widget or provider reads the seed directly; only the local repositories do.

<br />

## Project structure

```
lib/
  config/       brand, palette, theme, motion, timing, design tokens
  models/       catalog, deals, account, orders, money
  services/     seed loading, storage, and the catalog, auth, account and order repositories (each with a remote stub)
  providers/    Riverpod state; core_providers.dart is the one place data sources are chosen
  screens/      splash, auth, home (one file per section), search, product, restaurant, cart, orders,
                saved, offers, profile
  widgets/      rider, wordmark, food card, fly to cart, sheets, fields, buttons
assets/data/    the seed, one JSON file per entity
test/           unit, provider, screen and whole-app tests
tool/           icon, font and screenshot generators
```

<br />

## How it is built

- **Seed versus state.** The menu is read-only JSON bundled with the app. What you change (cart, saved,
  deal, address, read marks, orders, theme, session) is stored separately in `shared_preferences`, so a
  reset brings the seed back.
- **Derived, never tallied.** Cart totals, delivery, discounts and "add $x more" are computed from the
  lines, the menu and the deal on every read. Two screens can never disagree.
- **Money is integer cents** everywhere, turned into text in one function.
- **Every repository is async with a commented remote implementation**, so a real backend drops in
  without touching a widget (see [Connect a backend](#connect-a-backend)).
- **Seed dates never go stale.** Seeded orders store their age, not a date, and are stamped against
  the first launch, so they age like real orders and a reset starts them again.
- **One motion config and one timing config.** Ambient loops stop under reduce-motion and in tests.
- **One modal surface** for every sheet: it rises from the bottom, blurs behind and caps its height.

<br />

## Testing

```bash
flutter analyze
flutter test
```

89 tests cover the cart and order maths, search ranking, the seed's integrity (every id it references exists, every image is
bundled, no em dashes), the repositories and providers, every screen at phone size including a small
phone at large text, the fly-to-cart flight, every order status at a pinned clock, the nested tab navigation, the
overscroll fill on iOS, and the whole app through the splash, including a check
that the first screen is not rebuilt when the splash leaves.

<br />

## Made by FlutterZip

Dishly is made by **[FlutterZip](https://flutterzip.com)**: premium Flutter app templates and UI, built to ship.

- Website: **[flutterzip.com](https://flutterzip.com)**
- Instagram: **[@flutter_zip](https://instagram.com/flutter_zip)** for new templates, builds and behind-the-scenes

<br />

## Credits

- Food art: [Fluent Emoji](https://github.com/microsoft/fluentui-emoji) 3D renders by Microsoft, under the [MIT License](assets/images/food/LICENSE.txt).
- Typeface: [Bricolage Grotesque](https://github.com/ateliertriay/bricolage) by Mathieu Triay, under the SIL Open Font License 1.1.
- The rider, scooter, banner city, loader and app icon are drawn in code. The Apple and Google sign-in buttons follow those companies' published guidelines.

<br />

## License

The code is released under the [MIT License](LICENSE): use it in personal and commercial apps, free.
The Fluent Emoji renders are under Microsoft's [MIT License](assets/images/food/LICENSE.txt), and the
Bricolage Grotesque font under the [SIL Open Font License 1.1](assets/fonts/OFL.txt).

<br />

<div align="center">

**[flutterzip.com](https://flutterzip.com)** · **[@flutter_zip](https://instagram.com/flutter_zip)**

<sub>Dishly · Flutter food delivery app template · restaurant ordering UI kit for iOS and Android</sub>

</div>
