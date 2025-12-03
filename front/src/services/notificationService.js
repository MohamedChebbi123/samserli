import { useState, useEffect, useCallback } from 'react';
import apiService from './apiService';

class NotificationService {
  constructor() {
    this.listeners = [];
    this.unreadCount = 0;
  }

  subscribe(listener) {
    this.listeners.push(listener);
    return () => {
      this.listeners = this.listeners.filter((l) => l !== listener);
    };
  }

  notify() {
    this.listeners.forEach((listener) => listener(this.unreadCount));
  }

  async fetchUnreadCount() {
    try {
      const data = await apiService.getUnreadCount();
      this.unreadCount = data.unread_count || 0;
      this.notify();
      return this.unreadCount;
    } catch (error) {
      console.error('Error fetching unread count:', error);
      return 0;
    }
  }

  async markConversationAsRead(otherUserId) {
    try {
      await apiService.markConversationAsRead(otherUserId);
      await this.fetchUnreadCount();
    } catch (error) {
      console.error('Error marking conversation as read:', error);
    }
  }

  reset() {
    this.unreadCount = 0;
    this.notify();
  }

  getUnreadCount() {
    return this.unreadCount;
  }
}

const notificationService = new NotificationService();

// Custom hook to use notification service
export const useNotifications = () => {
  const [unreadCount, setUnreadCount] = useState(0);

  useEffect(() => {
    const unsubscribe = notificationService.subscribe(setUnreadCount);
    notificationService.fetchUnreadCount();
    return unsubscribe;
  }, []);

  const refresh = useCallback(() => {
    notificationService.fetchUnreadCount();
  }, []);

  return { unreadCount, refresh };
};

export default notificationService;
