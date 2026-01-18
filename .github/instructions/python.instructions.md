---
applyTo: "**/*.py"
---

# Python Standards

## Precedence
Workspace root guidance in [copilot-instructions.md](../copilot-instructions.md) applies first. Stack-specific files (FastAPI, PyTorch) override these rules where stated.

## Pydantic v2 (Mandatory)
- Use Pydantic v2 for all validation; use `ConfigDict`, `Field`, and `field_validator`
- Legacy v1 models: migrate or add shim with owner/issue/removal date

```python
from pydantic import BaseModel, Field, field_validator, ConfigDict

class ExampleModel(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True, validate_assignment=True)
    name: str = Field(..., min_length=1, max_length=100)
```

## Configuration
Use `pydantic-settings` for env-based config with `.env` support.

## Type Hints
- Mandatory for all functions; use `typing.Annotated` for DI
- Document numpy array shapes in docstrings

## Structured Logging
- Log before/after significant operations with context (event, scope, request_id, status, duration_ms)
- Never log secrets or PII

## Async Patterns
- No blocking calls in async code; use async HTTP/DB clients
- Wrap in transactions where appropriate

## Code Quality
- Max function length: 50 lines; max cyclomatic complexity: 10
- Fix all linter issues before commit

## Formatting
```bash
ruff check . --fix && black . && pre-commit run --all-files
```

## Anti-Patterns
- No sync blocking in async functions
- No global mutable state
- No broad exception catching; log and re-raise with context
- No raw SQL; use ORM query builder
