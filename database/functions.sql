CREATE OR REPLACE FUNCTION calculate_sample_age(p_sample_id INTEGER)
RETURNS INTEGER AS $$
DECLARE
  v_collection DATE;
  v_birth DATE;
BEGIN
  SELECT s.collection_date, p.birth_date
  INTO v_collection, v_birth
  FROM samples s
  JOIN participants p ON p.participant_id = s.participant_id
  WHERE s.sample_id = p_sample_id;

  IF v_collection IS NULL OR v_birth IS NULL THEN
    RETURN NULL;
  END IF;

  RETURN DATE_PART('year', AGE(v_collection, v_birth));
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION calculate_average_biomarker_value(p_biomarker_id INTEGER)
RETURNS NUMERIC AS $$
DECLARE
  v_avg NUMERIC;
BEGIN
  SELECT AVG(measured_value) INTO v_avg
  FROM experiment_biomarkers
  WHERE biomarker_id = p_biomarker_id;

  RETURN COALESCE(v_avg, 0);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION calculate_experiment_success_rate(p_study_id INTEGER)
RETURNS NUMERIC AS $$
DECLARE
  v_total INTEGER;
  v_completed INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_total FROM experiments WHERE study_id = p_study_id;
  SELECT COUNT(*) INTO v_completed
  FROM experiments
  WHERE study_id = p_study_id AND status = 'completed';

  IF v_total = 0 THEN
    RETURN 0;
  END IF;

  RETURN ROUND((v_completed::NUMERIC / v_total::NUMERIC) * 100, 2);
END;
$$ LANGUAGE plpgsql;
