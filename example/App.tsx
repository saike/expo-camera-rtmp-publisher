import React, { useState, useEffect, useRef } from 'react';
import { StyleSheet, View, Button, Text, SafeAreaView, StatusBar, TextInput, Platform, Alert } from 'react-native';
import {
  ExpoCameraRtmpPublisherView,
  requestCameraPermissionsAsync,
  requestMicrophonePermissionsAsync,
} from 'expo-camera-rtmp-publisher';

import config from './config';
import { IExpoCameraRtmpPublisherForward } from 'expo-camera-rtmp-publisher/ExpoCameraRtmpPublisherView';

export default function App() {
  const [isPublishing, setIsPublishing] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [rtmpUrl, setRtmpUrl] = useState(`${config.url}${config.streamKey}`);
  const [hasCameraPermission, setHasCameraPermission] = useState<boolean | null>(null);
  const [hasMicrophonePermission, setHasMicrophonePermission] = useState<boolean | null>(null);
  const publisherView = useRef<IExpoCameraRtmpPublisherForward>(null);
  const [muted, setMuted] = useState(false);

  useEffect(() => {
    // Запрос разрешений на камеру и микрофон
    (async () => {
      const cameraPermission = await requestCameraPermissionsAsync();
      setHasCameraPermission(cameraPermission.granted);

      const microphonePermission = await requestMicrophonePermissionsAsync();
      setHasMicrophonePermission(microphonePermission.granted);
    })();

    // Подписка на изменения статуса публикации

  }, []);

  const handleStartPublishing = async () => {
    try {
      await publisherView.current?.startPublishing(config.url, config.streamKey, {
        videoWidth: 720,
        videoHeight: 1280,
        videoBitrate: '1000000',
        audioBitrate: '128000',
      });
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to start publishing');
    }
  };

  const handleStopPublishing = async () => {
    try {
      await publisherView.current?.stopPublishing();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to stop publishing');
    }
  };

  const handleSwitchCamera = async () => {
    try {
      await publisherView.current?.switchCamera();
    } catch (err) {
      console.log(error)
      setError(err instanceof Error ? err.message : 'Failed to switch camera');
    }
  };

  const handleToggleTorch = async () => {
    try {
      await publisherView.current?.toggleTorch(1.0);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to toggle torch');
    }
  };

  const handleMute = () => {
    setMuted(!muted);
  }

  // Если разрешения еще загружаются
  if (hasCameraPermission === null || hasMicrophonePermission === null) {
    return (
      <View style={styles.container}>
        <Text style={styles.statusText}>Запрос разрешений...</Text>
      </View>
    );
  }

  // Если разрешение на камеру не получено
  if (!hasCameraPermission) {
    return (
      <View style={styles.container}>
        <Text style={styles.statusText}>Необходим доступ к камере для работы приложения</Text>
        <Button
          title="Запросить разрешение снова"
          onPress={async () => {
            const permission = await requestCameraPermissionsAsync();
            setHasCameraPermission(permission.granted);
          }}
        />
      </View>
    );
  }

  // Если разрешение на микрофон не получено
  if (!hasMicrophonePermission) {
    return (
      <View style={styles.container}>
        <Text style={styles.statusText}>Необходим доступ к микрофону для работы приложения</Text>
        <Button
          title="Запросить разрешение снова"
          onPress={async () => {
            const permission = await requestMicrophonePermissionsAsync();
            setHasMicrophonePermission(permission.granted);
          }}
        />
      </View>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="light-content" />

      <View style={styles.cameraContainer}>
        <ExpoCameraRtmpPublisherView
          ref={publisherView}
          style={styles.camera}
          muted={muted}
          cameraPosition="front"
          onPublishStarted={() => setIsPublishing(true)}
          onPublishStopped={() => setIsPublishing(false)}
          onPublishError={(error: string) => setError(error)}
        />
      </View>

      <View style={styles.controls}>
        <TextInput
          style={styles.input}
          value={rtmpUrl}
          onChangeText={setRtmpUrl}
          placeholder="RTMP URL"
          placeholderTextColor="#999"
        />

        <View style={styles.buttonRow}>
          <Button
            title={isPublishing ? "Остановить трансляцию" : "Начать трансляцию"}
            onPress={isPublishing ? handleStopPublishing : handleStartPublishing}
            color={isPublishing ? "#e74c3c" : "#2ecc71"}
          />
        </View>

        <View style={styles.buttonRow}>
          <Button title="Переключить камеру" onPress={handleSwitchCamera} />
          <Button title="Вкл/выкл фонарик" onPress={handleToggleTorch} />
          <Button title="Вкл/выкл Микрофон" color={!muted ? "#e74c3c" : "#2ecc71"} onPress={handleMute} />
        </View>

        {error && (
          <Text style={styles.errorText}>{error}</Text>
        )}

        <Text style={styles.statusText}>
          Статус: {isPublishing ? "Трансляция идет" : "Трансляция остановлена"}
        </Text>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#000',
  },
  cameraContainer: {
    flex: 1,
  },
  camera: {
    flex: 1,
    backgroundColor: 'red',
  },
  controls: {
    padding: 20,
    backgroundColor: 'rgba(0, 0, 0, 0.7)',
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
  },
  input: {
    height: 40,
    borderColor: '#666',
    borderWidth: 1,
    borderRadius: 5,
    marginBottom: 20,
    paddingHorizontal: 10,
    color: '#fff',
    backgroundColor: '#333',
  },
  buttonRow: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    flexWrap: 'wrap',
    marginBottom: 20,
  },
  errorText: {
    color: '#e74c3c',
    textAlign: 'center',
    marginVertical: 10,
  },
  statusText: {
    color: '#fff',
    textAlign: 'center',
  },
});
