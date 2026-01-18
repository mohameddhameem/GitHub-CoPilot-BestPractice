# AGENTS.md - FastAPI Backend

## Project Context
This is a FastAPI REST API backend. See root [AGENTS.md](../AGENTS.md) for repo-wide guidance.

## Key Files
- `src/main.py` - Application entry point
- `src/api/routes/` - API endpoints
- `src/services/` - Business logic
- `src/db/` - Database models and sessions

## Before Making Changes
1. Ensure you understand the request/response models in `src/models/`
2. Check existing services before creating new ones
3. Follow dependency injection patterns

## Commands
```bash
# Development
uvicorn src.main:app --reload

# Lint and format
ruff check . --fix && black .

# Test
pytest tests/ -v
```

## Database Migrations
```bash
# Generate migration
alembic revision --autogenerate -m "description"

# Apply migration
alembic upgrade head
```
