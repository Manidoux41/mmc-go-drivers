-- 1. Table des Profils (utilisateurs enrichis)
CREATE TABLE profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  username TEXT UNIQUE,
  full_name TEXT,
  tier TEXT DEFAULT 'free', -- 'free', 'expert', 'professional', 'diamond'
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Table des Véhicules
CREATE TABLE vehicles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  registration TEXT UNIQUE NOT NULL,
  brand TEXT,
  model TEXT,
  height FLOAT,
  length FLOAT,
  width FLOAT,
  unladen_weight FLOAT,
  ptac FLOAT,
  fuel_type TEXT, -- 'diesel', 'electric', 'hvo', 'gas'
  mileage FLOAT DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Table des Activités (Planning)
CREATE TABLE activities (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  type TEXT NOT NULL, -- 'ps', 'fs', 'trip', 'nettoyage', 'hlp', 'bc'
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE NOT NULL,
  departure TEXT,
  arrival TEXT,
  vehicle_id UUID REFERENCES vehicles(id) ON DELETE SET NULL,
  driver_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  stops JSONB, -- Pour les points de passage BC
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS (Row Level Security) - Configuration de base
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE activities ENABLE ROW LEVEL SECURITY;

-- Profils : visibles par tous les authentifiés, modifiables par le propriétaire
CREATE POLICY "Public profiles are viewable by everyone" ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);

-- Véhicules : visibles par tous les authentifiés
CREATE POLICY "Vehicles are viewable by authenticated users" ON vehicles FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Admins can manage vehicles" ON vehicles FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND tier = 'diamond')
);

-- Activités : visibilité selon le rôle
CREATE POLICY "Drivers can view assigned activities" ON activities FOR SELECT USING (
  auth.uid() = driver_id OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND tier = 'diamond')
);
CREATE POLICY "Admins can manage all activities" ON activities FOR ALL USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND tier = 'diamond')
);

-- Fonction pour créer automatiquement un profil à l'inscription
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, username, full_name, tier)
  VALUES (new.id, new.email, new.raw_user_meta_data->>'full_name', 'free');
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
