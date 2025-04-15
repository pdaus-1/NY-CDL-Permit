import { registerRootComponent } from 'expo';
import App from './App';

// registerRootComponent 确保无论你是在 Expo Go 还是独立构建中加载 App，环境都设定正确
registerRootComponent(App);

