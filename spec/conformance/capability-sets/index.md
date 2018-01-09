---
title: "SMART App Launch: Capability Sets"
layout: default
---
## Capability Sets

The following four Capability Sets are defined. Any individual SMART server will publish a granular list of its capabilities; from this list you can determine which of these Capability Sets are supported:


### Patient Access for Standalone Apps
1. `launch-standalone`
1. At least one of `client-public` or `client-confidential-symmetric`
1. `context-standalone-patient`
1. `permission-patient`

###  Patient Access for EHR Launch (i.e. from Portal)
1. `launch-ehr`
1. At least one of `client-public` or `client-confidential-symmetric`
1. `context-ehr-patient`
1. `permission-patient`

###  Clinician Access for Standalone
1. `launch-standalone`
1. At least one of `client-public` or `client-confidential-symmetric`
1. `permission-user`
1. `permission-patient`

###  Clinician Access for EHR Launch
1. `launch-ehr`
1. At least one of `client-public` or `client-confidential-symmetric`
1. `context-ehr-patient` support
1. `context-ehr-encounter` support
1. `permission-user`
1. `permission-patient`
