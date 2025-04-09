import * as React from 'react';

import { ExpoCameraRtmpPublisherViewProps } from './ExpoCameraRtmpPublisher.types';

export default function ExpoCameraRtmpPublisherView(props: ExpoCameraRtmpPublisherViewProps) {
  return (
    <div>
      <iframe
        style={{ flex: 1 }}
        src={props.url}
        onLoad={() => props.onLoad({ nativeEvent: { url: props.url } })}
      />
    </div>
  );
}
