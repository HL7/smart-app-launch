## SMART App Launch IG

Official publication: https://hl7.org/fhir/smart-app-launch/

The SMART App Launch Framework connects third-party applications to Electronic
Health Record data, allowing apps to launch from inside or outside the user
interface of an EHR system.

## Contributing to the Specification

If you have suggestions or need to discuss potential substantive changes, please:

* Join the conversation in [`#smart` on chat.fhir.org](https://chat.fhir.org/#narrow/stream/179170-smart)
* Submit change requests or issues through the [HL7 JIRA](https://jira.hl7.org/).

our contributions help us improve the SMART App Launch Framework, making it more robust and versatile.


## Developers: Building this IG


### Launch the publisher dev environment

```sh
$ cd smart-app-launch

$ docker run \
    --rm -it \
    -v "$(pwd):/home/publisher/ig" \
    hl7fhir/ig-publisher-base
```

### Now, in the docker container...

```sh
$ sushi # This shouldn't be necessary but currently it is, the first time
$ _updatePublisher.sh # If you haven't done it before
$ _genonce.sh
```

