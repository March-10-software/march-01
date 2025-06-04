import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import { supabase } from '@/main';
import type { User, AuthError, Session } from '@supabase/supabase-js';

// Types pour le profil utilisateur
export interface UserProfile {
  id: string;
  email: string;
  first_name?: string;
  last_name?: string;
  avatar_url?: string;
  role?: string;
  organisation_id?: string;
  modules?: string[];
  created_at?: string;
  updated_at?: string;
}

export const useUserStore = defineStore('user', () => {
  // État
  const user = ref<User | null>(null);
  const profile = ref<UserProfile | null>(null);
  const loading = ref(false);
  const error = ref<string | null>(null);
  const session = ref<Session | null>(null);

  // Getters
  const isAuthenticated = computed(() => !!user.value);
  const isAdmin = computed(() => profile.value?.role === 'admin');
  const userFullName = computed(() => {
    if (!profile.value) return '';
    if (profile.value.first_name && profile.value.last_name) {
      return `${profile.value.first_name} ${profile.value.last_name}`;
    }
    return profile.value.email;
  });
  
  const userInitials = computed(() => {
    if (!profile.value) return '';
    if (profile.value.first_name && profile.value.last_name) {
      return `${profile.value.first_name[0]}${profile.value.last_name[0]}`.toUpperCase();
    }
    return profile.value.email?.substring(0, 2).toUpperCase() || '';
  });

  const userModules = computed(() => profile.value?.modules || []);

  // Actions
  async function loadUser() {
    try {
      loading.value = true;
      error.value = null;
      
      // Récupérer la session utilisateur
      const { data: sessionData, error: sessionError } = await supabase.auth.getSession();
      
      if (sessionError) {
        throw sessionError;
      }
      
      if (sessionData?.session) {
        session.value = sessionData.session;
        user.value = sessionData.session.user;
        
        // Charger le profil utilisateur depuis la base de données
        await fetchUserProfile();
      }
    } catch (err: any) {
      console.error('Erreur lors du chargement de l\'utilisateur:', err);
      error.value = err.message || 'Erreur lors du chargement de l\'utilisateur';
    } finally {
      loading.value = false;
    }
  }

  async function fetchUserProfile() {
    if (!user.value) return;

    try {
      const { data, error: profileError } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', user.value.id)
        .single();

      if (profileError) {
        throw profileError;
      }

      if (data) {
        profile.value = data as UserProfile;
      } else {
        // Si le profil n'existe pas, on le crée
        await createUserProfile();
      }
    } catch (err: any) {
      console.error('Erreur lors de la récupération du profil:', err);
      error.value = err.message || 'Erreur lors de la récupération du profil';
    }
  }

  async function createUserProfile() {
    if (!user.value) return;

    try {
      const newProfile: Partial<UserProfile> = {
        id: user.value.id,
        email: user.value.email || '',
        role: 'user',
        modules: ['stageplanner'], // Module par défaut
        created_at: new Date().toISOString(),
      };

      const { error: insertError } = await supabase
        .from('profiles')
        .insert(newProfile);

      if (insertError) {
        throw insertError;
      }

      profile.value = newProfile as UserProfile;
    } catch (err: any) {
      console.error('Erreur lors de la création du profil:', err);
      error.value = err.message || 'Erreur lors de la création du profil';
    }
  }

  async function login(email: string, password: string) {
    try {
      loading.value = true;
      error.value = null;

      const { data, error: authError } = await supabase.auth.signInWithPassword({
        email,
        password,
      });

      if (authError) {
        throw authError;
      }

      if (data?.user) {
        user.value = data.user;
        session.value = data.session;
        await fetchUserProfile();
        return true;
      }
      
      return false;
    } catch (err: any) {
      console.error('Erreur de connexion:', err);
      error.value = err.message || 'Erreur de connexion';
      return false;
    } finally {
      loading.value = false;
    }
  }

  async function loginWithMagicLink(email: string) {
    try {
      loading.value = true;
      error.value = null;

      const { error: authError } = await supabase.auth.signInWithOtp({
        email,
        options: {
          emailRedirectTo: `${window.location.origin}/auth/callback`,
        },
      });

      if (authError) {
        throw authError;
      }

      return true;
    } catch (err: any) {
      console.error('Erreur d\'envoi du lien magique:', err);
      error.value = err.message || 'Erreur d\'envoi du lien magique';
      return false;
    } finally {
      loading.value = false;
    }
  }

  async function register(email: string, password: string) {
    try {
      loading.value = true;
      error.value = null;

      const { data, error: authError } = await supabase.auth.signUp({
        email,
        password,
      });

      if (authError) {
        throw authError;
      }

      if (data?.user) {
        user.value = data.user;
        session.value = data.session;
        await createUserProfile();
        return true;
      }
      
      return false;
    } catch (err: any) {
      console.error('Erreur d\'inscription:', err);
      error.value = err.message || 'Erreur d\'inscription';
      return false;
    } finally {
      loading.value = false;
    }
  }

  async function logout() {
    try {
      loading.value = true;
      error.value = null;

      const { error: authError } = await supabase.auth.signOut();

      if (authError) {
        throw authError;
      }

      clearUser();
      return true;
    } catch (err: any) {
      console.error('Erreur de déconnexion:', err);
      error.value = err.message || 'Erreur de déconnexion';
      return false;
    } finally {
      loading.value = false;
    }
  }

  async function updateProfile(updates: Partial<UserProfile>) {
    if (!user.value || !profile.value) return false;

    try {
      loading.value = true;
      error.value = null;

      const { error: updateError } = await supabase
        .from('profiles')
        .update({
          ...updates,
          updated_at: new Date().toISOString(),
        })
        .eq('id', user.value.id);

      if (updateError) {
        throw updateError;
      }

      // Mettre à jour le profil local
      profile.value = { ...profile.value, ...updates };
      return true;
    } catch (err: any) {
      console.error('Erreur de mise à jour du profil:', err);
      error.value = err.message || 'Erreur de mise à jour du profil';
      return false;
    } finally {
      loading.value = false;
    }
  }

  async function resetPassword(email: string) {
    try {
      loading.value = true;
      error.value = null;

      const { error: resetError } = await supabase.auth.resetPasswordForEmail(email, {
        redirectTo: `${window.location.origin}/reset-password`,
      });

      if (resetError) {
        throw resetError;
      }

      return true;
    } catch (err: any) {
      console.error('Erreur de réinitialisation du mot de passe:', err);
      error.value = err.message || 'Erreur de réinitialisation du mot de passe';
      return false;
    } finally {
      loading.value = false;
    }
  }

  function clearUser() {
    user.value = null;
    profile.value = null;
    session.value = null;
    error.value = null;
  }

  // Initialiser l'écouteur d'authentification
  function initAuthListener() {
    return supabase.auth.onAuthStateChange(async (event, newSession) => {
      if (event === 'SIGNED_IN' && newSession) {
        user.value = newSession.user;
        session.value = newSession;
        await fetchUserProfile();
      } else if (event === 'SIGNED_OUT') {
        clearUser();
      } else if (event === 'USER_UPDATED' && newSession) {
        user.value = newSession.user;
        session.value = newSession;
        await fetchUserProfile();
      }
    });
  }

  // Retourner l'état et les méthodes
  return {
    // État
    user,
    profile,
    loading,
    error,
    session,
    
    // Getters
    isAuthenticated,
    isAdmin,
    userFullName,
    userInitials,
    userModules,
    
    // Actions
    loadUser,
    fetchUserProfile,
    login,
    loginWithMagicLink,
    register,
    logout,
    updateProfile,
    resetPassword,
    clearUser,
    initAuthListener,
  };
});
