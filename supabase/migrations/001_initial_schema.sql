-- PLANNER Suite - Schéma initial de la base de données
-- Migration 001: Création des schémas et tables principales

-- =============================================
-- Configuration générale et extensions
-- =============================================
-- Extension pour générer des UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Extension pour la recherche full-text
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Extension pour les types géographiques
CREATE EXTENSION IF NOT EXISTS postgis;

-- =============================================
-- Schémas pour chaque module
-- =============================================
-- Schéma principal pour les données partagées
CREATE SCHEMA IF NOT EXISTS public;

-- Schéma pour le module STAGEPLANNER
CREATE SCHEMA IF NOT EXISTS stageplanner;

-- Schéma pour le module BARPLANNER
CREATE SCHEMA IF NOT EXISTS barplanner;

-- Schéma pour le module CLEANPLANNER
CREATE SCHEMA IF NOT EXISTS cleanplanner;

-- Schéma pour le module SECUREPLANNER
CREATE SCHEMA IF NOT EXISTS secureplanner;

-- Schéma pour le module COMMERCEPLANNER
CREATE SCHEMA IF NOT EXISTS commerceplanner;

-- Schéma pour le module FESTIVALPLANNER
CREATE SCHEMA IF NOT EXISTS festivalplanner;

-- Schéma pour le module LIFEPLANNER
CREATE SCHEMA IF NOT EXISTS lifeplanner;

-- =============================================
-- Tables communes (schéma public)
-- =============================================

-- Table des organisations (multi-tenant)
CREATE TABLE public.organisations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    logo_url TEXT,
    primary_color VARCHAR(7) DEFAULT '#0066ff',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    subscription_tier VARCHAR(20) DEFAULT 'home', -- 'home', 'pro', 'ultra'
    subscription_ends_at TIMESTAMPTZ,
    max_users INT DEFAULT 5,
    max_storage_gb INT DEFAULT 5,
    settings JSONB DEFAULT '{}'::JSONB
);
COMMENT ON TABLE public.organisations IS 'Organisations utilisant PLANNER Suite';

-- Table des profils utilisateurs (extension de auth.users)
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    avatar_url TEXT,
    phone VARCHAR(20),
    bio TEXT,
    organisation_id UUID REFERENCES public.organisations(id) ON DELETE SET NULL,
    role VARCHAR(20) DEFAULT 'user', -- 'admin', 'user', 'manager'
    modules TEXT[] DEFAULT ARRAY['stageplanner']::TEXT[],
    settings JSONB DEFAULT '{}'::JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_sign_in_at TIMESTAMPTZ
);
COMMENT ON TABLE public.profiles IS 'Profils étendus des utilisateurs';

-- Table des modules disponibles
CREATE TABLE public.modules (
    id VARCHAR(20) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    color VARCHAR(7) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    requires_subscription VARCHAR(20) DEFAULT 'home', -- 'home', 'pro', 'ultra'
    settings JSONB DEFAULT '{}'::JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
COMMENT ON TABLE public.modules IS 'Modules disponibles dans PLANNER Suite';

-- Table des abonnements organisation-module
CREATE TABLE public.organisation_modules (
    organisation_id UUID REFERENCES public.organisations(id) ON DELETE CASCADE,
    module_id VARCHAR(20) REFERENCES public.modules(id) ON DELETE CASCADE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    activated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ,
    settings JSONB DEFAULT '{}'::JSONB,
    PRIMARY KEY (organisation_id, module_id)
);
COMMENT ON TABLE public.organisation_modules IS 'Modules activés pour chaque organisation';

-- Table des notifications
CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(20) NOT NULL DEFAULT 'info', -- 'info', 'success', 'warning', 'error'
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    action_url TEXT,
    action_text VARCHAR(50),
    module_id VARCHAR(20) REFERENCES public.modules(id) ON DELETE SET NULL,
    resource_type VARCHAR(50),
    resource_id UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ
);
COMMENT ON TABLE public.notifications IS 'Notifications utilisateur';

