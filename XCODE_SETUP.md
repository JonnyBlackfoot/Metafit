# MetaFit Xcode project (wired up)

This folder contains **`MetaFit.xcodeproj`** with your **metafit** (iPhone) + **metafit Watch App** targets connected to the shared MetaFit codebase.

## What was done

- **`Shared/`** — Models, `LlamaService`, `HealthKitManager`, `WatchConnectivityManager` (included in **both** iPhone and Watch targets).
- **`metafit/`** — iPhone companion: `MetaFitPhoneApp`, `GlassesConnectionView`, `GlassesBridgeService`, `PhoneSettingsView`, Meta `Info.plist` keys (`MetaFit-iOS-Info.plist`).
- **`metafit Watch App/`** — Watch app: `MetaFitWatchApp`, all Watch views/view models, HealthKit entitlements, watch `MetaFit-Watch-Info.plist`.
- **Swift Package** — `https://github.com/facebook/meta-wearables-dat-ios` is added to the **metafit** (iPhone) target only (`MWDATCore`, `MWDATCamera`).
- Template files removed from **metafit** / **metafit Watch App** that conflicted with `@main` (`MetaFitApp` / `metafitApp`, `ContentView`, `Item` on iPhone bridge; watch `metafitApp` / `ContentView`).

## What you should run

1. Open **`MetaFit.xcodeproj`** in Xcode.
2. Select the **`metafit`** scheme (not the standalone **MetaFit** iOS-only target unless you intend to use that duplicate).
3. Choose an **iPhone** simulator or device and run — Xcode installs the embedded Watch app when a Watch is paired or a Watch simulator is used with the phone.
4. To focus on the Watch UI: choose the **`metafit Watch App`** scheme and a **Watch** simulator.

## After opening

- **File → Packages → Resolve Package Versions** (first open) so the Meta Wearables package downloads.
- In **Signing & Capabilities**, confirm **HealthKit** is enabled for the Watch target if Xcode prompts (entitlements file is `metafit Watch App/MetaFitWatch.entitlements`).
- Fill **Meta App ID** / **Client Token** in `metafit/MetaFit-iOS-Info.plist` under `MWDAT` when you move beyond developer mode.

## Note on the extra **MetaFit** target

The project still contains a third target, **MetaFit** (`munnylab.MetaFit`), which is the original template app. You can ignore it or delete that target later to avoid confusion.
