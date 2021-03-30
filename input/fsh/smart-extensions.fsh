Extension: OauthUris
Id: oauth-uris
Title: "SMART on FHIR Oauth URIs"

Description: "Declares support for automated dicovery of OAuth2 endpoints, if a
server supports SMART on FHIR authorization for access. Any time a client sees
this extension, it must be prepared to authorize using SMART’s OAuth2-based
protocol."

* ^context.type = #element
* ^context.expression = "CapabilityStatement.rest.security"

* extension contains
    authorize 1..1 MS and
    token 0..1 MS and
    register 0..1 MS and
    manage 0..1 MS and
    introspect 0..1 MS and
    revoke 0..1 MS

* extension[authorize] ^short = "URL indicating the OAuth2 \"authorize\" endpoint for this FHIR server."
* extension[authorize].value[x] only uri
* extension[token] ^short = "URL indicating the OAuth2 \"token\" endpoint for this FHIR server. Required unless the implicit grant flow is used."
* extension[token].value[x] only uri
* extension[register] ^short = "URL indicating the OAuth2 dynamic registration endpoint for this FHIR server, if supported."
* extension[register].value[x] only uri
* extension[manage] ^short = "URL where an end-user can view which applications have access to data and make adjustments to these access rights."
* extension[manage].value[x] only uri
* extension[introspect] ^short = "URL indicating the introspection endpoint that can be used to validate a token."
* extension[introspect].value[x] only uri
* extension[revoke] ^short = "URL indicating the endpoint that can be used to revoke a token."
* extension[revoke].value[x] only uri
