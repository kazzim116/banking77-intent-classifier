# ---------------------------------------------------------------------------
# Base image
# ---------------------------------------------------------------------------

# CPU-only: we don't need an nvidia/cuda base image since we're not using GPU.
FROM python:3.12-slim

# ---------------------------------------------------------------------------
# Working directory
# ---------------------------------------------------------------------------

WORKDIR /app

# ---------------------------------------------------------------------------
# Install system dependencies
# ---------------------------------------------------------------------------

# --no-install-recommends keeps the image lean by skipping optional packages.
# rm -rf /var/lib/apt/lists/* clears the apt cache to reduce image size.
RUN apt-get update && apt-get install -y \
    build-essential \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------------
# Install Python dependencies
# ---------------------------------------------------------------------------

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

# Install CPU-only PyTorch explicitly 
RUN pip install --no-cache-dir \
    torch --index-url https://download.pytorch.org/whl/cpu

# ---------------------------------------------------------------------------
# Copy application code
# ---------------------------------------------------------------------------
COPY app/ ./app/

# ---------------------------------------------------------------------------
# Copy model weights
# ---------------------------------------------------------------------------
COPY models/banking77-distilbert ./models/banking77-distilbert

# ---------------------------------------------------------------------------
# Expose port
# ---------------------------------------------------------------------------
EXPOSE 8000

# ---------------------------------------------------------------------------
# Start the server
# ---------------------------------------------------------------------------
#
# --host 0.0.0.0 is critical: without it uvicorn binds to 127.0.0.1
# (localhost inside the container) and the container is unreachable
# from outside. 0.0.0.0 means "accept connections on all interfaces."
#
# --workers 1 — one worker process
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]