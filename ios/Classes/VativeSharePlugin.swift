import Flutter
import UIKit
import FBSDKShareKit


public class VativeSharePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "vative_share", binaryMessenger: registrar.messenger())
    let instance = VativeSharePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
      case "shareVideoToInstaStory":
          self.shareVideoToStory(call: call, result: result)
      case "shareImageToInstaStory":
          self.shareImageToStory(call: call, result: result)
      case "shareImageToFeed":
          self.shareImageToFeed(call: call, result: result)
      case "shareVideoToInstaFeed":
          self.shareVideoToFeed(call: call, result: result)
      case "checkInstagramInstalled":
          self.isInstagramInstalled(result: result)  
      case "shareLinkToFacebook":
            shareLinkToFacebook(call: call, result: result) 
      case "shareLinkToWhatsApp":
          self.shareLinkToWhatsApp(call: call, result: result)
      case "shareLinkToSnapchat":
          self.shareLinkToSnapchat(call: call, result: result)
      default:
          result(FlutterMethodNotImplemented)
      }
  }


  private func shareLinkToSnapchat(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let urlString = args["url"] as? String,
          let originalURL = URL(string: urlString) else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Expected 'url'", details: nil))
        return
    }

    // Encode the URL
    guard let encodedURL = originalURL.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
          let snapchatShareURL = URL(string: "https://www.snapchat.com/share?link=\(encodedURL)") else {
        result(FlutterError(code: "ENCODING_ERROR", message: "Failed to encode URL", details: nil))
        return
    }

    // Open Snapchat share link in Safari
    UIApplication.shared.open(snapchatShareURL, options: [:]) { success in
        result(success)
    }
}



