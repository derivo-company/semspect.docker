#!/bin/bash
set -e

CONFIG_DIR="/var/lib/semspect/config"

# Handle license
# SemSpect expects the license in the installation directory by default.
# If the user puts a license in the config dropzone, we securely symlink it.
if [ -f "$CONFIG_DIR/semspect.lic" ]; then
    echo "Found license in $CONFIG_DIR, linking to application directory..."
    ln -sf "$CONFIG_DIR/semspect.lic" /app/semspect.lic
fi

# Bind core configurations
# We inject the JVM parameters directly into the environment variable expected by the server script.
export SEMSPECT_JDK_OPTIONS="\
-Dde.derivo.semspect.server.data.path=/var/lib/semspect/server-data \
-Dde.derivo.semspect.server.configuration.path=$CONFIG_DIR/semspect_config.yaml \
-Dde.derivo.semspect.server.configuration.dossier.path=$CONFIG_DIR/dossier.yaml \
-Dde.derivo.semspect.server.configuration.facets.path=$CONFIG_DIR/facets.yaml \
-Dde.derivo.semspect.server.configuration.category.path=$CONFIG_DIR/categories.yaml \
$SEMSPECT_JDK_OPTIONS"

# first argument passed to 'docker run'
COMMAND=$1

case "$COMMAND" in
    serve)
        DATA_PATH=$2
        if [ -z "$DATA_PATH" ]; then
            echo "Error: You must provide a path to the RDF data."
            echo "Usage: docker run -p 8080:8080 semspect-image serve /path/to/data.ttl"
            exit 1
        fi
        TARGET_DIR=$(dirname "$DATA_PATH")

        echo "Starting Serve Mode: Generating indices for $DATA_PATH and starting server..."
        exec /app/semspect-server.sh \
            --semspect.rdf.databases[0].database=default-db \
            --semspect.rdf.databases[0].mode=generate \
            --semspect.rdf.databases[0].indexing.rdfDataSources[0]="file://$DATA_PATH" \
            --semspect.rdf.databases[0].indicesDirectory="$TARGET_DIR/indices" \
            "${@:3}" # <-- forward all additional arguments
        ;;

    generate)
        # path to the data file or directory mounted in the volume
        DATA_PATH=$2
        if [ -z "$DATA_PATH" ]; then
            echo "Error: You must provide a path to the RDF data."
            echo "Usage: docker run semspect-image generate /path/to/data.ttl"
            exit 1
        fi

        # extract the directory of the target file to save indices next to it
        TARGET_DIR=$(dirname "$DATA_PATH")

        echo "Starting Generate Mode: Generating indices for $DATA_PATH..."
        exec /app/semspect-server.sh \
            --semspect.rdf.databases[0].database=default-db \
            --semspect.rdf.databases[0].mode=generate \
            --semspect.rdf.databases[0].indexing.rdfDataSources[0]="file://$DATA_PATH" \
            --semspect.rdf.databases[0].indicesDirectory="$TARGET_DIR/indices" \
            --semspect.rdf.databases[0].indexing.terminateAfterIndexing=true \
            "${@:3}" # <-- forward all additional arguments
        ;;

    load)
        # path to the pre-calculated indices directory mounted in the volume
        INDEX_PATH=$2
        if [ -z "$INDEX_PATH" ]; then
            echo "Error: You must provide a path to the indices directory."
            echo "Usage: docker run semspect-image load /path/to/indices"
            exit 1
        fi

        echo "Starting Read-Only Mode: Serving indices from $INDEX_PATH..."
        exec /app/semspect-server.sh \
            --semspect.rdf.databases[0].database=default-db \
            --semspect.rdf.databases[0].mode=load \
            --semspect.rdf.databases[0].indicesDirectory="$INDEX_PATH" \
            --semspect.rdf.managed.indicesDirectory=/var/lib/semspect/server-indices \
            "${@:3}" # <-- forward all additional arguments
        ;;

    *)
        # default fallback: boot the empty managed mode REST API
        echo "Starting Daemon Mode: Managed API Server..."
        # pass all user arguments ($@) to the server script
        exec /app/semspect-server.sh \
            --semspect.rdf.managed.indicesDirectory=/var/lib/semspect/server-indices \
            "$@"
        ;;
esac