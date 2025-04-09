import { registerWebModule, NativeModule } from 'expo';

import { ExpoCameraRtmpPublisherModuleEvents } from './ExpoCameraRtmpPublisher.types';

class ExpoCameraRtmpPublisherModule extends NativeModule<ExpoCameraRtmpPublisherModuleEvents> {
  PI = Math.PI;
  async setValueAsync(value: string): Promise<void> {
    this.emit('onChange', { value });
  }
  hello() {
    return 'Hello world! 👋';
  }
}

export default registerWebModule(ExpoCameraRtmpPublisherModule);
