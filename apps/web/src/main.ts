import { createApp } from 'vue';
import { createPinia } from 'pinia';
import { createClient } from '@supabase/supabase-js';
import { VueQueryPlugin } from '@tanstack/vue-query';
import { createRouter, createWebHistory } from 'vue-router';

// Importation des styles globaux
import './assets/styles/main.css';
import './assets/styles/tailwind.css';

// Importation du composant racine
import App from './App.vue';

// Importation des routes
import { routes } from './router';

// Configuration de Supabase
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Les variables d\'environnement Supabase ne sont pas définies. Vérifiez votre fichier .env');
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true
  },
  realtime: {
    params: {
      eventsPerSecond: 10
    }
  }
});

// Création du router
const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior(to, from, savedPosition) {
    if (savedPosition) {
      return savedPosition;
    } else {
      return { top: 0 };
    }
  }
});

// Protection des routes qui nécessitent une authentification
router.beforeEach(async (to, from, next) => {
  const { data: { session } } = await supabase.auth.getSession();
  const requiresAuth = to.matched.some(record => record.meta.requiresAuth);
  
  if (requiresAuth && !session) {
    next({ name: 'login', query: { redirect: to.fullPath } });
  } else if (to.path === '/login' && session) {
    next({ name: 'dashboard' });
  } else {
    next();
  }
});

// Création de l'application
const app = createApp(App);

// Configuration du store Pinia
const pinia = createPinia();
app.use(pinia);

// Configuration du router
app.use(router);

// Configuration de Vue Query pour les requêtes API
app.use(VueQueryPlugin, {
  queryClientConfig: {
    defaultOptions: {
      queries: {
        refetchOnWindowFocus: false,
        retry: 1,
        staleTime: 30000,
      },
    },
  },
});

// Exposition de Supabase globalement pour faciliter le debugging en dev
if (import.meta.env.DEV) {
  window.supabase = supabase;
}

// Détection du thème préféré de l'utilisateur
const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
document.documentElement.classList.toggle('dark', prefersDark);

// Montage de l'application
app.mount('#app');

// Enregistrement du service worker pour PWA
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/sw.js').then(registration => {
      console.log('Service Worker enregistré avec succès:', registration);
    }).catch(error => {
      console.log('Échec de l\'enregistrement du Service Worker:', error);
    });
  });
}
