import logging

import torch
import torch.nn as nn
from fastapi import FastAPI
from pydantic import BaseModel, ConfigDict, Field

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class InferenceRequest(BaseModel):
    model_config = ConfigDict(validate_assignment=True)
    data: list[float] = Field(..., min_length=1, description="Input data for inference")


class InferenceResponse(BaseModel):
    prediction: list[float]
    status: str


app = FastAPI(title="Multi-Stack Starter Kit - PyTorch AI Backend")


class SimpleModel(nn.Module):
    def __init__(self):
        super().__init__()
        self.linear = nn.Linear(10, 1)

    def forward(self, x):
        return self.linear(x)


model = SimpleModel()
model.eval()


@app.post("/predict", response_model=InferenceResponse)
async def predict(request: InferenceRequest):
    logger.info("Inference request received", extra={"data_length": len(request.data)})

    # Placeholder inference logic
    try:
        input_tensor = torch.tensor(request.data).unsqueeze(0)
        # Ensure input has 10 features for our dummy model
        if input_tensor.shape[1] < 10:
            input_tensor = torch.cat([input_tensor, torch.zeros(1, 10 - input_tensor.shape[1])], dim=1)
        elif input_tensor.shape[1] > 10:
            input_tensor = input_tensor[:, :10]

        with torch.no_grad():
            output = model(input_tensor)

        return InferenceResponse(prediction=output.squeeze(0).tolist(), status="success")
    except Exception as e:
        logger.error("Inference failed", exc_info=True)
        return InferenceResponse(prediction=[], status=f"error: {e!s}")


@app.get("/health")
async def health():
    return {"status": "healthy", "torch_version": torch.__version__, "cuda_available": torch.cuda.is_available()}
