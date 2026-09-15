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

## UI demo
The dashboard starts in demo mode with 72% water, a running pump, 12.4 L/min
flow, 180 L daily usage, and 5,400 L monthly usage. Use the Low / Normal / Full
chips to preview tank states and alerts. Pump controls change local sample data;
no pump command is sent to Firebase in demo mode. Values persist while the app
is running and reset on restart.

Edit `_demoTank` in `lib/services/firebase_service.dart` to customize the readings.
Usage and notification history are labeled sample content.

To connect the dashboard to Firebase instead:
```powershell
flutter run --dart-define=DEMO_MODE=false
```
