<template>
  <div class="dashboard">
    <!-- En-tête du tableau de bord -->
    <div class="mb-8">
      <h1 class="text-3xl font-bold mb-2">Bienvenue, {{ userFullName }}</h1>
      <p class="text-gray-600 dark:text-gray-400">
        {{ currentDateFormatted }} | {{ activeModulesCount }} modules actifs
      </p>
    </div>

    <!-- Statistiques globales -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
      <div v-for="(stat, index) in stats" :key="index" 
        class="glass dark:glass-dark p-6 rounded-xl transition-transform duration-300 hover:scale-105">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm text-gray-600 dark:text-gray-400">{{ stat.title }}</p>
            <h3 class="text-2xl font-bold mt-1">{{ stat.value }}</h3>
            <p class="text-xs mt-2" :class="stat.change > 0 ? 'text-green-500' : 'text-red-500'">
              <span v-if="stat.change > 0">+</span>{{ stat.change }}% depuis le mois dernier
            </p>
          </div>
          <div :class="`p-4 rounded-full ${stat.bgColor} bg-opacity-20`">
            <component :is="stat.icon" class="h-6 w-6" :class="stat.iconColor" />
          </div>
        </div>
      </div>
    </div>

    <!-- Contenu principal en deux colonnes -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
      <!-- Colonne de gauche (2/3) -->
      <div class="lg:col-span-2 space-y-8">
        <!-- Calendrier des événements à venir -->
        <div class="glass dark:glass-dark p-6 rounded-xl">
          <div class="flex items-center justify-between mb-6">
            <h2 class="text-xl font-semibold">Événements à venir</h2>
            <router-link to="/calendar" class="text-primary-500 hover:text-primary-700 text-sm flex items-center">
              Voir tout
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 ml-1" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd" />
              </svg>
            </router-link>
          </div>
          
          <div class="calendar-container">
            <FullCalendar 
              ref="calendarRef"
              :options="calendarOptions"
            />
          </div>
        </div>

        <!-- Modules actifs -->
        <div class="glass dark:glass-dark p-6 rounded-xl">
          <h2 class="text-xl font-semibold mb-6">Modules PLANNER</h2>
          
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div 
              v-for="module in modules" 
              :key="module.id" 
              class="neu-convex dark:neu-convex-dark p-4 rounded-xl transition-all duration-300 hover:shadow-lg"
            >
              <div class="flex items-center">
                <div :class="`p-3 rounded-full ${module.bgColor} bg-opacity-20 mr-4`">
                  <component :is="module.icon" class="h-5 w-5" :class="module.iconColor" />
                </div>
                <div>
                  <h3 class="font-semibold">{{ module.name }}</h3>
                  <p class="text-xs text-gray-600 dark:text-gray-400">{{ module.description }}</p>
                </div>
              </div>
              <div class="mt-4 flex justify-between items-center">
                <span :class="`text-xs px-2 py-1 rounded-full ${module.statusBg} ${module.statusColor}`">
                  {{ module.status }}
                </span>
                <router-link :to="module.path" class="text-sm text-primary-500 hover:text-primary-700">
                  Accéder
                </router-link>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Colonne de droite (1/3) -->
      <div class="space-y-8">
        <!-- Tâches en attente -->
        <div class="glass dark:glass-dark p-6 rounded-xl">
          <div class="flex items-center justify-between mb-6">
            <h2 class="text-xl font-semibold">Tâches en attente</h2>
            <router-link to="/lifeplanner/tasks" class="text-primary-500 hover:text-primary-700 text-sm flex items-center">
              Voir tout
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 ml-1" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd" />
              </svg>
            </router-link>
          </div>
          
          <div v-if="tasks.length > 0" class="space-y-3">
            <div 
              v-for="task in tasks" 
              :key="task.id" 
              class="flex items-center justify-between p-3 bg-white/30 dark:bg-gray-800/30 rounded-lg"
            >
              <div class="flex items-center">
                <input 
                  type="checkbox" 
                  :checked="task.completed" 
                  @change="toggleTask(task.id)" 
                  class="mr-3 h-4 w-4 text-primary-500 rounded focus:ring-primary-500"
                />
                <span :class="{ 'line-through text-gray-500': task.completed }">
                  {{ task.title }}
                </span>
              </div>
              <span 
                :class="`text-xs px-2 py-1 rounded-full ${task.priorityColor}`"
              >
                {{ task.priority }}
              </span>
            </div>
          </div>
          
          <div v-else class="text-center py-6 text-gray-500">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-12 w-12 mx-auto mb-2 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <p>Aucune tâche en attente</p>
            <button 
              @click="addNewTask" 
              class="mt-2 text-primary-500 hover:text-primary-700 text-sm"
            >
              + Ajouter une tâche
            </button>
          </div>
        </div>

        <!-- Notifications récentes -->
        <div class="glass dark:glass-dark p-6 rounded-xl">
          <h2 class="text-xl font-semibold mb-6">Notifications récentes</h2>
          
          <div v-if="recentNotifications.length > 0" class="space-y-4">
            <div 
              v-for="notification in recentNotifications" 
              :key="notification.id" 
              class="flex items-start p-3 bg-white/30 dark:bg-gray-800/30 rounded-lg"
            >
              <div :class="`p-2 rounded-full ${notification.bgColor} mr-3`">
                <component :is="notification.icon" class="h-4 w-4 text-white" />
              </div>
              <div>
                <p class="text-sm font-medium">{{ notification.title }}</p>
                <p class="text-xs text-gray-600 dark:text-gray-400">{{ notification.time }}</p>
              </div>
            </div>
          </div>
          
          <div v-else class="text-center py-6 text-gray-500">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-12 w-12 mx-auto mb-2 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
            </svg>
            <p>Aucune notification récente</p>
          </div>
        </div>

        <!-- Statistiques d'utilisation -->
        <div class="glass dark:glass-dark p-6 rounded-xl">
          <h2 class="text-xl font-semibold mb-4">Utilisation du compte</h2>
          
          <div class="mb-6">
            <div class="flex justify-between mb-1">
              <span class="text-sm font-medium">Espace de stockage</span>
              <span class="text-sm text-gray-600 dark:text-gray-400">{{ storageUsed }} / {{ storageLimit }}</span>
            </div>
            <div class="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2.5">
              <div 
                class="bg-primary-500 h-2.5 rounded-full" 
                :style="{ width: storagePercentage + '%' }"
              ></div>
            </div>
          </div>
          
          <div>
            <div class="flex justify-between mb-1">
              <span class="text-sm font-medium">Équipe</span>
              <span class="text-sm text-gray-600 dark:text-gray-400">{{ teamMembers }} / {{ teamLimit }} membres</span>
            </div>
            <div class="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2.5">
              <div 
                class="bg-barplanner-500 h-2.5 rounded-full" 
                :style="{ width: teamPercentage + '%' }"
              ></div>
            </div>
          </div>
          
          <div class="mt-6 text-center">
            <router-link 
              to="/settings/subscription" 
              class="text-sm text-primary-500 hover:text-primary-700"
            >
              Mettre à niveau vers PRO
            </router-link>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { format } from 'date-fns';
