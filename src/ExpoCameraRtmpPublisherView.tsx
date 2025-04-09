import { requireNativeView } from 'expo';
import * as React from 'react';

import { ExpoCameraRtmpPublisherViewProps } from './ExpoCameraRtmpPublisher.types';

const NativeView: React.ComponentType<ExpoCameraRtmpPublisherViewProps> =
  requireNativeView('ExpoCameraRtmpPublisher');

export default function ExpoCameraRtmpPublisherView(props: ExpoCameraRtmpPublisherViewProps) {
  return <NativeView {...props} />;
}
