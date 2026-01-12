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
