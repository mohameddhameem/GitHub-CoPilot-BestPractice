# GitHub Copilot Instructions - FastAPI Backend

## Python and FastAPI Best Practices

### Project Structure
```
src/
├── api/
│   ├── routes/         # API endpoints
│   ├── dependencies.py # Dependency injection
│   └── middleware.py   # Custom middleware
├── core/
│   ├── config.py       # Pydantic settings
│   ├── security.py     # Auth and security
│   └── logging.py      # Logging configuration
├── models/             # Pydantic models
│   ├── domain/         # Domain entities
│   ├── requests/       # API request models
│   └── responses/      # API response models
├── services/           # Business logic
├── repositories/       # Data access layer
├── db/                 # Database related
│   ├── models.py       # SQLAlchemy models
│   └── session.py      # DB session management
└── utils/              # Helper functions
```

### Pydantic Usage (MANDATORY)
- Use Pydantic v2 for all data validation
- Define models for ALL requests, responses, and configurations
- Use `ConfigDict` for model configuration
- Leverage `Field` for validation and documentation
- Use `field_validator` for custom validation

```python
from pydantic import BaseModel, Field, field_validator, ConfigDict
from datetime import datetime
from typing import Optional

class UserCreateRequest(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True, validate_assignment=True)
    
    username: str = Field(..., min_length=3, max_length=50, pattern=r'^[a-zA-Z0-9_]+$')
    email: str = Field(..., max_length=255)
    password: str = Field(..., min_length=8)
    
    @field_validator('email')
    @classmethod
    def validate_email(cls, v: str) -> str:
        if '@' not in v:
            raise ValueError('Invalid email format')
        return v.lower()

class UserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    
    id: str
    username: str
    email: str
    created_at: datetime
    is_active: bool = True
```

### Configuration Management
```python
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file='.env',
        env_file_encoding='utf-8',
        case_sensitive=False
    )
    
    app_name: str = Field(default='FastAPI Backend')
    debug: bool = Field(default=False)
    database_url: str = Field(..., validation_alias='DATABASE_URL')
    secret_key: str = Field(..., min_length=32)
    log_level: str = Field(default='INFO')

settings = Settings()
```

### API Endpoint Structure
```python
from fastapi import APIRouter, Depends, HTTPException, status
from typing import Annotated
import logging

logger = logging.getLogger(__name__)
router = APIRouter(prefix='/users', tags=['users'])

@router.post('/', response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(
    request: UserCreateRequest,
    user_service: Annotated[UserService, Depends(get_user_service)],
) -> UserResponse:
    logger.info('Creating user', extra={'username': request.username})
    
    try:
        user = await user_service.create_user(request)
        logger.info('User created successfully', extra={'user_id': user.id})
        return UserResponse.model_validate(user)
    except DuplicateUserError as e:
        logger.warning('User creation failed: duplicate', extra={'username': request.username})
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail='User already exists'
        ) from e
    except Exception as e:
        logger.error('User creation failed', extra={'error': str(e)}, exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail='Internal server error'
        ) from e
```

### Dependency Injection
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
        finally:
            await session.close()

DBSession = Annotated[AsyncSession, Depends(get_db_session)]

def get_user_repository(session: DBSession) -> UserRepository:
    return UserRepository(session)

UserRepo = Annotated[UserRepository, Depends(get_user_repository)]
```

### Logging Standards (CRITICAL)
```python
import logging
import json
from datetime import datetime

class StructuredLogger:
    def __init__(self, name: str):
        self.logger = logging.getLogger(name)
    
    def _log(self, level: int, message: str, **kwargs):
        log_data = {
            'timestamp': datetime.utcnow().isoformat(),
            'message': message,
            **kwargs
        }
        self.logger.log(level, json.dumps(log_data))
    
    def info(self, message: str, **kwargs):
        self._log(logging.INFO, message, **kwargs)

logger = StructuredLogger(__name__)

# Usage - Log before and after data manipulation
async def process_data(data: list[dict]) -> list[ProcessedData]:
    logger.info('Starting data processing', count=len(data), data_sample=data[:2])
    
    processed = [transform(item) for item in data]
    
    logger.info('Data processing completed', 
                original_count=len(data), 
                processed_count=len(processed),
                success_rate=len(processed)/len(data))
    
    return processed
