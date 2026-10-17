# ZiggyBites User App — Structure

| Field     | Value                                              |
| --------- | -------------------------------------------------- |
| Type      | Flutter shell + WebView of `https://ziggybites.com/` |
| Package   | `com.ziggybites.user`                              |
| Version   | `3.2.3+8`                                          |

---

## Modules

| Module                              | WebView? | Summary                                              |
| ----------------------------------- | -------- | ---------------------------------------------------- |
| `main.dart`                         | No       | App entry; Firebase + notifications; home → WebView  |
| `config/app_config.dart`            | No       | App name, URLs, colors, onboarding, FCM endpoint     |
| `config/theme_config.dart`          | No       | Light / dark theme                                   |
| `screens/splash_screen.dart`        | No       | Native splash (not current home)                     |
| `screens/onboarding_screen.dart`    | No       | Native intro slides                                  |
| `screens/webview_screen.dart`       | **Yes**  | Main screen; loads full website SPA                  |
| `services/api_service.dart`         | No       | Native HTTP (save FCM token)                         |
| `utils/notification_service.dart`   | No       | FCM + local notifications                            |
| `utils/fcm_background_handler.dart` | No       | Background push handler                              |
| `utils/download_service.dart`       | No       | File / receipt downloads                             |
| `utils/permission_handler_util.dart`| No       | Camera, location, mic, storage                       |
| `utils/prefs_util.dart`             | No       | Local storage (token, phone, theme)                  |
| `utils/connectivity_util.dart`      | No       | Network status                                       |
| `utils/status_bar_util.dart`        | No       | Status bar styling                                   |
| `widgets/exit_dialog.dart`          | No       | Exit confirmation                                    |
| `widgets/offline_screen.dart`       | No       | Offline overlay                                      |

---

## Product screens (all inside WebView)

| Route                                      | Name            |
| ------------------------------------------ | --------------- |
| `/#/food/user`                             | Home            |
| `/#/user/auth/login`                       | Login           |
| `/#/user/auth/portal`                      | Auth / signup   |
| `/#/food/user/restaurants`                 | Restaurants     |
| `/#/food/user/address-selector`            | Address / map   |
| `/#/food/user/profile`                     | Profile         |
| `/#/food/user/profile/subscriptions`       | Subscriptions   |

---

## Tree

| Path         | Contents                              |
| ------------ | ------------------------------------- |
| `lib/`       | App source                            |
| `config/`    | `app_config`, `theme_config`          |
| `screens/`   | `splash`, `onboarding`, `webview` ★   |
| `services/`  | `api_service`                         |
| `utils/`     | notifications, downloads, prefs, …    |
| `widgets/`   | `exit_dialog`, `offline_screen`       |

**Rule:** Only `webview_screen.dart` uses WebView. Home, login, profile, restaurants, etc. are website routes — not Flutter UI.

---

## Disadvantages of full-app WebView

| Area              | Disadvantage                                                                 |
| ----------------- | ---------------------------------------------------------------------------- |
| Performance       | Slower than native Flutter; heavier memory; less smooth scroll/animations    |
| Store review      | Apple/Google may reject thin website wrappers without clear native value     |
| UX                | Back, keyboard, gestures, safe areas feel browser-like, not native           |
| Offline           | Needs network for almost everything; site down ≈ app broken                  |
| Debugging         | Bugs span Flutter bridges + website; harder to trace                         |
| Fragility         | Web updates can break JS handlers without an app release                     |
| Native features   | Push, camera, UPI, Google Sign-In need custom bridges (fragile)              |
| Consistency       | Android WebView vs iOS WKWebView can behave differently                      |
| Security/session  | Cookie/session model weaker than a real native auth flow                     |
| Product feel      | Users may notice “this is just the website”; less premium vs native apps     |

**Trade-off:** Faster shipping (one web UI for web + app), but weaker performance, polish, offline, and store risk.
