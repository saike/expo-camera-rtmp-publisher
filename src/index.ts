// Reexport the native module. On web, it will be resolved to ExpoCameraRtmpPublisherModule.web.ts
// and on native platforms to ExpoCameraRtmpPublisherModule.ts
export { default } from './ExpoCameraRtmpPublisherModule';
export { default as ExpoCameraRtmpPublisherView } from './ExpoCameraRtmpPublisherView';
export * from  './ExpoCameraRtmpPublisher.types';
