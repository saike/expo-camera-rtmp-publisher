# Expo Camera RTMP Publisher

Модуль для React Native/Expo, позволяющий вести RTMP трансляции с камеры мобильного устройства. Поддерживает iOS и Android платформы.

## Особенности

- Потоковое вещание видео по RTMP протоколу
- Переключение между фронтальной и основной камерой
- Управление фонариком устройства
- Настройка параметров трансляции (разрешение, битрейт)
- Обработка событий начала/остановки трансляции и ошибок
- Полная интеграция с системой разрешений Expo

## Установка

### В управляемых Expo проектах

```bash
npx expo install expo-camera-rtmp-publisher
```

### В bare React Native проектах

Убедитесь, что у вас [установлен и настроен пакет `expo`](https://docs.expo.dev/bare/installing-expo-modules/) перед продолжением.

```bash
npm install expo-camera-rtmp-publisher
```

#### Android конфигурация

Дополнительная конфигурация не требуется.

#### iOS конфигурация

Выполните `npx pod-install` после установки npm пакета.

## Использование

### Базовый пример

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
      console.error('Ошибка начала трансляции:', err);
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
        title={isPublishing ? "Остановить" : "Начать трансляцию"}
        onPress={isPublishing ? 
          () => publisherRef.current?.stopPublishing() : 
          startPublishing
        }
      />
    </View>
  );
}
```

### Разрешения

Перед использованием камеры и микрофона необходимо запросить разрешения:

```javascript
import { requestCameraPermissionsAsync, requestMicrophonePermissionsAsync } from 'expo-camera-rtmp-publisher';

async function requestPermissions() {
  const cameraPermission = await requestCameraPermissionsAsync();
  const microphonePermission = await requestMicrophonePermissionsAsync();
  
  if (!cameraPermission.granted || !microphonePermission.granted) {
    // Обработка отсутствия разрешений
  }
}
```

## API

### ExpoCameraRtmpPublisherView

#### Свойства

| Свойство | Тип | Описание |
|----------|-----|---------|
| `cameraPosition` | `'front'` \| `'back'` | Позиция камеры (по умолчанию `'front'`) |
| `onPublishStarted` | `() => void` | Callback, вызываемый при начале трансляции |
| `onPublishStopped` | `() => void` | Callback, вызываемый при остановке трансляции |
| `onPublishError` | `(error: string) => void` | Callback, вызываемый при ошибке трансляции |

#### Методы

| Метод | Параметры | Описание |
|-------|-----------|---------|
| `startPublishing` | `(rtmpUrl: string, options?: PublishOptions)` | Начинает RTMP трансляцию |
| `stopPublishing` | - | Останавливает RTMP трансляцию |
| `switchCamera` | - | Переключает между фронтальной и основной камерой |
| `toggleTorch` | `(level: number)` | Включает/выключает фонарик с указанной яркостью |

#### Тип PublishOptions

| Свойство | Тип | Описание |
|----------|-----|---------|
| `videoWidth` | `number` | Ширина видео в пикселях |
| `videoHeight` | `number` | Высота видео в пикселях |
| `videoBitrate` | `string` | Битрейт видео, например `'1M'` |
| `audioBitrate` | `string` | Битрейт аудио, например `'128k'` |

### Функции

| Функция | Возвращаемое значение | Описание |
|---------|----------------------|---------|
| `requestCameraPermissionsAsync` | `Promise<PermissionResponse>` | Запрашивает разрешение на использование камеры |
| `requestMicrophonePermissionsAsync` | `Promise<PermissionResponse>` | Запрашивает разрешение на использование микрофона |
| `getCameraPermissionsAsync` | `Promise<PermissionResponse>` | Проверяет текущее разрешение на использование камеры |
| `getMicrophonePermissionsAsync` | `Promise<PermissionResponse>` | Проверяет текущее разрешение на использование микрофона |

#### Тип PermissionResponse

| Свойство | Тип | Описание |
|----------|-----|---------|
| `status` | `string` | Статус разрешения (`'granted'` или `'denied'`) |
| `granted` | `boolean` | Флаг, указывающий на наличие разрешения |

## Лицензия

MIT
