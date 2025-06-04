<template>
  <div class="app-container" :class="{ 'dark': isDarkMode }">
    <div class="min-h-screen bg-background-light dark:bg-background-dark transition-colors duration-300">
      <!-- Overlay pour les notifications et dialogs -->
      <div v-if="showNotification" class="notification-overlay">
        <div class="glass dark:glass-dark p-4 rounded-xl shadow-glass max-w-md mx-auto animate-float">
          <div class="flex items-center justify-between">
            <h3 class="text-lg font-semibold">{{ notification.title }}</h3>
            <button @click="closeNotification" class="text-gray-500 hover:text-gray-700 dark:text-gray-300 dark:hover:text-gray-100">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
              </svg>
            </button>
          </div>
          <p class="mt-2 text-sm">{{ notification.message }}</p>
        </div>
      </div>

      <!-- Layout principal -->
      <div class="flex h-screen overflow-hidden">
        <!-- Sidebar -->
        <aside 
          class="sidebar transition-all duration-300 ease-in-out" 
          :class="{ 'sidebar-collapsed': isSidebarCollapsed }"
        >
          <div class="h-full neu-convex dark:neu-convex-dark p-4 flex flex-col">
            <!-- Logo -->
            <div class="flex items-center justify-center mb-8">
              <img 
                v-if="!isSidebarCollapsed" 
                src="@/assets/logo/planner-suite-logo.svg" 
                alt="PLANNER Suite" 
                class="h-10"
              />
              <img 
                v-else 
                src="@/assets/logo/planner-icon.svg" 
                alt="PLANNER" 
                class="h-10 w-10"
              />
            </div>

            <!-- Navigation -->
            <nav class="flex-1">
              <ul class="space-y-2">
                <li v-for="(item, index) in navigationItems" :key="index">
                  <router-link 
                    :to="item.path" 
                    class="nav-link flex items-center p-3 rounded-xl transition-all duration-200"
                    :class="{ 
                      'active': currentRoute === item.path,
                      'justify-center': isSidebarCollapsed 
                    }"
                  >
                    <span class="icon" :class="item.iconClass">
                      <component :is="item.icon" class="h-6 w-6" />
                    </span>
                    <span v-if="!isSidebarCollapsed" class="ml-3">{{ item.name }}</span>
                  </router-link>
                </li>
              </ul>
            </nav>

            <!-- Modules -->
            <div class="mt-6">
              <h3 v-if="!isSidebarCollapsed" class="text-xs uppercase font-semibold text-gray-500 dark:text-gray-400 mb-2 px-3">
                Modules
              </h3>
              <ul class="space-y-2">
                <li v-for="(module, index) in moduleItems" :key="index">
                  <router-link 
                    :to="module.path" 
                    class="module-link flex items-center p-3 rounded-xl transition-all duration-200"
                    :class="{ 
                      'active': currentRoute === module.path,
                      'justify-center': isSidebarCollapsed,
                      [module.colorClass]: true
                    }"
                  >
                    <span class="icon">
                      <component :is="module.icon" class="h-6 w-6" />
                    </span>
                    <span v-if="!isSidebarCollapsed" class="ml-3">{{ module.name }}</span>
                  </router-link>
                </li>
              </ul>
            </div>

            <!-- Footer -->
            <div class="mt-auto pt-4">
              <div class="flex items-center justify-center">
                <button 
                  @click="toggleTheme" 
                  class="p-2 rounded-full hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors"
                >
                  <svg v-if="isDarkMode" xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-yellow-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" />
                  </svg>
                  <svg v-else xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-gray-700" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
                  </svg>
                </button>
                <button 
                  @click="toggleSidebar" 
                  class="p-2 ml-2 rounded-full hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors"
                >
                  <svg v-if="isSidebarCollapsed" xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 5l7 7-7 7M5 5l7 7-7 7" />
                  </svg>
                  <svg v-else xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 19l-7-7 7-7m8 14l-7-7 7-7" />
                  </svg>
                </button>
              </div>
            </div>
          </div>
        </aside>

        <!-- Contenu principal -->
        <main class="flex-1 overflow-x-hidden overflow-y-auto">
          <!-- Header -->
          <header class="sticky top-0 z-30 glass dark:glass-dark backdrop-blur-lg">
            <div class="flex items-center justify-between h-16 px-6">
              <!-- Titre de la page -->
              <div class="flex items-center">
                <h1 class="text-xl font-semibold">{{ pageTitle }}</h1>
              </div>

              <!-- Barre de recherche / Palette de commande -->
              <div class="flex-1 max-w-lg mx-4">
                <div class="relative">
                  <input 
                    type="text" 
                    placeholder="Rechercher ou taper une commande (⌘K)" 
                    class="w-full py-2 pl-10 pr-4 rounded-xl bg-white/50 dark:bg-gray-800/50 backdrop-blur-sm border border-gray-200 dark:border-gray-700 focus:outline-none focus:ring-2 focus:ring-primary-500"
                    @focus="openCommandPalette"
                    @keydown.meta.k.prevent="openCommandPalette"
                  />
                  <div class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                    </svg>
                  </div>
                </div>
              </div>

              <!-- Actions utilisateur -->
              <div class="flex items-center space-x-4">
                <!-- Notifications -->
                <button class="relative p-2 rounded-full hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors">
                  <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
                  </svg>
                  <span class="absolute top-0 right-0 inline-flex items-center justify-center px-2 py-1 text-xs font-bold leading-none text-white transform translate-x-1/2 -translate-y-1/2 bg-red-500 rounded-full">3</span>
                </button>

                <!-- Menu utilisateur -->
                <div class="relative">
                  <button 
                    @click="toggleUserMenu" 
                    class="flex items-center space-x-2 focus:outline-none"
                  >
                    <div class="w-10 h-10 overflow-hidden rounded-full neu-convex dark:neu-convex-dark">
                      <img 
                        src="https://i.pravatar.cc/300" 
                        alt="Avatar utilisateur" 
                        class="object-cover w-full h-full"
                      />
                    </div>
                    <span v-if="!isSidebarCollapsed" class="text-sm font-medium">David Marchand</span>
                  </button>

                  <!-- Dropdown menu -->
                  <div 
                    v-if="isUserMenuOpen" 
                    class="absolute right-0 mt-2 w-48 glass dark:glass-dark rounded-xl shadow-glass py-2 z-50"
                  >
                    <router-link to="/profile" class="block px-4 py-2 text-sm hover:bg-white/20 dark:hover:bg-gray-700/50">
                      Profil
                    </router-link>
                    <router-link to="/settings" class="block px-4 py-2 text-sm hover:bg-white/20 dark:hover:bg-gray-700/50">
                      Paramètres
                    </router-link>
                    <div class="border-t border-gray-200 dark:border-gray-700 my-1"></div>
                    <button @click="logout" class="block w-full text-left px-4 py-2 text-sm text-red-500 hover:bg-white/20 dark:hover:bg-gray-700/50">
                      Déconnexion
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </header>

          <!-- Contenu dynamique -->
          <div class="p-6">
            <router-view v-slot="{ Component }">
              <transition name="fade" mode="out-in">
                <component :is="Component" />
              </transition>
            </router-view>
          </div>
        </main>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useUserStore } from '@/stores/user';
