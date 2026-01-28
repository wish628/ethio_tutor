#!/bin/bash

echo "Building Ethio Tutor APK..."
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null
then
    echo "Error: Flutter is not installed or not in PATH"
    echo "Please install Flutter from https://flutter.dev"
    exit 1
fi

echo "Getting dependencies..."
flutter pub get

echo ""
echo "Building APK in release mode..."
flutter build apk --release

echo ""
echo "Build complete!"
echo "APK location: build/app/outputs/flutter-apk/app-release.apk"