# MetaFit

Apple Watch gym workout app built with SwiftUI and HealthKit. It is a watch-only app: there is no iPhone companion. Start a workout, pick exercises, log sets, run a rest timer, finish, and review history on the watch.

## Requirements

- A Mac with Xcode 15 or later
- A watchOS 10 simulator runtime (installed from Xcode → Settings → Components)

This repository cannot be built on Linux or Windows. watchOS apps compile only with Xcode on macOS.

## Open and run

1. Open `Metafit.xcodeproj` in Xcode.
2. In the toolbar scheme menu, select **MetafitWatch**.
3. Choose an Apple Watch simulator destination, for example **Apple Watch Series 10 (46mm)** or **Apple Watch Ultra 2**. Do not pick an iPhone destination; this target runs on watchOS.
4. Press **Run** (⌘R).

If the build stops because signing requires a development team, select the **MetafitWatch** target, open **Signing & Capabilities**, and choose your Team. A free personal team is enough for the simulator. The target is already set to sign watch-simulator builds locally (`Sign to Run Locally`) when no team is selected.

On first launch the app asks for Health permission so it can read heart rate and save the workout. The Watch simulator often has no live heart-rate samples, and HealthKit workout sessions may be declined there. Exercise logging, the rest timer, and history still work; those are stored on the watch with UserDefaults. Heart rate appears when a sample is available (a real Apple Watch, or a simulator that has Health data).

### Workout flow

1. **Start Workout** on the home screen.
2. **Add Exercise**, choose a category, then choose a lift.
3. Adjust reps and weight, then **Complete Set**. The rest timer opens (30s, 60s, 90s, 2m, 3m).
4. **Finish** to save the session, or cancel it.
5. **Workout History** opens a past session and its summary.

## Project layout

```
Metafit.xcodeproj          # watchOS app target, shared MetafitWatch scheme
MetafitWatch/
├── MetafitApp.swift       # @main entry; requests HealthKit authorization
├── Info.plist             # WKWatchOnly, privacy strings, workout background mode
├── MetafitWatch.entitlements
└── Assets.xcassets
MetaFitSource/             # compiled into the MetafitWatch target
├── Models/
├── Views/
└── Services/
```

The single target is `MetafitWatch` (`com.metafit.watchapp`, watchOS 10+). HealthKit is enabled in the entitlements, and `NSHealthShareUsageDescription` / `NSHealthUpdateUsageDescription` are in the Info.plist. `WKCompanionAppBundleIdentifier` is intentionally unset so Xcode does not look for an iPhone app.
