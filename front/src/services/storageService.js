import * as SecureStore from 'expo-secure-store';

class StorageService {
  async setToken(token) {
    try {
      await SecureStore.setItemAsync('token', token);
    } catch (error) {
      console.error('Error saving token:', error);
      throw error;
    }
  }

  async getToken() {
    try {
      return await SecureStore.getItemAsync('token');
    } catch (error) {
      console.error('Error getting token:', error);
      return null;
    }
  }

  async removeToken() {
    try {
      await SecureStore.deleteItemAsync('token');
    } catch (error) {
      console.error('Error removing token:', error);
      throw error;
    }
  }

  async setItem(key, value) {
    try {
      await SecureStore.setItemAsync(key, value);
    } catch (error) {
      console.error(`Error saving ${key}:`, error);
      throw error;
    }
  }

  async getItem(key) {
    try {
      return await SecureStore.getItemAsync(key);
    } catch (error) {
      console.error(`Error getting ${key}:`, error);
      return null;
    }
  }

  async removeItem(key) {
    try {
      await SecureStore.deleteItemAsync(key);
    } catch (error) {
      console.error(`Error removing ${key}:`, error);
      throw error;
    }
  }

  async clear() {
    try {
      await this.removeToken();
      // Add any other keys you want to clear on logout
    } catch (error) {
      console.error('Error clearing storage:', error);
      throw error;
    }
  }
}

export default new StorageService();
