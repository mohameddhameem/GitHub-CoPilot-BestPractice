---
applyTo: "pytorch-ai-backend/**/*.py"
---

# PyTorch Inference Backend

## Project Structure
```
src/
  api/
    routes/           # Inference endpoints
    dependencies.py   # DI for model loading
  core/
    config.py         # Pydantic settings
    logging.py        # Structured logging
  models/
    schemas.py        # Pydantic request/response models
    architectures/    # Model architectures
    registry.py       # Model registry
  services/
    inference.py      # Inference logic
    preprocessing.py  # Data preprocessing
    postprocessing.py # Output processing
  monitoring/         # Model performance monitoring
  utils/
    model_loader.py   # Model loading utilities
    optimizers.py     # Inference optimizers
```

## Inference Request/Response Models
```python
from pydantic import BaseModel, Field, field_validator, ConfigDict

class InferenceRequest(BaseModel):
    model_config = ConfigDict(arbitrary_types_allowed=True)
    
    input_data: list[float] = Field(..., min_length=1)
    model_version: str = Field(default='v1.0')
    batch_size: int = Field(default=1, gt=0, le=128)
    
    @field_validator('input_data')
    @classmethod
    def validate_shape(cls, v):
        if len(v) != 784:
            raise ValueError(f'Expected 784 features, got {len(v)}')
        return v

class InferenceResponse(BaseModel):
    predictions: list[float]
    confidence_scores: list[float]
    model_version: str
    inference_time_ms: float
```

## Model Loading
- Load models once at startup, not per request
- Prefer ONNX Runtime or TorchScript over raw PyTorch
- Use `torch.inference_mode()` instead of `torch.no_grad()`

```python
import torch
import onnxruntime as ort

class InferenceEngine:
    def __init__(self, settings):
        self.model = self._load_model(settings)
    
    def _load_model(self, settings):
        if settings.model_type == 'onnx':
            opts = ort.SessionOptions()
            opts.graph_optimization_level = ort.GraphOptimizationLevel.ORT_ENABLE_ALL
            return ort.InferenceSession(str(settings.model_path), sess_options=opts)
        elif settings.model_type == 'torchscript':
            model = torch.jit.load(str(settings.model_path))
            model.eval()
            return model
```

## Inference with Logging
```python
from time import perf_counter

@torch.inference_mode()
async def predict(self, input_data):
    start = perf_counter()
    logger.info('Starting inference', extra={'shape': input_data.shape})
    
    output = self.model.run(None, {'input': input_data})[0]
    
    elapsed = (perf_counter() - start) * 1000
    logger.info('Inference complete', extra={'time_ms': round(elapsed, 2)})
    return output
```

## Batching for Throughput
- Batch multiple requests for better GPU utilization
- Cap batch sizes to control memory usage
- Expose backpressure when queues grow

## Device Placement
- Prefer CUDA when available; fallback to CPU
- Set thread limits for CPU inference
- Use FP16 on supported hardware

## Model Governance
- Version every model artifact
- Store hashes and metadata for integrity
- Document training data and eval metrics in model card

## Reliability
- Add warmup on startup to populate caches
- Validate input shapes and ranges before inference
- Scrub PII from logs

## Testing
- Unit tests for preprocessing/postprocessing
- Integration tests for full pipeline
- Performance benchmarks for latency and throughput
- Validate outputs against expected ranges

## Optimization Checklist
- Convert model to ONNX or TorchScript
- Enable graph optimizations
- Implement batching
- Profile and eliminate bottlenecks
- Monitor inference latency
