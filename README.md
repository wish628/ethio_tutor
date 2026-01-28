# Ethio Tutor - Amharic & Oromo Language Learning App

A mobile application for learning Amharic and Afaan Oromo languages with AI-powered tutoring assistance using Addis AI APIs.

## Features

- AI-powered language tutoring using Addis AI APIs
- Support for both Amharic and Afaan Oromo languages
- Voice recording and playback functionality
- Real-time language practice with feedback
- Beautiful UI optimized for Ethiopian scripts (Ge'ez)
- Secure API key management with environment variables
- Cross-platform compatibility (Android/iOS)

## Tech Stack

- **Flutter**: Cross-platform mobile development framework
- **Addis AI APIs**: For language processing, STT, and TTS in Amharic and Afaan Oromo
- **Dart**: Programming language for Flutter
- **HTTP**: For API communications
- **Just Audio**: For audio playback
- **Record**: For voice recording
- **Google Fonts**: For proper Ethiopian script rendering
- **Flutter Dotenv**: For secure API key management

## Setup Instructions

### Prerequisites

- Flutter SDK installed
- Access to Addis AI API (register at addisassistant.com to get your API key)

### Installation

1. Clone or download this repository
2. Navigate to the project directory: `cd ethio_tutor`
3. Install dependencies: `flutter pub get`
4. Get your Addis AI API key from [addisassistant.com](https://addisassistant.com)
5. Copy `.env.example` to `.env` and replace the placeholder with your actual API key. Do NOT commit `.env` to version control.

Security note: this repository previously contained a committed API key. The repo has been sanitized — please rotate any exposed keys in your Addis AI account.

### Configuration

1. Make sure to set up your Addis AI API key in the `.env` file
2. Ensure your Android device/emulator has microphone permissions enabled

### Running the App

- For development: `flutter run`
- For release build: `flutter build apk --release`

The APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`

## API Endpoints Used

- `/api/v1/chat_generate` - For language tutoring conversations
- `/api/v1/audio` - For text-to-speech conversion

## File Structure

```
lib/
├── main.dart          # Main UI and app entry point
├── ai_service.dart    # Addis AI API integration
```

## Permissions

The app requires the following permissions:
- RECORD_AUDIO: For voice recording
- INTERNET: For API calls
- WRITE_EXTERNAL_STORAGE: For saving audio files

## Contributing

Feel free to submit issues and enhancement requests!