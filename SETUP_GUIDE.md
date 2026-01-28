# Ethio Tutor - Setup Guide

Complete guide to set up and run the Amharic & Oromo language learning app.

## Project Structure

```
ethio_tutor/
├── lib/
│   ├── main.dart          # Main UI and app entry point
│   └── ai_service.dart    # Addis AI API integration
├── android/
│   └── app/
│       └── src/
│           └── main/
│               └── AndroidManifest.xml
├── pubspec.yaml          # Dependencies and project config
├── .env                  # Environment variables (not committed)
├── README.md             # Project documentation
├── SETUP_GUIDE.md        # This file
├── build_apk.bat         # Windows build script
└── build_apk.sh          # Unix build script
```

## Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (bundled with Flutter)
- Android Studio or VS Code with Flutter plugin
- Android device or emulator for testing

## Installation Steps

### 1. Install Flutter

If you haven't installed Flutter yet:

1. Download from [flutter.dev](https://flutter.dev)
2. Extract to a folder (e.g., `C:\src\flutter`)
3. Add Flutter's bin directory to your PATH environment variable
4. Run `flutter doctor` to verify installation

### 2. Get the Project

Clone or download this repository to your local machine.

### 3. Install Dependencies

Navigate to the project directory and run:

```bash
flutter pub get
```

This will install all the required packages listed in pubspec.yaml.

### 4. Set Up API Key

1. Register at [addisassistant.com](https://addisassistant.com) to get your API key
2. Create a `.env` file in the project root (already exists with template)
3. Replace `your_addis_ai_api_key_here` with your actual API key:

```env
ADDIS_AI_API_KEY=your_actual_api_key_here
BASE_URL=https://api.addisassistant.com/api/v1
```

## Running the Application

### Development Mode

To run the app in development mode:

```bash
flutter run
```

This will launch the app on your connected device or emulator.

### Release Build (APK)

To build a release APK for distribution:

```bash
flutter build apk --release
```

The APK will be created at:
`build/app/outputs/flutter-apk/app-release.apk`

#### Automated Build Scripts

We've provided build scripts for convenience:

**Windows:**
Double-click `build_apk.bat` or run in command prompt:
```cmd
build_apk.bat
```

**Linux/Mac:**
Run in terminal:
```bash
chmod +x build_apk.sh
./build_apk.sh
```

## Key Features Implemented

1. **Language Selection:** Toggle between Amharic and Afaan Oromo
2. **Voice Recording:** Long-press the mic button to record
3. **AI Interaction:** Connects to Addis AI for language tutoring
4. **Text-to-Speech:** Hear AI responses in the selected language
5. **Ethiopian Script Support:** Proper rendering of Ge'ez script using Google Fonts

## Dependencies Overview

- `http`: For API communications with Addis AI
- `record`: For capturing user voice input
- `just_audio`: For playing AI voice responses
- `path_provider`: For handling file paths on device
- `permission_handler`: For requesting necessary permissions
- `flutter_dotenv`: For managing API keys securely
- `google_fonts`: For proper Ethiopian script rendering

## Troubleshooting

### Common Issues:

1. **Missing Permissions:** Make sure to grant microphone permission to the app
2. **API Key Errors:** Verify your API key is correctly entered in `.env`
3. **Network Issues:** Ensure device has internet connection for API calls
4. **Build Failures:** Run `flutter clean` and `flutter pub get` before rebuilding

### Debugging:

Check the console output when running `flutter run` for detailed error messages.

## API Integration Details

The app connects to Addis AI APIs:

1. **Chat Generation API:** `POST /api/v1/chat_generate`
   - Sends user input and receives AI tutoring response
   - Includes target language parameter

2. **Text-to-Speech API:** `POST /api/v1/audio`
   - Converts AI text response to audio
   - Returns audio file bytes

## Security Notes

- Store API keys in `.env` file which should not be committed to version control
- The app handles permissions appropriately for voice recording
- All API communication happens over HTTPS

### Urgent: If you previously committed `.env` with a real key

- Rotate the exposed Addis AI API key immediately from your Addis AI dashboard.
- After rotation, update your local `.env` with the new key and do NOT commit it.

### Android signing (release)

1. Create a Java keystore if you don't have one:

```powershell
keytool -genkey -v -keystore %USERPROFILE%\my-release-key.jks -alias my-key-alias -keyalg RSA -keysize 2048 -validity 10000
```

2. Copy `android/key.properties.template` to `android/key.properties` and fill the values (do NOT commit `android/key.properties`).

3. Ensure your `android/app/build.gradle` references `key.properties` as shown in Flutter docs.

Optional helper: there's a helper script at `scripts/create_keystore.ps1` that runs `keytool` interactively and creates a keystore for you (Windows PowerShell). After running it, update `android/key.properties` from the template.

### CI and pre-commit hooks

- A GitHub Actions workflow is included at `.github/workflows/flutter-ci.yml` which runs `flutter analyze` and `flutter test` on PRs. It will fail if a `.env` file is present in the repo.
- The repository also includes a workflow to build a signed release AAB/APK on GitHub Actions. This allows you to build release artifacts without installing Flutter locally. To use it you must add the following repository secrets (Settings → Secrets → Actions):

   - `ADDIS_AI_API_KEY` — your Addis AI API key (string)
   - `BASE_URL` — optional, defaults to https://api.addisassistant.com/api/v1 (string)
   - `ANDROID_KEYSTORE_BASE64` — base64-encoded contents of your keystore file (optional if you don't want to sign)
   - `KEYSTORE_PASSWORD` — keystore password
   - `KEY_PASSWORD` — key password
   - `KEY_ALIAS` — key alias used in the keystore

Steps to create and upload the keystore secret (PowerShell example):

1. Create your keystore locally (or on any machine with Java JDK installed):

```powershell
keytool -genkey -v -keystore C:\path\to\upload-keystore.jks -alias my-key-alias -keyalg RSA -keysize 2048 -validity 10000
```

2. Convert the keystore to base64 (PowerShell):

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes('C:\path\to\upload-keystore.jks')) | Out-File -Encoding ascii keystore.base64.txt
```

3. Copy the contents of `keystore.base64.txt` and paste into the `ANDROID_KEYSTORE_BASE64` secret in GitHub repo settings. Add the other secrets (`KEYSTORE_PASSWORD`, `KEY_PASSWORD`, `KEY_ALIAS`, `ADDIS_AI_API_KEY`, `BASE_URL`) in the Secrets UI.

4. Trigger the release build from the Actions tab (there's also an option to trigger on push to `main`). The workflow will create a `.env` from `ADDIS_AI_API_KEY`, decode and write the keystore, create `android/key.properties` at build time, build an AAB, and upload it as an artifact you can download.
- A local git hook template is available at `.githooks/pre-commit`. To enable it locally run:

```bash
git config core.hooksPath .githooks
```

This prevents accidental commits of `.env`.

## Next Steps

1. Test the app thoroughly on different devices
2. Optimize for performance if needed
3. Add additional language learning features
4. Implement offline capabilities if required
5. Polish UI/UX based on user feedback