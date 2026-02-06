# DSP KPI

Admin and driver dashboard for DSP KPIs, with a PDF parsing service and Firebase backend.

## Repo layout
- `flutter_app/kpi_admin/`: Flutter admin/driver application
- `parser_service/`: Python PDF parsing service
- `firebase/functions/`: Firebase Cloud Functions (TypeScript)
- `firebase/*.rules`: Firestore/Storage rules and indexes
- `*.pdf`: Sample scorecard/POD quality inputs

## Requirements
- Flutter (latest stable) + Dart
- Node.js 22 (for Firebase Functions)
- Python 3.10+
- Firebase project configured (see "Firebase config" below)

## Getting started

### Flutter app
```sh
cd flutter_app/kpi_admin
flutter pub get
flutter run -d chrome
```

### Parser service
```sh
cd parser_service
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python app.py
```

### Firebase functions
```sh
cd firebase/functions
npm install
npm run build
```

## Firebase config
This repo ignores Firebase config files that contain API keys. Generate them locally with the FlutterFire CLI:
```sh
cd flutter_app/kpi_admin
flutterfire configure
```

Expected files (generated locally):
- `flutter_app/kpi_admin/lib/firebase_options.dart`
- `flutter_app/kpi_admin/android/app/google-services.json`
- `flutter_app/kpi_admin/ios/Runner/GoogleService-Info.plist`
- `flutter_app/kpi_admin/macos/Runner/GoogleService-Info.plist`

## Notes
- The parser service ingests DSP scorecard and POD quality PDFs and writes structured data for the app to consume.
- Sample PDFs in the repo root can be used to validate parser behavior.
