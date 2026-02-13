FROM debian:bookworm-slim AS builder

# Install system dependencies required for building (detected while trying to run the install-build-deps script)
RUN apt-get update && \
    apt-get install -y \
        python3 \
        python3-pip \
        git \
        curl \
        tar \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

COPY . .

# Initialize a git repo (required by install-build-deps for git clean)
RUN git config --global user.email "docker@build" && \
    git config --global user.name "Docker Build" && \
    git init && \
    git add -A && \
    git commit -m "Initial commit"

RUN tools/install-build-deps --ui

# Build the UI (output goes to out/ui/dist)
RUN ui/build

FROM python:3.11-slim

WORKDIR /app

COPY --from=builder /workspace/out/ui/ui/dist /app/ui

EXPOSE 8080

CMD ["python", "-m", "http.server", "8080", "--directory", "/app/ui"]
