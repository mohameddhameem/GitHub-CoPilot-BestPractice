---
applyTo: "**/*.py"
---

# Python Standards

## Pydantic v2 (Mandatory)
- Use Pydantic v2 for all data validation
- Define models for requests, responses, and configurations
- Use `ConfigDict` for model configuration
- Use `Field` for validation and documentation
- Use `field_validator` for custom validation

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
```python
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file='.env', case_sensitive=False)
    
    app_name: str = Field(default='App')
    debug: bool = Field(default=False)
```

## Type Hints
- Type hints mandatory for all functions
- Use `typing.Annotated` for dependency injection
- Document numpy array shapes in docstrings

## Structured Logging
- Log before and after significant data manipulation
- Include contextual information: timestamps, data shapes, key values
- Use appropriate log levels (DEBUG, INFO, WARNING, ERROR)
- Never log secrets or PII

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
- Avoid blocking calls in async code
- Use async HTTP/DB clients
- Wrap operations in transactions where appropriate

## Code Quality
- Maximum function length: 50 lines
- Maximum cyclomatic complexity: 10
- Fix all linter issues before commit

## Formatting
Run before commit:
```bash
ruff check . --fix
black .
```

## Anti-Patterns to Avoid
- No synchronous blocking calls in async functions
- No global mutable state
- No overly broad exception catching
- No raw SQL strings; use ORM query builder
