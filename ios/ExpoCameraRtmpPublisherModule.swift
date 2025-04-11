import ExpoModulesCore
import AVFoundation
import HaishinKit

public class ExpoCameraRtmpPublisherModule: Module {

  public func definition() -> ModuleDefinition {

    Name("ExpoCameraRtmpPublisher")

    View(ExpoCameraRtmpPublisherView.self) {
      
      Prop("cameraPosition") { (view: ExpoCameraRtmpPublisherView, position: String) in
        let cameraPos = position == "front" ? AVCaptureDevice.Position.front : AVCaptureDevice.Position.back
        view.cameraPosition = cameraPos
        print("Camera position in prop: \(position)")
      }

      Prop("muted") { (view: ExpoCameraRtmpPublisherView, muted: Bool?) in
        view.muted = muted ?? false
      }
      
      Events("onPublishStarted", "onPublishStopped", "onPublishError", "onReady")

      AsyncFunction("startPublishing") { (view: ExpoCameraRtmpPublisherView, url: String, name: String, options: [String: Any]) in
        let publishOptions = PublishOptions(
          videoWidth: options["videoWidth"] as? Int32 ?? 1080,
          videoHeight: options["videoHeight"] as? Int32 ?? 1920,
          videoBitrate: options["videoBitrate"] as? Int32 ?? 2_000_000,
          audioBitrate: options["audioBitrate"] as? Int32 ?? 128_000
        )
        view.startPublishing(url: url, name: name, options: publishOptions)
      }

      AsyncFunction("stopPublishing") { (view: ExpoCameraRtmpPublisherView) in
        view.stopPublishing()
      }

      AsyncFunction("switchCamera") { (view: ExpoCameraRtmpPublisherView) in
        view.switchCamera()
      }

      AsyncFunction("toggleTorch") { (view: ExpoCameraRtmpPublisherView, level: Float, promise: Promise) in
        view.toggleTorch(level: level)

      }
    }

    Events("onPublishStateChange")
    
    // Permissions methods
    Function("requestCameraPermissionsAsync") { () -> [String: Any] in
      return try self.requestCameraPermissionsAsync()
    }
    
    Function("requestMicrophonePermissionsAsync") { () -> [String: Any] in
      return try self.requestMicrophonePermissionsAsync()
    }
    
    Function("getCameraPermissionsAsync") { () -> [String: Any] in
      return try self.getCameraPermissionsAsync()
    }
    
    Function("getMicrophonePermissionsAsync") { () -> [String: Any] in
      return try self.getMicrophonePermissionsAsync()
    }
  }

  // MARK: - Permissions methods
  
  private func requestCameraPermissionsAsync() throws -> [String: Any] {
    let status = AVCaptureDevice.authorizationStatus(for: .video)
    
    switch status {
    case .authorized:
      return ["status": "granted", "granted": true]
    case .denied, .restricted:
      return ["status": "denied", "granted": false]
    case .notDetermined:
      let semaphore = DispatchSemaphore(value: 0)
      var resultDict: [String: Any] = ["status": "denied", "granted": false]
      
      AVCaptureDevice.requestAccess(for: .video) { granted in
        resultDict = granted ? 
          ["status": "granted", "granted": true] : 
          ["status": "denied", "granted": false]
        semaphore.signal()
      }
      
      _ = semaphore.wait(timeout: .distantFuture)
      return resultDict
    @unknown default:
      return ["status": "denied", "granted": false]
    }
  }
  
  private func requestMicrophonePermissionsAsync() throws -> [String: Any] {
    let status = AVCaptureDevice.authorizationStatus(for: .audio)
    
    switch status {
    case .authorized:
      return ["status": "granted", "granted": true]
    case .denied, .restricted:
      return ["status": "denied", "granted": false]
    case .notDetermined:
      let semaphore = DispatchSemaphore(value: 0)
      var resultDict: [String: Any] = ["status": "denied", "granted": false]
      
      AVCaptureDevice.requestAccess(for: .audio) { granted in
        resultDict = granted ? 
          ["status": "granted", "granted": true] : 
          ["status": "denied", "granted": false]
        semaphore.signal()
      }
      
      _ = semaphore.wait(timeout: .distantFuture)
      return resultDict
    @unknown default:
      return ["status": "denied", "granted": false]
    }
  }
  
  private func getCameraPermissionsAsync() throws -> [String: Any] {
    let status = AVCaptureDevice.authorizationStatus(for: .video)
    
    switch status {
    case .authorized:
      return ["status": "granted", "granted": true]
    case .denied:
      return ["status": "denied", "granted": false]
    case .restricted:
      return ["status": "never_ask_again", "granted": false]
    case .notDetermined:
      return ["status": "undetermined", "granted": false]
    @unknown default:
      return ["status": "denied", "granted": false]
    }
  }
  
  private func getMicrophonePermissionsAsync() throws -> [String: Any] {
    let status = AVCaptureDevice.authorizationStatus(for: .audio)
    
    switch status {
    case .authorized:
      return ["status": "granted", "granted": true]
    case .denied:
      return ["status": "denied", "granted": false]
    case .restricted:
      return ["status": "never_ask_again", "granted": false]
    case .notDetermined:
      return ["status": "undetermined", "granted": false]
    @unknown default:
      return ["status": "denied", "granted": false]
    }
  }
}
