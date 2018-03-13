---
title: "SMART App Launch: FHIR Authorization Endpoint Discovery"
layout: default
---

The authorization endpoints accepted by a FHIR resource server are exposed as a Well-Known Uniform Resource Identifiers (URIs) [(RFC5785)][well-known] JSON document.

FHIR endpoints requiring authorization MUST serve a JSON document at the location formed by appending `/.well-known/fhir-authorization-configuration` to their base URL.
Contrary to RFC5785 Appendix B.4, the `.well-known` path component may be appended even if the FHIR endpoint already contains a path component.

## Request

Sample requests:

#### Base URL "fhir.ehr.io"

```
GET /.well-known/fhir-authorization-configuration HTTP/1.1
Host: fhir.ehr.io
```

#### Base URL "www.ehr.io/apis/fhir"

```
GET /apis/fhir/.well-known/fhir-authorization-configuration HTTP/1.1
Host: www.ehr.io
```

## Response

A JSON document must be returned using the `application/json` mime type.

### Metadata

- `authorization_endpoint`: **REQUIRED**, URL to the OAuth2 authorization endpoint.
- `token_endpoint`: **CONDITIONAL**, URL to the OAuth2 token endpoint, required unless the _implicit_ grant flow is used.
- `token_endpoint_auth_methods`: **OPTIONAL**, array of client authentication methods supported by the token endpoint. The options are "client_secret_post" and "client_secret_basic".
- `registration_endpoint`: **OPTIONAL**, if available, URL to the OAuth2 dynamic registration endpoint for this FHIR server.
- `scopes_supported`: **RECOMMENDED**, array of scopes a client may request. See [scopes and launch context][smart-scopes].
- `response_types_supported`: **RECOMMENDED**, array of OAuth2 `response_type` values that are supported
- `manage_endpoint`: **RECOMMENDED**, URL to the user-facing authorization management workflow entry point for this FHIR server.

### Sample Response

```
HTTP/1.1 200 OK
Content-Type: application/json

{
  "authorization_endpoint": "https://emr.io/auth/authorize",
  "token_endpoint": "https://emr.io/auth/token",
  "token_endpoint_auth_methods_supported": ["client_secret_basic],
  "registration_endpoint": "https://emr.io/auth/register",
  "scopes_supported": ["openid", "profile", "launch", "launch/patient", "patient/*.*", "user/*.*", "offline_access"],
  "response_types_supported": ["code", "code id_token", "id_token", "refresh_token"],
  "manage_endpoint": "https://emr.io/user/manage"
}
```

## Well-Known URI Registry

- URI Suffix: fhir-authorization-configuration


[well-known]: https://tools.ietf.org/html/rfc5785
[oid]: https://openid.net/specs/openid-connect-discovery-1_0.html
[smart-scopes]: http://docs.smarthealthit.org/authorization/scopes-and-launch-context/#quick-start
