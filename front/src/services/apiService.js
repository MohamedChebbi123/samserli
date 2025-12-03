import axios from 'axios';
import { API_BASE_URL } from '../constants/config';
import storageService from './storageService';

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 30000,
});

// Request interceptor to add auth token
apiClient.interceptors.request.use(
  async (config) => {
    const token = await storageService.getToken();
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor to handle errors
apiClient.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401) {
      // Token expired or invalid - clear storage
      await storageService.clear();
      // You can navigate to login screen here if needed
    }
    return Promise.reject(error);
  }
);

class ApiService {
  // Auth APIs
  async login(email, password) {
    const response = await apiClient.post('/login_user', { email, password });
    return response.data;
  }

  async register(formData) {
    const response = await apiClient.post('/register_new_user', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  }

  async forgotPassword(email) {
    const response = await apiClient.post('/forgot_password', { email });
    return response.data;
  }

  async verifyResetCode(email, code) {
    const response = await apiClient.post('/verify_reset_code', { email, code });
    return response.data;
  }

  async resetPassword(email, code, newPassword) {
    const response = await apiClient.post('/reset_password', {
      email,
      code,
      new_password: newPassword,
    });
    return response.data;
  }

  // User APIs
  async getUser() {
    const response = await apiClient.get('/get_user');
    return response.data;
  }

  async updateProfile(formData) {
    const response = await apiClient.put('/update_profile', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  }

  async changePassword(oldPassword, newPassword) {
    const response = await apiClient.put('/change_password', {
      old_password: oldPassword,
      new_password: newPassword,
    });
    return response.data;
  }

  // House APIs
  async fetchHouses() {
    const response = await apiClient.get('/fetch_houses');
    return response.data;
  }

  async addHouse(formData) {
    const response = await apiClient.post('/add_house', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  }

  async updateHouse(houseId, formData) {
    const response = await apiClient.put(`/update_house/${houseId}`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  }

  async deleteHouse(houseId) {
    const response = await apiClient.delete(`/delete_house/${houseId}`);
    return response.data;
  }

  async getUserHouses() {
    const response = await apiClient.get('/get_user_houses');
    return response.data;
  }

  // Favourites APIs
  async addToFavourites(houseId) {
    const response = await apiClient.post(`/add_to_favourites/${houseId}`);
    return response.data;
  }

  async removeFromFavourites(houseId) {
    const response = await apiClient.delete(`/remove_from_favourites/${houseId}`);
    return response.data;
  }

  async getFavourites() {
    const response = await apiClient.get('/get_favourites');
    return response.data;
  }

  // Messages APIs
  async getConversations() {
    const response = await apiClient.get('/get_conversations');
    return response.data;
  }

  async getMessages(otherUserId) {
    const response = await apiClient.get(`/get_messages/${otherUserId}`);
    return response.data;
  }

  async sendMessage(receiverId, content, houseId = null) {
    const response = await apiClient.post('/send_message', {
      receiver_id: receiverId,
      content,
      house_id: houseId,
    });
    return response.data;
  }

  async getUnreadCount() {
    const response = await apiClient.get('/get_unread_message_count');
    return response.data;
  }

  async markConversationAsRead(otherUserId) {
    const response = await apiClient.put(`/mark_conversation_as_read/${otherUserId}`);
    return response.data;
  }
}

export default new ApiService();
