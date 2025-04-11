# Expo Camera RTMP Publisher

A React Native/Expo module for RTMP streaming from a mobile device camera.
**Currently only iOS platform is supported.**

## Features

- Video streaming via RTMP protocol
- Front and back camera support with switching capability
- Device flashlight control with brightness adjustment
- Configurable video and audio settings (resolution, bitrate)
- Audio muting control
- Broadcasting state management (start/stop/error events)
- Full integration with Expo permissions system
- Hardware-accelerated video encoding
- Built on HaishinKit for iOS

## Installation

### In managed Expo projects

```bash
npx expo install expo-camera-rtmp-publisher
```

### In bare React Native projects

Make sure you have
[installed and configured the `expo` package](https://docs.expo.dev/bare/installing-expo-modules/)
before continuing.

```bash
npm install expo-camera-rtmp-publisher
```

#### iOS configuration

Run `npx pod-install` after installing the npm package.

> **Note:** Android support is currently under development.

## Usage

### Basic example

```jsx
import React, { useRef, useState } from "react";
import { Button, View } from "react-native";
import {
  ExpoCameraRtmpPublisherView,
  requestCameraPermissionsAsync,
  requestMicrophonePermissionsAsync,
} from "expo-camera-rtmp-publisher";

export default function App() {
  const [isPublishing, setIsPublishing] = useState(false);
  const publisherRef = useRef(null);

  const startPublishing = async () => {
    try {
      await publisherRef.current?.startPublishing(
        "rtmp://your-rtmp-server/live",
        "stream-key",
        {
          videoWidth: 1080,
          videoHeight: 1920,
          videoBitrate: 2000000,
          audioBitrate: 128000,
        },
      );
    } catch (err) {
      console.error("Broadcasting error:", err);
    }
  };

  return (
    <View style={{ flex: 1 }}>
      <ExpoCameraRtmpPublisherView
        ref={publisherRef}
        style={{ flex: 1 }}
        cameraPosition="front"
        muted={false}
        onPublishStarted={() => setIsPublishing(true)}
        onPublishStopped={() => setIsPublishing(false)}
        onPublishError={(error) => console.error(error)}
      />

      <Button
        title={isPublishing ? "Stop Broadcasting" : "Start Broadcasting"}
        onPress={isPublishing
          ? () => publisherRef.current?.stopPublishing()
          : startPublishing}
      />
    </View>
  );
}
```

### Permissions

Before using the camera and microphone, you need to request permissions:

```javascript
import { requestCameraPermissionsAsync, requestMicrophonePermissionsAsync } from 'expo-camera-rtmp-publisher;

async function requestPermissions() {
  const cameraPermission = await requestCameraPermissionsAsync();
  const microphonePermission = await requestMicrophonePermissionsAsync();
  
  if (!cameraPermission.granted || !microphonePermission.granted) {
    // Handle missing permissions
  }
}
```

### Required Configuration Files

For the module to work properly, you need to add the following configurations to
your project files:

#### iOS (Info.plist)

Add the following to your `ios/Info.plist` file to request camera and microphone
permissions:

```xml
<key>NSCameraUsageDescription</key>
<string>The application requests access to the camera for video broadcasting</string>
<key>NSMicrophoneUsageDescription</key>
<string>The application requests access to the microphone for audio broadcasting</string>
```

## API

### ExpoCameraRtmpPublisherView

#### Properties

| Property           | Type                      | Description                               |
| ------------------ | ------------------------- | ----------------------------------------- |
| `cameraPosition`   | `'front'` \| `'back'`     | Camera position (default: `'front'`)      |
| `muted`            | `boolean`                 | Audio muting state (default: `false`)     |
| `onPublishStarted` | `() => void`              | Callback when broadcasting starts         |
| `onPublishStopped` | `() => void`              | Callback when broadcasting stops          |
| `onPublishError`   | `(error: string) => void` | Callback when a broadcasting error occurs |

#### Methods

| Method            | Parameters                                              | Description                             |
| ----------------- | ------------------------------------------------------- | --------------------------------------- |
| `startPublishing` | `(url: string, name: string, options?: PublishOptions)` | Starts RTMP broadcasting                |
| `stopPublishing`  | `()`                                                    | Stops RTMP broadcasting                 |
| `switchCamera`    | `()`                                                    | Switches between front and back cameras |
| `toggleTorch`     | `(level: number)`                                       | Controls flashlight (0.0-1.0)           |

#### PublishOptions Type

| Property       | Type     | Default   | Description                      |
| -------------- | -------- | --------- | -------------------------------- |
| `videoWidth`   | `number` | `1080`    | Video width in pixels            |
| `videoHeight`  | `number` | `1920`    | Video height in pixels           |
| `videoBitrate` | `number` | `2000000` | Video bitrate in bits per second |
| `audioBitrate` | `number` | `128000`  | Audio bitrate in bits per second |

### Permission Functions

| Function                            | Return Type                   | Description                       |
| ----------------------------------- | ----------------------------- | --------------------------------- |
| `requestCameraPermissionsAsync`     | `Promise<PermissionResponse>` | Requests camera access            |
| `requestMicrophonePermissionsAsync` | `Promise<PermissionResponse>` | Requests microphone access        |
| `getCameraPermissionsAsync`         | `Promise<PermissionResponse>` | Gets camera permission status     |
| `getMicrophonePermissionsAsync`     | `Promise<PermissionResponse>` | Gets microphone permission status |

#### PermissionResponse Type

| Property  | Type      | Description                                       |
| --------- | --------- | ------------------------------------------------- |
| `status`  | `string`  | Permission status (`'granted'`, `'denied'`, etc.) |
| `granted` | `boolean` | Whether permission is granted                     |

## License

MIT
