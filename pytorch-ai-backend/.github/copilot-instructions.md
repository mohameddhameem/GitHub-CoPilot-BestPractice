# GitHub Copilot Instructions - PyTorch AI Model Backend

## ML Engineering Best Practices

### Project Structure
```
src/
├── api/
│   ├── routes/         # Inference endpoints
│   └── dependencies.py # DI for model loading
├── core/
│   ├── config.py       # Pydantic settings
│   └── logging.py      # Structured logging
├── models/
│   ├── schemas.py      # Pydantic request/response models
│   ├── architectures/  # Model architectures
│   └── registry.py     # Model registry
├── services/
│   ├── inference.py    # Inference logic
│   ├── preprocessing.py # Data preprocessing
│   └── postprocessing.py # Output processing
├── monitoring/         # Model performance monitoring
└── utils/
    ├── model_loader.py # Model loading utilities
    └── optimizers.py   # Inference optimizers
```

### Pydantic Models (MANDATORY)
```python
from pydantic import BaseModel, Field, field_validator, ConfigDict
from typing import Optional, Literal
import numpy as np

class InferenceRequest(BaseModel):
    model_config = ConfigDict(arbitrary_types_allowed=True)
    
    input_data: list[float] = Field(..., min_length=1)
    model_version: str = Field(default='v1.0')
    batch_size: int = Field(default=1, gt=0, le=128)
    
    @field_validator('input_data')
    @classmethod
    def validate_input_shape(cls, v: list[float]) -> list[float]:
        if len(v) != 784:  # Example: MNIST input
            raise ValueError(f'Expected 784 features, got {len(v)}')
        return v

class InferenceResponse(BaseModel):
    model_config = ConfigDict(arbitrary_types_allowed=True)
    
    predictions: list[float]
    confidence_scores: list[float]
    model_version: str
    inference_time_ms: float
    preprocessing_time_ms: float
    postprocessing_time_ms: float
```

### Model Configuration
```python
from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict
from pathlib import Path

class ModelSettings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file='.env',
        case_sensitive=False
    )
    
    model_path: Path = Field(..., validation_alias='MODEL_PATH')
    model_type: Literal['onnx', 'torchscript', 'pytorch'] = Field(default='onnx')
    device: Literal['cpu', 'cuda', 'mps'] = Field(default='cpu')
    batch_size: int = Field(default=8, gt=0)
    use_fp16: bool = Field(default=False)
    enable_onnx_optimization: bool = Field(default=True)
    cache_size: int = Field(default=100, ge=0)

settings = ModelSettings()
```

### Inference Optimization (CRITICAL)
```python
import torch
import onnxruntime as ort
from typing import Union
import numpy as np
import logging
from functools import lru_cache
from time import perf_counter

logger = logging.getLogger(__name__)

class InferenceEngine:
    def __init__(self, settings: ModelSettings):
        self.settings = settings
        self.model = self._load_optimized_model()
        logger.info('Inference engine initialized', 
                   extra={'model_type': settings.model_type, 'device': settings.device})
    
    def _load_optimized_model(self) -> Union[ort.InferenceSession, torch.nn.Module]:
        """Load model with optimal inference backend."""
        logger.info('Loading model', extra={'path': str(self.settings.model_path)})
        
        if self.settings.model_type == 'onnx':
            # ONNX Runtime provides fastest inference for most models
            providers = ['CUDAExecutionProvider', 'CPUExecutionProvider']
            session_options = ort.SessionOptions()
            session_options.graph_optimization_level = ort.GraphOptimizationLevel.ORT_ENABLE_ALL
            session_options.intra_op_num_threads = 4
            
            model = ort.InferenceSession(
                str(self.settings.model_path),
                sess_options=session_options,
                providers=providers
            )
            logger.info('ONNX model loaded with optimizations', 
                       extra={'providers': model.get_providers()})
            return model
            
        elif self.settings.model_type == 'torchscript':
            # TorchScript for PyTorch-specific optimizations
            model = torch.jit.load(str(self.settings.model_path))
            model.eval()
            if self.settings.device == 'cuda':
                model = model.cuda()
                if self.settings.use_fp16:
                    model = model.half()
            logger.info('TorchScript model loaded')
            return model
            
        else:
            # Standard PyTorch model (slowest, use only if necessary)
            logger.warning('Using standard PyTorch model - consider converting to ONNX or TorchScript')
            model = torch.load(str(self.settings.model_path))
            model.eval()
            return model
    
    @torch.inference_mode()  # Faster than torch.no_grad()
    async def predict(self, input_data: np.ndarray) -> np.ndarray:
        """Run optimized inference."""
        start_time = perf_counter()
        
        logger.info('Starting inference', 
                   extra={'input_shape': input_data.shape, 'dtype': str(input_data.dtype)})
        
        if self.settings.model_type == 'onnx':
            # ONNX inference (fastest)
            input_name = self.model.get_inputs()[0].name
            output = self.model.run(None, {input_name: input_data})[0]
        else:
            # PyTorch inference
            input_tensor = torch.from_numpy(input_data)
            if self.settings.device == 'cuda':
                input_tensor = input_tensor.cuda()
                if self.settings.use_fp16:
                    input_tensor = input_tensor.half()
            
            output = self.model(input_tensor)
            output = output.cpu().numpy()
        
        inference_time = (perf_counter() - start_time) * 1000
        
        logger.info('Inference completed', 
                   extra={
                       'output_shape': output.shape,
                       'inference_time_ms': round(inference_time, 2),
                       'throughput_samples_per_sec': round(len(output) / (inference_time / 1000), 2)
                   })
        
        return output
```

