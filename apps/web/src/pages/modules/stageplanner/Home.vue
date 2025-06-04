<template>
  <div class="stageplanner-home">
    <!-- En-tête du module STAGEPLANNER -->
    <div class="mb-8">
      <div class="flex flex-col md:flex-row md:items-center md:justify-between">
        <div>
          <h1 class="text-3xl font-bold mb-2 text-stageplanner-600 dark:text-stageplanner-400">
            STAGEPLANNER
          </h1>
          <p class="text-gray-600 dark:text-gray-400">
            Planification et gestion des événements de spectacle vivant
          </p>
        </div>
        <div class="mt-4 md:mt-0 flex space-x-3">
          <button 
            @click="openCreateEventModal" 
            class="btn-primary flex items-center px-4 py-2 bg-stageplanner-500 hover:bg-stageplanner-600 text-white rounded-xl transition-colors"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M10 5a1 1 0 011 1v3h3a1 1 0 110 2h-3v3a1 1 0 11-2 0v-3H6a1 1 0 110-2h3V6a1 1 0 011-1z" clip-rule="evenodd" />
            </svg>
            Nouvel événement
          </button>
          <button 
            @click="openInviteTeamModal" 
            class="btn-secondary flex items-center px-4 py-2 bg-white dark:bg-gray-800 border border-stageplanner-500 text-stageplanner-500 dark:text-stageplanner-400 rounded-xl hover:bg-stageplanner-50 dark:hover:bg-gray-700 transition-colors"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" viewBox="0 0 20 20" fill="currentColor">
              <path d="M9 6a3 3 0 11-6 0 3 3 0 016 0zM17 6a3 3 0 11-6 0 3 3 0 016 0zM12.93 17c.046-.327.07-.66.07-1a6.97 6.97 0 00-1.5-4.33A5 5 0 0119 16v1h-6.07zM6 11a5 5 0 015 5v1H1v-1a5 5 0 015-5z" />
            </svg>
            Convoquer équipe
          </button>
        </div>
      </div>
    </div>

    <!-- Statistiques rapides -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
      <div 
        v-for="(stat, index) in stats" 
        :key="index" 
        class="glass dark:glass-dark p-6 rounded-xl transition-transform duration-300 hover:scale-105"
      >
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm text-gray-600 dark:text-gray-400">{{ stat.title }}</p>
            <h3 class="text-2xl font-bold mt-1">{{ stat.value }}</h3>
            <p class="text-xs mt-2" :class="stat.change > 0 ? 'text-green-500' : 'text-red-500'">
              <span v-if="stat.change > 0">+</span>{{ stat.change }}% depuis le mois dernier
            </p>
          </div>
          <div class="p-4 rounded-full bg-stageplanner-100 dark:bg-stageplanner-900/30">
            <component :is="stat.icon" class="h-6 w-6 text-stageplanner-500 dark:text-stageplanner-400" />
          </div>
        </div>
      </div>
    </div>

    <!-- Calendrier principal -->
    <div class="glass dark:glass-dark p-6 rounded-xl mb-8">
      <div class="flex items-center justify-between mb-6">
        <div class="flex items-center">
          <h2 class="text-xl font-semibold">Calendrier des événements</h2>
          <div class="ml-4 flex space-x-2">
            <button 
              v-for="view in calendarViews" 
              :key="view.value" 
              @click="changeCalendarView(view.value)" 
              class="px-3 py-1 text-sm rounded-lg transition-colors"
              :class="currentView === view.value ? 'bg-stageplanner-100 dark:bg-stageplanner-900/30 text-stageplanner-700 dark:text-stageplanner-300' : 'hover:bg-gray-100 dark:hover:bg-gray-800'"
            >
              {{ view.label }}
            </button>
          </div>
        </div>
        <div class="flex items-center space-x-2">
          <button 
            @click="today" 
            class="px-3 py-1 text-sm bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors"
          >
            Aujourd'hui
          </button>
          <button 
            @click="prev" 
            class="p-1 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z" clip-rule="evenodd" />
            </svg>
          </button>
          <button 
            @click="next" 
            class="p-1 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd" />
            </svg>
          </button>
        </div>
      </div>
      
      <div class="calendar-container">
        <FullCalendar 
          ref="calendarRef"
          :options="calendarOptions"
        />
      </div>
    </div>

    <!-- Contenu en deux colonnes -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
      <!-- Colonne de gauche (2/3) -->
      <div class="lg:col-span-2 space-y-8">
        <!-- Événements à venir -->
        <div class="glass dark:glass-dark p-6 rounded-xl">
          <div class="flex items-center justify-between mb-6">
            <h2 class="text-xl font-semibold">Événements à venir</h2>
            <router-link 
              to="/stageplanner/events" 
              class="text-stageplanner-500 hover:text-stageplanner-700 text-sm flex items-center"
            >
              Voir tout
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 ml-1" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd" />
              </svg>
            </router-link>
          </div>
          
          <div v-if="upcomingEvents.length > 0" class="space-y-4">
            <div 
              v-for="event in upcomingEvents" 
              :key="event.id" 
              class="neu-convex dark:neu-convex-dark p-4 rounded-xl hover:shadow-lg transition-shadow cursor-pointer"
              @click="viewEventDetails(event.id)"
            >
              <div class="flex items-center justify-between">
                <div class="flex items-center">
                  <div class="w-2 h-12 bg-stageplanner-500 rounded-full mr-4"></div>
                  <div>
                    <h3 class="font-semibold">{{ event.title }}</h3>
                    <p class="text-sm text-gray-600 dark:text-gray-400">
                      {{ formatEventDate(event.start) }} • {{ event.location }}
                    </p>
                  </div>
                </div>
                <div class="text-right">
                  <span 
                    :class="`px-2 py-1 text-xs rounded-full ${event.statusClass}`"
                  >
                    {{ event.status }}
                  </span>
                  <p class="text-sm mt-1">{{ event.teamCount }} personnes</p>
                </div>
              </div>
            </div>
          </div>
          
          <div v-else class="text-center py-8 text-gray-500">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-12 w-12 mx-auto mb-2 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
            </svg>
            <p>Aucun événement à venir</p>
            <button 
              @click="openCreateEventModal" 
              class="mt-2 text-stageplanner-500 hover:text-stageplanner-700 text-sm"
            >
              + Créer un événement
            </button>
          </div>
        </div>

        <!-- Équipes récentes -->
        <div class="glass dark:glass-dark p-6 rounded-xl">
          <div class="flex items-center justify-between mb-6">
            <h2 class="text-xl font-semibold">Équipes récentes</h2>
            <router-link 
              to="/stageplanner/team" 
              class="text-stageplanner-500 hover:text-stageplanner-700 text-sm flex items-center"
            >
              Voir tout
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 ml-1" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd" />
              </svg>
            </router-link>
          </div>
          
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div 
              v-for="team in recentTeams" 
              :key="team.id" 
              class="neu-convex dark:neu-convex-dark p-4 rounded-xl hover:shadow-lg transition-shadow"
            >
              <div class="flex items-center justify-between">
                <div>
                  <h3 class="font-semibold">{{ team.name }}</h3>
                  <p class="text-sm text-gray-600 dark:text-gray-400">{{ team.memberCount }} membres</p>
                </div>
                <div class="flex -space-x-2">
                  <div 
                    v-for="(member, idx) in team.members.slice(0, 3)" 
                    :key="idx" 
                    class="w-8 h-8 rounded-full border-2 border-white dark:border-gray-800 overflow-hidden"
                  >
                    <img 
                      :src="member.avatar" 
                      :alt="member.name" 
                      class="w-full h-full object-cover"
                    />
                  </div>
                  <div 
                    v-if="team.members.length > 3" 
                    class="w-8 h-8 rounded-full bg-stageplanner-100 dark:bg-stageplanner-900/30 text-stageplanner-500 dark:text-stageplanner-400 flex items-center justify-center text-xs border-2 border-white dark:border-gray-800"
                  >
                    +{{ team.members.length - 3 }}
                  </div>
                </div>
              </div>
              <div class="mt-3 flex justify-end">
                <button 
                  @click="viewTeamDetails(team.id)" 
                  class="text-sm text-stageplanner-500 hover:text-stageplanner-700"
                >
                  Voir détails
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Colonne de droite (1/3) -->
      <div class="space-y-8">
        <!-- Actions rapides -->
        <div class="glass dark:glass-dark p-6 rounded-xl">
          <h2 class="text-xl font-semibold mb-4">Actions rapides</h2>
          
          <div class="space-y-3">
            <button 
              v-for="action in quickActions" 
              :key="action.id" 
              @click="action.action" 
              class="w-full flex items-center p-3 rounded-xl text-left bg-white/50 dark:bg-gray-800/50 hover:bg-white dark:hover:bg-gray-700 transition-colors"
            >
              <div :class="`p-2 rounded-full ${action.bgColor} mr-3`">
                <component :is="action.icon" class="h-5 w-5 text-white" />
              </div>
              <span>{{ action.label }}</span>
            </button>
          </div>
        </div>

        <!-- Intermittents disponibles -->
        <div class="glass dark:glass-dark p-6 rounded-xl">
          <div class="flex items-center justify-between mb-6">
            <h2 class="text-xl font-semibold">Intermittents disponibles</h2>
            <button 
              @click="viewAllIntermittents" 
              class="text-stageplanner-500 hover:text-stageplanner-700 text-sm flex items-center"
            >
              Voir tout
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 ml-1" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd" />
              </svg>
            </button>
          </div>
          
          <div v-if="availableIntermittents.length > 0" class="space-y-3">
            <div 
              v-for="person in availableIntermittents" 
              :key="person.id" 
              class="flex items-center justify-between p-3 bg-white/30 dark:bg-gray-800/30 rounded-lg hover:bg-white/50 dark:hover:bg-gray-700/50 transition-colors"
            >
              <div class="flex items-center">
                <div class="w-10 h-10 rounded-full overflow-hidden mr-3">
                  <img 
                    :src="person.avatar" 
                    :alt="person.name" 
                    class="w-full h-full object-cover"
                  />
                </div>
                <div>
                  <h3 class="font-medium">{{ person.name }}</h3>
                  <p class="text-xs text-gray-600 dark:text-gray-400">{{ person.specialty }}</p>
                </div>
              </div>
              <button 
                @click="inviteIntermittent(person.id)" 
                class="p-2 text-stageplanner-500 hover:bg-stageplanner-50 dark:hover:bg-stageplanner-900/20 rounded-full transition-colors"
              >
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                  <path d="M8 9a3 3 0 100-6 3 3 0 000 6zM8 11a6 6 0 016 6H2a6 6 0 016-6zM16 7a1 1 0 10-2 0v1h-1a1 1 0 100 2h1v1a1 1 0 102 0v-1h1a1 1 0 100-2h-1V7z" />
                </svg>
              </button>
            </div>
          </div>
          
          <div v-else class="text-center py-6 text-gray-500">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-12 w-12 mx-auto mb-2 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
            </svg>
            <p>Aucun intermittent disponible</p>
            <button 
              @click="addNewIntermittent" 
              class="mt-2 text-stageplanner-500 hover:text-stageplanner-700 text-sm"
            >
              + Ajouter un intermittent
            </button>
          </div>
        </div>

        <!-- Dernières activités -->
        <div class="glass dark:glass-dark p-6 rounded-xl">
          <h2 class="text-xl font-semibold mb-4">Dernières activités</h2>
          
          <div class="relative">
            <!-- Timeline line -->
            <div class="absolute top-0 bottom-0 left-4 w-0.5 bg-gray-200 dark:bg-gray-700"></div>
            
            <!-- Timeline items -->
            <div class="space-y-6 relative">
              <div 
                v-for="activity in recentActivities" 
                :key="activity.id" 
                class="ml-10 relative"
              >
                <!-- Timeline dot -->
                <div 
                  class="absolute -left-10 mt-1.5 w-4 h-4 rounded-full border-2 border-white dark:border-gray-800"
                  :class="activity.dotColor"
                ></div>
                
                <p class="text-sm">
                  <span class="font-medium">{{ activity.user }}</span>
                  <span class="text-gray-600 dark:text-gray-400">{{ activity.action }}</span>
                  <span class="font-medium">{{ activity.target }}</span>
                </p>
                <span class="text-xs text-gray-500">{{ activity.time }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal pour créer un événement -->
    <div v-if="showCreateEventModal" class="fixed inset-0 z-50 overflow-y-auto">
      <div class="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
        <div class="fixed inset-0 transition-opacity" @click="showCreateEventModal = false">
          <div class="absolute inset-0 bg-gray-500 dark:bg-gray-900 opacity-75"></div>
        </div>

        <div class="inline-block align-bottom glass dark:glass-dark rounded-xl text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full">
          <div class="px-6 pt-5 pb-4">
            <div class="flex items-center justify-between mb-4">
              <h3 class="text-lg font-medium text-stageplanner-600 dark:text-stageplanner-400">
                Créer un nouvel événement
              </h3>
              <button @click="showCreateEventModal = false" class="text-gray-500 hover:text-gray-700 dark:text-gray-300 dark:hover:text-gray-100">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
            
            <!-- Formulaire de création d'événement -->
            <form @submit.prevent="createEvent">
              <div class="space-y-4">
                <div>
                  <label for="event-title" class="block text-sm font-medium text-gray-700 dark:text-gray-300">
                    Titre de l'événement
                  </label>
                  <input 
                    id="event-title" 
                    v-model="newEvent.title" 
                    type="text" 
                    class="mt-1 block w-full rounded-md bg-white/50 dark:bg-gray-800/50 border border-gray-300 dark:border-gray-700 focus:border-stageplanner-500 focus:ring focus:ring-stageplanner-500 focus:ring-opacity-50"
                    placeholder="Concert, spectacle, répétition..."
                    required
                  />
                </div>
                
                <div class="grid grid-cols-2 gap-4">
                  <div>
                    <label for="event-start" class="block text-sm font-medium text-gray-700 dark:text-gray-300">
                      Date de début
                    </label>
                    <input 
                      id="event-start" 
                      v-model="newEvent.start" 
                      type="datetime-local" 
                      class="mt-1 block w-full rounded-md bg-white/50 dark:bg-gray-800/50 border border-gray-300 dark:border-gray-700 focus:border-stageplanner-500 focus:ring focus:ring-stageplanner-500 focus:ring-opacity-50"
                      required
                    />
                  </div>
                  <div>
                    <label for="event-end" class="block text-sm font-medium text-gray-700 dark:text-gray-300">
                      Date de fin
                    </label>
                    <input 
                      id="event-end" 
                      v-model="newEvent.end" 
                      type="datetime-local" 
                      class="mt-1 block w-full rounded-md bg-white/50 dark:bg-gray-800/50 border border-gray-300 dark:border-gray-700 focus:border-stageplanner-500 focus:ring focus:ring-stageplanner-500 focus:ring-opacity-50"
                      required
                    />
                  </div>
                </div>
                
                <div>
                  <label for="event-location" class="block text-sm font-medium text-gray-700 dark:text-gray-300">
                    Lieu
                  </label>
                  <input 
                    id="event-location" 
                    v-model="newEvent.location" 
                    type="text" 
                    class="mt-1 block w-full rounded-md bg-white/50 dark:bg-gray-800/50 border border-gray-300 dark:border-gray-700 focus:border-stageplanner-500 focus:ring focus:ring-stageplanner-500 focus:ring-opacity-50"
                    placeholder="Nom de la salle, adresse..."
                    required
                  />
                </div>
                
                <div>
                  <label for="event-description" class="block text-sm font-medium text-gray-700 dark:text-gray-300">
                    Description
                  </label>
                  <textarea 
                    id="event-description" 
                    v-model="newEvent.description" 
                    rows="3" 
                    class="mt-1 block w-full rounded-md bg-white/50 dark:bg-gray-800/50 border border-gray-300 dark:border-gray-700 focus:border-stageplanner-500 focus:ring focus:ring-stageplanner-500 focus:ring-opacity-50"
                    placeholder="Informations complémentaires..."
                  ></textarea>
                </div>
                
                <div>
                  <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">
                    Spécialités requises
                  </label>
                  <div class="mt-2 flex flex-wrap gap-2">
                    <div 
                      v-for="specialty in specialties" 
                      :key="specialty.id" 
                      @click="toggleSpecialty(specialty.id)" 
                      class="px-3 py-1 rounded-full text-sm cursor-pointer transition-colors"
                      :class="newEvent.selectedSpecialties.includes(specialty.id) 
                        ? 'bg-stageplanner-100 dark:bg-stageplanner-900/30 text-stageplanner-700 dark:text-stageplanner-300 border-2 border-stageplanner-500' 
                        : 'bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-700'"
                    >
                      {{ specialty.name }}
                    </div>
                  </div>
                </div>
              </div>
              
              <div class="mt-6 flex justify-end space-x-3">
                <button 
                  type="button" 
                  @click="showCreateEventModal = false" 
                  class="px-4 py-2 bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-xl text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors"
                >
                  Annuler
                </button>
                <button 
                  type="submit" 
                  class="px-4 py-2 bg-stageplanner-500 hover:bg-stageplanner-600 text-white rounded-xl transition-colors"
                >
                  Créer l'événement
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal pour convoquer une équipe -->
    <div v-if="showInviteTeamModal" class="fixed inset-0 z-50 overflow-y-auto">
      <!-- Contenu du modal similaire à celui de création d'événement -->
      <!-- À implémenter selon les besoins -->
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { format } from 'date-fns';
import { fr } from 'date-fns/locale';
import FullCalendar from '@fullcalendar/vue3';
import dayGridPlugin from '@fullcalendar/daygrid';
import timeGridPlugin from '@fullcalendar/timegrid';
import listPlugin from '@fullcalendar/list';
import interactionPlugin from '@fullcalendar/interaction';
import resourceTimelinePlugin from '@fullcalendar/resource-timeline';
import { useUserStore } from '@/stores/user';
import { useNotificationStore } from '@/stores/notification';
import { supabase } from '@/main';

// Stores
const userStore = useUserStore();
const notificationStore = useNotificationStore();

// Références
const calendarRef = ref(null);

// État
const currentView = ref('dayGridWeek');
const showCreateEventModal = ref(false);
const showInviteTeamModal = ref(false);

// Nouveau événement
const newEvent = ref({
  title: '',
  start: '',
  end: '',
  location: '',
  description: '',
  selectedSpecialties: [] as number[]
});

// Vues du calendrier
const calendarViews = [
  { label: 'Mois', value: 'dayGridMonth' },
  { label: 'Semaine', value: 'dayGridWeek' },
  { label: 'Jour', value: 'timeGridDay' },
  { label: 'Liste', value: 'listWeek' },
  { label: 'Timeline', value: 'resourceTimelineWeek' }
];

// Options du calendrier
const calendarOptions = {
  plugins: [
    dayGridPlugin,
    timeGridPlugin,
    listPlugin,
    interactionPlugin,
    resourceTimelinePlugin
  ],
  initialView: currentView.value,
  headerToolbar: false, // On gère notre propre toolbar
  events: [], // Sera rempli depuis Supabase
  editable: true,
  selectable: true,
  selectMirror: true,
  dayMaxEvents: true,
  weekends: true,
  firstDay: 1, // Lundi
  locale: 'fr',
  eventTimeFormat: {
    hour: '2-digit',
    minute: '2-digit',
    meridiem: false,
    hour12: false
  },
  slotLabelFormat: {
    hour: '2-digit',
    minute: '2-digit',
    meridiem: false,
    hour12: false
  },
  allDayText: 'Journée entière',
  eventColor: '#0066ff', // STAGEPLANNER color
  select: handleDateSelect,
  eventClick: handleEventClick,
  eventsSet: handleEvents,
  eventDrop: handleEventDrop,
  eventResize: handleEventResize,
  resourceAreaHeaderContent: 'Équipes',
  resources: [] // Sera rempli avec les équipes
};

// Données mockées pour le prototype
const upcomingEvents = ref([
  {
    id: 1,
    title: 'Concert Rock - Les Indomptables',
    start: new Date(new Date().setDate(new Date().getDate() + 2)),
    end: new Date(new Date().setDate(new Date().getDate() + 2)),
    location: 'Salle Olympia',
    status: 'Confirmé',
    statusClass: 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300',
    teamCount: 8
  },
  {
    id: 2,
    title: 'Répétition Générale - Théâtre Municipal',
    start: new Date(new Date().setDate(new Date().getDate() + 1)),
    end: new Date(new Date().setDate(new Date().getDate() + 1)),
    location: 'Théâtre Municipal',
    status: 'En attente',
    statusClass: 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-300',
    teamCount: 5
  },
  {
    id: 3,
    title: 'Festival Jazz - Scène principale',
    start: new Date(new Date().setDate(new Date().getDate() + 5)),
    end: new Date(new Date().setDate(new Date().getDate() + 7)),
    location: 'Parc des Expositions',
    status: 'À compléter',
    statusClass: 'bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-300',
    teamCount: 12
  }
]);

const recentTeams = ref([
  {
    id: 1,
    name: 'Équipe Son',
    memberCount: 5,
    members: [
      { name: 'Jean Dupont', avatar: 'https://i.pravatar.cc/150?img=1' },
      { name: 'Marie Martin', avatar: 'https://i.pravatar.cc/150?img=2' },
      { name: 'Pierre Durand', avatar: 'https://i.pravatar.cc/150?img=3' },
      { name: 'Sophie Lefebvre', avatar: 'https://i.pravatar.cc/150?img=4' },
      { name: 'Thomas Bernard', avatar: 'https://i.pravatar.cc/150?img=5' }
    ]
  },
  {
    id: 2,
    name: 'Équipe Lumière',
    memberCount: 4,
    members: [
      { name: 'Lucie Moreau', avatar: 'https://i.pravatar.cc/150?img=6' },
      { name: 'Nicolas Petit', avatar: 'https://i.pravatar.cc/150?img=7' },
      { name: 'Camille Robert', avatar: 'https://i.pravatar.cc/150?img=8' },
      { name: 'Alexandre Simon', avatar: 'https://i.pravatar.cc/150?img=9' }
    ]
  },
  {
    id: 3,
    name: 'Équipe Plateau',
    memberCount: 3,
    members: [
      { name: 'Julie Dubois', avatar: 'https://i.pravatar.cc/150?img=10' },
      { name: 'Maxime Leroy', avatar: 'https://i.pravatar.cc/150?img=11' },
      { name: 'Emma Girard', avatar: 'https://i.pravatar.cc/150?img=12' }
    ]
  },
  {
    id: 4,
    name: 'Équipe Régie',
    memberCount: 2,
    members: [
      { name: 'Antoine Fournier', avatar: 'https://i.pravatar.cc/150?img=13' },
      { name: 'Chloé Mercier', avatar: 'https://i.pravatar.cc/150?img=14' }
    ]
  }
]);

const availableIntermittents = ref([
  {
    id: 1,
    name: 'Julien Lambert',
    specialty: 'Ingénieur Son',
    avatar: 'https://i.pravatar.cc/150?img=15'
  },
  {
    id: 2,
    name: 'Émilie Rousseau',
    specialty: 'Éclairagiste',
    avatar: 'https://i.pravatar.cc/150?img=16'
  },
  {
    id: 3,
    name: 'Romain Blanc',
    specialty: 'Technicien Plateau',
    avatar: 'https://i.pravatar.cc/150?img=17'
  }
]);

const recentActivities = ref([
  {
    id: 1,
    user: 'David Marchand',
    action: ' a créé l\'événement ',
    target: 'Concert Rock - Les Indomptables',
    time: 'Il y a 2 heures',
    dotColor: 'bg-stageplanner-500'
  },
  {
    id: 2,
    user: 'Marie Martin',
    action: ' a confirmé sa disponibilité pour ',
    target: 'Festival Jazz',
    time: 'Il y a 3 heures',
    dotColor: 'bg-green-500'
  },
  {
    id: 3,
    user: 'Pierre Durand',
    action: ' a décliné sa disponibilité pour ',
    target: 'Répétition Générale',
    time: 'Il y a 5 heures',
    dotColor: 'bg-red-500'
  },
  {
    id: 4,
    user: 'David Marchand',
    action: ' a ajouté ',
    target: 'Julien Lambert à l\'équipe Son',
    time: 'Il y a 1 jour',
    dotColor: 'bg-blue-500'
  }
]);

const stats = [
  { 
    title: 'Événements ce mois', 
    value: '8', 
    change: 12.5,
    icon: 'CalendarIcon'
  },
  { 
    title: 'Intermittents actifs', 
    value: '14', 
    change: 8.3,
    icon: 'UsersIcon'
  },
  { 
    title: 'Taux de réponse', 
    value: '92%', 
    change: 4.2,
    icon: 'CheckCircleIcon'
  },
  { 
    title: 'Heures planifiées', 
    value: '156', 
    change: -2.5,
    icon: 'ClockIcon'
  }
];

const quickActions = [
  {
    id: 1,
    label: 'Créer un événement',
    icon: 'CalendarIcon',
    bgColor: 'bg-stageplanner-500',
    action: openCreateEventModal
  },
  {
    id: 2,
    label: 'Ajouter un intermittent',
    icon: 'UserAddIcon',
    bgColor: 'bg-barplanner-500',
    action: addNewIntermittent
  },
  {
    id: 3,
    label: 'Créer une équipe',
    icon: 'UserGroupIcon',
    bgColor: 'bg-cleanplanner-500',
    action: createTeam
  },
  {
    id: 4,
    label: 'Envoyer un message groupé',
    icon: 'MailIcon',
    bgColor: 'bg-secureplanner-500',
    action: sendGroupMessage
  }
];

const specialties = [
  { id: 1, name: 'Son' },
  { id: 2, name: 'Lumière' },
  { id: 3, name: 'Plateau' },
  { id: 4, name: 'Régie' },
  { id: 5, name: 'Vidéo' },
  { id: 6, name: 'Décors' },
  { id: 7, name: 'Costumes' },
  { id: 8, name: 'Maquillage' }
];

// Méthodes
function changeCalendarView(view) {
  currentView.value = view;
  const calendarApi = calendarRef.value.getApi();
  calendarApi.changeView(view);
}

function today() {
  const calendarApi = calendarRef.value.getApi();
  calendarApi.today();
}

function prev() {
  const calendarApi = calendarRef.value.getApi();
  calendarApi.prev();
}

function next() {
  const calendarApi = calendarRef.value.getApi();
  calendarApi.next();
}

function handleDateSelect(selectInfo) {
  newEvent.value.start = formatDateForInput(selectInfo.start);
  newEvent.value.end = formatDateForInput(selectInfo.end);
  showCreateEventModal.value = true;
}

function handleEventClick(clickInfo) {
  viewEventDetails(clickInfo.event.id);
}

function handleEvents(events) {
  // Mise à jour des événements si nécessaire
  console.log('Events updated:', events);
}

function handleEventDrop(dropInfo) {
  // Gérer le déplacement d'un événement
  console.log('Event dropped:', dropInfo.event);
  updateEvent(dropInfo.event);
}

function handleEventResize(resizeInfo) {
  // Gérer le redimensionnement d'un événement
  console.log('Event resized:', resizeInfo.event);
  updateEvent(resizeInfo.event);
}

function formatDateForInput(date) {
  const d = new Date(date);
  const year = d.getFullYear();
  const month = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  const hours = String(d.getHours()).padStart(2, '0');
  const minutes = String(d.getMinutes()).padStart(2, '0');
  
  return `${year}-${month}-${day}T${hours}:${minutes}`;
}

function formatEventDate(date) {
  return format(new Date(date), 'EEEE d MMMM yyyy à HH:mm', { locale: fr });
}

function openCreateEventModal() {
  // Réinitialiser le formulaire
  newEvent.value = {
    title: '',
    start: formatDateForInput(new Date()),
    end: formatDateForInput(new Date(new Date().getTime() + 2 * 60 * 60 * 1000)), // +2h par défaut
    location: '',
    description: '',
    selectedSpecialties: []
  };
  
  showCreateEventModal.value = true;
}

function openInviteTeamModal() {
  showInviteTeamModal.value = true;
}

function toggleSpecialty(id) {
  const index = newEvent.value.selectedSpecialties.indexOf(id);
  if (index === -1) {
    newEvent.value.selectedSpecialties.push(id);
  } else {
    newEvent.value.selectedSpecialties.splice(index, 1);
  }
}

async function createEvent() {
  try {
    // Convertir les dates en objets Date
    const startDate = new Date(newEvent.value.start);
    const endDate = new Date(newEvent.value.end);
    
    // Préparer l'objet événement pour Supabase
    const eventData = {
      title: newEvent.value.title,
      starts_at: startDate.toISOString(),
      ends_at: endDate.toISOString(),
      location: newEvent.value.location,
      description: newEvent.value.description,
      specialties: newEvent.value.selectedSpecialties,
      organisation_id: userStore.profile?.organisation_id,
      created_by: userStore.user?.id,
      created_at: new Date().toISOString(),
      status: 'draft'
    };
    
    // Enregistrer dans Supabase
    const { data, error } = await supabase
      .from('events')
      .insert(eventData)
      .select();
    
    if (error) {
      throw error;
    }
    
    // Ajouter l'événement au calendrier
    if (data && data.length > 0) {
      const newCalendarEvent = {
        id: data[0].id,
        title: data[0].title,
        start: data[0].starts_at,
        end: data[0].ends_at,
        backgroundColor: '#0066ff', // STAGEPLANNER color
        borderColor: '#0066ff'
      };
      
      const calendarApi = calendarRef.value.getApi();
      calendarApi.addEvent(newCalendarEvent);
      
      // Ajouter à la liste des événements à venir
      upcomingEvents.value.unshift({
        id: data[0].id,
        title: data[0].title,
        start: new Date(data[0].starts_at),
        end: new Date(data[0].ends_at),
        location: data[0].location,
        status: 'À compléter',
        statusClass: 'bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-300',
        teamCount: 0
      });
      
      // Notification de succès
      notificationStore.success(
        'Événement créé',
        `L'événement "${data[0].title}" a été créé avec succès.`
      );
    }
    
    // Fermer le modal
    showCreateEventModal.value = false;
  } catch (error) {
    console.error('Erreur lors de la création de l\'événement:', error);
    notificationStore.error(
      'Erreur',
      'Une erreur est survenue lors de la création de l\'événement.'
    );
  }
}

async function updateEvent(event) {
  try {
    // Préparer les données à mettre à jour
    const eventData = {
      starts_at: event.start.toISOString(),
      ends_at: event.end ? event.end.toISOString() : event.start.toISOString(),
      updated_at: new Date().toISOString()
    };
    
    // Mettre à jour dans Supabase
    const { error } = await supabase
      .from('events')
      .update(eventData)
      .eq('id', event.id);
    
    if (error) {
      throw error;
    }
    
    // Notification de succès
    notificationStore.success(
      'Événement mis à jour',
      `L'événement "${event.title}" a été mis à jour.`
    );
  } catch (error) {
    console.error('Erreur lors de la mise à jour de l\'événement:', error);
    notificationStore.error(
      'Erreur',
      'Une erreur est survenue lors de la mise à jour de l\'événement.'
    );
    
    // Annuler le changement dans le calendrier
    const calendarApi = calendarRef.value.getApi();
    calendarApi.refetchEvents();
  }
}

function viewEventDetails(id) {
  // Rediriger vers la page de détail de l'événement
  console.log('Voir les détails de l\'événement:', id);
  // router.push(`/stageplanner/events/${id}`);
}

function viewTeamDetails(id) {
  // Rediriger vers la page de détail de l'équipe
  console.log('Voir les détails de l\'équipe:', id);
  // router.push(`/stageplanner/team/${id}`);
}

function addNewIntermittent() {
  // Rediriger vers la page d'ajout d'intermittent
  console.log('Ajouter un nouvel intermittent');
  // router.push('/stageplanner/team/add');
}

function createTeam() {
  // Ouvrir un modal pour créer une équipe
  console.log('Créer une nouvelle équipe');
}

function sendGroupMessage() {
  // Ouvrir un modal pour envoyer un message groupé
  console.log('Envoyer un message groupé');
}

function inviteIntermittent(id) {
  // Ouvrir un modal pour inviter un intermittent à un événement
  console.log('Inviter l\'intermittent:', id);
}

function viewAllIntermittents() {
  // Rediriger vers la page de tous les intermittents
  console.log('Voir tous les intermittents');
  // router.push('/stageplanner/team');
}

// Cycle de vie
onMounted(async () => {
  // Charger les événements depuis Supabase
  try {
    const { data, error } = await supabase
      .from('events')
      .select('*')
      .order('starts_at', { ascending: true });
    
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
        backgroundColor: '#0066ff', // STAGEPLANNER color
        borderColor: '#0066ff'
      }));
      
      // Mettre à jour les options du calendrier
      calendarOptions.events = formattedEvents;
    }
  } catch (error) {
    console.error('Erreur lors du chargement des événements:', error);
    notificationStore.error(
      'Erreur',
      'Une erreur est survenue lors du chargement des événements.'
    );
  }
});
</script>

<style scoped>
.calendar-container {
  height: 600px;
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
  cursor: pointer;
  transition: transform 0.2s ease;
}

:deep(.fc-event:hover) {
  transform: translateY(-1px);
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
}

:deep(.fc-timegrid-slot) {
  height: 40px !important;
}

:deep(.fc-list-event-title) {
  font-weight: 500;
}

/* Animation pour les cartes */
.glass, .neu-convex, .neu-convex-dark {
  transition: all 0.3s ease;
}

.glass:hover, .neu-convex:hover, .neu-convex-dark:hover {
  transform: translateY(-2px);
}
</style>
