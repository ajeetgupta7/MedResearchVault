# DBMS Features in MedResearchVault

- PostgreSQL-first persistent storage for all critical entities
- Declarative constraints (PK/FK/UQ/NOT NULL/CHECK)
- Index strategy for common lookup and analytics paths
- Predefined views for operational analytics
- Stored functions: sample age, average biomarker value, experiment success rate
- Stored procedures for participant/sample registration and workflow operations
- Triggers for audit logging, status transition validation, and destroyed-sample protection
- Deterministic fictional seed dataset with transactional rollback/commit demonstration
- Safe DBMS operations API that only allows pre-whitelisted SQL view queries