import { fr } from 'date-fns/locale';
import FullCalendar from '@fullcalendar/vue3';
import dayGridPlugin from '@fullcalendar/daygrid';
import interactionPlugin from '@fullcalendar/interaction';
import { useUserStore } from '@/stores/user';
import { supabase } from '@/main';

// Stores
const userStore = useUserStore();

// Références
const calendarRef = ref(null);

// État
const events = ref([
  {
    id: '1',
    title: 'Concert Rock',
    start: new Date(new Date().setDate(new Date().getDate() + 2)),
    end: new Date(new Date().setDate(new Date().getDate() + 2)),
    backgroundColor: '#0066ff', // STAGEPLANNER
    borderColor: '#0066ff'
  },
  {
    id: '2',
    title: 'Service Bar',
    start: new Date(new Date().setDate(new Date().getDate() + 1)),
    end: new Date(new Date().setDate(new Date().getDate() + 1)),
    backgroundColor: '#9900ff', // BARPLANNER
    borderColor: '#9900ff'
  },
  {
    id: '3',
    title: 'Entretien bureaux',
    start: new Date(new Date().setDate(new Date().getDate() + 3)),
    end: new Date(new Date().setDate(new Date().getDate() + 3)),
    backgroundColor: '#00ff40', // CLEANPLANNER
    borderColor: '#00ff40'
  }
]);

