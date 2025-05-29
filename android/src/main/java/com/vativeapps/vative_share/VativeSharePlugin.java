package com.vativeapps.vative_share;

import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.core.content.FileProvider;

import com.facebook.FacebookSdk;
import com.facebook.share.model.ShareLinkContent;
import com.facebook.share.widget.ShareDialog;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.concurrent.Executors;

import android.app.Activity;


/** VativeSharePlugin */
public class VativeSharePlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  private MethodChannel channel;
  private Context context;
  private Activity activity;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "vative_share");
    channel.setMethodCallHandler(this);
    context = flutterPluginBinding.getApplicationContext();
  }


  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    activity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    activity = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    activity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivity() {
    activity = null;
  }



  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "getPlatformVersion":
        result.success("Android " + Build.VERSION.RELEASE);
        break;

      case "shareLinkToFacebook":
        String fbUrl = call.argument("url");
        shareToFacebook(fbUrl, result);
        break;

      case "shareLinkToWhatsApp":
        String waUrl = call.argument("url");
        shareToWhatsApp(waUrl, result);
        break;

      case "shareLinkToSnapchat":
        String snapUrl = call.argument("url");
        shareToSnapchat(snapUrl, result);
        break;

      case "checkInstagramInstalled":
        boolean isInstalled = isInstagramInstalled();
        result.success(isInstalled);
        break;

      case "shareVideoToInstaStory":
        String videoPath = call.argument("videoPath");
        String facebookAppId = call.argument("facebookAppId");
        String stickerPath = call.argument("stickerPath");
        String topBgColor = call.argument("topBackgroundColor");
        String bottomBgColor = call.argument("bottomBackgroundColor");
        shareVideoToInstagramStory(videoPath, facebookAppId, stickerPath, topBgColor, bottomBgColor, result);
        break;

      case "shareImageToInstaStory":
        String imagePath = call.argument("imagePath");
        String fbAppId = call.argument("facebookAppId");
        String sticker = call.argument("stickerPath");
        String topColor = call.argument("topBackgroundColor");
        String bottomColor = call.argument("bottomBackgroundColor");
        shareImageToInstagramStory(imagePath, fbAppId, sticker, topColor, bottomColor, result);
        break;

      case "shareImageToFeed":
        String feedImagePath = call.argument("imagePath");
        shareImageToInstagramFeed(feedImagePath, result);
        break;

      case "shareVideoToInstaFeed":
        String feedVideoPath = call.argument("videoPath");
        shareVideoToInstagramFeed(feedVideoPath, result);
        break;
      

      default:
        result.notImplemented();
        break;
    }
  }

  private void shareToFacebook(String url, Result result) {
    try {
      Intent intent = new Intent(Intent.ACTION_SEND);
      intent.setType("text/plain");
      intent.putExtra(Intent.EXTRA_TEXT, url);
      intent.setPackage("com.facebook.katana");
      intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      context.startActivity(intent);
      result.success(true);
    } catch (ActivityNotFoundException e) {
      result.error("FB_APP_NOT_FOUND", "Facebook app not installed", null);
    }
  }

  private void shareToWhatsApp(String url, Result result) {
    try {
      Intent sendIntent = new Intent(Intent.ACTION_SEND);
      sendIntent.putExtra(Intent.EXTRA_TEXT, url);
      sendIntent.setType("text/plain");
      sendIntent.setPackage("com.whatsapp");
      sendIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      context.startActivity(sendIntent);
      result.success(true);
    } catch (ActivityNotFoundException e) {
      result.error("WA_APP_NOT_FOUND", "WhatsApp app not installed", null);
    }
  }

  private void shareToSnapchat(String url, Result result) {
    try {
      String encodedUrl = Uri.encode(url);
      String snapUrl = "https://www.snapchat.com/share?link=" + encodedUrl;
      Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(snapUrl));
      browserIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      context.startActivity(browserIntent);
      result.success(true);
    } catch (Exception e) {
      result.error("SNAP_ERROR", "Failed to share to Snapchat", e.getMessage());
    }
  }



  //Insta Methods

  private boolean isInstagramInstalled() {
    try {
      context.getPackageManager().getPackageInfo("com.instagram.android", 0);
      return true;
    } catch (PackageManager.NameNotFoundException e) {
      return false;
    }
  }

  private void shareVideoToInstagramStory(String videoPath, String appId, String stickerPath,
                                          String topBgColor, String bottomBgColor, Result result) {
    if (!isInstagramInstalled()) {
      result.error("INSTAGRAM_NOT_INSTALLED", "Instagram app not installed", null);
      return;
    }

    try {
      File videoFile = new File(videoPath);
      if (!videoFile.exists()) {
        result.error("FILE_NOT_FOUND", "Video file not found", null);
        return;
      }

      Uri videoUri = FileProvider.getUriForFile(
          context,
          context.getPackageName() + ".fileprovider",
          videoFile
      );

      Intent shareIntent = new Intent("com.instagram.share.ADD_TO_STORY");
      shareIntent.setDataAndType(videoUri, "video/mp4");
      shareIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
      shareIntent.setPackage("com.instagram.android");
      shareIntent.putExtra("source_application", appId);

      // Add background colors if provided
      if (topBgColor != null) {
        shareIntent.putExtra("top_background_color", topBgColor);
      }
      if (bottomBgColor != null) {
        shareIntent.putExtra("bottom_background_color", bottomBgColor);
      }

      // Add sticker if provided
      if (stickerPath != null) {
        File stickerFile = new File(stickerPath);
        if (stickerFile.exists()) {
          Uri stickerUri = FileProvider.getUriForFile(
              context,
              context.getPackageName() + ".fileprovider",
              stickerFile
          );
          shareIntent.putExtra("interactive_asset_uri", stickerUri);
          context.grantUriPermission("com.instagram.android", stickerUri, Intent.FLAG_GRANT_READ_URI_PERMISSION);
        }
      }

      context.grantUriPermission("com.instagram.android", videoUri, Intent.FLAG_GRANT_READ_URI_PERMISSION);

      if (shareIntent.resolveActivity(context.getPackageManager()) != null) {
        if (activity != null) {
          activity.startActivity(shareIntent);
        } else {
          shareIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
          context.startActivity(shareIntent);
        }
        result.success(true);
      } else {
        result.error("SHARE_FAILED", "Could not resolve Instagram activity", null);
      }
    } catch (Exception e) {
      Log.e("VativeShare", "Error sharing video to Instagram story", e);
      result.error("SHARE_ERROR", e.getMessage(), null);
    }
  }

  private void shareImageToInstagramStory(String imagePath, String appId, String stickerPath,
                                          String topBgColor, String bottomBgColor, Result result) {
    if (!isInstagramInstalled()) {
      result.error("INSTAGRAM_NOT_INSTALLED", "Instagram app not installed", null);
      return;
    }

    try {
      File imageFile = new File(imagePath);
      if (!imageFile.exists()) {
        result.error("FILE_NOT_FOUND", "Image file not found", null);
        return;
      }

      Uri imageUri = FileProvider.getUriForFile(
          context,
          context.getPackageName() + ".fileprovider",
          imageFile
      );

      Intent shareIntent = new Intent("com.instagram.share.ADD_TO_STORY");
      shareIntent.setDataAndType(imageUri, "image/*");
      shareIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
      shareIntent.setPackage("com.instagram.android");
      shareIntent.putExtra("source_application", appId);

      // Add background colors if provided
      if (topBgColor != null) {
        shareIntent.putExtra("top_background_color", topBgColor);
      }
      if (bottomBgColor != null) {
        shareIntent.putExtra("bottom_background_color", bottomBgColor);
      }

      // Add sticker if provided
      if (stickerPath != null) {
        File stickerFile = new File(stickerPath);
        if (stickerFile.exists()) {
          Uri stickerUri = FileProvider.getUriForFile(
              context,
              context.getPackageName() + ".fileprovider",
              stickerFile
          );
          shareIntent.putExtra("interactive_asset_uri", stickerUri);
          context.grantUriPermission("com.instagram.android", stickerUri, Intent.FLAG_GRANT_READ_URI_PERMISSION);
        }
      }

      context.grantUriPermission("com.instagram.android", imageUri, Intent.FLAG_GRANT_READ_URI_PERMISSION);

      if (shareIntent.resolveActivity(context.getPackageManager()) != null) {
        if (activity != null) {
          activity.startActivity(shareIntent);
        } else {
          shareIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
          context.startActivity(shareIntent);
        }
        result.success(true);
      } else {
        result.error("SHARE_FAILED", "Could not resolve Instagram activity", null);
      }
    } catch (Exception e) {
      Log.e("VativeShare", "Error sharing image to Instagram story", e);
      result.error("SHARE_ERROR", e.getMessage(), null);
    }
  }

  private void shareImageToInstagramFeed(String imagePath, Result result) {
    if (!isInstagramInstalled()) {
      result.error("INSTAGRAM_NOT_INSTALLED", "Instagram app not installed", null);
      return;
    }

    try {
      File imageFile = new File(imagePath);
      if (!imageFile.exists()) {
        result.error("FILE_NOT_FOUND", "Image file not found", null);
        return;
      }

      // Create a temporary file with .jpg extension for Instagram feed sharing
      File tempDir = new File(context.getExternalFilesDir(Environment.DIRECTORY_PICTURES), "temp");
      if (!tempDir.exists()) {
        tempDir.mkdirs();
      }
      
      File tempFile = new File(tempDir, "instagram_image_" + System.currentTimeMillis() + ".jpg");
      
      // Copy original file to temp location
      copyFile(imageFile, tempFile);

      Uri imageUri = FileProvider.getUriForFile(
          context,
          context.getPackageName() + ".fileprovider",
          tempFile
      );

      Intent shareIntent = new Intent(Intent.ACTION_SEND);
      shareIntent.setType("image/*");
      shareIntent.putExtra(Intent.EXTRA_STREAM, imageUri);
      shareIntent.setPackage("com.instagram.android");
      shareIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);

      context.grantUriPermission("com.instagram.android", imageUri, Intent.FLAG_GRANT_READ_URI_PERMISSION);

      if (shareIntent.resolveActivity(context.getPackageManager()) != null) {
        if (activity != null) {
          activity.startActivity(shareIntent);
        } else {
          shareIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
          context.startActivity(shareIntent);
        }
        result.success(true);
      } else {
        result.error("SHARE_FAILED", "Could not resolve Instagram activity", null);
      }
    } catch (Exception e) {
      Log.e("VativeShare", "Error sharing image to Instagram feed", e);
      result.error("SHARE_ERROR", e.getMessage(), null);
    }
  }

  private void shareVideoToInstagramFeed(String videoPath, Result result) {
    if (!isInstagramInstalled()) {
      result.error("INSTAGRAM_NOT_INSTALLED", "Instagram app not installed", null);
      return;
    }

    try {
      File videoFile = new File(videoPath);
      if (!videoFile.exists()) {
        result.error("FILE_NOT_FOUND", "Video file not found", null);
        return;
      }

      // Create a temporary file with .mp4 extension for Instagram feed sharing
      File tempDir = new File(context.getExternalFilesDir(Environment.DIRECTORY_MOVIES), "temp");
      if (!tempDir.exists()) {
        tempDir.mkdirs();
      }
      
      File tempFile = new File(tempDir, "instagram_video_" + System.currentTimeMillis() + ".mp4");
      
      // Copy original file to temp location
      copyFile(videoFile, tempFile);

      Uri videoUri = FileProvider.getUriForFile(
          context,
          context.getPackageName() + ".fileprovider",
          tempFile
      );

      Intent shareIntent = new Intent(Intent.ACTION_SEND);
      shareIntent.setType("video/*");
      shareIntent.putExtra(Intent.EXTRA_STREAM, videoUri);
      shareIntent.setPackage("com.instagram.android");
      shareIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);

      context.grantUriPermission("com.instagram.android", videoUri, Intent.FLAG_GRANT_READ_URI_PERMISSION);

      if (shareIntent.resolveActivity(context.getPackageManager()) != null) {
        if (activity != null) {
          activity.startActivity(shareIntent);
        } else {
          shareIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
          context.startActivity(shareIntent);
        }
        result.success(true);
      } else {
        result.error("SHARE_FAILED", "Could not resolve Instagram activity", null);
      }
    } catch (Exception e) {
      Log.e("VativeShare", "Error sharing video to Instagram feed", e);
      result.error("SHARE_ERROR", e.getMessage(), null);
    }
  }

  private void copyFile(File source, File destination) throws IOException {
    FileInputStream inputStream = new FileInputStream(source);
    FileOutputStream outputStream = new FileOutputStream(destination);
    
    byte[] buffer = new byte[1024];
    int length;
    while ((length = inputStream.read(buffer)) > 0) {
      outputStream.write(buffer, 0, length);
    }
    
    inputStream.close();
    outputStream.close();
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
