This page outlines a protocol for [public applications](app-launch.html#support-for-public-and-confidential-apps) to request persistent API authorization on behalf of a user or patient. It differs from the [UDAP specification](https://www.udap.org/) in that it allows a purely public app (one without any static credential) to request persistant API access.

### Background
With the existing public app workflow, the app is not given a refresh token or any other way to request new access tokens. This means the app is limited to using APIs for the time its first access token is valid.

This is by design, given that public apps are susceptible to various attacks such as Cross-Site Scripting (XSS). Granting these apps refresh tokens (and allowing them to use the tokens without authentication) opens up the possibility of refresh token theft. This idea of "\[persistent\] bearer tokens in the browser" is not a viable solution for sensitive use cases such as health applications because of this risk.

The only secure way for public apps to be granted persistent API access is to have the app's authorization tied to an un-extractable credential stored on the device the app is running on. There are different ways to tie the authorization and credential together, such as [sender-constrained tokens](https://datatracker.ietf.org/doc/html/draft-ietf-oauth-security-topics#section-4.9.1.1.2) with Mutual TLS, but those protocols still rely on a registration step that is left undefined. They also do not build off of existing [asymmetric authentication](client-confidential-asymmetric.html) methods defined in SMART.

### Overview
The _SMART Protected Dynamic Client Registration_ protocol defined here acheieves the necessary security of per-device credentials while building off of existing OAuth 2.0 workflows.

This protocol is a combination of:
1. The existing public app workflow, secured with PKCE and redirect URI validation
2. Protected Dynamic Client Registration, which is secured with an initial access token from step 1
3. The JWT Bearer grant type, which has semantics for requesting access tokens issued on behalf of a specific user

### Workflow
#### Step 0: The initial app registers with the authorization server
The _SMART Protected Dynamic Client Registration_ protocol requires an initial client_id for use with the public client profile. The authorization server will also provision a `software_id` to the app for use in step 2 below. These 2 values must be 1:1, and can optionally be the same value. 

#### Step 1: The app obtains an initial access token
The app initiates a normal SMART App Launch after registering as a public client with the authorization server. 

The app requests the `system/DynamicClient.register` scope during the launch to indicate it would like to request persistent API access through this workflow.

If successful, the app will now have an initial access token with the `system/DynamicClient.register` scope assigned. Between step 1 and step 2, the app should only store the initial access token in memory. This token is especially sensitive and should be protected from XSS attacks until it is revoked in step 2.

#### Step 2: The app registers a dynamic client instance
The app registers a new dynamic client instance using [dynamic client registration](https://datatracker.ietf.org/doc/html/rfc7591). See [details below](#smart-dynreg-details) on how SMART applies dynamic client registration in this protocol.

The app first needs to create a new public-private key pair unique to this session. See [Managing On-Device Keys](#managing-on-device-keys) for guidance on creating and storing a private key.

Once the app has created the key pair, it will serialize the public key as a [JSON Web Key Set (JWKS)](https://tools.ietf.org/html/rfc7517) and submit this to the authorization server in the `jwks` request field.

##### Example Registration Request
The client submits the request to the server's `registration_endpoint` (defined in [smart-configuration metadata](conformance.html#metadata)), including it's `initial_access_token`, `software_id` and `jwks`:

```
POST /auth/token HTTP/1.1
Host: ehr.example.com
Content-Type: application/json
Authorization: Bearer {{initial_access_token}}

{
    "software_id": "{{software_id}}",
    "jwks": { 
        "keys": [{
                "kty": "RSA",
                "e": "AQAB",
                "n": "vGASMnWdI-ManPgJi5XeT15Uf1tgpaNBmxfa-_bKG6G1DDTsYBy2K1uubppWMcl8Ff_2oWe6wKDMx2-bvrQQkR1zcV96yOgNmfDXuSSR1y7xk1Kd-uUhvmIKk81UvKbKOnPetnO1IftpEBm5Llzy-1dN3kkJqFabFSd3ujqi2ZGuvxfouZ-S3lpTU3O6zxNR6oZEbP2BwECoBORL5cOWOu_pYJvALf0njmamRQ2FKKCC-pf0LBtACU9tbPgHorD3iDdis1_cvk16i9a3HE2h4Hei4-nDQRXfVgXLzgr7GdJf1ArR1y65LVWvtuwNf7BaxVkEae1qKVLa2RUeg8imuw",
                "kid":"1248110c-afbd-484c-b75b-b30200ffcf05"
            }
        ]
    }
}
```

##### Example Registration Response
After reviewing the request, the authorization server will revoke the initial access token and respond with an HTTP `201 Created` status code. The body of the response includes the new client's information, such as:
- The app's new dynamic `client_id`, associated with the submitted `jwks`
- The `grant_types` the app is authorized for, which includes `urn:ietf:params:oauth:grant-type:jwt-bearer`
- A `token_endpoint_auth_method` set to `none`. Notably the JWT Bearer grant type does not require client authentication. Rather, it's `assertion` parameter is a JWT that serves a similar purpose.

Example minimal response:
```
{
    "token_endpoint_auth_method": "none",
    "grant_types": [
        "urn:ietf:params:oauth:grant-type:jwt-bearer"
    ],
    "software_id": "{{software_id}}",
    "client_id": "G65DA2AF4-1C91-11EC-9280-0050568B7514",
    "client_id_issued_at": 1632417134,
}
```

#### Step 3: Request subsequent access tokens
The app can now use its private key to request new access tokens at will using the `urn:ietf:params:oauth:grant-type:jwt-bearer` [grant type](https://datatracker.ietf.org/doc/html/rfc7523#section-2.1). This grant type is similar to `client_credentials`, but differs in that the access tokens requested by the client are specific to a given user. The app uses the `sub` claim to denote which user the access token should be issued to.

Conveniently, this protocol allows authorization servers to link a given dynamic client to an [authorization event](#authorization-event-linking), and associates every `client_id` with the `sub` of the user who authorized the registration. This means the dynamic client can use its own `client_id` as the `sub` for convenience, rather than discovering the sub of the authorizing user.

The `assertion` parameter of the request is therefore identical to a `client_assertion` from [SMART Backend Services](backend-services.html), except the `client_id` (used for the `sub` and `iss` assertion claims) is that of the dynamic client.

##### Example Token Request
```
POST /auth/token HTTP/1.1
Host: ehr.example.com
Content-Type: application/x-www-form-urlencoded

grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=[assertion]&client_id=G65DA2AF4-1C91-11EC-9280-0050568B7514
```

##### Token Response
The token response matches the `authorization_code` grant type from the [SMART App Launch](app-launch.html#response-5), except that the `id_token` and `refresh_token` response parameters are not present. 

<a id="authorization-event-linking"></a>

### Linking a Client ID to an Authorization Event
This protocol notably allows an authorization server to link the initial access token (and any user decisions made while authorizating that token) with the newly created dynamic client as part of the registration request. The user is able to review the request for the `system/DynamicClient.register` scope and have their decisions propogate to the dynamic client. The user can, for instance, decide how long the dynamic client should have access to their data before being revoked.

<a id="managing-on-device-keys"></a>

### Managing On-Device Keys
All applications using the protected dynamic client registration workflow are expected to secure their private keys appropriately.

Some common key management strategies include:
- For browser-based applications, using the [WebCrypto API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Crypto_API) and [Indexeddb](https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API) storage
- For native applications, using the device's [Trusted Platform Module](https://en.wikipedia.org/wiki/Trusted_Platform_Module) (TPM) or [Hardware Security Module](https://en.wikipedia.org/wiki/Hardware_security_module) (HSM)

<a id="smart-dynreg-details"></a>

### SMART Protected Dynamic Client Registration Details
This workflow supports a subset of dynamic client registration [uses cases](https://datatracker.ietf.org/doc/html/rfc7591#appendix-A), specifically:
- [Protected Registration](https://datatracker.ietf.org/doc/html/rfc7591#appendix-A.1.2)
- [Registration without a Software Statement](https://datatracker.ietf.org/doc/html/rfc7591#appendix-A.2.1)
- [Registration by the Client](https://datatracker.ietf.org/doc/html/rfc7591#appendix-A.3.1)
- [Client ID per Client Software Instance](https://datatracker.ietf.org/doc/html/rfc7591#appendix-A.4.1)
- [Stateful Registration](https://datatracker.ietf.org/doc/html/rfc7591#appendix-A.5.1)