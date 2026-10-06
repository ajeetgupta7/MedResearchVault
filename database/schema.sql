-- MedResearchVault core schema (3NF-oriented)

CREATE TABLE IF NOT EXISTS roles (
  role_id SERIAL PRIMARY KEY,
  role_name VARCHAR(80) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS users (
  user_id SERIAL PRIMARY KEY,
  username VARCHAR(80) UNIQUE NOT NULL,
  email VARCHAR(120) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role_id INTEGER NOT NULL REFERENCES roles(role_id),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS departments (
  department_id SERIAL PRIMARY KEY,
  department_name VARCHAR(120) UNIQUE NOT NULL,
  location VARCHAR(120) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS researchers (
  researcher_id SERIAL PRIMARY KEY,
  researcher_code VARCHAR(20) UNIQUE NOT NULL,
  first_name VARCHAR(80) NOT NULL,
  last_name VARCHAR(80) NOT NULL,
  email VARCHAR(120) UNIQUE NOT NULL,
  specialization VARCHAR(120) NOT NULL,
  department_id INTEGER NOT NULL REFERENCES departments(department_id),
  user_id INTEGER UNIQUE REFERENCES users(user_id),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS studies (
  study_id SERIAL PRIMARY KEY,
  study_code VARCHAR(20) UNIQUE NOT NULL,
  title VARCHAR(255) NOT NULL,
  objective TEXT NOT NULL,
  status VARCHAR(30) NOT NULL CHECK (status IN ('planned','active','completed','paused','cancelled')),
  start_date DATE NOT NULL,
  end_date DATE,
  principal_investigator_id INTEGER NOT NULL REFERENCES researchers(researcher_id),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE TABLE IF NOT EXISTS study_researchers (
  study_id INTEGER NOT NULL REFERENCES studies(study_id) ON DELETE CASCADE,
  researcher_id INTEGER NOT NULL REFERENCES researchers(researcher_id) ON DELETE CASCADE,
  assigned_role VARCHAR(100) NOT NULL,
  assigned_at TIMESTAMP NOT NULL DEFAULT NOW(),
  PRIMARY KEY (study_id, researcher_id)
);

CREATE TABLE IF NOT EXISTS diseases (
  disease_id SERIAL PRIMARY KEY,
  disease_code VARCHAR(20) UNIQUE NOT NULL,
  disease_name VARCHAR(120) UNIQUE NOT NULL,
  category VARCHAR(120) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS participants (
  participant_id SERIAL PRIMARY KEY,
  participant_code VARCHAR(20) UNIQUE NOT NULL,
  disease_id INTEGER NOT NULL REFERENCES diseases(disease_id),
  study_id INTEGER NOT NULL REFERENCES studies(study_id),
  enrollment_date DATE NOT NULL,
  birth_date DATE NOT NULL,
  sex VARCHAR(20) NOT NULL CHECK (sex IN ('male','female','other','undisclosed')),
  status VARCHAR(20) NOT NULL DEFAULT 'enrolled' CHECK (status IN ('enrolled','active','withdrawn','completed')),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  CHECK (birth_date < enrollment_date)
);

CREATE TABLE IF NOT EXISTS samples (
  sample_id SERIAL PRIMARY KEY,
  sample_code VARCHAR(20) UNIQUE NOT NULL,
  participant_id INTEGER NOT NULL REFERENCES participants(participant_id),
  study_id INTEGER NOT NULL REFERENCES studies(study_id),
  sample_type VARCHAR(60) NOT NULL,
  collection_date DATE NOT NULL,
  storage_location VARCHAR(120) NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'stored' CHECK (status IN ('stored','in_analysis','consumed','destroyed')),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS experiments (
  experiment_id SERIAL PRIMARY KEY,
  experiment_code VARCHAR(20) UNIQUE NOT NULL,
  study_id INTEGER NOT NULL REFERENCES studies(study_id),
  sample_id INTEGER NOT NULL REFERENCES samples(sample_id),
  researcher_id INTEGER NOT NULL REFERENCES researchers(researcher_id),
  experiment_type VARCHAR(100) NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'queued' CHECK (status IN ('queued','running','completed','failed','cancelled')),
  experiment_date DATE NOT NULL,
  success_score NUMERIC(5,2) NOT NULL DEFAULT 0 CHECK (success_score BETWEEN 0 AND 100),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS biomarkers (
  biomarker_id SERIAL PRIMARY KEY,
  biomarker_code VARCHAR(20) UNIQUE NOT NULL,
  biomarker_name VARCHAR(120) UNIQUE NOT NULL,
  unit VARCHAR(20) NOT NULL,
  reference_min NUMERIC(10,3) NOT NULL,
  reference_max NUMERIC(10,3) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  CHECK (reference_max >= reference_min)
);

CREATE TABLE IF NOT EXISTS experiment_biomarkers (
  experiment_id INTEGER NOT NULL REFERENCES experiments(experiment_id) ON DELETE CASCADE,
  biomarker_id INTEGER NOT NULL REFERENCES biomarkers(biomarker_id) ON DELETE CASCADE,
  measured_value NUMERIC(12,4) NOT NULL,
  measured_at TIMESTAMP NOT NULL DEFAULT NOW(),
  PRIMARY KEY (experiment_id, biomarker_id)
);

CREATE TABLE IF NOT EXISTS research_results (
  result_id SERIAL PRIMARY KEY,
  experiment_id INTEGER NOT NULL REFERENCES experiments(experiment_id),
  finding TEXT NOT NULL,
  conclusion TEXT NOT NULL,
  confidence_score NUMERIC(5,2) NOT NULL CHECK (confidence_score BETWEEN 0 AND 100),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS publications (
  publication_id SERIAL PRIMARY KEY,
  publication_code VARCHAR(20) UNIQUE NOT NULL,
  title VARCHAR(255) NOT NULL,
  journal VARCHAR(255) NOT NULL,
  publication_date DATE NOT NULL,
  doi VARCHAR(120) UNIQUE,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS study_publications (
  study_id INTEGER NOT NULL REFERENCES studies(study_id) ON DELETE CASCADE,
  publication_id INTEGER NOT NULL REFERENCES publications(publication_id) ON DELETE CASCADE,
  PRIMARY KEY (study_id, publication_id)
);

CREATE TABLE IF NOT EXISTS audit_logs (
  audit_id BIGSERIAL PRIMARY KEY,
  table_name VARCHAR(80) NOT NULL,
  record_id VARCHAR(80) NOT NULL,
  action VARCHAR(20) NOT NULL CHECK (action IN ('INSERT','UPDATE','DELETE')),
  actor VARCHAR(120) NOT NULL DEFAULT 'system',
  changed_at TIMESTAMP NOT NULL DEFAULT NOW(),
  details JSONB
);
