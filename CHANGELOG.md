# Changelog

Deployers: read the entry for the version you are moving to before you apply a Railway "update available" notice. Breaking changes come first.

## 0.24.33-railway.1 (2026-11-17)

- First release of the template: libSQL Server v0.24.33 (`ghcr.io/tursodatabase/libsql-server:v0.24.33@sha256:f8ca0134cdded747793888e48591aece07647d9d598d3ac229aabfa93159ca88`).
- Volume at `/var/lib/sqld` for the database.
- Authentication on by default: a generated `SQLD_AUTH_TOKEN` (sent as `authToken` / `Authorization: Bearer`). The server refuses to start without authentication unless `SQLD_ALLOW_NO_AUTH=true`.
- Runs in `standalone` mode on Railway's `PORT`, health check `/health`.
