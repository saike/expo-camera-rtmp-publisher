import ExpoModulesCore
import AVFoundation
import HaishinKit
import VideoToolbox
import UIKit

public struct PublishOptions {
    var videoWidth: Int32 = 1080
    var videoHeight: Int32 = 1920
    var videoBitrate: Int32 = 2_000_000
    var audioBitrate: Int32 = 128_000
    
    public init(videoWidth: Int32 = 1080, videoHeight: Int32 = 1920, videoBitrate: Int32 = 2_000_000, audioBitrate: Int32 = 128_000) {
        self.videoWidth = videoWidth
        self.videoHeight = videoHeight
        self.videoBitrate = videoBitrate
        self.audioBitrate = audioBitrate
    }
}

class ExpoCameraRtmpPublisherView: ExpoView {
    private let mixer = MediaMixer()
    private let rtmpStream: RTMPStream
    private let rtmpConnection = RTMPConnection()
    private let hkView: MTHKView

    private var isAudioConfigured = false
    private var isVideoConfigured = false
    private var isPublishing = false
    private var lastCamera: AVCaptureDevice?
    private var currentPosition: AVCaptureDevice.Position = .back

    let onPublishStarted = EventDispatcher()
    let onPublishStopped = EventDispatcher()
    let onPublishError = EventDispatcher()

    var cameraPosition: AVCaptureDevice.Position = .front {
        didSet {
            Task {
                await attachCamera(cameraPosition)
            }
        }
    }

    var muted: Bool = false {
        didSet {
            setAudioMuted(muted)
        }
    }

    func setCameraPosition(position: AVCaptureDevice.Position) {
        self.cameraPosition = position
    }

    required init(appContext: AppContext? = nil) {
        self.rtmpStream = RTMPStream(connection: rtmpConnection)
        self.hkView = MTHKView(frame: .zero)
        super.init(appContext: appContext)
        
        setupAudioSession()
        setupStream()
        
        // Add HKView as subview
        addSubview(hkView)
        hkView.frame = bounds
        hkView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
    }

    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true)
        } catch {
            print("Failed to setup audio session:", error)
        }
    }

    private func setupStream() {
        Task {
            do {
                // Configure basic mixer settings
                try await mixer.setFrameRate(30)
                try await mixer.setSessionPreset(.medium)
                
                // Configure stream outputs
                try await mixer.addOutput(rtmpStream)
                try await mixer.addOutput(hkView)
                
                // Initial camera & audio setup
                await attachCamera(cameraPosition)
                await attachAudio()
                
                // Setup connection event listeners
                Task {
                    for await status in rtmpConnection.status {
                        switch status.code {
                        case RTMPConnection.Code.connectSuccess.rawValue:
                            print("RTMP Connected")
                            onPublishStarted([:])
                        case RTMPConnection.Code.connectClosed.rawValue:
                            print("RTMP Disconnected")
                            onPublishStopped([:])

                        case RTMPConnection.Code.connectFailed.rawValue:
                            print("RTMP Connection Failed:", status.description)
                            onPublishError([
                                "error": status.description,
                                "code": status.code
                            ])

                        default:
                            print("RTMP Status:", status.code)
                        }
                    }
                }
            } catch {
                print("Failed to setup stream:", error)
            }
        }
    }

    private func attachAudio() async {
        guard let audioDevice = AVCaptureDevice.default(for: .audio) else {
            print("No audio device available")
            return
        }
        
        do {
            try await mixer.attachAudio(audioDevice, track: 0)
        } catch {
            print("Failed to attach audio device:", error)
        }
    }

    private func attachCamera(_ position: AVCaptureDevice.Position) async {
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else {
            print("No camera available for position:", position)
            return
        }
        self.lastCamera = camera
        
        do {
            try await mixer.attachVideo(camera, track: 0) { videoUnit in
                videoUnit.isVideoMirrored = position == .front
                videoUnit.preferredVideoStabilizationMode = .standard
            }
        } catch {
            print("Failed to attach camera:", error)
        }
    }

    public func switchCamera() {
        Task {
            print("Switching camera")
            let position: AVCaptureDevice.Position = currentPosition == .back ? .front : .back
            if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) {
                await attachCamera(position)
                currentPosition = position
            }
        }
    }

    public func toggleTorch(level: Float) {
        Task {
            guard let camera = lastCamera else { return }
            
            do {
                try camera.lockForConfiguration()
                if camera.hasTorch {
                    if camera.torchMode == .off {
                        try camera.setTorchModeOn(level: level)
                    } else {
                        camera.torchMode = .off
                    }
                }
                camera.unlockForConfiguration()
            } catch {
                print("Failed to toggle torch:", error)
                throw error
            }
        }
    }

    private func setAudioMuted(_ muted: Bool) {
        Task {
            var settings = mixer.audioMixerSettings
            settings.tracks[0] = AudioMixerTrackSettings(isMuted: muted)
            mixer.setAudioMixerSettings(settings)
        }
    }

    public func startPublishing(url: String, name: String, options: PublishOptions) {
        guard !isPublishing else { return }
        
        Task {
            do {
                // Configure video settings
                let videoSettings = VideoCodecSettings(
                    videoSize: CGSize(width: CGFloat(options.videoWidth), height: CGFloat(options.videoHeight)),
                    bitRate: Int(options.videoBitrate),
                    scalingMode: .trim,
                    maxKeyFrameIntervalDuration: 2
                )
                await rtmpStream.setVideoSettings(videoSettings)
                
                // Configure audio settings
                let audioSettings = AudioCodecSettings(
                    bitRate: Int(options.audioBitrate)
                )
                await rtmpStream.setAudioSettings(audioSettings)
                
                // Connect and publish
                try await rtmpConnection.connect(url)
                try await rtmpStream.publish(name)
                
                isPublishing = true
            } catch {
                print("Failed to start publishing:", error)
            }
        }
    }

    public func stopPublishing() {
        guard isPublishing else { return }
        
        Task {
            do {
                try await rtmpStream.close()
                try await rtmpConnection.close()
                isPublishing = false
            } catch {
                print("Failed to stop publishing:", error)
            }
        }
    }
}