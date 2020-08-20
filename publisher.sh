#!/bin/sh

docker run \
    --rm -it \
    -v $(pwd):/home/publisher/ig \
    hl7fhir/ig-publisher-base
