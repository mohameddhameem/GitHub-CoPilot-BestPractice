applyTo: "**/*.py"
---

# Python Standards

## Precedence
- Workspace root guidance in [.github/copilot-instructions.md](../copilot-instructions.md) applies first. Python guidance here is the baseline for all `.py` files. If a stack-specific file (FastAPI, PyTorch) conflicts, the stack file takes precedence; otherwise, inherit these rules.

## Pydantic v2 (Mandatory)
- Goal: enforce consistent validation and config handling with Pydantic v2.
- Use Pydantic v2 for all data validation
- Define models for requests, responses, and configurations
- Use `ConfigDict` for model configuration
- Use `Field` for validation and documentation
- Use `field_validator` for custom validation
- Legacy interop: if Pydantic v1 models are encountered, prefer migrating; temporary shims allowed only with an owner, issue link, and removal date noted in code comments.

```python
from pydantic import BaseModel, Field, field_validator, ConfigDict

class ExampleModel(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True, validate_assignment=True)
    
    name: str = Field(..., min_length=1, max_length=100)
    
    @field_validator('name')
    @classmethod
    def validate_name(cls, v: str) -> str:
        return v.strip()
```

## Configuration with pydantic-settings
- Goal: load settings from environment safely and predictably.
```python
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file='.env', case_sensitive=False)
    
    app_name: str = Field(default='App')
    debug: bool = Field(default=False)
```

## Type Hints
- Goal: make interfaces explicit and analyzable.
- Type hints mandatory for all functions
- Use `typing.Annotated` for dependency injection
- Document numpy array shapes in docstrings

## Structured Logging
- Goal: produce auditable, non-sensitive logs with context.
- Log before and after significant data manipulation
- Include contextual information: timestamps, data shapes, key values
- Use appropriate log levels (DEBUG, INFO, WARNING, ERROR)
- Never log secrets or PII
- Minimum fields: event, scope/module, correlation/request id, status/outcome, duration_ms when applicable.
- Example schema: `{ "event": "process_data", "scope": "service.users", "request_id": "...", "status": "ok", "duration_ms": 12 }`.

```python
import logging
logger = logging.getLogger(__name__)

def process_data(data: list) -> list:
    logger.info('Starting processing', extra={'count': len(data)})
    result = transform(data)
    logger.info('Processing complete', extra={'input': len(data), 'output': len(result)})
    return result
```

## Async Patterns
- Goal: keep event loops non-blocking and resilient.
- Avoid blocking calls in async code; offload CPU-bound work to executors
- Use async HTTP/DB clients
- Wrap operations in transactions where appropriate
- Good: `await session.execute(...)` with timeouts. Bad: `requests.get()` inside `async def`.

## Code Quality
- Goal: keep code small, readable, and analyzable.
- Maximum function length: 50 lines
- Maximum cyclomatic complexity: 10
- Fix all linter issues before commit

## Formatting and CI hooks
- Goal: keep style and linting automated and consistent with setup scripts.
- Run before commit:
```bash
ruff check . --fix
black .
pre-commit run --all-files
```
*CI expectation*: same commands run in CI; fixes must be committed.

## Anti-Patterns to Avoid
- Goal: eliminate patterns that hide bugs or harm performance.
- No synchronous blocking calls in async functions
- No global mutable state
- No overly broad exception catching
- No raw SQL strings; use ORM query builder
- No silent failures; log and re-raise with context instead of bare except/return
