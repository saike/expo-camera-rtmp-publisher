import { requireNativeViewManager } from "expo-modules-core";
import * as React from "react";
import { ViewProps, StyleProp, ViewStyle } from "react-native";

export type PublishOptions = {
  videoWidth?: number;
  videoHeight?: number;
  videoBitrate?: string;
  audioBitrate?: string;
}

export type Props = ViewProps & {
  style?: StyleProp<ViewStyle>;
  muted?: boolean;
  cameraPosition?: "front" | "back";
  onPublishStarted?: () => void;
  onPublishStopped?: () => void;
  onPublishError?: (error: string) => void;
  ref?: React.ForwardedRef<IExpoCameraRtmpPublisherForward>;
};

export interface IExpoCameraRtmpPublisherForward {
  startPublishing(url: string, name: string, options?: PublishOptions): Promise<void>;
  stopPublishing(): Promise<void>;
  switchCamera(): Promise<void>;
  toggleTorch(level: number): Promise<void>;
  onPublishStarted(): void;
  onPublishStopped(): void;
  onPublishError(error: string): void;
}

const NativeView: React.ComponentType<Props> = requireNativeViewManager(
  "ExpoCameraRtmpPublisher",
);

export default React.forwardRef<IExpoCameraRtmpPublisherForward, Props>(function ExpoCameraRtmpPublisherView(props: Props, ref) {
  return <NativeView {...props} ref={ref} />;
});
