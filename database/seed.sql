-- deterministic fictional seed data
TRUNCATE TABLE study_publications, research_results, experiment_biomarkers, biomarkers,
  experiments, samples, participants, diseases, study_researchers, studies,
  researchers, departments, users, roles, publications, audit_logs RESTART IDENTITY CASCADE;

INSERT INTO roles(role_name) VALUES
('Administrator'), ('Principal Investigator'), ('Research Assistant'), ('Data Analyst');

INSERT INTO users(username, email, password_hash, role_id)
SELECT
  CASE WHEN n = 1 THEN 'admin' ELSE 'user_' || n END,
  CASE WHEN n = 1 THEN 'admin@mrv.local' ELSE 'user_' || n || '@mrv.local' END,
  '$2b$12$gb6lyhLfHMFZSLBTxIM6euPdeA0S/NvWvntn4g4QzYUt5EJwgX8Vq', -- password: MRV@1234
  CASE
    WHEN n = 1 THEN 1
    WHEN n <= 6 THEN 2
    WHEN n <= 16 THEN 3
    ELSE 4
  END
FROM generate_series(1, 25) n;

INSERT INTO departments(department_name, location) VALUES
('Oncology Research','Block A'),
('Neurology Research','Block B'),
('Immunology Lab','Block C'),
('Genomics Unit','Block D'),
('Epidemiology Center','Block E');

INSERT INTO researchers(researcher_code, first_name, last_name, email, specialization, department_id, user_id)
SELECT
  'R' || LPAD(n::text, 3, '0'),
  'Researcher' || n,
  'Med' || n,
  'researcher' || n || '@mrv.local',
  CASE (n % 5)
    WHEN 0 THEN 'Oncology'
    WHEN 1 THEN 'Neurology'
    WHEN 2 THEN 'Immunology'
    WHEN 3 THEN 'Genomics'
    ELSE 'Epidemiology'
  END,
  ((n - 1) % 5) + 1,
  n + 1
FROM generate_series(1, 15) n;

INSERT INTO diseases(disease_code, disease_name, category)
SELECT
  'D' || LPAD(n::text, 3, '0'),
  'Disease ' || n,
  CASE (n % 4)
    WHEN 0 THEN 'Oncology'
    WHEN 1 THEN 'Neurology'
    WHEN 2 THEN 'Immunology'
    ELSE 'Metabolic'
  END
FROM generate_series(1, 10) n;

INSERT INTO studies(study_code, title, objective, status, start_date, end_date, principal_investigator_id)
SELECT
  'S' || LPAD(n::text, 3, '0'),
  'Study ' || n || ' on Disease Mechanisms',
  'Investigate controlled fictional dataset for research education.',
  CASE (n % 5)
    WHEN 0 THEN 'planned'
    WHEN 1 THEN 'active'
    WHEN 2 THEN 'completed'
    WHEN 3 THEN 'paused'
    ELSE 'active'
  END,
  DATE '2024-01-01' + (n * 12),
  CASE WHEN n % 3 = 0 THEN DATE '2026-01-01' + (n * 5) ELSE NULL END,
  ((n - 1) % 15) + 1
FROM generate_series(1, 10) n;

INSERT INTO study_researchers(study_id, researcher_id, assigned_role)
SELECT s.study_id, ((s.study_id + offset) % 15) + 1,
       CASE WHEN offset = 0 THEN 'Principal Investigator' ELSE 'Collaborator' END
FROM studies s
CROSS JOIN generate_series(0, 2) offset
ON CONFLICT DO NOTHING;

INSERT INTO participants(participant_code, disease_id, study_id, enrollment_date, birth_date, sex, status)
SELECT
  'P' || LPAD(n::text, 4, '0'),
  ((n - 1) % 10) + 1,
  ((n - 1) % 10) + 1,
  DATE '2025-01-01' + (n % 120),
  DATE '1980-01-01' + ((n * 53) % 12000),
  CASE (n % 4)
    WHEN 0 THEN 'male'
    WHEN 1 THEN 'female'
    WHEN 2 THEN 'other'
    ELSE 'undisclosed'
  END,
  CASE (n % 4)
    WHEN 0 THEN 'enrolled'
    WHEN 1 THEN 'active'
    WHEN 2 THEN 'completed'
    ELSE 'withdrawn'
  END
FROM generate_series(1, 100) n;

