#!/bin/sh

docker run \
    --rm -it \
    -v $(pwd):/home/publisher/ig \
    -v ~/.fhir:/home/publisher/.fhir \
    hl7fhir/ig-publisher-base
