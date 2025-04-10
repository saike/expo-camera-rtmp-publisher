import ExpoModulesCore
import AVFoundation
import FFLivekit

public struct PublishOptions {
  var videoWidth: Int = 1080
  var videoHeight: Int = 1920
  var videoBitrate: String = "2M"
  var audioBitrate: String = "128k"
  
  public init(videoWidth: Int = 1080, videoHeight: Int = 1920, videoBitrate: String = "2M", audioBitrate: String = "128k") {
    self.videoWidth = videoWidth
    self.videoHeight = videoHeight
    self.videoBitrate = videoBitrate
    self.audioBitrate = audioBitrate
  }
}

class ExpoCameraRtmpPublisherView: ExpoView, FFLiveKitDelegate {
  
  weak var module: ExpoCameraRtmpPublisherModule?

  private var ffLiveKit: FFLiveKit?
  private var cameraSource: CameraSource?
  private var microphoneSource: MicrophoneSource?
  private var isPublishing = false
  

  var cameraPosition: AVCaptureDevice.Position = .front
  
  // Event dispatchers
  let onPublishStarted = EventDispatcher()
  let onPublishStopped = EventDispatcher()
  let onPublishError = EventDispatcher()

  required init(appContext: AppContext? = nil) {
    super.init(appContext: appContext)
    
    // Initialize camera source
    setupCameraPreview()
  }
  
  private func setupCameraPreview() {
    // Initialize camera source with the specified position
      cameraSource = CameraSource(position: cameraPosition)
    
      // Start camera preview
      cameraSource?.startPreview(previewView: self)
      print("Camera preview initialized with position: \(cameraPosition == .front ? "front" : "back")")
  }
  
  private func updateCameraPosition() {
    if let cameraSource = cameraSource {
      cameraSource.switchCamera()
    } else {
      setupCameraPreview()
    }
  }
  
  func setPublishingState(_ isPublishing: Bool) {
    self.isPublishing = isPublishing
    if isPublishing {
      onPublishStarted([:])
    } else {
      onPublishStopped([:])
    }
  }
  
  func notifyError(_ error: String) {
    onPublishError(["error": error])
  }
  
  public func startPublishing(rtmpUrl: String, options: PublishOptions = PublishOptions()) throws {
    // Save reference to the current camera source
    
    // Create and configure microphoneSource
    do {
      microphoneSource = try MicrophoneSource()
    } catch {
      onPublishError(["error": "Failed to initialize microphone: \(error.localizedDescription)"])
      throw error
    }
    
    // Configure FFLiveKit
    ffLiveKit = FFLiveKit(options: [
      .outputVideoSize((options.videoWidth, options.videoHeight)),
      .outputVideoBitrate(options.videoBitrate),
      .outputAudioBitrate(options.audioBitrate)
    ])
    
    // Create RTMP connection
    let rtmpConnection = try RTMPConnection(baseUrl: rtmpUrl)
    
    // Connect to RTMP server
    try ffLiveKit?.connect(connection: rtmpConnection)
    
    // Add sources
    if let camera = cameraSource, let microphone = microphoneSource {
      ffLiveKit?.addSources(sources: [camera, microphone])
    }
    
    // Prepare FFLiveKit
    ffLiveKit?.prepare(delegate: self)
    
    // Start publishing
    try ffLiveKit?.publish()
    
    // Update the state
    isPublishing = true
    
    onPublishStarted([:])
  }
  
  public func stopPublishing() {
    ffLiveKit?.stop()
    isPublishing = false
    
    onPublishStopped([:])
  }
  
  public func switchCamera() {
    cameraSource?.switchCamera()
  }
  
  public func toggleTorch(level: Float = 1.0) {
    cameraSource?.toggleTorch(level: level)
  }

  public func setCameraPosition(position: AVCaptureDevice.Position) {
    // Проверяем, изменилась ли позиция камеры
    print("Setting camera position to: \(position == .front ? "front" : "back") from \(self.cameraPosition == .front ? "front" : "back")")
    if self.cameraPosition != position {
      print("Switching camera position")
      cameraSource?.switchCamera()
      self.cameraPosition = position
    }
  }

   public func _FFLiveKit(didChange status: RecordingState) {
    
  }
  
  public func _FFLiveKit(onStats stats: FFStat) {
    // Handle stats if needed
  }
  
  public func _FFLiveKit(onError error: String) {

    isPublishing = false
    
    onPublishError(["error": error])
  }
  
}