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
flow, 180 L daily usage, and 5,400 L monthly usage. Pump controls change local sample data;
no pump command is sent to Firebase in demo mode. Values persist while the app
is running and reset on restart.

Edit `_demoTank` in `lib/services/firebase_service.dart` to customize the readings.
Usage and notification history are labeled sample content.

To connect the dashboard to Firebase instead:
```powershell
flutter run --dart-define=DEMO_MODE=false
```

## Mobile interface
- Phone-first layout with safe areas, persistent bottom tabs, and animated selection.
- Shared animated circular tank on Home, tank cards, and tank details.
- Aqua water screens, violet usage charts, coral notifications, and mint profile settings.
- Week/month usage switch and local read/unread notification controls.
- Profile preferences are local previews; they do not configure notifications or automation.
- Login and registration support scrolling while the phone keyboard is open.

Run `flutter test` for phone layouts, larger text, keyboard and navigation checks.
