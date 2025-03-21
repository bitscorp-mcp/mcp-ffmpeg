
### Multi-stage Dockerfile for MCP FFmpeg Server

# Stage 1: Builder
FROM node:lts-alpine AS builder

# Install ffmpeg and any build dependencies
RUN apk add --no-cache ffmpeg

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies including dev dependencies (needed for building)
RUN npm install

# Copy the rest of the application source code
COPY . .

# Build the TypeScript code
RUN npm run build

# Stage 2: Production
FROM node:lts-alpine

# Install ffmpeg in production image
RUN apk add --no-cache ffmpeg

# Set working directory
WORKDIR /app

# Copy only the necessary files from builder
COPY package*.json ./

# Install production dependencies only
RUN npm install --production --ignore-scripts

# Copy built files from the builder stage
COPY --from=builder /app/dist ./dist

# Expose port if needed (not needed for stdio-based MCP servers)

# Start the MCP server
CMD [ "node", "dist/mcp-ffmpeg.js" ]