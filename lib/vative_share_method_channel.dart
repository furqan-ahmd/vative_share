import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'vative_share_platform_interface.dart';

class MethodChannelVativeShare extends VativeSharePlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('vative_share');

  @override
  Future<void> shareImageToInstaStory({
    required String imagePath,
    required String facebookAppId,
    String? stickerPath,
    String? topBackgroundColor,
    String? bottomBackgroundColor,
  }) async {
    await methodChannel.invokeMethod('shareImageToInstaStory', {
      'imagePath': imagePath,
      'facebookAppId': facebookAppId,
      'stickerPath': stickerPath,
      'topBackgroundColor': topBackgroundColor,
      'bottomBackgroundColor': bottomBackgroundColor,
    });
  }

  @override
  Future<void> shareVideoToInstaStory({
    required String videoPath,
    required String facebookAppId,
    String? stickerPath,
    String? topBackgroundColor,
    String? bottomBackgroundColor,
  }) async {
    await methodChannel.invokeMethod('shareVideoToInstaStory', {
      'videoPath': videoPath,
      'facebookAppId': facebookAppId,
      'stickerPath': stickerPath,
      'topBackgroundColor': topBackgroundColor,
      'bottomBackgroundColor': bottomBackgroundColor,
    });
  }

  @override
  Future<void> shareImageToInstaFeed({
    required String imagePath,
  }) async {
    await methodChannel.invokeMethod('shareImageToFeed', {
      'imagePath': imagePath,
    });
  }

  @override
  Future<void> shareVideoToInstaFeed({
    required String videoPath,
  }) async {
    await methodChannel.invokeMethod('shareVideoToInstaFeed', {
      'videoPath': videoPath,
    });
  }

  @override
  Future<void> shareLinkToFacebookFeed({
    required String url,
    required String quote,
  }) async {
    await methodChannel.invokeMethod('shareLinkToFacebook', {
      'url': url,
      'quote': quote,
    });
  }

  @override
  Future<void> shareLinkToWhatsApp({
    required String url,
    required String message,
  }) async {
    await methodChannel.invokeMethod('shareLinkToWhatsApp', {
      'url': url,
      'message': message,
    });
  }

  @override
  Future<void> shareLinkToSnapchat({
    required String url,
    required String message,
  }) async {
    await methodChannel.invokeMethod('shareLinkToSnapchat', {
      'url': url,
      'message': message,
    });
  }

  @override
  Future<bool> isInstagramInstalled() async {
    final installed =
        await methodChannel.invokeMethod<bool>('checkInstagramInstalled');
    return installed ?? false;
  }
}
