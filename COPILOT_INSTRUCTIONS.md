# Copilot Development Instructions (Project Local)

1. Keep all domain data in PostgreSQL; do not use browser localStorage for application records.
2. Use Flask API for all reads/writes from frontend.
3. Preserve RBAC roles: Administrator, Principal Investigator, Research Assistant, Data Analyst.
4. Keep MedResearchVault disclaimer visible in user-facing surfaces.
5. Never commit secrets; use `.env` and `.env.example`.
