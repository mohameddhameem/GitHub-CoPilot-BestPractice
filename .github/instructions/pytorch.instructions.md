---
applyTo: "pytorch-ai-backend/**/*.py"
---

# PyTorch Inference Backend

## Precedence
Root guidance → [python.instructions.md](python.instructions.md) → this file.

## Project Structure
```
src/
  api/routes/           # Inference endpoints
  models/schemas.py     # Pydantic request/response
  models/architectures/ # Model definitions
  services/inference.py # Core inference logic
  utils/model_loader.py # Loading utilities
```

## Request/Response Validation
```python
class InferenceRequest(BaseModel):
    model_config = ConfigDict(arbitrary_types_allowed=True)
    input_data: list[float] = Field(..., min_length=1)

    @field_validator('input_data')
    @classmethod
    def validate_shape(cls, v):
        if len(v) != 784:
            raise ValueError(f'Expected 784 features, got {len(v)}')
        return v
```

## Model Loading
- Load once at startup, not per request
- Prefer ONNX Runtime or TorchScript over raw PyTorch
- Use `torch.inference_mode()` instead of `torch.no_grad()`

## Inference
- Log latency (time_ms) and input shapes; never log PII
- Use bounded queues + max batch size for throughput

## Device Placement
- CUDA when available, fallback to CPU
- Set `OMP_NUM_THREADS`/`MKL_NUM_THREADS` explicitly for CPU

## Model Governance
- Version all artifacts; store hash + metadata in `model-registry/`
- Document training data and eval metrics in model cards

## Testing
- Happy path + invalid-shape + out-of-range per model entrypoint
- Maintain latency benchmarks under `benchmarks/`

## Formatting
```bash
ruff check pytorch-ai-backend --fix && black pytorch-ai-backend
```