const tasks = ref([
  { id: 1, title: 'Confirmer l\'équipe technique', completed: false, priority: 'Urgent', priorityColor: 'bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-300' },
  { id: 2, title: 'Vérifier le matériel son', completed: true, priority: 'Normal', priorityColor: 'bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-300' },
  { id: 3, title: 'Envoyer planning aux intermittents', completed: false, priority: 'Élevé', priorityColor: 'bg-orange-100 text-orange-800 dark:bg-orange-900/30 dark:text-orange-300' }
]);

const recentNotifications = ref([
  { 
    id: 1, 
    title: 'Nouveau message de Jean Dupont', 
    time: 'Il y a 5 minutes',
    icon: 'ChatIcon',
    bgColor: 'bg-primary-500'
  },
  { 
    id: 2, 
    title: 'Rappel: Concert demain à 20h', 
    time: 'Il y a 30 minutes',
    icon: 'BellIcon',
    bgColor: 'bg-yellow-500'
  },
  { 
    id: 3, 
    title: 'Demande de congé approuvée', 
    time: 'Il y a 2 heures',
    icon: 'CheckCircleIcon',
    bgColor: 'bg-green-500'
  }
]);

// Options du calendrier
const calendarOptions = {
  plugins: [dayGridPlugin, interactionPlugin],
  initialView: 'dayGridWeek',
  headerToolbar: {
    left: '',
    center: '',
    right: 'prev,next'
  },
  height: 'auto',
  events: events.value,
  eventClick: handleEventClick,
  eventTimeFormat: {
    hour: '2-digit',
    minute: '2-digit',
    meridiem: false,
    hour12: false
  },
  locale: 'fr',
  dayMaxEvents: 2,
  moreLinkClick: 'day'
};

// Modules PLANNER
const modules = [
  {
    id: 'stageplanner',
    name: 'STAGEPLANNER',
    description: 'Planification spectacle vivant',
    icon: 'MusicNoteIcon',
    iconColor: 'text-stageplanner-500',
    bgColor: 'bg-stageplanner-500',
    status: 'Actif',
    statusBg: 'bg-green-100 dark:bg-green-900/30',
    statusColor: 'text-green-800 dark:text-green-300',
    path: '/stageplanner'
  },
  {
    id: 'barplanner',
    name: 'BARPLANNER',
    description: 'Gestion équipe bar & restaurant',
    icon: 'BeakerIcon',
    iconColor: 'text-barplanner-500',
    bgColor: 'bg-barplanner-500',
    status: 'Actif',
    statusBg: 'bg-green-100 dark:bg-green-900/30',
    statusColor: 'text-green-800 dark:text-green-300',
    path: '/barplanner'
  },
  {
    id: 'cleanplanner',
    name: 'CLEANPLANNER',
    description: 'Planning équipe nettoyage',
    icon: 'SparklesIcon',
    iconColor: 'text-cleanplanner-500',
    bgColor: 'bg-cleanplanner-500',
    status: 'Inactif',
    statusBg: 'bg-gray-100 dark:bg-gray-700',
    statusColor: 'text-gray-800 dark:text-gray-300',
    path: '/cleanplanner'
  },
  {
    id: 'secureplanner',
    name: 'SECUREPLANNER',
    description: 'Gestion agents de sécurité',
    icon: 'ShieldCheckIcon',
    iconColor: 'text-secureplanner-500',
    bgColor: 'bg-secureplanner-500',
    status: 'Inactif',
    statusBg: 'bg-gray-100 dark:bg-gray-700',
    statusColor: 'text-gray-800 dark:text-gray-300',
    path: '/secureplanner'
  }
];

