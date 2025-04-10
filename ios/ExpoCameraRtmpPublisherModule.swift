import ExpoModulesCore
import AVFoundation
import FFLivekit

public class ExpoCameraRtmpPublisherModule: Module {
  // Each module class must implement the definition function. The definition consists of components
  // that describes the module's functionality and behavior.
  // See https://docs.expo.dev/modules/module-api for more details about available components.
  



  
  public func definition() -> ModuleDefinition {
    // Sets the name of the module that JavaScript code will use to refer to the module. Takes a string as an argument.
    // Can be inferred from module's class name, but it's recommended to set it explicitly for clarity.
    // The module will be accessible from `requireNativeModule('ExpoCameraRtmpPublisher')` in JavaScript.
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
  
  // MARK: - View Management
  
  // private func registerView(_ view: ExpoCameraRtmpPublisherView) {
  //   view.setModule(self)
  //   publisherViews.append(view)
  // }
  
  // func unregisterView(_ view: ExpoCameraRtmpPublisherView) {
  //   publisherViews.removeAll(where: { $0 === view })
    
  //   // Если это активный view с которого шла трансляция - останавливаем трансляцию
  //   if let cameraSource = view.getCameraSource(), self.cameraSource === cameraSource, isPublishing {
  //     stopPublishing()
  //   }
  // }
  
  // MARK: - Public methods for view
  
  // func startPublishingFromView(rtmpUrl: String, cameraSource: CameraSource?) {
  //   guard let cameraSource = cameraSource else { return }
    
  //   do {
  //     try startPublishingInternal(rtmpUrl: rtmpUrl, cameraSource: cameraSource)
  //   } catch {
  //     // Уведомление view об ошибке
  //     publisherViews.forEach { view in
  //       if view.getCameraSource() === cameraSource {
  //         view.notifyError(error.localizedDescription)
  //       }
  //     }
      
  //     // Глобальное событие об ошибке
  //     sendEvent("onPublishStateChange", [
  //       "isPublishing": false,
  //       "error": error.localizedDescription
  //     ])
  //   }
  // }
  
  // MARK: - Publishing methods
  // public func setCameraSource(cameraSource: CameraSource) {
  //   self.cameraSource = cameraSource
  // }
  
  // private func startPublishing(rtmpUrl: String) throws {
  //   // if isPublishing {
  //   //   stopPublishing()
  //   // }
  //   try startPublishingInternal(rtmpUrl: rtmpUrl)

  //   // // Если есть активные view, используем cameraSource из первого
  //   // if let view = publisherViews.first, let viewCameraSource = view.getCameraSource() {
  //   // } else {
  //   //   // Если нет активных view, создаем отдельный cameraSource
  //   //   let newCameraSource = CameraSource(position: .front, preset: .hd1280x720)
  //   //   try startPublishingInternal(rtmpUrl: rtmpUrl, cameraSource: newCameraSource)
  //   // }
  // }
  
  
  
  // MARK: - Permissions methods
  
  private func requestCameraPermissionsAsync() throws -> [String: Any] {
    let status = AVCaptureDevice.authorizationStatus(for: .video)
    
    switch status {
    case .authorized:
      return ["status": "granted", "granted": true]
    case .denied, .restricted:
      return ["status": "denied", "granted": false]
    case .notDetermined:
      // Создаем промис для асинхронного запроса
      let semaphore = DispatchSemaphore(value: 0)
      var resultDict: [String: Any] = ["status": "denied", "granted": false]
      
      AVCaptureDevice.requestAccess(for: .video) { granted in
        resultDict = granted ? 
          ["status": "granted", "granted": true] : 
          ["status": "denied", "granted": false]
        semaphore.signal()
      }
      
      // Ждем завершения запроса разрешения (блокирующий вызов)
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
      // Создаем промис для асинхронного запроса
      let semaphore = DispatchSemaphore(value: 0)
      var resultDict: [String: Any] = ["status": "denied", "granted": false]
      
      AVCaptureDevice.requestAccess(for: .audio) { granted in
        resultDict = granted ? 
          ["status": "granted", "granted": true] : 
          ["status": "denied", "granted": false]
        semaphore.signal()
      }
      
      // Ждем завершения запроса разрешения (блокирующий вызов)
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
  
  // MARK: - FFLiveKitDelegate methods
  
 
}
