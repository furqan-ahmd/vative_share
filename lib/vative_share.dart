import 'vative_share_platform_interface.dart';

class VativeShare {
  VativeShare._();

  /// Share an image to Instagram Story
  static Future<void> shareImageToInstaStory({
    required String imagePath,
    required String facebookAppId,
    String? stickerPath,
    String? topBackgroundColor,
    String? bottomBackgroundColor,
  }) {
    return VativeSharePlatform.instance.shareImageToInstaStory(
      imagePath: imagePath,
      facebookAppId: facebookAppId,
      stickerPath: stickerPath,
      topBackgroundColor: topBackgroundColor,
      bottomBackgroundColor: bottomBackgroundColor,
    );
  }

  /// Share a video to Instagram Story
  static Future<void> shareVideoToInstaStory({
    required String videoPath,
    required String facebookAppId,
    String? stickerPath,
    String? topBackgroundColor,
    String? bottomBackgroundColor,
  }) {
    return VativeSharePlatform.instance.shareVideoToInstaStory(
      videoPath: videoPath,
      facebookAppId: facebookAppId,
      stickerPath: stickerPath,
      topBackgroundColor: topBackgroundColor,
      bottomBackgroundColor: bottomBackgroundColor,
    );
  }

  /// Share an image to Instagram feed
  static Future<void> shareImageToFeed({
    required String imagePath,
  }) {
    return VativeSharePlatform.instance
        .shareImageToInstaFeed(imagePath: imagePath);
  }

  /// Share a video to Instagram feed
  static Future<void> shareVideoToInstagramFeed({
    required String videoPath,
  }) {
    return VativeSharePlatform.instance
        .shareVideoToInstaFeed(videoPath: videoPath);
  }

  /// Share a link to Facebook feed with an optional quote
  static Future<void> shareLinkToFacebookFeed({
    required String url,
    required String quote,
  }) {
    return VativeSharePlatform.instance.shareLinkToFacebookFeed(
      url: url,
      quote: quote,
    );
  }

  /// Check if the Instagram app is installed
  static Future<bool> isInstagramInstalled() {
    return VativeSharePlatform.instance.isInstagramInstalled();
  }

  static Future<void> shareLinkToWhatsApp({
    required String url,
    required String message,
  }) {
    return VativeSharePlatform.instance.shareLinkToWhatsApp(
      url: url,
      message: message,
    );
  }
  

  static Future<void> shareLinkToSnapchat({
  required String url,
  required String message,
}) {
  return VativeSharePlatform.instance.shareLinkToSnapchat(
    url: url,
    message: message,
  );
}

  
}
