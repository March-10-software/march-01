import { RouteRecordRaw } from 'vue-router';

// Layouts
const DefaultLayout = () => import('@/layouts/DefaultLayout.vue');
const AuthLayout = () => import('@/layouts/AuthLayout.vue');

// Pages principales
const Dashboard = () => import('@/pages/Dashboard.vue');
const Calendar = () => import('@/pages/Calendar.vue');
const Team = () => import('@/pages/Team.vue');
const Settings = () => import('@/pages/Settings.vue');
const Profile = () => import('@/pages/Profile.vue');
const NotFound = () => import('@/pages/NotFound.vue');

// Pages d'authentification
const Login = () => import('@/pages/auth/Login.vue');
const Register = () => import('@/pages/auth/Register.vue');
const ForgotPassword = () => import('@/pages/auth/ForgotPassword.vue');
const ResetPassword = () => import('@/pages/auth/ResetPassword.vue');

// Pages des modules
const StageplannerHome = () => import('@/pages/modules/stageplanner/Home.vue');
const StageplannerEvents = () => import('@/pages/modules/stageplanner/Events.vue');
const StageplannerEventDetail = () => import('@/pages/modules/stageplanner/EventDetail.vue');
const StageplannerTeam = () => import('@/pages/modules/stageplanner/Team.vue');

const BarplannerHome = () => import('@/pages/modules/barplanner/Home.vue');
const CleanplannerHome = () => import('@/pages/modules/cleanplanner/Home.vue');
const SecureplannerHome = () => import('@/pages/modules/secureplanner/Home.vue');
const CommerceplannerHome = () => import('@/pages/modules/commerceplanner/Home.vue');
const FestivalplannerHome = () => import('@/pages/modules/festivalplanner/Home.vue');

// LifePlanner
const LifeplannerHome = () => import('@/pages/lifeplanner/Home.vue');
const LifeplannerCalendar = () => import('@/pages/lifeplanner/Calendar.vue');
const LifeplannerTasks = () => import('@/pages/lifeplanner/Tasks.vue');

