FROM alpine AS builder
ARG ARTIFACT=https://www.semspect.de/rdf-semspect-distribution-19.2.0.zip

RUN apk update && apk upgrade
RUN apk add --no-cache unzip

RUN mkdir /app

WORKDIR /app
ADD $ARTIFACT /app

RUN unzip rdf-semspect-distribution-*.zip && \
    rm rdf-semspect-distribution-*.zip && \
    mv rdf-semspect-distribution-*/* . && \
    rmdir rdf-semspect-distribution-*/

FROM amazoncorretto:17-alpine

RUN apk update && apk upgrade
RUN apk add --no-cache bash

RUN addgroup -S semspect && adduser -S semspect -G semspect
RUN mkdir -p /app 
WORKDIR /app

COPY --from=builder /app /app

RUN chown -R semspect:semspect /app

USER semspect

EXPOSE 8080

# Set the entrypoint to run the server script
CMD ["/app/semspect-server.sh"]
