version: '3'
services:
  ollama:
    image: ollama/ollama:latest@sha256:1e12ddab3f8272d7de9248de649b084568b49115c72561a34b43a137db1e6885
    ports:
      - "11434:11434"
    environment:
      - OLLAMA_HOST=0.0.0.0
      - CUDA_HOME=/usr/local/cuda
      - CUDA_VISIBLE_DEVICES=0
      - LD_LIBRARY_PATH=/usr/local/cuda/lib64
      - NVIDIA_DRIVER_CAPABILITIES=compute,utility
      - NVIDIA_VISIBLE_DEVICES=all
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              capabilities: [gpu]
      restart_policy:
        condition: any
        delay: 5s
        max_attempts: 0
        window: 0s
      placement:
        constraints: [node.role == manager]
    runtime: nvidia
