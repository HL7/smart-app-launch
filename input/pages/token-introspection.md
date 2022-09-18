SMART on FHIR EHRs SHOULD support Token Introspection, which allows a broader ecosystem of resource servers to leverage authorization decisions managed by a single authorization server. Token Introspection is conducted according to [RFC 7662: OAuth 2.0 Token Introspection](https://datatracker.ietf.org/doc/html/rfc7662), with the additional considerations presented in the sections below.

### Required fields in the introspection response

In addition to the `active` field required by RFC7662 (a boolean indicating whether the access token is active), the following fields SHALL be included in the introspection response:

* `scope`. As included in the original access token response. The list of scopes granted by the authorization server as a space-separated JSON string.

* `client_id`. As included in the original access token response. The client identifier of the client to which the token was issued.

* `exp`. As included in the original access token response. The integer timestamp indicating when the access token expires.

### Conditional fields in the introspection response

In addition to the required fields, the following fields SHALL be included in the introspection response when the specified conditions are met:

* SMART Launch Context. If a launch context parameter defined in <a href="scopes-and-launch-context.html">Scopes and Launch Context</a> (e.g., `patient` or `intent`) was included in the original access token response, the parameter SHALL be included in the token introspection response.

* ID Token Claims. If an `id_token` was included in the original access token response, the following claims from the ID Token SHALL be included in the Token Introspection response:

  * `iss`
  * `sub`

* ID Token Claims. If an `id_token` was included in the original access token response, the following claims from the ID Token SHOULD be included in the Token Introspection response:

  * `fhirUser`

### Authorization to perform Token Introspection

SMART on FHIR EHRs MAY implement access control protecting the Token Introspection endpoint. If access control is implemented, any client authorized to issue Token Introspection API calls SHOULD be able to authenticate to the Token Introspection endpoint using its client credentials. Further considerations for access control are out of scope for the SMART App Launch IG.


### Example Request and Response

Example Token Introspection request:

     POST /introspect HTTP/1.1
     Host: server.example.com
     Accept: application/json
     Content-Type: application/x-www-form-urlencoded
     Authorization: Bearer 23410913-abewfq.123483

     token=2YotnFZFEjr1zCsicMWpAA


Example Token Introspection response:

     HTTP/1.1 200 OK
     Content-Type: application/json

     {
      "active": true,
      "client_id": "07a89bd2-52ce-4576-8b85-71698efa8328",
      "scope": "patient/*.read openid fhirUser",
      "sub": "c91dfe96-731d-4e66-b4f9-01f8f8a4b7b2",
      "patient": "456",
      "fhirUser": "https://ehr.example.org/fhir/Patient/123",
      "exp": 1597678964,
     }
