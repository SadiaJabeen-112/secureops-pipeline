# ════════════════════════════════════════════
# SecureOps Pipeline — Multi-Stage Dockerfile
# Stage 1: Build  |  Stage 2: Production
# ════════════════════════════════════════════

# ── STAGE 1: BUILD ──────────────────────────
FROM node:20-alpine AS builder

LABEL maintainer="Sadia Jabeen <sadiajabeen053@gmail.com>"
LABEL description="SecureOps Pipeline - Build Stage"

WORKDIR /build

COPY app/ .

RUN echo "Build stage complete — files validated" && ls -la

# ── STAGE 2: PRODUCTION ─────────────────────
FROM nginx:1.25-alpine AS production

LABEL maintainer="Sadia Jabeen <sadiajabeen053@gmail.com>"
LABEL description="SecureOps Pipeline - Production Stage"
LABEL version="1.0"

RUN addgroup -g 1001 appgroup && \
    adduser -D -u 1001 -G appgroup appuser

RUN rm -rf /usr/share/nginx/html/*

COPY --from=builder /build /usr/share/nginx/html

COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

RUN chown -R appuser:appgroup /usr/share/nginx/html && \
    chown -R appuser:appgroup /var/cache/nginx && \
    chown -R appuser:appgroup /var/log/nginx && \
    touch /var/run/nginx.pid && \
    chown appuser:appgroup /var/run/nginx.pid

USER appuser

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:80/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