import { useNotificationStore } from '@/stores/notification';
import { supabase } from '@/main';

// Stores
const userStore = useUserStore();
const notificationStore = useNotificationStore();
const route = useRoute();
const router = useRouter();

// État local
const isDarkMode = ref(localStorage.getItem('theme') === 'dark' || (!localStorage.getItem('theme') && window.matchMedia('(prefers-color-scheme: dark)').matches));
const isSidebarCollapsed = ref(localStorage.getItem('sidebarCollapsed') === 'true');
const isUserMenuOpen = ref(false);
const showNotification = ref(false);
const notification = ref({ title: '', message: '' });

// Computed
const currentRoute = computed(() => route.path);
const pageTitle = computed(() => {
  const routeName = route.name?.toString() || '';
  return routeName.charAt(0).toUpperCase() + routeName.slice(1);
});

// Navigation principale
const navigationItems = [
  { name: 'Tableau de bord', path: '/dashboard', icon: 'HomeIcon', iconClass: 'text-primary-500' },
  { name: 'Calendrier', path: '/calendar', icon: 'CalendarIcon', iconClass: 'text-primary-500' },
  { name: 'Équipe', path: '/team', icon: 'UsersIcon', iconClass: 'text-primary-500' },
  { name: 'Paramètres', path: '/settings', icon: 'CogIcon', iconClass: 'text-gray-500' },
];

