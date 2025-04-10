// Reexport the native module. On web, it will be resolved to ExpoCameraRtmpPublisherModule.web.ts
// and on native platforms to ExpoCameraRtmpPublisherModule.ts
import { EventSubscription } from "expo-modules-core";

import ExpoCameraRtmpPublisherModule from "./ExpoCameraRtmpPublisherModule";
export { default as ExpoCameraRtmpPublisher } from "./ExpoCameraRtmpPublisherModule";

export {
  default as ExpoCameraRtmpPublisherView,
  Props as ExpoCameraRtmpPublisherViewProps,
} from "./ExpoCameraRtmpPublisherView";

export type PermissionResponse = {
  status: string;
  granted: boolean;
};

export function requestCameraPermissionsAsync(): Promise<PermissionResponse> {
  return ExpoCameraRtmpPublisherModule.requestCameraPermissionsAsync();
}

export function requestMicrophonePermissionsAsync(): Promise<PermissionResponse> {
  return ExpoCameraRtmpPublisherModule.requestMicrophonePermissionsAsync();
}

export function getCameraPermissionsAsync(): Promise<PermissionResponse> {
  return ExpoCameraRtmpPublisherModule.getCameraPermissionsAsync();
}

export function getMicrophonePermissionsAsync(): Promise<PermissionResponse> {
  return ExpoCameraRtmpPublisherModule.getMicrophonePermissionsAsync();
}

// export function getTheme(): string {
//   return ExpoCameraRtmpPublisher.getTheme();
// }

// export function setTheme(theme: string): void {
//   return ExpoCameraRtmpPublisher.setTheme(theme);
// }

// export type ThemeChangeEvent = {
//   theme: string;
// };

// export function addThemeListener(
//   listener: (event: ThemeChangeEvent) => void,
// ): EventSubscription {
//   return ExpoCameraRtmpPublisher.addListener(
//     "onChangeTheme" as never,
//     listener as never,
//   );
// }