-- Table des fichiers
CREATE TABLE public.files (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    storage_path TEXT NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    size_bytes BIGINT NOT NULL,
    organisation_id UUID NOT NULL REFERENCES public.organisations(id) ON DELETE CASCADE,
    uploaded_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE SET NULL,
    module_id VARCHAR(20) REFERENCES public.modules(id) ON DELETE SET NULL,
    resource_type VARCHAR(50),
    resource_id UUID,
    is_public BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
COMMENT ON TABLE public.files IS 'Fichiers uploadés par les utilisateurs';

-- =============================================
-- Tables pour le module STAGEPLANNER
-- =============================================

-- Table des lieux (salles de spectacle, théâtres, etc.)
CREATE TABLE stageplanner.venues (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    address TEXT,
    city VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) DEFAULT 'France',
    contact_name VARCHAR(255),
    contact_email VARCHAR(255),
    contact_phone VARCHAR(20),
    capacity INT,
    notes TEXT,
    technical_sheet_file_id UUID REFERENCES public.files(id) ON DELETE SET NULL,
    organisation_id UUID NOT NULL REFERENCES public.organisations(id) ON DELETE CASCADE,
    location GEOGRAPHY(POINT),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
COMMENT ON TABLE stageplanner.venues IS 'Lieux de spectacle pour STAGEPLANNER';

-- Table des événements
CREATE TABLE stageplanner.events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    starts_at TIMESTAMPTZ NOT NULL,
    ends_at TIMESTAMPTZ NOT NULL,
    venue_id UUID REFERENCES stageplanner.venues(id) ON DELETE SET NULL,
    location VARCHAR(255),
    status VARCHAR(20) DEFAULT 'draft', -- 'draft', 'published', 'confirmed', 'cancelled', 'completed'
    organisation_id UUID NOT NULL REFERENCES public.organisations(id) ON DELETE CASCADE,
    created_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    notes TEXT,
    public_notes TEXT,
    color VARCHAR(7),
    all_day BOOLEAN DEFAULT FALSE,
    is_recurring BOOLEAN DEFAULT FALSE,
    recurrence_rule TEXT,
    parent_event_id UUID REFERENCES stageplanner.events(id) ON DELETE SET NULL
);
COMMENT ON TABLE stageplanner.events IS 'Événements pour STAGEPLANNER';

