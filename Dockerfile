# --------------------------------------------------
# Stage 1: Swift WASM Build
# --------------------------------------------------
FROM swift:6.1-jammy AS builder

WORKDIR /app

# Install Node.js (for npm scripts)
RUN apt-get update && \
    apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

RUN swift sdk install "https://github.com/swiftwasm/swift/releases/download/swift-wasm-6.1-RELEASE/swift-wasm-6.1-RELEASE-wasm32-unknown-wasi.artifactbundle.zip" \
    --checksum "7550b4c77a55f4b637c376f5d192f297fe185607003a6212ad608276928db992"

# Copy manifests first (better caching)
COPY Package.swift Package.resolved ./
COPY package.json package-lock.json* ./

RUN npm install

# Copy full project
COPY . .

# Build Swift → WASM
RUN npm run build:main

# --------------------------------------------------
# Stage 2: Assemble dist (structure preserved)
# --------------------------------------------------
FROM node:20-slim AS dist

WORKDIR /dist

# Copy static assets
COPY --from=builder /app/index.html ./index.html
COPY --from=builder /app/assets ./assets
COPY --from=builder /app/.well-known ./.well-known
COPY --from=builder /app/.build ./.build

# Sanity checks (fail fast)
RUN test -f .build/plugins/PackageToJS/outputs/Package/index.js && \
    test -f .build/plugins/PackageToJS/outputs/Package/portfolio.wasm && \
    test -f .well-known/apple-app-site-association

# --------------------------------------------------
# Stage 3: Static runtime (nginx)
# --------------------------------------------------
FROM nginx:alpine AS production

COPY --from=dist /dist /usr/share/nginx/html

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
