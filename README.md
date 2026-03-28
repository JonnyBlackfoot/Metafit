# MetaFit

Apple Watch gym fitness app built with SwiftUI and HealthKit.

## Features

- **Daily Workout Creation** - Start a new workout session each day at the gym
- **Exercise Library** - 40+ exercises across 7 categories (Chest, Back, Shoulders, Arms, Legs, Core, Cardio)
- **Set Tracking** - Log reps and weight for each set with easy +/- controls
- **Rest Timer** - Configurable rest timer between sets (30s, 60s, 90s, 2m, 3m presets)
- **Live Stats** - Real-time workout duration, heart rate (via HealthKit), and completed sets
- **Workout History** - View past workouts with duration, volume, and exercise breakdowns
- **Weekly Stats** - Track workout count and total volume for the week
- **HealthKit Integration** - Records workouts to Apple Health, tracks heart rate and calories

## Project Structure

```
MetafitWatch/
├── MetafitApp.swift              # App entry point
├── Models/
│   ├── Exercise.swift            # Exercise, ExerciseSet, WorkoutExercise models
│   ├── ExerciseCategory.swift    # Categories and exercise library
│   └── Workout.swift             # Workout model with computed stats
├── Views/
│   ├── HomeView.swift            # Main screen with today's workout and stats
│   ├── ActiveWorkoutView.swift   # Active workout session with live stats
│   ├── ExercisePickerView.swift  # Browse and select exercises by category
│   ├── LogSetView.swift          # Log reps and weight for each set
│   ├── RestTimerView.swift       # Circular rest timer between sets
│   ├── WorkoutSummaryView.swift  # Post-workout summary
│   └── HistoryView.swift         # Past workout history
└── Services/
    ├── WorkoutManager.swift      # Workout state management
    ├── HealthKitManager.swift    # HealthKit workout sessions and heart rate
    └── StorageManager.swift      # Local persistence via UserDefaults
```

## Requirements

- watchOS 10.0+
- Xcode 15.0+
- Swift 5.9+

## Setup

1. Open `Metafit.xcodeproj` in Xcode
2. Select a watchOS simulator or paired Apple Watch
3. Build and run

The app will request HealthKit permissions on first launch to track heart rate and save workouts.
