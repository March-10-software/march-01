import { defineStore } from 'pinia';
import { ref, computed } from 'vue';

// Types pour les notifications
export interface Notification {
  id: string;
  title: string;
  message: string;
  type: 'success' | 'error' | 'info' | 'warning';
  read: boolean;
  createdAt: Date;
  autoClose?: boolean;
  duration?: number;
}

export const useNotificationStore = defineStore('notification', () => {
  // État
  const notifications = ref<Notification[]>([]);
  const maxNotifications = ref(50); // Limite le nombre de notifications stockées

  // Getters
  const unreadNotifications = computed(() => 
    notifications.value.filter(notification => !notification.read)
  );
  
  const latestNotification = computed(() => 
    notifications.value.length > 0 ? notifications.value[0] : null
  );

  const notificationsByType = computed(() => {
    const result: Record<string, Notification[]> = {
      success: [],
      error: [],
      info: [],
      warning: []
    };
    
    notifications.value.forEach(notification => {
      result[notification.type].push(notification);
    });
    
    return result;
  });

  // Actions
  function addNotification(notification: Omit<Notification, 'id' | 'read' | 'createdAt'>) {
    const newNotification: Notification = {
      id: generateId(),
      read: false,
      createdAt: new Date(),
      autoClose: notification.autoClose !== false, // Par défaut, les notifications se ferment automatiquement
      duration: notification.duration || 5000, // Durée par défaut: 5 secondes
      ...notification
    };
    
    // Ajouter au début du tableau (pour que la plus récente soit en premier)
    notifications.value.unshift(newNotification);
    
    // Limiter le nombre de notifications stockées
    if (notifications.value.length > maxNotifications.value) {
      notifications.value = notifications.value.slice(0, maxNotifications.value);
    }
    
    // Fermer automatiquement la notification après la durée spécifiée
    if (newNotification.autoClose) {
      setTimeout(() => {
        markAsRead(newNotification.id);
      }, newNotification.duration);
    }
    
    return newNotification;
  }
  
  function success(title: string, message: string, options: Partial<Notification> = {}) {
    return addNotification({ title, message, type: 'success', ...options });
  }
  
  function error(title: string, message: string, options: Partial<Notification> = {}) {
    // Les erreurs ne se ferment pas automatiquement par défaut
    return addNotification({ 
      title, 
      message, 
      type: 'error', 
      autoClose: false,
      ...options 
    });
  }
  
  function info(title: string, message: string, options: Partial<Notification> = {}) {
    return addNotification({ title, message, type: 'info', ...options });
  }
  
  function warning(title: string, message: string, options: Partial<Notification> = {}) {
    return addNotification({ title, message, type: 'warning', ...options });
  }
  
  function markAsRead(id: string) {
    const notification = notifications.value.find(n => n.id === id);
    if (notification) {
      notification.read = true;
    }
  }
  
  function markAllAsRead() {
    notifications.value.forEach(notification => {
      notification.read = true;
    });
  }
  
  function removeNotification(id: string) {
    notifications.value = notifications.value.filter(n => n.id !== id);
  }
  
  function clearNotifications() {
    notifications.value = [];
  }
  
  // Utilitaire pour générer un ID unique
  function generateId() {
    return Date.now().toString(36) + Math.random().toString(36).substring(2);
  }

  // Retourner l'état et les méthodes
  return {
    // État
    notifications,
    maxNotifications,
    
    // Getters
    unreadNotifications,
    latestNotification,
    notificationsByType,
    
    // Actions
    addNotification,
    success,
    error,
    info,
    warning,
    markAsRead,
    markAllAsRead,
    removeNotification,
    clearNotifications
  };
});
