# For amd64 container images
FROM --platform=linux/amd64 ubuntu:22.04 AS runtime-amd64
RUN apt-get update && \
    apt-get install -y ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
COPY --from=container-build-amd64 /go/src/github.com/ollama/ollama/dist/linux-amd64/bin/ /bin/
COPY --from=runners-cuda-amd64 /go/src/github.com/ollama/ollama/dist/linux-amd64/lib/ /lib/

# Generate private key if it does not exist
RUN mkdir -p /root/.ollama && \
    if [! -f /root/.ollama/id_ed25519 ]; then \
        ssh-keygen -t ed25519 -N "" -f /root/.ollama/id_ed25519; \
        echo "Your new public key is: $(cat /root/.ollama/id_ed25519.pub)"; \
    fi

EXPOSE 11434
ENV OLLAMA_HOST 0.0.0.0
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV NVIDIA_VISIBLE_DEVICES=all
ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]

# For arm64 container images
FROM --platform=linux/arm64 ubuntu:22.04 AS runtime-arm64
RUN apt-get update && \
    apt-get install -y ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
COPY --from=container-build-arm64 /go/src/github.com/ollama/ollama/dist/linux-arm64/bin/ /bin/
COPY --from=runners-arm64 /go/src/github.com/ollama/ollama/dist/linux-arm64/lib/ /lib/
COPY --from=runners-jetpack5-arm64 /go/src/github.com/ollama/ollama/dist/linux-arm64-jetpack5/lib/ /lib/
COPY --from=runners-jetpack6-arm64 /go/src/github.com/ollama/ollama/dist/linux-arm64-jetpack6/lib/ /lib/

# Generate private key if it does not exist
RUN mkdir -p /root/.ollama && \
    if [! -f /root/.ollama/id_ed25519 ]; then \
        ssh-keygen -t ed25519 -N "" -f /root/.ollama/id_ed25519; \
        echo "Your new public key is: $(cat /root/.ollama/id_ed25519.pub)"; \
    fi

EXPOSE 11434
ENV OLLAMA_HOST 0.0.0.0
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV NVIDIA_VISIBLE_DEVICES=all
ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]

FROM runtime-$TARGETARCH
EXPOSE 11434
ENV OLLAMA_HOST 0.0.0.0
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV NVIDIA_VISIBLE_DEVICES=all
ENTRYPOINT ["/bin/ollama"]
CMD ["serve"]
