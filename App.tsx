import { NativeWindStyleSheet } from 'nativewind';

NativeWindStyleSheet.setOutput({
  default: "native",
});

export { App as default } from './src/app';