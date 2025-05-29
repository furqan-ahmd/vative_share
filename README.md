# VativeShare

A comprehensive Flutter plugin for sharing content to popular social media platforms including Instagram, Facebook, WhatsApp, and Snapchat. This plugin provides native implementations for both iOS and Android with full Instagram Stories sharing support.

## Features

### Instagram
- ✅ Share images to Instagram Stories
- ✅ Share videos to Instagram Stories  
- ✅ Check if Instagram is installed

### Other Platforms
- ✅ Share links to Facebook
- ✅ Share messages and links to WhatsApp
- ✅ Share links to Snapchat
- ✅ Cross-platform compatibility
## Installation


Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  vative_share:
    git:
      url: https://github.com/vativeappsorg/vative_share
      ref: main
```


Then run:

```bash
flutter pub get
```

## Platform Setup

### iOS Setup

1. **Add URL Schemes** to your `ios/Runner/Info.plist`:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>instagram</string>
    <string>instagram-stories</string>
    <string>whatsapp</string>
    <string>fbapi</string>
    <string>snapchat</string>
    <string>facebook</string>
</array>
```


3. **Configure Facebook App ID** in `ios/Runner/Info.plist`:

```xml
<key>FacebookAppID</key>
<string>YOUR_FACEBOOK_APP_ID</string>
<key>FacebookDisplayName</key>
<string>YOUR_APP_NAME</string>
```

**Note:** The Facebook App ID is required for Instagram Stories sharing and Facebook sharing features.

### Android Setup

1. **Add permissions** to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

2. **Add FileProvider** to your `android/app/src/main/AndroidManifest.xml`:

```xml
<application>
    <provider
        android:name="androidx.core.content.FileProvider"
        android:authorities="${applicationId}.fileprovider"
        android:exported="false"
        android:grantUriPermissions="true">
        <meta-data
            android:name="android.support.FILE_PROVIDER_PATHS"
            android:resource="@xml/filepaths" />
    </provider>
</application>
```

3. **Create file paths configuration** at `android/app/src/main/res/xml/filepaths.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<paths xmlns:android="http://schemas.android.com/apk/res/android">
    <external-files-path name="external_files" path="." />
    <external-cache-path name="external_cache" path="." />
    <cache-path name="cache" path="." />
    <files-path name="files" path="." />
    <external-path name="external" path="." />
</paths>
```

4. **Add Facebook App ID** to your `android/app/src/main/AndroidManifest.xml`:

```xml
<application>
    <!-- Facebook App ID for Instagram Stories and Facebook sharing -->
    <meta-data
        android:name="com.facebook.sdk.ApplicationId"
        android:value="@string/facebook_app_id" />
</application>
```

5. **Add Facebook App ID** to your `android/app/src/main/res/values/strings.xml`:

```xml
<resources>
    <string name="facebook_app_id">YOUR_FACEBOOK_APP_ID</string>
</resources>
```

**Note:** The Facebook App ID configuration is required for Instagram Stories sharing and Facebook sharing features.

## Usage

### Import the package

```dart
import 'package:vative_share/vative_share.dart';
```

### Check Instagram Installation

```dart
bool isInstagramInstalled = await VativeShare.checkInstagramInstalled();
if (!isInstagramInstalled) {
  // Handle Instagram not installed
  print('Instagram is not installed');
  return;
}
```

### Share Image to Instagram Story

```dart
try {
  bool success = await VativeShare.shareImageToInstaStory(
    imagePath: '/path/to/your/image.jpg',
    facebookAppId: 'YOUR_FACEBOOK_APP_ID',
    stickerPath: '/path/to/sticker.png', // Optional
    topBackgroundColor: '#FF0000', // Optional
    bottomBackgroundColor: '#00FF00', // Optional
  );
  
  if (success) {
    print('Successfully shared to Instagram Story');
  }
} catch (e) {
  print('Error sharing to Instagram Story: $e');
}
```

### Share Video to Instagram Story

