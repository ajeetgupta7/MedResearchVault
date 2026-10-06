CREATE OR REPLACE VIEW active_studies AS
SELECT s.study_id, s.study_code, s.title, s.status, s.start_date, s.principal_investigator_id
FROM studies s
WHERE s.status = 'active';

CREATE OR REPLACE VIEW participant_research_summary AS
SELECT p.participant_id, p.participant_code, d.disease_name, s.study_code,
       COUNT(sa.sample_id) AS sample_count,
       COUNT(e.experiment_id) AS experiment_count
FROM participants p
JOIN diseases d ON d.disease_id = p.disease_id
JOIN studies s ON s.study_id = p.study_id
LEFT JOIN samples sa ON sa.participant_id = p.participant_id
LEFT JOIN experiments e ON e.sample_id = sa.sample_id
GROUP BY p.participant_id, p.participant_code, d.disease_name, s.study_code;

CREATE OR REPLACE VIEW biomarker_summary AS
SELECT b.biomarker_id, b.biomarker_name,
       COUNT(eb.experiment_id) AS measured_experiments,
       AVG(eb.measured_value) AS avg_value,
       MIN(eb.measured_value) AS min_value,
       MAX(eb.measured_value) AS max_value
FROM biomarkers b
LEFT JOIN experiment_biomarkers eb ON eb.biomarker_id = b.biomarker_id
GROUP BY b.biomarker_id, b.biomarker_name;

CREATE OR REPLACE VIEW researcher_activity AS
SELECT r.researcher_id, r.researcher_code,
       r.first_name || ' ' || r.last_name AS researcher_name,
       COUNT(DISTINCT sr.study_id) AS assigned_studies,
       COUNT(DISTINCT e.experiment_id) AS executed_experiments
FROM researchers r
LEFT JOIN study_researchers sr ON sr.researcher_id = r.researcher_id
LEFT JOIN experiments e ON e.researcher_id = r.researcher_id
GROUP BY r.researcher_id, r.researcher_code, researcher_name;

CREATE OR REPLACE VIEW experiment_summary AS
SELECT e.experiment_id, e.experiment_code, e.experiment_type, e.status,
       st.study_code, sa.sample_code,
       r.first_name || ' ' || r.last_name AS researcher_name,
       e.success_score
FROM experiments e
JOIN studies st ON st.study_id = e.study_id
JOIN samples sa ON sa.sample_id = e.sample_id
JOIN researchers r ON r.researcher_id = e.researcher_id;
