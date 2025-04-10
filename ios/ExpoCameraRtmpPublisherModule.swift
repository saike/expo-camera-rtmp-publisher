import ExpoModulesCore
import AVFoundation
import FFLivekit

public class ExpoCameraRtmpPublisherModule: Module {

  
  public func definition() -> ModuleDefinition {

    Name("ExpoCameraRtmpPublisher")

    View(ExpoCameraRtmpPublisherView.self) {
      
      Prop("cameraPosition") { (view: ExpoCameraRtmpPublisherView, position: String) in
        let cameraPos = position == "front" ? AVCaptureDevice.Position.front : AVCaptureDevice.Position.back
        view.setCameraPosition(position: cameraPos)
        print("Camera position in prop: \(position)")
      }
      
      Events("onPublishStarted", "onPublishStopped", "onPublishError")

      AsyncFunction("startPublishing") { (view: ExpoCameraRtmpPublisherView, rtmpUrl: String, options: [String: Any]?) in
        var publishOptions = PublishOptions()
        
        if let options = options {
          if let videoWidth = options["videoWidth"] as? Int {
            publishOptions.videoWidth = videoWidth
          }
          
          if let videoHeight = options["videoHeight"] as? Int {
            publishOptions.videoHeight = videoHeight
          }
          
          if let videoBitrate = options["videoBitrate"] as? String {
            publishOptions.videoBitrate = videoBitrate
          }
          
          if let audioBitrate = options["audioBitrate"] as? String {
            publishOptions.audioBitrate = audioBitrate
          }
        }
        
        try view.startPublishing(rtmpUrl: rtmpUrl, options: publishOptions)
      }

      AsyncFunction("stopPublishing") { (view: ExpoCameraRtmpPublisherView) in
        try view.stopPublishing()
      }

      AsyncFunction("switchCamera") { (view: ExpoCameraRtmpPublisherView) in
        try view.switchCamera()
      }

      AsyncFunction("toggleTorch") { (view: ExpoCameraRtmpPublisherView, level: Float) in
        try view.toggleTorch(level: level)
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
      // Create a promise for asynchronous request
      let semaphore = DispatchSemaphore(value: 0)
      var resultDict: [String: Any] = ["status": "denied", "granted": false]
      
      AVCaptureDevice.requestAccess(for: .video) { granted in
        resultDict = granted ? 
          ["status": "granted", "granted": true] : 
          ["status": "denied", "granted": false]
        semaphore.signal()
      }
      
      // Wait for permission request completion (blocking call)
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
      // Create a promise for asynchronous request
      let semaphore = DispatchSemaphore(value: 0)
      var resultDict: [String: Any] = ["status": "denied", "granted": false]
      
      AVCaptureDevice.requestAccess(for: .audio) { granted in
        resultDict = granted ? 
          ["status": "granted", "granted": true] : 
          ["status": "denied", "granted": false]
        semaphore.signal()
      }
      
      // Wait for permission request completion (blocking call)
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
