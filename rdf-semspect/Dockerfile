FROM alpine AS builder
ARG ARTIFACT=https://www.semspect.de/rdf-semspect-distribution-19.2.0.zip

RUN apk upgrade --no-cache && \
    apk add --no-cache unzip

WORKDIR /app
ADD $ARTIFACT /app

RUN unzip rdf-semspect-distribution-*.zip && \
    rm rdf-semspect-distribution-*.zip && \
    mv rdf-semspect-distribution-*/* . && \
    rmdir rdf-semspect-distribution-*/

FROM amazoncorretto:17-alpine

RUN apk upgrade --no-cache && \
    apk add --no-cache bash

RUN addgroup -S semspect && adduser -S semspect -G semspect
WORKDIR /app

COPY --from=builder /app /app

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh && \
    chown -R semspect:semspect /app

USER semspect

EXPOSE 8080

ENTRYPOINT ["/app/entrypoint.sh"]