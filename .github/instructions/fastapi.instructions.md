---
applyTo: "fastapi-backend/**/*.py"
---

# FastAPI Backend

## Precedence
Root guidance → [python.instructions.md](python.instructions.md) → this file. FastAPI rules override Python baseline where stated.

## Project Structure
```
src/
  api/routes/         # Thin handlers; delegate to services
  core/               # Config, security, logging
  models/             # Pydantic request/response models
  services/           # Business logic
  repositories/       # Data access
  db/                 # SQLAlchemy models, session
```

## Endpoint Pattern
```python
@router.post('/', response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(
    request: UserCreateRequest,
    service: Annotated[UserService, Depends(get_user_service)],
) -> UserResponse:
    user = await service.create_user(request)
    return UserResponse.model_validate(user)
```

## Dependency Injection
- Use async generators for DB sessions with commit/rollback
- Define typed aliases: `DBSession = Annotated[AsyncSession, Depends(get_db_session)]`

## Database
- SQLAlchemy 2.0 async; Alembic migrations (one per PR)
- Set pool limits and timeouts; review autogen SQL before merge

## Error Handling
- Custom exception classes → HTTP status mapping
- Never expose internal errors to clients

## Security
- JWT with rotation; secrets in env/vault; CORS allowlist; validate all inputs

## Testing
- pytest + pytest-asyncio; happy path + 2 error cases per route/service
- Transactional rollbacks per test; shared client fixture with DI overrides

## Formatting
```bash
ruff check fastapi-backend --fix && black fastapi-backend
```
