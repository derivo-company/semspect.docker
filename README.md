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