-- Table des plannings détaillés d'événements
CREATE TABLE stageplanner.event_schedules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES stageplanner.events(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    starts_at TIMESTAMPTZ NOT NULL,
    ends_at TIMESTAMPTZ NOT NULL,
    description TEXT,
    type VARCHAR(50), -- 'setup', 'rehearsal', 'soundcheck', 'show', 'teardown'
    location VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
COMMENT ON TABLE stageplanner.event_schedules IS 'Plannings détaillés des événements';

-- Table des spécialités d'intermittents
CREATE TABLE stageplanner.specialties (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    color VARCHAR(7),
    organisation_id UUID NOT NULL REFERENCES public.organisations(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
COMMENT ON TABLE stageplanner.specialties IS 'Spécialités des intermittents (son, lumière, etc.)';

-- Table des intermittents
CREATE TABLE stageplanner.intermittents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    social_security_number VARCHAR(20),
    conges_spectacles_number VARCHAR(20),
    medical_visit_date DATE,
    notes TEXT,
    organisation_id UUID NOT NULL REFERENCES public.organisations(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE,
    hourly_rate DECIMAL(10, 2),
    UNIQUE (organisation_id, email)
);
COMMENT ON TABLE stageplanner.intermittents IS 'Intermittents du spectacle';

-- Table de liaison intermittents-spécialités
CREATE TABLE stageplanner.intermittent_specialties (
    intermittent_id UUID REFERENCES stageplanner.intermittents(id) ON DELETE CASCADE,
    specialty_id UUID REFERENCES stageplanner.specialties(id) ON DELETE CASCADE,
    level INT DEFAULT 1, -- 1: débutant, 2: intermédiaire, 3: expert
    is_primary BOOLEAN DEFAULT FALSE,
    notes TEXT,
    PRIMARY KEY (intermittent_id, specialty_id)
);
COMMENT ON TABLE stageplanner.intermittent_specialties IS 'Spécialités des intermittents';

-- Table des équipes
CREATE TABLE stageplanner.teams (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    color VARCHAR(7),
    organisation_id UUID NOT NULL REFERENCES public.organisations(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
COMMENT ON TABLE stageplanner.teams IS 'Équipes d\'intermittents';

-- Table de liaison équipes-intermittents
CREATE TABLE stageplanner.team_members (
    team_id UUID REFERENCES stageplanner.teams(id) ON DELETE CASCADE,
    intermittent_id UUID REFERENCES stageplanner.intermittents(id) ON DELETE CASCADE,
    role VARCHAR(50),
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (team_id, intermittent_id)
);
COMMENT ON TABLE stageplanner.team_members IS 'Membres des équipes';

-- Table des spécialités requises pour un événement
CREATE TABLE stageplanner.event_required_specialties (
    event_id UUID REFERENCES stageplanner.events(id) ON DELETE CASCADE,
    specialty_id UUID REFERENCES stageplanner.specialties(id) ON DELETE CASCADE,
    count INT NOT NULL DEFAULT 1,
    notes TEXT,
    PRIMARY KEY (event_id, specialty_id)
);
COMMENT ON TABLE stageplanner.event_required_specialties IS 'Spécialités requises pour un événement';

-- Table des convocations d'intermittents
CREATE TABLE stageplanner.event_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES stageplanner.events(id) ON DELETE CASCADE,
    intermittent_id UUID NOT NULL REFERENCES stageplanner.intermittents(id) ON DELETE CASCADE,
    specialty_id UUID REFERENCES stageplanner.specialties(id) ON DELETE SET NULL,
    status VARCHAR(20) DEFAULT 'proposed', -- 'proposed', 'available', 'unavailable', 'confirmed', 'cancelled'
    response_at TIMESTAMPTZ,
    confirmation_at TIMESTAMPTZ,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (event_id, intermittent_id)
);
COMMENT ON TABLE stageplanner.event_assignments IS 'Convocations des intermittents aux événements';

-- Table des informations techniques par spécialité pour un événement
CREATE TABLE stageplanner.event_technical_info (
    event_id UUID REFERENCES stageplanner.events(id) ON DELETE CASCADE,
    specialty_id UUID REFERENCES stageplanner.specialties(id) ON DELETE CASCADE,
    information TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (event_id, specialty_id)
);
COMMENT ON TABLE stageplanner.event_technical_info IS 'Informations techniques par spécialité pour un événement';

-- Table des absences et congés des intermittents
CREATE TABLE stageplanner.intermittent_absences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    intermittent_id UUID NOT NULL REFERENCES stageplanner.intermittents(id) ON DELETE CASCADE,
    starts_at TIMESTAMPTZ NOT NULL,
    ends_at TIMESTAMPTZ NOT NULL,
    type VARCHAR(20) NOT NULL, -- 'vacation', 'sick_leave', 'unavailable', 'other'
    reason TEXT,
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'approved', 'rejected'
    approved_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    approved_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
COMMENT ON TABLE stageplanner.intermittent_absences IS 'Absences et congés des intermittents';

-- Table des demandes de remplacement
CREATE TABLE stageplanner.replacement_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_assignment_id UUID NOT NULL REFERENCES stageplanner.event_assignments(id) ON DELETE CASCADE,
    requested_by UUID NOT NULL REFERENCES stageplanner.intermittents(id) ON DELETE CASCADE,
    replacement_id UUID REFERENCES stageplanner.intermittents(id) ON DELETE SET NULL,
    reason TEXT,
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'approved', 'rejected', 'completed'
    response_at TIMESTAMPTZ,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
COMMENT ON TABLE stageplanner.replacement_requests IS 'Demandes de remplacement pour les événements';

-- =============================================
-- Tables pour le module LIFEPLANNER
-- =============================================

-- Table des événements personnels
CREATE TABLE lifeplanner.events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    starts_at TIMESTAMPTZ NOT NULL,
    ends_at TIMESTAMPTZ NOT NULL,
    location VARCHAR(255),
    color VARCHAR(7),
    is_all_day BOOLEAN DEFAULT FALSE,
    is_recurring BOOLEAN DEFAULT FALSE,
    recurrence_rule TEXT,
    parent_event_id UUID REFERENCES lifeplanner.events(id) ON DELETE SET NULL,
    visibility VARCHAR(20) DEFAULT 'private', -- 'private', 'public', 'shared'
    shared_with UUID[] DEFAULT ARRAY[]::UUID[],
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
COMMENT ON TABLE lifeplanner.events IS 'Événements personnels des utilisateurs';

-- Table des tâches personnelles
CREATE TABLE lifeplanner.tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    due_date TIMESTAMPTZ,
    completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMPTZ,
    priority VARCHAR(20) DEFAULT 'normal', -- 'low', 'normal', 'high', 'urgent'
    tags TEXT[],
    parent_task_id UUID REFERENCES lifeplanner.tasks(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
COMMENT ON TABLE lifeplanner.tasks IS 'Tâches personnelles des utilisateurs';

-- =============================================
-- Données initiales
-- =============================================

-- Insertion des modules disponibles
INSERT INTO public.modules (id, name, description, icon, color, is_active, requires_subscription)
VALUES
    ('stageplanner', 'STAGEPLANNER', 'Planification pour le spectacle vivant', 'MusicNoteIcon', '#0066ff', true, 'home'),
    ('barplanner', 'BARPLANNER', 'Gestion des équipes de bar et restaurant', 'BeakerIcon', '#9900ff', true, 'pro'),
    ('cleanplanner', 'CLEANPLANNER', 'Organisation des équipes de nettoyage', 'SparklesIcon', '#00ff40', true, 'pro'),
    ('secureplanner', 'SECUREPLANNER', 'Gestion des agents de sécurité', 'ShieldCheckIcon', '#ff8000', true, 'pro'),
    ('commerceplanner', 'COMMERCEPLANNER', 'Gestion des rendez-vous commerciaux', 'ShoppingBagIcon', '#ffeb00', true, 'ultra'),
    ('festivalplanner', 'FESTIVALPLANNER', 'Organisation d''événements d''envergure', 'TicketIcon', '#ff0000', true, 'ultra'),
    ('lifeplanner', 'LIFEPLANNER', 'Planification personnelle', 'HeartIcon', '#0066ff', true, 'home');

-- =============================================
-- Row Level Security (RLS)
-- =============================================

-- Activer RLS sur les tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.files ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organisations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organisation_modules ENABLE ROW LEVEL SECURITY;

ALTER TABLE stageplanner.venues ENABLE ROW LEVEL SECURITY;
ALTER TABLE stageplanner.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE stageplanner.event_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE stageplanner.specialties ENABLE ROW LEVEL SECURITY;
ALTER TABLE stageplanner.intermittents ENABLE ROW LEVEL SECURITY;
ALTER TABLE stageplanner.intermittent_specialties ENABLE ROW LEVEL SECURITY;
ALTER TABLE stageplanner.teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE stageplanner.team_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE stageplanner.event_required_specialties ENABLE ROW LEVEL SECURITY;
ALTER TABLE stageplanner.event_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE stageplanner.event_technical_info ENABLE ROW LEVEL SECURITY;
ALTER TABLE stageplanner.intermittent_absences ENABLE ROW LEVEL SECURITY;
ALTER TABLE stageplanner.replacement_requests ENABLE ROW LEVEL SECURITY;

ALTER TABLE lifeplanner.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE lifeplanner.tasks ENABLE ROW LEVEL SECURITY;

-- Politique pour les profils (utilisateurs peuvent voir et modifier leur propre profil)
CREATE POLICY "Utilisateurs peuvent voir leur propre profil" 
    ON public.profiles FOR SELECT 
    USING (auth.uid() = id);

CREATE POLICY "Utilisateurs peuvent modifier leur propre profil" 
    ON public.profiles FOR UPDATE 
    USING (auth.uid() = id);

-- Politique pour les notifications (utilisateurs peuvent voir leurs propres notifications)
CREATE POLICY "Utilisateurs peuvent voir leurs propres notifications" 
    ON public.notifications FOR SELECT 
    USING (auth.uid() = user_id);

CREATE POLICY "Utilisateurs peuvent marquer leurs notifications comme lues" 
    ON public.notifications FOR UPDATE 
    USING (auth.uid() = user_id);

-- Politique pour les organisations (utilisateurs peuvent voir leur propre organisation)
CREATE POLICY "Utilisateurs peuvent voir leur propre organisation" 
    ON public.organisations FOR SELECT 
    USING (id IN (SELECT organisation_id FROM public.profiles WHERE id = auth.uid()));

-- Politique pour les événements STAGEPLANNER (utilisateurs peuvent voir les événements de leur organisation)
CREATE POLICY "Utilisateurs peuvent voir les événements de leur organisation" 
    ON stageplanner.events FOR SELECT 
    USING (organisation_id IN (SELECT organisation_id FROM public.profiles WHERE id = auth.uid()));

-- Politique pour les intermittents (utilisateurs peuvent voir les intermittents de leur organisation)
CREATE POLICY "Utilisateurs peuvent voir les intermittents de leur organisation" 
    ON stageplanner.intermittents FOR SELECT 
    USING (organisation_id IN (SELECT organisation_id FROM public.profiles WHERE id = auth.uid()));

-- Politique pour les événements LIFEPLANNER (utilisateurs peuvent voir leurs propres événements personnels)
CREATE POLICY "Utilisateurs peuvent voir leurs propres événements personnels" 
    ON lifeplanner.events FOR SELECT 
    USING (user_id = auth.uid() OR auth.uid() = ANY(shared_with));

CREATE POLICY "Utilisateurs peuvent modifier leurs propres événements personnels" 
    ON lifeplanner.events FOR ALL
    USING (user_id = auth.uid());

-- Politique pour les tâches LIFEPLANNER (utilisateurs peuvent voir leurs propres tâches)
CREATE POLICY "Utilisateurs peuvent voir leurs propres tâches" 
    ON lifeplanner.tasks FOR SELECT 
    USING (user_id = auth.uid());

CREATE POLICY "Utilisateurs peuvent modifier leurs propres tâches" 
    ON lifeplanner.tasks FOR ALL
    USING (user_id = auth.uid());

-- =============================================
-- Index pour optimiser les performances
-- =============================================

-- Index sur les organisations
CREATE INDEX idx_organisations_slug ON public.organisations(slug);

-- Index sur les profils
CREATE INDEX idx_profiles_organisation_id ON public.profiles(organisation_id);
CREATE INDEX idx_profiles_email ON public.profiles(email);

-- Index sur les notifications
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_notifications_created_at ON public.notifications(created_at);

-- Index sur les événements
CREATE INDEX idx_events_organisation_id ON stageplanner.events(organisation_id);
CREATE INDEX idx_events_starts_at ON stageplanner.events(starts_at);
CREATE INDEX idx_events_status ON stageplanner.events(status);

-- Index sur les intermittents
CREATE INDEX idx_intermittents_organisation_id ON stageplanner.intermittents(organisation_id);
CREATE INDEX idx_intermittents_email ON stageplanner.intermittents(email);

-- Index sur les convocations
CREATE INDEX idx_event_assignments_event_id ON stageplanner.event_assignments(event_id);
CREATE INDEX idx_event_assignments_intermittent_id ON stageplanner.event_assignments(intermittent_id);
CREATE INDEX idx_event_assignments_status ON stageplanner.event_assignments(status);

-- Index sur les événements personnels
CREATE INDEX idx_lifeplanner_events_user_id ON lifeplanner.events(user_id);
CREATE INDEX idx_lifeplanner_events_starts_at ON lifeplanner.events(starts_at);

-- Index sur les tâches personnelles
CREATE INDEX idx_lifeplanner_tasks_user_id ON lifeplanner.tasks(user_id);
CREATE INDEX idx_lifeplanner_tasks_due_date ON lifeplanner.tasks(due_date);
CREATE INDEX idx_lifeplanner_tasks_completed ON lifeplanner.tasks(completed);

-- =============================================
-- Fonctions et triggers
-- =============================================

-- Fonction pour mettre à jour le champ updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour les tables principales
CREATE TRIGGER update_profiles_updated_at
BEFORE UPDATE ON public.profiles
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_organisations_updated_at
BEFORE UPDATE ON public.organisations
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_events_updated_at
BEFORE UPDATE ON stageplanner.events
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_intermittents_updated_at
BEFORE UPDATE ON stageplanner.intermittents
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Fonction pour créer une notification
CREATE OR REPLACE FUNCTION create_notification(
    p_user_id UUID,
    p_title TEXT,
    p_message TEXT,
    p_type TEXT DEFAULT 'info',
    p_action_url TEXT DEFAULT NULL,
    p_action_text TEXT DEFAULT NULL,
    p_module_id TEXT DEFAULT NULL,
    p_resource_type TEXT DEFAULT NULL,
    p_resource_id UUID DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_notification_id UUID;
BEGIN
    INSERT INTO public.notifications (
        user_id, title, message, type, action_url, action_text, 
        module_id, resource_type, resource_id
    ) VALUES (
        p_user_id, p_title, p_message, p_type, p_action_url, p_action_text, 
        p_module_id, p_resource_type, p_resource_id
    )
    RETURNING id INTO v_notification_id;
    
    RETURN v_notification_id;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour notifier les intermittents lors d'une nouvelle convocation
CREATE OR REPLACE FUNCTION notify_intermittent_assignment()
RETURNS TRIGGER AS $$
DECLARE
    v_event_title TEXT;
    v_intermittent_user_id UUID;
BEGIN
    -- Récupérer le titre de l'événement
    SELECT title INTO v_event_title
    FROM stageplanner.events
    WHERE id = NEW.event_id;
    
    -- Récupérer l'ID utilisateur de l'intermittent (s'il existe)
    SELECT user_id INTO v_intermittent_user_id
    FROM stageplanner.intermittents
    WHERE id = NEW.intermittent_id;
    
    -- Si l'intermittent a un compte utilisateur, créer une notification
    IF v_intermittent_user_id IS NOT NULL THEN
        PERFORM create_notification(
            v_intermittent_user_id,
            'Nouvelle convocation',
            'Vous avez été convoqué(e) pour l''événement: ' || v_event_title,
            'info',
            '/stageplanner/events/' || NEW.event_id,
            'Voir détails',
            'stageplanner',
            'event',
            NEW.event_id
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_notify_intermittent_assignment
AFTER INSERT ON stageplanner.event_assignments
FOR EACH ROW EXECUTE FUNCTION notify_intermittent_assignment();
