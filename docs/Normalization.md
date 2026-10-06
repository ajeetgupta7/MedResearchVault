# Normalization (1NF/2NF/3NF)

## 1NF
All tables use atomic columns (no arrays/embedded repeating groups). Repeating relationships are separated into bridge tables (study_researchers, experiment_biomarkers, study_publications).

## 2NF
Each non-key attribute is fully dependent on the full key. Composite-key tables keep only attributes that depend on both key columns (e.g., measured_value depends on experiment_id + biomarker_id).

## 3NF
Transitive dependencies are removed:
- user role details are stored in roles, referenced by users
- department attributes are isolated from researchers
- disease descriptors are isolated from participants
- publication metadata is isolated and linked via study_publications
This ensures update consistency and minimal redundancy for analytics workflows.