export const routes: RouteRecordRaw[] = [
  // Routes d'authentification
  {
    path: '/',
    component: AuthLayout,
    children: [
      {
        path: 'login',
        name: 'login',
        component: Login,
        meta: {
          title: 'Connexion',
          requiresAuth: false
        }
      },
      {
        path: 'register',
        name: 'register',
        component: Register,
        meta: {
          title: 'Inscription',
          requiresAuth: false
        }
      },
      {
        path: 'forgot-password',
        name: 'forgot-password',
        component: ForgotPassword,
        meta: {
          title: 'Mot de passe oublié',
          requiresAuth: false
        }
      },
      {
        path: 'reset-password',
        name: 'reset-password',
        component: ResetPassword,
        meta: {
          title: 'Réinitialiser le mot de passe',
          requiresAuth: false
        }
      }
    ]
  },
  
  // Routes principales (protégées)
  {
    path: '/',
    component: DefaultLayout,
    meta: {
      requiresAuth: true
    },
    children: [
      {
        path: '',
        redirect: '/dashboard'
      },
      {
        path: 'dashboard',
        name: 'dashboard',
        component: Dashboard,
        meta: {
          title: 'Tableau de bord',
          icon: 'HomeIcon'
        }
      },
      {
        path: 'calendar',
        name: 'calendar',
        component: Calendar,
        meta: {
          title: 'Calendrier',
          icon: 'CalendarIcon'
        }
      },
      {
        path: 'team',
        name: 'team',
        component: Team,
        meta: {
          title: 'Équipe',
          icon: 'UsersIcon'
        }
      },
      {
        path: 'settings',
        name: 'settings',
        component: Settings,
        meta: {
          title: 'Paramètres',
          icon: 'CogIcon'
        }
      },
      {
        path: 'profile',
        name: 'profile',
        component: Profile,
        meta: {
          title: 'Profil',
          icon: 'UserIcon'
        }
      }
    ]
  },
  
  // Module STAGEPLANNER
  {
    path: '/stageplanner',
    component: DefaultLayout,
    meta: {
      requiresAuth: true,
      moduleColor: 'stageplanner'
    },
    children: [
      {
        path: '',
        name: 'stageplanner',
        component: StageplannerHome,
        meta: {
          title: 'STAGEPLANNER',
          icon: 'MusicNoteIcon'
        }
      },
      {
        path: 'events',
        name: 'stageplanner-events',
        component: StageplannerEvents,
        meta: {
          title: 'Événements',
          icon: 'CalendarIcon'
        }
      },
      {
        path: 'events/:id',
        name: 'stageplanner-event-detail',
        component: StageplannerEventDetail,
        meta: {
          title: 'Détail de l\'événement',
          icon: 'DocumentTextIcon'
        },
        props: true
      },
      {
        path: 'team',
        name: 'stageplanner-team',
        component: StageplannerTeam,
        meta: {
          title: 'Intermittents',
          icon: 'UsersIcon'
        }
      }
    ]
  },
  
  // Module BARPLANNER
  {
    path: '/barplanner',
    component: DefaultLayout,
    meta: {
      requiresAuth: true,
      moduleColor: 'barplanner'
    },
    children: [
      {
        path: '',
        name: 'barplanner',
        component: BarplannerHome,
        meta: {
          title: 'BARPLANNER',
          icon: 'BeakerIcon'
        }
      }
    ]
  },
  
  // Module CLEANPLANNER
  {
    path: '/cleanplanner',
    component: DefaultLayout,
    meta: {
      requiresAuth: true,
      moduleColor: 'cleanplanner'
    },
    children: [
      {
        path: '',
        name: 'cleanplanner',
        component: CleanplannerHome,
        meta: {
          title: 'CLEANPLANNER',
          icon: 'SparklesIcon'
        }
      }
    ]
  },
  
  // Module SECUREPLANNER
  {
    path: '/secureplanner',
    component: DefaultLayout,
    meta: {
      requiresAuth: true,
      moduleColor: 'secureplanner'
    },
    children: [
      {
        path: '',
        name: 'secureplanner',
        component: SecureplannerHome,
        meta: {
          title: 'SECUREPLANNER',
          icon: 'ShieldCheckIcon'
        }
      }
    ]
  },
  
  // Module COMMERCEPLANNER
  {
    path: '/commerceplanner',
    component: DefaultLayout,
    meta: {
      requiresAuth: true,
      moduleColor: 'commerceplanner'
    },
    children: [
      {
        path: '',
        name: 'commerceplanner',
        component: CommerceplannerHome,
        meta: {
          title: 'COMMERCEPLANNER',
          icon: 'ShoppingBagIcon'
        }
      }
    ]
  },
  
  // Module FESTIVALPLANNER
  {
    path: '/festivalplanner',
    component: DefaultLayout,
    meta: {
      requiresAuth: true,
      moduleColor: 'festivalplanner'
    },
    children: [
      {
        path: '',
        name: 'festivalplanner',
        component: FestivalplannerHome,
        meta: {
          title: 'FESTIVALPLANNER',
          icon: 'TicketIcon'
        }
      }
    ]
  },
  
  // LIFEPLANNER (personnel)
  {
    path: '/lifeplanner',
    component: DefaultLayout,
    meta: {
      requiresAuth: true,
      moduleColor: 'primary'
    },
    children: [
      {
        path: '',
        name: 'lifeplanner',
        component: LifeplannerHome,
        meta: {
          title: 'LIFEPLANNER',
          icon: 'HeartIcon'
        }
      },
      {
        path: 'calendar',
        name: 'lifeplanner-calendar',
        component: LifeplannerCalendar,
        meta: {
          title: 'Mon Calendrier',
          icon: 'CalendarIcon'
        }
      },
      {
        path: 'tasks',
        name: 'lifeplanner-tasks',
        component: LifeplannerTasks,
        meta: {
          title: 'Mes Tâches',
          icon: 'CheckCircleIcon'
        }
      }
    ]
  },
  
  // Route 404
  {
    path: '/:pathMatch(.*)*',
    name: 'not-found',
    component: NotFound,
    meta: {
      title: 'Page non trouvée'
    }
  }
];

export default routes;