// Modules PLANNER
const moduleItems = [
  { 
    name: 'STAGEPLANNER', 
    path: '/stageplanner', 
    icon: 'MusicNoteIcon', 
    colorClass: 'text-stageplanner-500 hover:bg-stageplanner-100 dark:hover:bg-stageplanner-900/30' 
  },
  { 
    name: 'BARPLANNER', 
    path: '/barplanner', 
    icon: 'BeakerIcon', 
    colorClass: 'text-barplanner-500 hover:bg-barplanner-100 dark:hover:bg-barplanner-900/30' 
  },
  { 
    name: 'CLEANPLANNER', 
    path: '/cleanplanner', 
    icon: 'SparklesIcon', 
    colorClass: 'text-cleanplanner-500 hover:bg-cleanplanner-100 dark:hover:bg-cleanplanner-900/30' 
  },
  { 
    name: 'SECUREPLANNER', 
    path: '/secureplanner', 
    icon: 'ShieldCheckIcon', 
    colorClass: 'text-secureplanner-500 hover:bg-secureplanner-100 dark:hover:bg-secureplanner-900/30' 
  },
  { 
    name: 'COMMERCEPLANNER', 
    path: '/commerceplanner', 
    icon: 'ShoppingBagIcon', 
    colorClass: 'text-commerceplanner-500 hover:bg-commerceplanner-100 dark:hover:bg-commerceplanner-900/30' 
  },
  { 
    name: 'FESTIVALPLANNER', 
    path: '/festivalplanner', 
    icon: 'TicketIcon', 
    colorClass: 'text-festivalplanner-500 hover:bg-festivalplanner-100 dark:hover:bg-festivalplanner-900/30' 
  },
];

// Méthodes
const toggleTheme = () => {
  isDarkMode.value = !isDarkMode.value;
  localStorage.setItem('theme', isDarkMode.value ? 'dark' : 'light');
  document.documentElement.classList.toggle('dark', isDarkMode.value);
};

const toggleSidebar = () => {
  isSidebarCollapsed.value = !isSidebarCollapsed.value;
  localStorage.setItem('sidebarCollapsed', isSidebarCollapsed.value.toString());
};

const toggleUserMenu = () => {
  isUserMenuOpen.value = !isUserMenuOpen.value;
};

const openCommandPalette = () => {
  // Implémentation de la palette de commande
  console.log('Ouverture de la palette de commande');
};

const closeNotification = () => {
  showNotification.value = false;
};

const logout = async () => {
  try {
    await supabase.auth.signOut();
    userStore.clearUser();
    router.push('/login');
  } catch (error) {
    console.error('Erreur lors de la déconnexion:', error);
  }
};

// Surveillance des notifications
watch(() => notificationStore.latestNotification, (newNotification) => {
  if (newNotification) {
    notification.value = newNotification;
    showNotification.value = true;
    setTimeout(() => {
      showNotification.value = false;
    }, 5000);
  }
});

// Fermer le menu utilisateur lors d'un clic à l'extérieur
onMounted(() => {
  document.addEventListener('click', (event) => {
    const target = event.target as HTMLElement;
    if (isUserMenuOpen.value && !target.closest('.user-menu')) {
      isUserMenuOpen.value = false;
    }
  });

  // Écouter les raccourcis clavier
  document.addEventListener('keydown', (event) => {
    if ((event.metaKey || event.ctrlKey) && event.key === 'k') {
      event.preventDefault();
      openCommandPalette();
    }
  });
});
</script>

<style scoped>
.app-container {
  @apply font-sans text-gray-900 dark:text-gray-100 antialiased;
}

.sidebar {
  @apply w-64 h-screen sticky top-0 transition-all duration-300 ease-in-out;
}

.sidebar-collapsed {
  @apply w-20;
}

.nav-link {
  @apply text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800;
}

.nav-link.active {
  @apply bg-primary-100 text-primary-700 dark:bg-primary-900/30 dark:text-primary-300;
}

.module-link.active {
  @apply bg-opacity-20 dark:bg-opacity-20;
}

.notification-overlay {
  @apply fixed top-4 right-4 z-50 max-w-md;
}

/* Transitions */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
