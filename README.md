# SemSpect Docker Image

Docker images for [RDF-SemSpect](https://doc.semspect.de/rdf-server/) a visual exploration tool for RDF knowledge graphs.

## Release Notes

Release Notes are distributed via the documentation: [https://doc.semspect.de/rdf-server/further-information/release-notes/](https://doc.semspect.de/rdf-server/further-information/release-notes/)

## Quick Start

Quick start with example data.

The examples use the northwind dataset available on the SemSpect documentation website: https://www.semspect.de/northwind-data.ttl

### Without License

```bash
docker run \
  -p 8080:8080 \
  -v PATH_TO_NORTHWIND_DATA_TTL:/data/northwind-data.ttl \
  --name rdf-semspect \
  ghcr.io/derivo-company/rdf-semspect:latest \
  ./semspect-smart.sh /data/northwind-data.ttl
```

### Wit License

```bash
docker run \
  -p 8080:8080 \
  -v PATH_TO_NORTHWIND_DATA_TTL:/data/northwind-data.ttl \
  -v PATH_TO_YOUR_LICENSE:/app/semspect.lic \
  --name rdf-semspect \
  ghcr.io/derivo-company/rdf-semspect:latest \
  ./semspect-smart.sh /data/northwind-data.ttl
```

## For Developers

## Release Process 

To create a new release:

1. Update the version in `./rdf-semspect/Dockerfile` to the desired release version
2. Create a matching tag in this repository

This will trigger a build of the new docker image. It should be available under `ghcr.io/derivo-company/rdf-semspect:SEMSPECT_VERSION` .

### Versioning Conventions

We use [semantic versioning](https://semver.org/) with build metadata annotation E.g. `v19.2.0+01`.

* Git Tags for versions are prefixed with `v` e.g., `v19.2.0+01`
* The core version follows the SemSpect version. E.g, `v19.2.0`. Aligned with versions on [https://doc.semspect.de/rdf-server/further-information/release-notes/](https://doc.semspect.de/rdf-server/further-information/release-notes/)
* The build metadata (e.g, `+01`) indicates the build number for the core version. The build number should be increased if the core version doesn't change but the Dockerfile or base images changed.

Pushing a fresh tag will 

* Update the `:latest` tag
* Create a new image according to provided version: `tag=v19.2.0+01` => new image with version `:19.2.0+01`
* Update the core version tag: `tag=v19.2.0+01` => new image with version `:19.2.0`
* Update the minor version tag: `tag=v19.2.0+01` => new image with version `:19.2`