private func shareLinkToFacebook(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let urlString = args["url"] as? String,
          let url = URL(string: urlString),
          let quote = args["quote"] as? String else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Expected 'url' and 'quote'", details: nil))
        return
    }
    
    let content = ShareLinkContent()
    content.contentURL = url
    content.quote = quote
    
    guard let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first?.rootViewController else {
        result(FlutterError(code: "NO_VIEW_CONTROLLER", message: "Could not get root view controller", details: nil))
        return
    }
    
    let dialog = ShareDialog(viewController: rootVC, content: content, delegate: nil)
    dialog.mode = .automatic
    
    do {
        try dialog.show()
        result(true)
    } catch {
        result(FlutterError(code: "SHARE_FAILED", message: "Failed to show share dialog", details: error.localizedDescription))
    }
}
  private func shareVideoToStory(call: FlutterMethodCall, result: @escaping FlutterResult) {
      guard let args = call.arguments as? [String: Any],
            let videoPath = args["videoPath"] as? String,
            let facebookAppId = args["facebookAppId"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required arguments", details: nil))
          return
      }
      
      let stickerPath = args["stickerPath"] as? String
      let topBackgroundColor = args["topBackgroundColor"] as? String
      let bottomBackgroundColor = args["bottomBackgroundColor"] as? String
      
      // Load video data
      guard let videoData = NSData(contentsOfFile: videoPath) else {
          result(FlutterError(code: "FILE_ERROR", message: "Could not load video file", details: nil))
          return
      }
      
      shareToInstagramStory(
          backgroundVideo: videoData,
          backgroundImage: nil,
          stickerPath: stickerPath,
          topBackgroundColor: topBackgroundColor,
          bottomBackgroundColor: bottomBackgroundColor,
          appId: facebookAppId,
          result: result
      )
  }

  private func isInstagramInstalled(result: @escaping FlutterResult) {
      let instagramURL = URL(string: "instagram://app")!
      result(UIApplication.shared.canOpenURL(instagramURL))
  }

  private func shareLinkToWhatsApp(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let urlString = args["url"] as? String,
          let message = args["message"] as? String else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Expected 'url' and 'message'", details: nil))
        return
    }

    let combinedText = "\(message) \(urlString)"
    let encodedText = combinedText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

    let whatsappURL = URL(string: "whatsapp://send?text=\(encodedText)")!

    if UIApplication.shared.canOpenURL(whatsappURL) {
        UIApplication.shared.open(whatsappURL, options: [:]) { success in
            result(success)
        }
    } else {
        result(FlutterError(code: "WHATSAPP_NOT_INSTALLED", message: "WhatsApp is not installed", details: nil))
    }
}
  
  private func shareImageToStory(call: FlutterMethodCall, result: @escaping FlutterResult) {
      guard let args = call.arguments as? [String: Any],
            let imagePath = args["imagePath"] as? String,
            let facebookAppId = args["facebookAppId"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required arguments", details: nil))
          return
      }
      
      let stickerPath = args["stickerPath"] as? String
      let topBackgroundColor = args["topBackgroundColor"] as? String
      let bottomBackgroundColor = args["bottomBackgroundColor"] as? String
      
      // Load image data
      guard let imageData = NSData(contentsOfFile: imagePath) else {
          result(FlutterError(code: "FILE_ERROR", message: "Could not load image file", details: nil))
          return
      }
      
      shareToInstagramStory(
          backgroundVideo: nil,
          backgroundImage: imageData,
          stickerPath: stickerPath,
          topBackgroundColor: topBackgroundColor,
          bottomBackgroundColor: bottomBackgroundColor,
          appId: facebookAppId,
          result: result
      )
  }
  
  private func shareToInstagramStory(
      backgroundVideo: NSData?,
      backgroundImage: NSData?,
      stickerPath: String?,
      topBackgroundColor: String?,
      bottomBackgroundColor: String?,
      appId: String,
      result: @escaping FlutterResult
  ) {
      let urlScheme = URL(string: "instagram-stories://share?source_application=\(appId)")!
    
      
      var pasteboardItems: [[String: Any]] = []
      var pasteboardItem: [String: Any] = [:]
      
      // Add background content
      if let backgroundVideo = backgroundVideo {
          pasteboardItem["com.instagram.sharedSticker.backgroundVideo"] = backgroundVideo
      } else if let backgroundImage = backgroundImage {
          pasteboardItem["com.instagram.sharedSticker.backgroundImage"] = backgroundImage
      }
      
      // Add sticker if provided
      if let stickerPath = stickerPath,
          let stickerData = NSData(contentsOfFile: stickerPath) {
          pasteboardItem["com.instagram.sharedSticker.stickerImage"] = stickerData
      }
      
      // Add background colors if provided
      if let topBackgroundColor = topBackgroundColor {
          pasteboardItem["com.instagram.sharedSticker.backgroundTopColor"] = topBackgroundColor
      }
      if let bottomBackgroundColor = bottomBackgroundColor {
          pasteboardItem["com.instagram.sharedSticker.backgroundBottomColor"] = bottomBackgroundColor
      }
      
      pasteboardItems.append(pasteboardItem)
      
      // Set pasteboard options with expiration date
      let pasteboardOptions: [UIPasteboard.OptionsKey: Any] = [
          .expirationDate: Date().addingTimeInterval(60 * 5)
      ]
      
      // Set items to pasteboard
      UIPasteboard.general.setItems(pasteboardItems, options: pasteboardOptions)
      
      // Open Instagram
      UIApplication.shared.open(urlScheme, options: [:]) { success in
          DispatchQueue.main.async {
              result(success)
          }
      }
  }
  
    // MARK: - Feed sharing methods (direct to Instagram)
  
  private func shareImageToFeed(call: FlutterMethodCall, result: @escaping FlutterResult) {
      guard let args = call.arguments as? [String: Any],
            let imagePath = args["imagePath"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required arguments", details: nil))
          return
      }
      
      guard let image = UIImage(contentsOfFile: imagePath) else {
          result(FlutterError(code: "FILE_ERROR", message: "Could not load image file", details: nil))
          return
      }
      
      // Use Document Interaction with .ig extension for direct Instagram sharing
      shareToInstagramFeed(image: image, videoPath: nil, result: result)
  }
  
  private func shareVideoToFeed(call: FlutterMethodCall, result: @escaping FlutterResult) {
      guard let args = call.arguments as? [String: Any],
            let videoPath = args["videoPath"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required arguments", details: nil))
          return
      }
      
      // Use Document Interaction with .igv extension for direct Instagram video sharing
      shareToInstagramFeed(image: nil, videoPath: videoPath, result: result)
  }
  
  // MARK: - Direct Instagram Feed Sharing
  
  private func shareToInstagramFeed(image: UIImage?, videoPath: String?, result: @escaping FlutterResult) {
      let tempDir = NSTemporaryDirectory()
      let fileName: String
      let tempFilePath: String
      let uti: String
      
      if let image = image {
          // For images: use .ig extension
          fileName = "instagram-image-\(Date().timeIntervalSince1970).ig"
          tempFilePath = tempDir + fileName
          uti = "com.instagram.photo"
          
          // Convert image to JPEG data
          guard let imageData = image.jpegData(compressionQuality: 0.9) else {
              result(FlutterError(code: "IMAGE_ERROR", message: "Could not convert image to JPEG", details: nil))
              return
          }
          
          // Write image data to temp file
          do {
              try imageData.write(to: URL(fileURLWithPath: tempFilePath))
          } catch {
              result(FlutterError(code: "FILE_WRITE_ERROR", message: "Could not write image file: \(error.localizedDescription)", details: nil))
              return
          }
      } else if let videoPath = videoPath {
          // For videos: use .igv extension
          fileName = "instagram-video-\(Date().timeIntervalSince1970).igv"
          tempFilePath = tempDir + fileName
          uti = "com.instagram.video"
          
          // Copy video file to temp location with .igv extension
          do {
              let sourceURL = URL(fileURLWithPath: videoPath)
              let tempURL = URL(fileURLWithPath: tempFilePath)
              try FileManager.default.copyItem(at: sourceURL, to: tempURL)
          } catch {
              result(FlutterError(code: "FILE_COPY_ERROR", message: "Could not copy video file: \(error.localizedDescription)", details: nil))
              return
          }
      } else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Either image or video path must be provided", details: nil))
          return
      }
      
      // Create and configure Document Interaction Controller
      let tempFileURL = URL(fileURLWithPath: tempFilePath)
      let documentController = UIDocumentInteractionController(url: tempFileURL)
      documentController.delegate = self
      documentController.uti = uti
      
      // Get the root view controller
      guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first,
            let rootViewController = window.rootViewController else {
          result(FlutterError(code: "NO_VIEW_CONTROLLER", message: "Could not find root view controller", details: nil))
          return
      }
      
      // Present Instagram sharing interface
      DispatchQueue.main.async {
          let presented = documentController.presentOpenInMenu(from: CGRect.zero, in: rootViewController.view, animated: true)
          
          if presented {
              result(true)
          } else {
              // If Document Interaction fails, try opening Instagram directly
              self.openInstagramWithFallback(result: result)
          }
      }
  }
  
  // MARK: - Fallback methods
  
  private func openInstagramWithFallback(result: @escaping FlutterResult) {
      // Try Instagram app URL scheme first
      if let url = URL(string: "instagram://app"), UIApplication.shared.canOpenURL(url) {
          UIApplication.shared.open(url, options: [:]) { success in
              DispatchQueue.main.async {
                  result(success)
              }
          }
      } else {
          // Fallback to universal link
          if let url = URL(string: "https://www.instagram.com") {
              UIApplication.shared.open(url, options: [:]) { success in
                  DispatchQueue.main.async {
                      result(success)
                  }
              }
          } else {
              result(false)
          }
      }
  }
  
  // MARK: - General Instagram methods
  
  private func openInstagram(result: @escaping FlutterResult) {
      // Try Instagram app URL scheme first
      if let url = URL(string: "instagram://app"), UIApplication.shared.canOpenURL(url) {
          UIApplication.shared.open(url, options: [:]) { success in
              DispatchQueue.main.async {
                  result(success)
              }
          }
      } else {
          // Fallback to universal link
          if let url = URL(string: "https://www.instagram.com") {
              UIApplication.shared.open(url, options: [:]) { success in
                  DispatchQueue.main.async {
                      result(success)
                  }
              }
          } else {
              result(false)
          }
      }
  }
}




extension VativeSharePlugin: UIDocumentInteractionControllerDelegate {
  func documentInteractionController(_ controller: UIDocumentInteractionController, viewControllerForPreview animated: Bool) -> UIViewController {
      guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first,
            let rootViewController = window.rootViewController else {
          return UIViewController()
      }
      return rootViewController
  }
  
  func documentInteractionController(_ controller: UIDocumentInteractionController, viewForPreview animated: Bool) -> UIView? {
      guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first else {
          return nil
      }
      return window.rootViewController?.view
  }
  
  func documentInteractionController(_ controller: UIDocumentInteractionController, rectForPreview animated: Bool) -> CGRect {
      guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first,
            let rootViewController = window.rootViewController else {
          return CGRect.zero
      }
      return rootViewController.view.frame
  }
}

