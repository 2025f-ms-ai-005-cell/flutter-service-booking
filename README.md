# Bookly — Flutter Service Booking Demo

A small, AI-assisted portfolio project prepared for **Sadia Liaqat**. Demonstrates Flutter UI, appointment validation, duplicate-slot prevention and cancellation. It is a learning/demo project, **not client work or a production booking system**.

## Features

- Sample service catalogue with session durations.
- Date picker and time-slot selection in the device’s local timezone.
- Validation for customer name, future appointments and duplicate service slots.
- Appointment list and cancellation confirmation.
- Responsive constrained layout and Material 3.
- Booking logic tests plus a widget smoke test.

## Run (Flutter SDK required)

Windows PowerShell, from this repository:

```powershell
./setup.ps1
cd app
flutter test
flutter run -d chrome
```

For Android, connect an emulator/device and use `flutter run`.

On macOS/Linux: run `flutter create --platforms=android,web --project-name service_booking_demo app`, copy `pubspec.yaml` to `app/`, `booking_app.dart` to `app/lib/main.dart`, delete the generated `app/test/widget_test.dart`, and copy `booking_test.dart` to `app/test/`. Then run `flutter pub get` inside `app`.

## Source layout

`booking_app.dart` contains the UI and observable in-memory booking store; `booking_test.dart` covers its behavior. The setup script generates Flutter’s standard platform scaffolding, then installs these sources. Existing `app/` directories are never overwritten by the script.

## Honest limitations

No Firebase, sign-in, payment processing, notifications or backend concurrency control. Bookings live only in memory and reset on restart. A real backend would need server-side slot locking, security rules, account verification and timezone handling. No claims of deployment or commercial use.

## Verification

Tests are included. See `VERIFICATION.md` for what was actually executed in the authoring environment.

## Next milestone

Separate repository interfaces from UI, add persistent demo storage, then implement authenticated Firebase booking transactions with security-rule tests after a real Firebase project is supplied.

[Sadia’s LinkedIn](https://www.linkedin.com/in/sadia-liaqat-493998398/)
