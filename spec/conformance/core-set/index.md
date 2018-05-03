---
title: "SMART App Launch: Core Capabilities"
layout: default
---

To be conformant with SMART on FHIR's Core Capabilities, an EHR must support
the following capabilities, and must advertise them in an external [.well-known][well-known] json file:

* `launch-ehr`
* `launch-standalone`
* `client-public`
* `client-confidential-symmetric`
* `sso-openid-connect`
* `context-banner`
* `context-style`
* `context-ehr-patient`
* `context-ehr-encounter`
* `context-standalone-patient`
* `context-standalone-encounter`
* `permission-offline`
* `permission-patient`
* `permission-user`

[well-known]:  ../../well-known/index.html
