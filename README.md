[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/libsql-server?utm_medium=integration&utm_source=button&utm_campaign=libsql-server)

# libSQL Server on Railway

A Railway template for [libSQL Server](https://github.com/tursodatabase/libsql) (`sqld`), the server mode of libSQL, Turso's open-source, open-contribution fork of SQLite. Your apps talk to it over HTTP or WebSockets with any libSQL client (`@libsql/client`, `libsql` for Python, Rust and Go), and they can keep a local embedded replica in sync with it.

## What it deploys

| Service | Source | Notes |
|---|---|---|
| `libSQL` | this repo (`Dockerfile`) | libSQL Server **v0.24.33**, `ghcr.io/tursodatabase/libsql-server:v0.24.33@sha256:f8ca0134cdded747793888e48591aece07647d9d598d3ac229aabfa93159ca88`. Public domain on port 8080, health check `/health`, volume at `/var/lib/sqld` (the database and its write-ahead log). |

`railway-start.sh` turns authentication on before the server starts: the template generates `SQLD_AUTH_TOKEN`, and every query must send it as `Authorization: Bearer <token>`. libSQL clients do that when you pass the token as `authToken`. The script refuses to start with no authentication at all. `/health` and `/version` answer without the token.

## Connecting

```js
import { createClient } from "@libsql/client";

const db = createClient({
  url: process.env.LIBSQL_URL,            // libsql://YOUR-DOMAIN.up.railway.app
  authToken: process.env.SQLD_AUTH_TOKEN,
});
await db.execute("SELECT 1");
```

From another service in the same Railway project, use the private network and skip the public proxy:

```
LIBSQL_URL=${{libSQL.LIBSQL_PRIVATE_URL}}
LIBSQL_AUTH_TOKEN=${{libSQL.SQLD_AUTH_TOKEN}}
```

Embedded replicas work too: `createClient({ url: "file:local.db", syncUrl: process.env.LIBSQL_URL, authToken })`, then `await db.sync()`.

Plain HTTP also works: `curl -H "Authorization: Bearer $SQLD_AUTH_TOKEN" -d '{"statements":["SELECT 1"]}' https://YOUR-DOMAIN.up.railway.app/`.

## Variables

| Variable | Default | Purpose |
|---|---|---|
| `SQLD_AUTH_TOKEN` | `${{secret(40,…)}}` (letters and digits) | Access token. Clients send it as `authToken` / `Authorization: Bearer`. To rotate it, change the value and redeploy. |
| `PORT` | `8080` | HTTP port sqld listens on (all interfaces, IPv4 and IPv6). |
| `LIBSQL_URL` | `libsql://${{RAILWAY_PUBLIC_DOMAIN}}` | Public connection URL, for your apps outside Railway. |
| `LIBSQL_PRIVATE_URL` | `http://${{RAILWAY_PRIVATE_DOMAIN}}:${{PORT}}` | Private-network URL, for other services in the project. |

Optional (not in the template; add them to the service if you need them):

- `SQLD_AUTH_JWT_KEY`: an Ed25519 public key (PEM or URL-safe base64). With it set, sqld switches to JWT authentication (Turso-style tokens you sign yourself) and ignores `SQLD_AUTH_TOKEN`.
- `SQLD_NODE=primary`: also opens sqld's internal gRPC port 5001, which sqld read replicas use. The template runs `standalone`, because that port doesn't check client authentication. Embedded replicas don't need it.
- `SQLD_ALLOW_NO_AUTH=true`: runs without authentication. Only do this after removing the public domain.
- Any other `SQLD_*` setting from the [upstream reference](https://github.com/tursodatabase/libsql/blob/libsql-server-v0.24.33/docs/DOCKER.md), for example `SQLD_ENABLE_BOTTOMLESS_REPLICATION` with the `LIBSQL_BOTTOMLESS_*` S3 variables for continuous backups to a bucket.

## Backups

The database lives on the Railway volume. Use Railway's volume backups, or download a SQL dump with `curl -H "Authorization: Bearer $SQLD_AUTH_TOKEN" https://YOUR-DOMAIN.up.railway.app/dump > backup.sql`.

## Updates

The template builds from this repo's `main` branch. When we bump the pinned libSQL Server version, Railway shows deployers an "update available" notice; read [CHANGELOG.md](CHANGELOG.md) before applying it. The data stays on the volume across updates.

## Local test

```sh
docker build -t libsql-railway .
docker run --rm -p 8080:8080 -e SQLD_AUTH_TOKEN=change-me-to-a-long-random-token -v libsql-data:/var/lib/sqld libsql-railway
curl -H "Authorization: Bearer change-me-to-a-long-random-token" -d '{"statements":["SELECT 1"]}' http://localhost:8080/
```

License: the wrapper is MIT; libSQL is MIT.
