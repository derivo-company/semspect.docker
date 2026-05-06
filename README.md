# SemSpect Docker Image

Docker images for [RDF-SemSpect](https://doc.semspect.de/rdf-server/), a visual exploration tool for RDF knowledge graphs.

## Release Notes

Release Notes are distributed via the documentation: [https://doc.semspect.de/rdf-server/further-information/release-notes/](https://doc.semspect.de/rdf-server/further-information/release-notes/)

## Usage

The SemSpect Docker image operates using a single persistent volume (`/var/lib/semspect`) and supports four distinct execution modes.

Remark: All examples below mount the local directory `./semspect-workspace` to `/var/lib/semspect`. 
Copy or link your local files in `./semspect-workspace` to make them available to SemSpect.

### 1. Managed Mode (Default)

Starts the SemSpect multi-database REST API used to create databases and import data.
Databases and indexes created in previous runs will be loaded only if you have a license.

```bash
docker run -d -p 8080:8080 \
  -v $(pwd)/semspect-workspace:/var/lib/semspect \
  --name rdf-semspect \
  ghcr.io/derivo-company/rdf-semspect:latest
```

### 2. Serve Mode (Quick Evaluation)

Ideal for free users or quick tests. SemSpect boots, generates the indices for the specified RDF file, and immediately serves the UI in a single step.

```bash
docker run -d -p 8080:8080 \
  -v $(pwd)/semspect-workspace:/var/lib/semspect \
  ghcr.io/derivo-company/rdf-semspect:latest \
  serve /var/lib/semspect/my-data.ttl
```

### 3. Generate Mode

A one-shot batch process. SemSpect boots, generates the indices for the specified RDF file, writes them to the mounted volume, and automatically exits. 

```bash
docker run --rm \
  -v $(pwd)/semspect-workspace:/var/lib/semspect \
  ghcr.io/derivo-company/rdf-semspect:latest \
  generate /var/lib/semspect/my-data.ttl
```

*Note: You can append native Spring Boot parameters to the command to customize the indexing process (e.g., `--semspect.rdf.databases[0].indexing.numberOfThreads=4`).*

### 4. Load Mode (License Required)

SemSpect boots and loads a pre-calculated index directory.

```bash
docker run -d -p 8080:8080 \
  -v $(pwd)/semspect-workspace:/var/lib/semspect \
  --name rdf-semspect \
  ghcr.io/derivo-company/rdf-semspect:latest \
  load /var/lib/semspect/indices
```

*Note: Just like Generate Mode, you can append parameters to customize exploration settings (e.g., `--semspect.rdf.databases[0].exploration.showTopClassInTree=true`).*

## Configuration & License

To provide a license or advanced UI configurations (dossier, facets, categories), create a `config` directory inside your mounted workspace volume. The container will automatically detect and apply files placed here.

Additionally, SemSpect will automatically create a `server-data` directory alongside your data to securely persist your saved UI explorations, custom categories, and internal application data.

**Local Workspace Structure:**
```text
./semspect-workspace/
├── config/                  <-- You create this (optional overrides & license)
│   ├── semspect.lic
│   ├── semspect_config.yaml
│   ├── dossier.yaml
│   ├── facets.yaml
│   └── categories.yaml
├── my-data.ttl              <-- You provide this (raw RDF data)
├── indices/                 <-- SemSpect generates this (during 'generate' mode)
├── server-indices/          <-- SemSpect generates this (live databases managed via REST API)
└── server-data/             <-- SemSpect generates this (saved explorations & custom classes)
```

*Note: If you need to override deeper Spring Boot server settings beyond the auto-detected YAML files, you can append `--spring.config.additional-location=/path/to/custom_config.yaml` to any of the `docker run` commands above.*

## Under the Hood: Mapping to Backend Scripts

Under the hood, all Docker commands (`serve`, `generate`, `load`) execute `semspect-server.sh`. The Docker wrapper simply translates the native Docker commands into the appropriate Spring Boot parameters, and automatically pins the `server-indices` and `server-data` properties to the `/var/lib/semspect` workspace volume.

## For Developers

### Release Process 

To create a new release:

1. Update the version in `./rdf-semspect/Dockerfile` to the desired release version.
2. Create a matching tag in this repository.

This will trigger a build of the new docker image. It should be available under `ghcr.io/derivo-company/rdf-semspect:SEMSPECT_VERSION`.

### Versioning Conventions

We use [semantic versioning](https://semver.org/) with build metadata annotation (e.g., `v19.2.0+01`).

* Git tags for versions are prefixed with `v` (e.g., `v19.2.0+01`).
* The core version follows the SemSpect version (e.g., `v19.2.0`), aligned with the [release notes](https://doc.semspect.de/rdf-server/further-information/release-notes/).
* The build metadata (e.g., `+01`) indicates the build number for the core version. The build number should be increased if the core version doesn't change but the Dockerfile or base images changed.

Pushing a fresh tag will:

* Update the `:latest` tag
* Create a new image according to the provided version: `tag=v19.2.0+01` => new image with version `:19.2.0+01`
* Update the core version tag: `tag=v19.2.0+01` => new image with version `:19.2.0`
* Update the minor version tag: `tag=v19.2.0+01` => new image with version `:19.2`