### Data Pipeline with Logging
```python
from typing import Tuple
import numpy as np
from time import perf_counter

class DataPreprocessor:
    @staticmethod
    def preprocess(raw_data: list[float]) -> Tuple[np.ndarray, float]:
        """Preprocess input data with comprehensive logging."""
        start_time = perf_counter()
        
        logger.info('Starting preprocessing', 
                   extra={'raw_data_length': len(raw_data)})
        
        # Convert to numpy
        data = np.array(raw_data, dtype=np.float32)
        logger.debug('Converted to numpy', extra={'shape': data.shape, 'dtype': str(data.dtype)})
        
        # Normalize
        original_min, original_max = data.min(), data.max()
        data = (data - data.mean()) / (data.std() + 1e-8)
        logger.debug('Normalized data', 
                    extra={'original_range': (float(original_min), float(original_max)),
                           'new_range': (float(data.min()), float(data.max()))})
        
        # Reshape for model
        data = data.reshape(1, -1)
        
        preprocessing_time = (perf_counter() - start_time) * 1000
        logger.info('Preprocessing completed', 
                   extra={
                       'output_shape': data.shape,
                       'preprocessing_time_ms': round(preprocessing_time, 2)
                   })
        
        return data, preprocessing_time
```

### Batching for Throughput
```python
from typing import List
import asyncio

class BatchInferenceService:
    def __init__(self, engine: InferenceEngine, max_batch_size: int = 32):
        self.engine = engine
        self.max_batch_size = max_batch_size
        self._batch_queue: List[dict] = []
        self._lock = asyncio.Lock()
    
    async def infer_with_batching(self, input_data: np.ndarray) -> np.ndarray:
        """Batch multiple requests for better throughput."""
        async with self._lock:
            self._batch_queue.append({'data': input_data, 'future': asyncio.Future()})
            
            if len(self._batch_queue) >= self.max_batch_size:
                await self._process_batch()
            
        return await self._batch_queue[-1]['future']
    
    async def _process_batch(self):
        """Process accumulated batch."""
        if not self._batch_queue:
            return
        
        logger.info('Processing batch', extra={'batch_size': len(self._batch_queue)})
        
        batch_data = np.vstack([item['data'] for item in self._batch_queue])
        results = await self.engine.predict(batch_data)
        
        for i, item in enumerate(self._batch_queue):
            item['future'].set_result(results[i])
        
        self._batch_queue.clear()
```

