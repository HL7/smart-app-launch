---
title: "FHIR Artifacts"
layout: default
active: profiles
---

The following FHIR artifact for have been defined for declaring conformance to the SMART’s App Launch specifications.

<!--

## Profiles

- [SMART on FHIR CapabilityStatement](../StructureDefinition-capabilitystatement-smartlaunch.html): The SMART on FHIR  CapabilityStatement defines extensions for automated discovery of OAuth2 endpoints and optional SMART launch features.

-->

## Extensions

- [Oauth URIs](../StructureDefinition-oauth-uris.html): Declares support for automated dicovery of OAuth2 endpoints If a server requires SMART on FHIR authorization for access. Any time a client sees this extension, it must be prepared to authorize using SMART's OAuth2-based protocol.

<br /><br />

<!--
- [SMART Capabilities](../../StructureDefinition-extension-smart-capabilities.html):  Support for optional SMART launch features.


## Terminology
**Value Sets**

- [CapabilityCodes](../../ValueSet-cap-codes.html): Codes describing *optional* SMART features

**Code Systems**

- [CapabilityCodes](../../CodeSystem-cap-codes.html): Codes describing *optional* SMART features
output/CodeSystem-cap-codes.html
-->