```

### Error Handling
- Use custom exception classes
- Map exceptions to HTTP status codes
- Include request context in error logs
- Never expose internal errors to clients
- Use exception handlers globally

```python
from fastapi import Request, status
from fastapi.responses import JSONResponse

class DomainException(Exception):
    def __init__(self, message: str, status_code: int = status.HTTP_400_BAD_REQUEST):
        self.message = message
        self.status_code = status_code
        super().__init__(self.message)

@app.exception_handler(DomainException)
async def domain_exception_handler(request: Request, exc: DomainException):
    logger.error('Domain exception occurred',
                 extra={'path': request.url.path, 'error': exc.message})
    return JSONResponse(
        status_code=exc.status_code,
        content={'detail': exc.message}
    )
```

### Database Operations
```python
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import Optional

class UserRepository:
    def __init__(self, session: AsyncSession):
        self.session = session
    
    async def get_by_id(self, user_id: str) -> Optional[User]:
        logger.debug('Fetching user by ID', extra={'user_id': user_id})
        
        result = await self.session.execute(
            select(User).where(User.id == user_id)
        )
        user = result.scalar_one_or_none()
        
        logger.debug('User fetch completed', 
                     extra={'user_id': user_id, 'found': user is not None})
        
        return user
```

### Testing
- Use pytest with pytest-asyncio
- Separate unit and integration tests
- Mock external dependencies
- Test error paths and edge cases
- Use fixtures for common setup

### Security and Compliance
- Use JWT or session tokens with rotation; store secrets in env/Key Vault, never in code
- Enforce CORS allowlist, HTTPS only, and sensible rate limits (e.g., FastAPI-limiter/Redis)
- Validate all inputs with Pydantic; reject oversized payloads; cap file uploads
- Log with minimal PII; scrub secrets from logs and traces
- Use dependency-injected permission checks and role-based authorization

### Database and Migrations
- Use SQLAlchemy 2.0 style; keep queries async
- Manage schema changes with Alembic; one migration per PR; autogenerate then review
- Wrap operations in transactions; set sensible timeouts and connection pool limits

### Performance and Resilience
- Avoid blocking calls in async code; prefer async HTTP/DB clients
- Configure connection pooling/backoff; add circuit breakers for critical upstreams
- Set request/DB timeouts; cap payload sizes; use gzip/brotli where appropriate
- Add caching where safe; expose health and readiness probes

### Code Quality and Formatting
- Type hints mandatory for all functions
- Maximum function length: 50 lines
- Maximum cyclomatic complexity: 10
- Fix all SonarLint issues immediately

**Python Formatting Stack:**
1. **ruff** — lint and organize imports
2. **black** — final formatter

Run locally:
```bash
ruff check . --fix
black .
```

**Pre-commit (lint/format only):**
```bash
pre-commit install
pre-commit run --all-files
```

**ruff configuration** (`pyproject.toml`):
```toml
[tool.ruff]
line-length = 120
target-version = "py311"
select = [
    "E",   # pycodestyle errors
    "W",   # pycodestyle warnings
    "F",   # pyflakes
    "I",   # isort
    "B",   # flake8-bugbear
    "C4",  # flake8-comprehensions
    "UP",  # pyupgrade
    "ARG", # flake8-unused-arguments
    "SIM", # flake8-simplify
]
ignore = ["E501"]  # Line too long (handled by black)

[tool.ruff.isort]
known-first-party = ["src"]

[tool.black]
line-length = 120
target-version = ["py311"]
include = "\\.pyi?$"
```

### Documentation
- OpenAPI schema auto-generated and accurate
- Docstrings for all public functions using Google style
- README with setup, deployment, and API docs
- Document environment variables

### TODO Management
Maintain TODO.md with:
- API endpoint implementations pending
- Performance optimizations needed
- Security improvements required
- Database migrations pending
- Test coverage gaps

## Anti-Patterns to Avoid
- No business logic in route handlers
- No raw SQL strings; use ORM query builder
- No synchronous blocking calls in async functions
- No global mutable state
- No overly broad exception catching
