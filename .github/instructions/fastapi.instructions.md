---
applyTo: "fastapi-backend/**/*.py"
---

# FastAPI Backend

## Precedence
- Root guidance in [.github/copilot-instructions.md](../copilot-instructions.md) applies first, then [python instructions](python.instructions.md). This file adds FastAPI-specific rules and overrides the Python baseline where stated.

## Project Structure
- Goal: keep handlers thin and logic organized by responsibility.
```
src/
  api/
    routes/           # API endpoints
    dependencies.py   # Dependency injection
    middleware.py     # Custom middleware
  core/
    config.py         # Pydantic settings
    security.py       # Auth and security
    logging.py        # Logging configuration
  models/
    domain/           # Domain entities
    requests/         # API request models
    responses/        # API response models
  services/           # Business logic
  repositories/       # Data access layer
  db/
    models.py         # SQLAlchemy models
    session.py        # DB session management
  utils/              # Helper functions
```

## API Endpoint Structure
- Goal: make handlers declarative, typed, and side-effect aware.
- Keep route handlers thin; delegate to services
- Use dependency injection for services and repositories
- Return typed response models

```python
from fastapi import APIRouter, Depends, HTTPException, status
from typing import Annotated

router = APIRouter(prefix='/users', tags=['users'])

@router.post('/', response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(
    request: UserCreateRequest,
    service: Annotated[UserService, Depends(get_user_service)],
) -> UserResponse:
    logger.info('Creating user', extra={'username': request.username})
    try:
        user = await service.create_user(request)
        return UserResponse.model_validate(user)
    except DuplicateUserError as e:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail='User exists') from e
```

    Good: `await session.execute(...)` using injected async session with timeouts. Bad: `Session().execute(...)` from sync engine inside `async def`.

## Dependency Injection
    - Goal: ensure resource lifetime (DB, clients) is managed and transactional.
```python
from typing import Annotated, AsyncGenerator
from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

async def get_db_session() -> AsyncGenerator[AsyncSession, None]:
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise

DBSession = Annotated[AsyncSession, Depends(get_db_session)]
```

## Database and Migrations
- Goal: safe concurrent DB access with controlled schema evolution.
- Use SQLAlchemy 2.0 async style
- Manage schema with Alembic; one migration per PR
- Set connection pool limits and timeouts
- Migration rules: autogenerate, then review SQL/DDL by hand; forbid unchecked autogen drift. Block merge if migration changes schema without code or vice versa.

## Error Handling
- Goal: return precise client-facing errors without leaking internals.
- Use custom exception classes
- Map exceptions to HTTP status codes
- Never expose internal errors to clients

```python
class DomainException(Exception):
    def __init__(self, message: str, status_code: int = 400):
        self.message = message
        self.status_code = status_code

@app.exception_handler(DomainException)
async def handle_domain_exception(request, exc):
    return JSONResponse(status_code=exc.status_code, content={'detail': exc.message})
```

## Security
- Goal: default-secure APIs with least privilege.
- JWT or session tokens with rotation
- Store secrets in env vars or vault
- Enforce CORS allowlist and HTTPS
- Validate all inputs; cap payload sizes
- Use dependency-injected permission checks

## Performance
- Goal: predictable latency and graceful degradation.
- Configure connection pooling and backoff
- Add circuit breakers for critical upstreams
- Expose health and readiness probes
- Use caching where safe
- Preferred resilience: httpx with timeouts + tenacity for retries/backoff; cap max attempts; instrument retry counts.

## Testing
- Goal: cover happy paths plus error/edge cases per endpoint and service.
- Use pytest with pytest-asyncio
- Separate unit and integration tests
- Mock external dependencies
- Minimum: happy path + two error/edge cases per route and per service
- Place tests under `tests/api/` and `tests/services/`
- DB isolation: prefer transactional rollbacks per test; if not feasible, use ephemeral test DB/container with unique schema per run.
- Fixtures: shared client fixture with dependency overrides; factory data builders for request payloads.

## Formatting and CI hooks
- Goal: align with workspace automation for FastAPI code.
- Run before commit:
```bash
ruff check fastapi-backend --fix
black fastapi-backend
pre-commit run --all-files
```
*CI expectation*: same commands; include Alembic migration for DB-affecting changes; fail if autogen diff exists.