INSERT INTO samples(sample_code, participant_id, study_id, sample_type, collection_date, storage_location, status)
SELECT
  'SM' || LPAD(n::text, 4, '0'),
  ((n - 1) % 100) + 1,
  ((((n - 1) % 100) + 1 - 1) % 10) + 1,
  CASE (n % 4)
    WHEN 0 THEN 'Blood'
    WHEN 1 THEN 'Tissue'
    WHEN 2 THEN 'Serum'
    ELSE 'Plasma'
  END,
  DATE '2025-02-01' + (n % 120),
  'Freezer-' || ((n - 1) % 20 + 1),
  CASE
    WHEN n > 150 AND n % 5 = 0 THEN 'destroyed'
    WHEN n % 6 = 0 THEN 'consumed'
    WHEN n % 7 = 0 THEN 'in_analysis'
    ELSE 'stored'
  END
FROM generate_series(1, 200) n;

INSERT INTO experiments(experiment_code, study_id, sample_id, researcher_id, experiment_type, status, experiment_date, success_score)
SELECT
  'E' || LPAD(n::text, 4, '0'),
  ((n - 1) % 10) + 1,
  ((n - 1) % 200) + 1,
  ((n - 1) % 15) + 1,
  CASE (n % 5)
    WHEN 0 THEN 'PCR'
    WHEN 1 THEN 'Sequencing'
    WHEN 2 THEN 'ELISA'
    WHEN 3 THEN 'Flow Cytometry'
    ELSE 'Microscopy'
  END,
  CASE (n % 5)
    WHEN 0 THEN 'queued'
    WHEN 1 THEN 'running'
    WHEN 2 THEN 'completed'
    WHEN 3 THEN 'failed'
    ELSE 'completed'
  END,
  DATE '2025-03-01' + (n % 120),
  ROUND(((n * 7) % 100)::numeric, 2)
FROM generate_series(1, 100) n
WHERE (((n - 1) % 200) + 1) NOT IN (SELECT sample_id FROM samples WHERE status = 'destroyed');

INSERT INTO biomarkers(biomarker_code, biomarker_name, unit, reference_min, reference_max)
SELECT
  'B' || LPAD(n::text, 3, '0'),
  'Biomarker ' || n,
  CASE WHEN n % 2 = 0 THEN 'mg/dL' ELSE 'ng/mL' END,
  (n * 0.5)::numeric(10,3),
  (n * 2.0)::numeric(10,3)
FROM generate_series(1, 20) n;

INSERT INTO experiment_biomarkers(experiment_id, biomarker_id, measured_value, measured_at)
SELECT
  ((n - 1) % 100) + 1,
  ((n - 1) % 20) + 1,
  ROUND((20 + (n % 70) + ((n % 5) * 0.17))::numeric, 4),
  NOW() - ((n % 30) || ' days')::interval
FROM generate_series(1, 300) n
ON CONFLICT (experiment_id, biomarker_id)
DO UPDATE SET measured_value = EXCLUDED.measured_value, measured_at = EXCLUDED.measured_at;

INSERT INTO research_results(experiment_id, finding, conclusion, confidence_score)
SELECT
  ((n - 1) % 100) + 1,
  'Fictional finding #' || n,
  'Educational conclusion #' || n,
  ROUND((45 + (n % 55))::numeric, 2)
FROM generate_series(1, 300) n;

INSERT INTO publications(publication_code, title, journal, publication_date, doi)
SELECT
  'PUB' || LPAD(n::text, 3, '0'),
  'Publication ' || n || ' on Translational Findings',
  CASE (n % 4)
    WHEN 0 THEN 'Journal of Clinical Data Science'
    WHEN 1 THEN 'Bioinformatics Insights'
    WHEN 2 THEN 'Molecular Analytics Review'
    ELSE 'Medical Systems Journal'
  END,
  DATE '2024-01-01' + (n * 20),
  '10.1000/mrv.' || LPAD(n::text, 3, '0')
FROM generate_series(1, 20) n;

INSERT INTO study_publications(study_id, publication_id)
SELECT ((n - 1) % 10) + 1, n
FROM generate_series(1, 20) n;

-- transactional demonstration with rollback and successful commit
BEGIN;
  INSERT INTO audit_logs(table_name, record_id, action, actor, details)
  VALUES ('transaction_demo', 'failed_batch', 'INSERT', 'seed-script', '{"state":"begin"}');
ROLLBACK;

BEGIN;
  INSERT INTO audit_logs(table_name, record_id, action, actor, details)
  VALUES ('transaction_demo', 'successful_batch', 'INSERT', 'seed-script', '{"state":"committed"}');
COMMIT;
