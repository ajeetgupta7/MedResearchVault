-- 1. Active studies with PI names (join)
SELECT s.study_code, s.title, r.first_name || ' ' || r.last_name AS principal_investigator
FROM studies s
JOIN researchers r ON r.researcher_id = s.principal_investigator_id
WHERE s.status = 'active';

-- 2. Studies and optional publication count (left join)
SELECT s.study_code, s.title, COUNT(sp.publication_id) AS publications
FROM studies s
LEFT JOIN study_publications sp ON sp.study_id = s.study_id
GROUP BY s.study_code, s.title;

-- 3. Participant counts per disease (group by)
SELECT d.disease_name, COUNT(p.participant_id) AS participants
FROM diseases d
JOIN participants p ON p.disease_id = d.disease_id
GROUP BY d.disease_name
HAVING COUNT(p.participant_id) > 0;

-- 4. Experiments with confidence >= 80
SELECT e.experiment_code, rr.confidence_score
FROM experiments e
JOIN research_results rr ON rr.experiment_id = e.experiment_id
WHERE rr.confidence_score >= 80;

-- 5. Researchers with no assigned studies (NOT EXISTS)
SELECT r.researcher_code, r.first_name, r.last_name
FROM researchers r
WHERE NOT EXISTS (
  SELECT 1 FROM study_researchers sr WHERE sr.researcher_id = r.researcher_id
);

-- 6. Studies that have participants (EXISTS)
SELECT s.study_code, s.title
FROM studies s
WHERE EXISTS (
  SELECT 1 FROM participants p WHERE p.study_id = s.study_id
);

-- 7. Avg biomarker value by biomarker (aggregate)
SELECT b.biomarker_name, AVG(eb.measured_value) AS avg_value
FROM biomarkers b
JOIN experiment_biomarkers eb ON eb.biomarker_id = b.biomarker_id
GROUP BY b.biomarker_name;

-- 8. Latest experiment per study (window function)
SELECT * FROM (
  SELECT e.*, ROW_NUMBER() OVER (PARTITION BY e.study_id ORDER BY e.experiment_date DESC) AS rn
  FROM experiments e
) x
WHERE x.rn = 1;

-- 9. Running success rate by study (CTE + CASE)
WITH summary AS (
  SELECT study_id,
         COUNT(*) AS total,
         SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) AS completed
  FROM experiments
  GROUP BY study_id
)
SELECT s.study_code,
       CASE WHEN summary.total = 0 THEN 0
            ELSE ROUND((summary.completed::numeric / summary.total::numeric) * 100, 2)
       END AS success_rate
FROM summary
JOIN studies s ON s.study_id = summary.study_id;

-- 10. Participant age at enrollment (function)
SELECT participant_code,
       DATE_PART('year', AGE(enrollment_date, birth_date)) AS age_at_enrollment
FROM participants;

-- 11. Top 5 researchers by experiments
SELECT r.researcher_code, COUNT(e.experiment_id) AS experiment_count
FROM researchers r
LEFT JOIN experiments e ON e.researcher_id = r.researcher_id
GROUP BY r.researcher_code
ORDER BY experiment_count DESC
LIMIT 5;

-- 12. Samples not used in any experiment
SELECT sa.sample_code
FROM samples sa
LEFT JOIN experiments e ON e.sample_id = sa.sample_id
WHERE e.experiment_id IS NULL;

-- 13. Publication counts by journal
SELECT journal, COUNT(*) AS publication_count
FROM publications
GROUP BY journal
ORDER BY publication_count DESC;

-- 14. Participant + sample counts by study
SELECT s.study_code, COUNT(DISTINCT p.participant_id) AS participants, COUNT(sa.sample_id) AS samples
FROM studies s
LEFT JOIN participants p ON p.study_id = s.study_id
LEFT JOIN samples sa ON sa.study_id = s.study_id
GROUP BY s.study_code;

-- 15. Biomarkers outside reference ranges
SELECT b.biomarker_name, eb.measured_value, b.reference_min, b.reference_max
FROM experiment_biomarkers eb
JOIN biomarkers b ON b.biomarker_id = eb.biomarker_id
WHERE eb.measured_value < b.reference_min OR eb.measured_value > b.reference_max;

-- 16. Total audit actions by table
SELECT table_name, action, COUNT(*) AS total
FROM audit_logs
GROUP BY table_name, action
ORDER BY total DESC;

-- 17. Experiments per month (time series)
SELECT DATE_TRUNC('month', experiment_date) AS month_bucket, COUNT(*) AS experiments
FROM experiments
GROUP BY month_bucket
ORDER BY month_bucket;

-- 18. Study with max participants (subquery)
SELECT study_code, title
FROM studies
WHERE study_id = (
  SELECT study_id FROM participants GROUP BY study_id ORDER BY COUNT(*) DESC LIMIT 1
);

-- 19. Disease coverage by department
SELECT dpt.department_name, COUNT(DISTINCT d.disease_id) AS diseases_covered
FROM departments dpt
JOIN researchers r ON r.department_id = dpt.department_id
JOIN studies s ON s.principal_investigator_id = r.researcher_id
JOIN participants p ON p.study_id = s.study_id
JOIN diseases d ON d.disease_id = p.disease_id
GROUP BY dpt.department_name;

-- 20. Rank studies by experiments (window rank)
SELECT s.study_code,
       COUNT(e.experiment_id) AS experiment_count,
       RANK() OVER (ORDER BY COUNT(e.experiment_id) DESC) AS experiment_rank
FROM studies s
LEFT JOIN experiments e ON e.study_id = s.study_id
GROUP BY s.study_code;

-- 21. High confidence result distribution
SELECT CASE
         WHEN confidence_score >= 90 THEN 'Excellent'
         WHEN confidence_score >= 75 THEN 'Good'
         WHEN confidence_score >= 50 THEN 'Moderate'
         ELSE 'Low'
       END AS confidence_band,
       COUNT(*)
FROM research_results
GROUP BY confidence_band;
