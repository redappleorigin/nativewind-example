import { StatusBar } from 'expo-status-bar';
import { Text, View } from 'react-native';

export const App: React.FC = () => {
  return (
    <View className="flex-1 items-center justify-center bg-white">
      <Text>Testing testing</Text>
      <StatusBar style="auto" />
    </View>
  );
}
