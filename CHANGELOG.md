# Changelog

All notable changes to this project will be documented in this file.

## [0.5.1](https://github.com/devopsgroupeu/openprime-postgres/compare/v0.5.0...v0.5.1) (2026-08-30)

### 🐛 Bug Fixes

* **backup:** give aws-cli a writable HOME so the upload can run as non-root ([c7e10db](https://github.com/devopsgroupeu/openprime-postgres/commit/c7e10db208f2ee42f0fec53bf0a77e63530f6d3c))

## [0.5.0](https://github.com/devopsgroupeu/openprime-postgres/compare/v0.4.2...v0.5.0) (2026-08-10)

### 🚀 Features

* add opt-in pg_dumpall backup CronJob with integrity check and S3 upload ([b39a44c](https://github.com/devopsgroupeu/openprime-postgres/commit/b39a44c6e5ddd0ff6eecade24d9211370bfd79ca))

## [0.4.2](https://github.com/devopsgroupeu/openprime-postgres/compare/v0.4.1...v0.4.2) (2026-07-07)

### 🏗️ Build System

* adopt semantic-release pipeline, enable CI, fix default-render nil-pointer ([#4](https://github.com/devopsgroupeu/openprime-postgres/issues/4)) ([f4baf8a](https://github.com/devopsgroupeu/openprime-postgres/commit/f4baf8a670a371bafad6e8042d739a9dc96d57b2))
