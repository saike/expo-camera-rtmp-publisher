import { NativeModule, requireNativeModule } from "expo-modules-core";

// import { ExpoCameraRtmpPublisherModuleEvents } from "./ExpoCameraRtmpPublisher.types";

declare class ExpoCameraRtmpPublisherModule extends NativeModule {

  requestCameraPermissionsAsync(): Promise<{ status: string; granted: boolean }>;
  requestMicrophonePermissionsAsync(): Promise<{ status: string; granted: boolean }>;
  getCameraPermissionsAsync(): Promise<{ status: string; granted: boolean }>;
  getMicrophonePermissionsAsync(): Promise<{ status: string; granted: boolean }>;
  addListener(
    eventName: string,
    listener: (...args: any[]) => void,
  ): { remove: () => void };
}

// This call loads the native module object from the JSI.
export default requireNativeModule<ExpoCameraRtmpPublisherModule>(
  "ExpoCameraRtmpPublisher",
);