// Statistiques
const stats = [
  { 
    title: 'Événements ce mois', 
    value: '12', 
    change: 8.2,
    icon: 'CalendarIcon',
    iconColor: 'text-primary-500',
    bgColor: 'bg-primary-500'
  },
  { 
    title: 'Membres d\'équipe', 
    value: '24', 
    change: 12.5,
    icon: 'UsersIcon',
    iconColor: 'text-barplanner-500',
    bgColor: 'bg-barplanner-500'
  },
  { 
    title: 'Tâches complétées', 
    value: '78%', 
    change: -3.4,
    icon: 'CheckCircleIcon',
    iconColor: 'text-cleanplanner-500',
    bgColor: 'bg-cleanplanner-500'
  },
  { 
    title: 'Heures planifiées', 
    value: '187', 
    change: 5.6,
    icon: 'ClockIcon',
    iconColor: 'text-secureplanner-500',
    bgColor: 'bg-secureplanner-500'
  }
];

// Utilisation du compte
const storageUsed = '2.4 Go';
const storageLimit = '5 Go';
const storagePercentage = 48;

const teamMembers = 24;
const teamLimit = 50;
const teamPercentage = (teamMembers / teamLimit) * 100;

// Computed
const userFullName = computed(() => {
  return userStore.userFullName || 'Utilisateur';
});

const currentDateFormatted = computed(() => {
  return format(new Date(), 'EEEE d MMMM yyyy', { locale: fr });
});

const activeModulesCount = computed(() => {
  return modules.filter(m => m.status === 'Actif').length;
});

// Méthodes
function handleEventClick(info) {
  console.log('Événement cliqué:', info.event);
  // Implémentation à venir: afficher les détails de l'événement
}

function toggleTask(id) {
  const task = tasks.value.find(t => t.id === id);
  if (task) {
    task.completed = !task.completed;
  }
}

function addNewTask() {
  // Implémentation à venir: ajouter une nouvelle tâche
  console.log('Ajouter une nouvelle tâche');
}

// Cycle de vie
onMounted(async () => {
  // Charger les événements depuis Supabase
  try {
    const { data, error } = await supabase
      .from('events')
      .select('*')
      .order('starts_at', { ascending: true })
      .limit(10);
    
    if (error) {
      throw error;
    }
    
    if (data && data.length > 0) {
      // Transformer les données pour FullCalendar
      const formattedEvents = data.map(event => ({
        id: event.id,
        title: event.title,
        start: event.starts_at,
        end: event.ends_at,
        backgroundColor: '#0066ff', // Par défaut STAGEPLANNER
        borderColor: '#0066ff'
      }));
      
      events.value = formattedEvents;
    }
  } catch (error) {
    console.error('Erreur lors du chargement des événements:', error);
  }
});
</script>

<style scoped>
.calendar-container {
  height: 300px;
}

/* Personnalisation du calendrier FullCalendar */
:deep(.fc) {
  --fc-border-color: rgba(209, 213, 219, 0.3);
  --fc-today-bg-color: rgba(0, 102, 255, 0.1);
  --fc-event-border-color: transparent;
  --fc-event-text-color: #fff;
  --fc-page-bg-color: transparent;
}

:deep(.fc-theme-standard td), :deep(.fc-theme-standard th) {
  border-color: var(--fc-border-color);
}

:deep(.fc-theme-standard .fc-scrollgrid) {
  border-color: var(--fc-border-color);
}

:deep(.fc-col-header-cell) {
  padding: 8px 0;
}

:deep(.fc-daygrid-day-number) {
  padding: 8px;
  font-weight: 500;
}

:deep(.fc-event) {
  border-radius: 4px;
  padding: 2px 4px;
  font-size: 0.8rem;
}

/* Animation pour les cartes */
.glass, .neu-convex, .neu-convex-dark {
  transition: all 0.3s ease;
}

.glass:hover, .neu-convex:hover, .neu-convex-dark:hover {
  transform: translateY(-5px);
}
</style>
