# OpenPrime PostgreSQL

PostgreSQL database for the OpenPrime infrastructure management platform.

## Overview

This repository contains a Helm chart for deploying PostgreSQL to Kubernetes as part of the OpenPrime platform.

## Helm Chart

Deploy PostgreSQL to Kubernetes:

```bash
helm install openprime-postgres ./chart
```

## Configuration

See `chart/values.yaml` for all available configuration options.

### Key Settings

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.tag` | PostgreSQL image tag | `15-alpine` |
| `persistence.size` | Storage size | `10Gi` |
| `postgresql.databases` | Databases to create | `openprime`, `keycloak` |

## Backup & Restore

A daily CronJob (`backup.enabled`, off by default) dumps the whole cluster and
uploads it to S3:

`pg_dumpall --clean` → `gzip -9` → `gzip -t` → size floor (`backup.minBytes`) →
`aws s3 cp s3://<bucket>/<prefix>/YYYY/MM/DD/postgres-<timestamp>.sql.gz`

`pg_dumpall` is used rather than `pg_dump` so roles are captured too — a restore
that loses the `openprime_user` / `keycloak_user` roles restores tables nothing
can read. `gzip -t` and the size floor exist because a truncated or near-empty
dump is still a *valid* gzip and would otherwise upload happily.

The IAM role behind the ServiceAccount is expected to be write-only:
`s3:PutObject` on the prefix and nothing else. The pod then cannot read a dump
back, list what exists, or delete one, so a compromised database pod cannot use
the backup path to exfiltrate the data or destroy its own backups.

### Restoring

> [!WARNING]
> Restore into `postgres:15-alpine`, not an arbitrary PostgreSQL 15.
> The dump carries the glibc locale name `en_US.utf8`; on a platform that
> spells it `en_US.UTF-8` (macOS, for instance) `psql` stops at
> `CREATE DATABASE` and restores **only the roles** — which looks like partial
> success rather than a failure.

```bash
aws s3 cp s3://<bucket>/<prefix>/<YYYY/MM/DD>/<dump>.sql.gz .
gzip -t <dump>.sql.gz            # verify before trusting it
gunzip -c <dump>.sql.gz | psql -h <host> -U postgres
```

A dump holds every user record and every encrypted cloud credential. Delete
local copies and any scratch database once the restore is verified.

### After a failed backup run

`backup.failedJobsHistoryLimit` keeps failed Jobs for investigation, and the
`KubeJobFailed` alert fires on their mere existence — a later successful run
does **not** clear it. Once you have investigated, delete the Job object:

```bash
kubectl -n <namespace> delete job <release>-backup-<id>
```

Leaving it behind keeps a resolved incident alerting the whole cluster
indefinitely.

## Database Schema

The OpenPrime backend uses Sequelize ORM with the following main tables:
- `users` - User accounts linked to Keycloak
- `environments` - Infrastructure environment configurations (JSONB)
- `cloud_credentials` - Encrypted cloud provider credentials

## Development

### Local Development

Use the main development environment from `openprime-local-testing`:

```bash
cd ../openprime-local-testing
npm start
```

PostgreSQL will be available at localhost:5432

### Database Shell

```bash
cd ../openprime-local-testing
npm run db:shell
```

## Related Repositories

- [openprime-app-backend](https://github.com/devopsgroupeu/openprime-app-backend) - Backend API using this database
- [openprime-local-testing](https://github.com/devopsgroupeu/openprime-local-testing) - Development environment

## License

Apache License 2.0 - see [LICENSE](LICENSE) for details.