### API Endpoint Structure
```python
from fastapi import APIRouter, Depends, HTTPException, status
from typing import Annotated
import logging

logger = logging.getLogger(__name__)
router = APIRouter(prefix='/inference', tags=['inference'])

@router.post('/predict', response_model=InferenceResponse)
async def predict(
    request: InferenceRequest,
    engine: Annotated[InferenceEngine, Depends(get_inference_engine)],
) -> InferenceResponse:
    """Run model inference with comprehensive logging."""
    logger.info('Prediction request received', 
               extra={'model_version': request.model_version, 
                      'input_size': len(request.input_data)})
    
    try:
        # Preprocessing
        preprocessed_data, preprocess_time = DataPreprocessor.preprocess(request.input_data)
        
        # Inference
        start_inference = perf_counter()
        predictions = await engine.predict(preprocessed_data)
        inference_time = (perf_counter() - start_inference) * 1000
        
        # Postprocessing
        start_postprocess = perf_counter()
        processed_predictions = postprocess_predictions(predictions)
        postprocess_time = (perf_counter() - start_postprocess) * 1000
        
        logger.info('Prediction completed successfully',
                   extra={
                       'total_time_ms': round(preprocess_time + inference_time + postprocess_time, 2),
                       'predictions_count': len(processed_predictions)
                   })
        
        return InferenceResponse(
            predictions=processed_predictions['values'],
            confidence_scores=processed_predictions['confidences'],
            model_version=request.model_version,
            inference_time_ms=round(inference_time, 2),
            preprocessing_time_ms=round(preprocess_time, 2),
            postprocessing_time_ms=round(postprocess_time, 2)
        )
        
    except Exception as e:
        logger.error('Prediction failed', 
                    extra={'error': str(e), 'error_type': type(e).__name__},
                    exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail='Inference failed'
        ) from e
```

### Model Monitoring
```python
from dataclasses import dataclass
from collections import deque
from typing import Deque
import numpy as np

@dataclass
class ModelMetrics:
    inference_times: Deque[float]
    prediction_distributions: Deque[np.ndarray]
    error_count: int
    total_requests: int
    
    def update(self, inference_time: float, predictions: np.ndarray, error: bool = False):
        self.inference_times.append(inference_time)
        self.prediction_distributions.append(predictions)
        self.total_requests += 1
        if error:
            self.error_count += 1
    
    def get_statistics(self) -> dict:
        return {
            'avg_inference_time_ms': np.mean(self.inference_times),
            'p95_inference_time_ms': np.percentile(self.inference_times, 95),
            'p99_inference_time_ms': np.percentile(self.inference_times, 99),
            'error_rate': self.error_count / self.total_requests if self.total_requests > 0 else 0,
            'total_requests': self.total_requests
        }

metrics = ModelMetrics(
    inference_times=deque(maxlen=1000),
    prediction_distributions=deque(maxlen=1000),
    error_count=0,
    total_requests=0
)
```

### Testing
- Unit tests for preprocessing/postprocessing
- Integration tests for full inference pipeline
- Performance benchmarks for latency and throughput
- Test with edge cases and adversarial inputs
- Validate model outputs against expected ranges

### Model Governance and Artifacts
- Version every model artifact; store in a registry (path includes model type + version)
- Keep hashes/size/created_at in metadata for integrity
- Document training data, eval metrics, and intended use in a model card

### Reliability, Performance, and Safety
- Provide GPU/CPU fallback: prefer CUDA when available, otherwise CPU with thread limits
- Add warmup on startup to populate caches and JIT paths
- Cap batch sizes and memory usage; expose backpressure when queues grow
- Use torch.inference_mode(); avoid global mutable state in shared engines
- Scrub PII from logs; validate inputs for shape/range before inference

### Code Quality and Formatting
- Type hints for all functions including numpy array shapes in docstrings
- Profile inference pipeline to identify bottlenecks
- Fix all SonarLint issues

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
    "NPY", # NumPy-specific rules
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
- Model card with architecture, performance metrics, limitations
- API documentation with example requests/responses
- Deployment guide with hardware requirements
- Monitoring and alerting setup

### TODO Management
Maintain TODO.md with:
- Model optimization experiments (quantization, pruning)
- Performance benchmarking results
- A/B testing plans
- Model retraining schedules
- Infrastructure scaling requirements

## Inference Optimization Checklist
- [ ] Convert model to ONNX or TorchScript
- [ ] Enable graph optimizations
- [ ] Use appropriate execution providers (CUDA, TensorRT)
- [ ] Implement batching for throughput
- [ ] Consider FP16 inference on supported hardware
- [ ] Profile and eliminate bottlenecks
- [ ] Implement model caching
- [ ] Use torch.inference_mode() instead of torch.no_grad()
- [ ] Optimize preprocessing pipeline
- [ ] Monitor inference latency and throughput

## Anti-Patterns to Avoid
- No model loading on every request
- No synchronous blocking in async inference
- No missing input validation
- No unhandled tensor shape mismatches
- No ignoring device placement (CPU vs GPU)

**NumPy array type hints** (use in docstrings):
```python
def preprocess(data: np.ndarray) -> np.ndarray:
    """
    Preprocess input data.
    
    Args:
        data: Input array of shape (batch_size, features)
        
    Returns:
        Normalized array of shape (batch_size, features)
    """
```
