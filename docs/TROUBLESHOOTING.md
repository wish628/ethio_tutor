# Troubleshooting Guide

Common issues and solutions for Ethio Tutor.

## Build Issues

### Flutter Dependencies Error

**Problem**: `flutter pub get` fails or shows dependency conflicts

**Solution**:
```bash
# Clean flutter
flutter clean

# Remove pubspec.lock
rm pubspec.lock

# Get dependencies again
flutter pub get
```

### Android Build Fails

**Problem**: Build fails with Gradle errors

**Solution**:
```bash
# Clean build
flutter clean

# Update gradle wrapper
cd android
./gradlew wrapper --gradle-version 7.5

# Try building again
cd ..
flutter build apk
```

### Missing API Key Error

**Problem**: App crashes or shows "API key not found"

**Solution**:
1. Verify `.env` file exists in project root
2. Check `.env` file contains `ADDIS_AI_API_KEY=your_key`
3. For GitHub Actions, verify secrets are configured
4. Rebuild the app after adding the key

## Runtime Issues

### Microphone Permission Denied

**Problem**: Can't record audio, permission denied message

**Solution**:
1. Go to device Settings
2. Navigate to Apps → Ethio Tutor → Permissions
3. Enable Microphone permission
4. Restart the app

**On Android 11+**: Also check if the app has "All files access" if needed.

### Audio Recording Not Working

**Problem**: Recording starts but no audio is captured

**Solutions**:
1. Check another app uses microphone successfully
2. Restart your device
3. Reinstall the app
4. Check if microphone is physically blocked or damaged

### AI Not Responding

**Problem**: App shows "Getting AI response..." but never completes

**Solutions**:
1. **Check Internet**: Ensure you have active internet connection
2. **Verify API Key**: Make sure your API key is valid
3. **Check API Status**: Visit https://status.addisassistant.com
4. **Wait and Retry**: The app has 3 automatic retries built-in
5. **Check Logs**: Look for error messages in logcat

```bash
# View Android logs
adb logcat | grep -i "ethio\|flutter"
```

### Voice Playback Issues

**Problem**: AI responds but no audio plays

**Solutions**:
1. Check device volume is not muted
2. Verify "Voice Feedback" is enabled in Settings
3. Try adjusting Speech Speed in Settings
4. Restart the app
5. Check if other apps can play audio

### App Crashes on Startup

**Problem**: App crashes immediately when opened

**Solutions**:
1. Clear app data: Settings → Apps → Ethio Tutor → Clear Data
2. Reinstall the app
3. Check if device meets minimum requirements (Android 5.0+)
4. View crash logs:
```bash
adb logcat -d > crash_log.txt
```

## Progress & Data Issues

### Progress Not Saving

**Problem**: Streak or lessons completed resets

**Solutions**:
1. Don't clear app data
2. Ensure app has storage permissions
3. Complete lessons fully before closing app
4. Check device storage isn't full

### Achievements Not Unlocking

**Problem**: Met requirements but achievement still locked

**Solutions**:
1. Pull down to refresh on Progress screen
2. Complete one more lesson to trigger check
3. Restart the app
4. Check if the requirement counter is correct

### Flashcard Progress Reset

**Problem**: All flashcards marked as "New" again

**Solutions**:
1. Don't uninstall/reinstall the app (data is lost)
2. Avoid clearing app data
3. Back up progress (feature coming soon)

## Network Issues

### Slow API Responses

**Problem**: Responses take too long

**Solutions**:
1. Check internet speed (minimum 1 Mbps recommended)
2. Switch from mobile data to WiFi or vice versa
3. Move closer to WiFi router
4. Try during off-peak hours
5. Contact Addis AI support if persistent

### Connection Timeout

**Problem**: "Request timeout" errors

**Solutions**:
1. Ensure stable internet connection
2. The app will retry automatically (up to 3 times)
3. Try again after a few moments
4. Check firewall/VPN isn't blocking the connection

## UI/UX Issues

### Text Not Displaying Correctly

**Problem**: Amharic/Oromo text shows boxes or strange characters

**Solutions**:
1. Update Google Fonts: The app should download Noto Sans Ethiopic automatically
2. Check internet connection (fonts download on first launch)
3. Restart the app
4. Clear app cache

### Dark Mode Not Working

**Problem**: Dark mode toggle doesn't work (Feature in development)

**Note**: Dark mode support is coming in a future update. Currently, the app follows your system theme partially.

### Animations Laggy

**Problem**: UI animations are slow or stuttering

**Solutions**:
1. Close other apps to free up memory
2. Restart device
3. Check if device has at least 2GB RAM
4. Disable animations in developer options temporarily

## GitHub Actions Build Issues

### Secrets Not Found

**Problem**: GitHub Actions fails with "ADDIS_AI_API_KEY not found"

**Solution**:
1. Go to repository Settings → Secrets and variables → Actions
2. Add secret named `ADDIS_AI_API_KEY`
3. Paste your API key
4. Re-run the workflow

### Build APK Workflow Fails

**Problem**: Workflow fails during build

**Solutions**:
1. Check workflow logs for specific error
2. Verify all dependencies in `pubspec.yaml` are valid
3. Ensure Flutter version in workflow matches local
4. Try running build locally first:
```bash
flutter build apk --release
```

## Getting Help

If your issue isn't listed here:

1. **Check GitHub Issues**: [github.com/wish628/ethio_tutor/issues](https://github.com/wish628/ethio_tutor/issues)
2. **Create New Issue**: Include:
   - Device model and Android version
   - App version
   - Steps to reproduce
   - Screenshots if applicable
   - Logcat output if available

3. **Contact Support**:
   - Email: support@ethiotutor.com
   - Include issue details and device information

## Debug Mode

To enable verbose logging:

```bash
# Run app in debug mode
flutter run --verbose

# Or for release with logs
flutter run --release --verbose
```

## Resetting the App

**Complete Reset** (WARNING: All progress will be lost):
1. Uninstall the app
2. Reinstall from latest APK
3. Set up API key again
4. Start fresh

**Soft Reset** (Keep installation):
1. Go to Settings → Apps → Ethio Tutor
2. Clear Cache (keeps progress)
3. Or Clear Data (resets everything)
