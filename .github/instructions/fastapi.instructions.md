---
applyTo: "fastapi-backend/**/*.py"
---

# FastAPI Backend

## Project Structure
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

## Dependency Injection
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
- Use SQLAlchemy 2.0 async style
- Manage schema with Alembic; one migration per PR
- Set connection pool limits and timeouts

## Error Handling
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
- JWT or session tokens with rotation
- Store secrets in env vars or vault
- Enforce CORS allowlist and HTTPS
- Validate all inputs; cap payload sizes
- Use dependency-injected permission checks

## Performance
- Configure connection pooling and backoff
- Add circuit breakers for critical upstreams
- Expose health and readiness probes
- Use caching where safe

## Testing
- Use pytest with pytest-asyncio
- Separate unit and integration tests
- Mock external dependencies
- Test error paths and edge cases
