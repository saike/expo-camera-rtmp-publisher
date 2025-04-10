# Expo Camera RTMP Publisher

A React Native/Expo module for RTMP streaming from a mobile device camera. **Currently only iOS platform is supported.**

## Features

- Video streaming via RTMP protocol
- Switching between front and back cameras
- Device flashlight control
- Stream parameter configuration (resolution, bitrate)
- Handling broadcasting start/stop events and errors
- Full integration with Expo permissions system

## Installation

### In managed Expo projects

```bash
npx expo install expo-camera-rtmp-publisher
```

### In bare React Native projects

Make sure you have [installed and configured the `expo` package](https://docs.expo.dev/bare/installing-expo-modules/) before continuing.

```bash
npm install expo-camera-rtmp-publisher
```

#### iOS configuration

Run `npx pod-install` after installing the npm package.

> **Note:** Android support is currently under development.

## Usage

### Basic example

```jsx
import React, { useRef, useState } from 'react';
import { View, Button } from 'react-native';
import { 
  ExpoCameraRtmpPublisherView,
  requestCameraPermissionsAsync,
  requestMicrophonePermissionsAsync
} from 'expo-camera-rtmp-publisher';

export default function App() {
  const [isPublishing, setIsPublishing] = useState(false);
  const publisherRef = useRef(null);
  
  const startPublishing = async () => {
    try {
      await publisherRef.current?.startPublishing('rtmp://your-rtmp-server/live/stream', {
        videoWidth: 720,
        videoHeight: 1280,
        videoBitrate: '1M',
        audioBitrate: '128k',
      });
    } catch (err) {
      console.error('Broadcasting start error:', err);
    }
  };
  
  return (
    <View style={{ flex: 1 }}>
      <ExpoCameraRtmpPublisherView
        ref={publisherRef}
        style={{ flex: 1 }}
        cameraPosition="front"
        onPublishStarted={() => setIsPublishing(true)}
        onPublishStopped={() => setIsPublishing(false)}
        onPublishError={(error) => console.error(error)}
      />
      
      <Button
        title={isPublishing ? "Stop" : "Start Broadcasting"}
        onPress={isPublishing ? 
          () => publisherRef.current?.stopPublishing() : 
          startPublishing
        }
      />
    </View>
  );
}
```

### Permissions

Before using the camera and microphone, you need to request permissions:

```javascript
import { requestCameraPermissionsAsync, requestMicrophonePermissionsAsync } from 'expo-camera-rtmp-publisher';

async function requestPermissions() {
  const cameraPermission = await requestCameraPermissionsAsync();
  const microphonePermission = await requestMicrophonePermissionsAsync();
  
  if (!cameraPermission.granted || !microphonePermission.granted) {
    // Handle missing permissions
  }
}
```

## API

### ExpoCameraRtmpPublisherView

#### Properties

| Property | Type | Description |
|----------|-----|-------------|
| `cameraPosition` | `'front'` \| `'back'` | Camera position (default is `'front'`) |
| `onPublishStarted` | `() => void` | Callback invoked when broadcasting starts |
| `onPublishStopped` | `() => void` | Callback invoked when broadcasting stops |
| `onPublishError` | `(error: string) => void` | Callback invoked when a broadcasting error occurs |

#### Methods

| Method | Parameters | Description |
|--------|------------|-------------|
| `startPublishing` | `(rtmpUrl: string, options?: PublishOptions)` | Starts RTMP broadcasting |
| `stopPublishing` | - | Stops RTMP broadcasting |
| `switchCamera` | - | Switches between front and back cameras |
| `toggleTorch` | `(level: number)` | Turns on/off the flashlight with specified brightness |

#### PublishOptions Type

| Property | Type | Description |
|----------|------|-------------|
| `videoWidth` | `number` | Video width in pixels |
| `videoHeight` | `number` | Video height in pixels |
| `videoBitrate` | `string` | Video bitrate, e.g., `'1M'` |
| `audioBitrate` | `string` | Audio bitrate, e.g., `'128k'` |

### Functions

| Function | Return Value | Description |
|----------|--------------|-------------|
| `requestCameraPermissionsAsync` | `Promise<PermissionResponse>` | Requests permission to use the camera |
| `requestMicrophonePermissionsAsync` | `Promise<PermissionResponse>` | Requests permission to use the microphone |
| `getCameraPermissionsAsync` | `Promise<PermissionResponse>` | Checks current camera permission status |
| `getMicrophonePermissionsAsync` | `Promise<PermissionResponse>` | Checks current microphone permission status |

#### PermissionResponse Type

| Property | Type | Description |
|----------|------|-------------|
| `status` | `string` | Permission status (`'granted'` or `'denied'`) |
| `granted` | `boolean` | Flag indicating whether permission is granted |

## License

MIT
