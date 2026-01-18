# AGENTS.md - PyTorch AI Backend

## Project Context
This is a PyTorch inference service. See root [AGENTS.md](../AGENTS.md) for repo-wide guidance.

## Key Files
- `src/main.py` - FastAPI app with inference endpoints
- `src/models/` - Pydantic schemas and model architectures
- `src/services/inference.py` - Core inference logic

## Before Making Changes
1. Check model loading patterns - models load once at startup
2. Validate input shapes match expected dimensions
3. Use `torch.inference_mode()` not `torch.no_grad()`

## Commands
```bash
# Development
uvicorn src.main:app --reload

# Lint and format
ruff check . --fix && black .

# Test
pytest tests/ -v

# Benchmark
python -m pytest benchmarks/ --benchmark-only
```

## Model Updates
- Store model artifacts with version + hash in `model-registry/`
- Update model cards with training data and eval metrics
- Run benchmark comparison before deploying new models
