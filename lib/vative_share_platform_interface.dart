import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'vative_share_method_channel.dart';

abstract class VativeSharePlatform extends PlatformInterface {
  VativeSharePlatform() : super(token: _token);
  static final Object _token = Object();

  static VativeSharePlatform _instance = MethodChannelVativeShare();

  static VativeSharePlatform get instance => _instance;

  static set instance(VativeSharePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> shareImageToInstaStory({
    required String imagePath,
    required String facebookAppId,
    String? stickerPath,
    String? topBackgroundColor,
    String? bottomBackgroundColor,
  });

  Future<void> shareVideoToInstaStory({
    required String videoPath,
    required String facebookAppId,
    String? stickerPath,
    String? topBackgroundColor,
    String? bottomBackgroundColor,
  });

  Future<void> shareImageToInstaFeed({
    required String imagePath,
  });

  Future<void> shareVideoToInstaFeed({
    required String videoPath,
  });

  Future<void> shareLinkToFacebookFeed({
    required String url,
    required String quote,
  });

  Future<bool> isInstagramInstalled();

  Future<void> shareLinkToWhatsApp({
    required String url,
    required String message,
  });

  Future<void> shareLinkToSnapchat({
    required String url,
    required String message,
  });
}