```dart
try {
  bool success = await VativeShare.shareVideoToInstaStory(
    videoPath: '/path/to/your/video.mp4',
    facebookAppId: 'YOUR_FACEBOOK_APP_ID',
    stickerPath: '/path/to/sticker.png', // Optional
    topBackgroundColor: '#000000', // Optional
    bottomBackgroundColor: '#FFFFFF', // Optional
  );
  
  if (success) {
    print('Successfully shared video to Instagram Story');
  }
} catch (e) {
  print('Error sharing video to Instagram Story: $e');
}
```

### Share to Other Platforms

```dart
// Share to Facebook
try {
  bool success = await VativeShare.shareLinkToFacebook(
    url: 'https://example.com',
    quote: 'Check out this amazing content!', // iOS only
  );
} catch (e) {
  print('Error sharing to Facebook: $e');
}

// Share to WhatsApp
try {
  bool success = await VativeShare.shareLinkToWhatsApp(
    url: 'https://example.com',
    message: 'Check this out!',
  );
} catch (e) {
  print('Error sharing to WhatsApp: $e');
}

// Share to Snapchat
try {
  bool success = await VativeShare.shareLinkToSnapchat(
    url: 'https://example.com',
  );
} catch (e) {
  print('Error sharing to Snapchat: $e');
}
```

## API Reference

### Instagram Methods

| Method | Description | Parameters |
|--------|-------------|------------|
| `checkInstagramInstalled()` | Check if Instagram is installed | None |
| `shareImageToInstaStory()` | Share image to Instagram Story | `imagePath`, `facebookAppId`, `stickerPath?`, `topBackgroundColor?`, `bottomBackgroundColor?` |
| `shareVideoToInstaStory()` | Share video to Instagram Story | `videoPath`, `facebookAppId`, `stickerPath?`, `topBackgroundColor?`, `bottomBackgroundColor?` |

### Other Platform Methods

| Method | Description | Parameters |
|--------|-------------|------------|
| `shareLinkToFacebook()` | Share link to Facebook | `url`, `quote?` (iOS only) |
| `shareLinkToWhatsApp()` | Share message/link to WhatsApp | `url`, `message` |
| `shareLinkToSnapchat()` | Share link to Snapchat | `url` |

## Error Handling

The plugin provides comprehensive error handling with specific error codes:

### Common Error Codes

- `INSTAGRAM_NOT_INSTALLED` - Instagram app is not installed
- `FILE_NOT_FOUND` - The specified file path doesn't exist
- `SHARE_FAILED` - Failed to open the sharing interface
- `SHARE_ERROR` - General sharing error
- `FB_APP_NOT_FOUND` - Facebook app not installed
- `WA_APP_NOT_FOUND` - WhatsApp app not installed
- `INVALID_ARGUMENTS` - Invalid or missing method arguments

### Example Error Handling

```dart
try {
  bool success = await VativeShare.shareImageToInstaStory(
    imagePath: imagePath,
    facebookAppId: facebookAppId,
  );
} on PlatformException catch (e) {
  switch (e.code) {
    case 'INSTAGRAM_NOT_INSTALLED':
      // Show dialog to install Instagram
      break;
    case 'FILE_NOT_FOUND':
      // Handle missing file
      break;
    case 'SHARE_FAILED':
      // Handle sharing failure
      break;
    default:
      // Handle other errors
      print('Error: ${e.message}');
  }
}
```

## Facebook App ID Setup

To use Instagram Story sharing, you need a Facebook App ID:

1. Go to [Facebook Developers](https://developers.facebook.com/)
2. Create a new app or use existing one
3. Get your App ID from the app settings
4. Configure the App ID in your platform-specific files as shown in setup

## Limitations

### Instagram Stories
- Sticker images should be PNG with transparency
- Background colors use hex format (e.g., '#FF0000')
- Video files should be MP4 format
- Maximum video duration: 15 seconds (Instagram limitation)
- Requires Facebook App ID for proper attribution

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you encounter any issues or have questions, please file an issue on the [GitHub repository](https://github.com/vativeapps/vative_share).

