# Tank Master IoT (Flutter)

Smart water tank mobile app with Firebase Realtime Database.

## Features
- Real-time water level display
- Tank status (`Tank Full`, `Low Level`, `Filling`, `Normal`)
- Pump ON/OFF control
- Daily and monthly usage cards
- Alerts for overflow and low level

## Project Structure
```text
lib/
  main.dart
  screens/
    dashboard.dart
  services/
    firebase_service.dart
  models/
    tank_model.dart
test/
  tank_model_test.dart
```

## Firebase Realtime Database Example
```json
{
  "tank": {
    "level": 65,
    "pump": true,
    "flow": 12,
    "dailyUsage": 180,
    "monthlyUsage": 3200,
    "overflowAlert": false,
    "lowLevelAlert": false
  }
}
```

## Setup
1. Install Flutter SDK and add it to your PATH.
2. Add Firebase to your Flutter app (`flutterfire configure`) and generate platform config files.
3. Run package install and start the app.

```powershell
flutter pub get
flutter run
```

## Test
```powershell
flutter test
```

## Optional Extensions
- Firebase Cloud Messaging notifications
- Daily and monthly usage charts
- Multiple tank support
