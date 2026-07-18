# Version History

## BASELINE_V1.0
**Date:** June 2026
**Status:** Active Production Baseline

### Description
The initial clean state of the Copy App POS System. All previous monolithic experimental features (M-Pesa, v2 UIs) have been stripped. The architecture has been split into:
1. `operations_app`: Local data-entry POS system.
2. `boss_app`: Super Admin dashboard for oversight.
3. `backend_api`: Centralized Railway PostgreSQL + Node.js sync server.

### Rollback Instructions
To restore this exact state:
```bash
git checkout BASELINE_V1.0
```
