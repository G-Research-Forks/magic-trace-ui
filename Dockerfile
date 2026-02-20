# Multi-stage Dockerfile for building and serving Perfetto UI
# Stage 1: Builder - Install dependencies and build the UI
FROM debian:bookworm-slim AS builder

# Install system dependencies required for building
RUN apt-get update && \
    apt-get install -y \
        python3 \
        python3-pip \
        git \
        curl \
        tar \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Copy the entire repository
COPY . .

# Initialize a git repo (required by install-build-deps for git clean)
RUN git config --global user.email "docker@build" && \
    git config --global user.name "Docker Build"

# Install build dependencies (downloads Node.js, build tools, etc.)
RUN tools/install-build-deps --ui

# Build the UI (output goes to out/ui/dist)
RUN ui/build

# Stage 2: Runtime - Serve the built UI with nginx
FROM nginxinc/nginx-unprivileged

# Copy built UI from builder stage
COPY --from=builder /workspace/out/ui/ui/dist /usr/share/nginx/html

# Expose port 8080 (nginx-unprivileged default)
EXPOSE 8080
