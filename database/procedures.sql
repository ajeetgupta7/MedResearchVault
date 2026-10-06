CREATE OR REPLACE PROCEDURE register_participant(
  p_participant_code VARCHAR,
  p_disease_id INTEGER,
  p_study_id INTEGER,
  p_enrollment_date DATE,
  p_birth_date DATE,
  p_sex VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO participants(participant_code, disease_id, study_id, enrollment_date, birth_date, sex)
  VALUES (p_participant_code, p_disease_id, p_study_id, p_enrollment_date, p_birth_date, p_sex);
END;
$$;

CREATE OR REPLACE PROCEDURE register_sample(
  p_sample_code VARCHAR,
  p_participant_id INTEGER,
  p_study_id INTEGER,
  p_sample_type VARCHAR,
  p_collection_date DATE,
  p_storage_location VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO samples(sample_code, participant_id, study_id, sample_type, collection_date, storage_location)
  VALUES (p_sample_code, p_participant_id, p_study_id, p_sample_type, p_collection_date, p_storage_location);
END;
$$;

CREATE OR REPLACE PROCEDURE create_experiment(
  p_experiment_code VARCHAR,
  p_study_id INTEGER,
  p_sample_id INTEGER,
  p_researcher_id INTEGER,
  p_experiment_type VARCHAR,
  p_experiment_date DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO experiments(experiment_code, study_id, sample_id, researcher_id, experiment_type, experiment_date)
  VALUES (p_experiment_code, p_study_id, p_sample_id, p_researcher_id, p_experiment_type, p_experiment_date);
END;
$$;

CREATE OR REPLACE PROCEDURE record_research_result(
  p_experiment_id INTEGER,
  p_finding TEXT,
  p_conclusion TEXT,
  p_confidence_score NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO research_results(experiment_id, finding, conclusion, confidence_score)
  VALUES (p_experiment_id, p_finding, p_conclusion, p_confidence_score);
END;
$$;

CREATE OR REPLACE PROCEDURE assign_researcher_to_study(
  p_study_id INTEGER,
  p_researcher_id INTEGER,
  p_assigned_role VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO study_researchers(study_id, researcher_id, assigned_role)
  VALUES (p_study_id, p_researcher_id, p_assigned_role)
  ON CONFLICT (study_id, researcher_id)
  DO UPDATE SET assigned_role = EXCLUDED.assigned_role, assigned_at = NOW();
END;
$$;
