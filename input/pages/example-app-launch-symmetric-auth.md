<a id="step-2-launch"></a>

### Launch App
This is a user-driven step triggering the subsequent workflow.

In this example, the launch is initiated against a FHIR server with a base URL of:

    https://smart.argo.run/v/r4/sim/eyJtIjoiMSIsImsiOiIxIiwiaSI6IjEiLCJqIjoiMSIsImIiOiI4N2EzMzlkMC04Y2FlLTQxOGUtODljNy04NjUxZTZhYWIzYzYifQ/fhir

... and the app's redirect URL has been registered as:

    https://sharp-lake-word.glitch.me/graph.html

... and the app's `client_secret` has been registered as:

    secret-key-1234567890

... and the app has been assigned a `client_id` of:

    demo_app_whatever

<a id="step-3-discovery"></a>

### Retrieve .well-known/smart-configuration

```sh
curl -s 'https://smart.argo.run/v/r4/sim/eyJtIjoiMSIsImsiOiIxIiwiaSI6IjEiLCJqIjoiMSIsImIiOiI4N2EzMzlkMC04Y2FlLTQxOGUtODljNy04NjUxZTZhYWIzYzYifQ/fhir/.well-known/smart-configuration' \
  -H 'accept: application/json'

{
  "authorization_endpoint": "https://smart.argo.run/v/r4/sim/eyJtIjoiMSIsImsiOiIxIiwiaSI6IjEiLCJqIjoiMSIsImIiOiI4N2EzMzlkMC04Y2FlLTQxOGUtODljNy04NjUxZTZhYWIzYzYifQ/auth/authorize",
  "token_endpoint": "https://smart.argo.run/v/r4/sim/eyJtIjoiMSIsImsiOiIxIiwiaSI6IjEiLCJqIjoiMSIsImIiOiI4N2EzMzlkMC04Y2FlLTQxOGUtODljNy04NjUxZTZhYWIzYzYifQ/auth/token",
  "introspection_endpoint": "https://smart.argo.run/v/r4/sim/eyJtIjoiMSIsImsiOiIxIiwiaSI6IjEiLCJqIjoiMSIsImIiOiI4N2EzMzlkMC04Y2FlLTQxOGUtODljNy04NjUxZTZhYWIzYzYifQ/auth/introspect",
  "code_challenge_methods_supported": [
    "S256"
  ],
  "grant_types_supported": [
    "authorization_code"
  ],
  "token_endpoint_auth_methods_supported": [
    "private_key_jwt",
    "client_secret_basic"
  ],
  "token_endpoint_auth_signing_alg_values_supported": [
    "RS384",
    "ES384"
  ],
  "scopes_supported": [
    "openid",
    "fhirUser",
    "launch",
    "launch/patient",
    "patient/*.cruds"
    "user/*.cruds",
    "offline_access"
  ],
  "response_types_supported": [
    "code"
  ],
  "capabilities": [
    "launch-ehr",
    "launch-standalone",
    "client-public",
    "client-confidential-symmetric",
    "client-confidential-asymmetric",
    "context-passthrough-banner",
    "context-passthrough-style",
    "context-ehr-patient",
    "context-ehr-encounter",
    "context-standalone-patient",
    "context-standalone-encounter",
    "permission-offline",
    "permission-patient",
    "permission-user",
    "permission-v2",
    "authorize-post"
  ]
}
```

<a id="step-4-authorization-code"></a>

### Obtain authorization code

Generate a PKCE code challenge and verifier, then redirect browser to the `authorize_endpoint` from the discovery response (newlines added for clarity):

    https://smart.argo.run/v/r4/sim/eyJtIjoiMSIsImsiOiIxIiwiaSI6IjEiLCJqIjoiMSIsImIiOiI4N2EzMzlkMC04Y2FlLTQxOGUtODljNy04NjUxZTZhYWIzYzYifQ/auth/authorize?
      response_type=code&
      client_id=demo_app_whatever&
      scope=launch%2Fpatient%20patient%2FObservation.rs%20patient%2FPatient.rs%20offline_access&
      redirect_uri=https%3A%2F%2Fsharp-lake-word.glitch.me%2Fgraph.html&
      aud=https%3A%2F%2Fsmart.argo.run%2Fv%2Fr4%2Fsim%2FeyJtIjoiMSIsImsiOiIxIiwiaSI6IjEiLCJqIjoiMSIsImIiOiI4N2EzMzlkMC04Y2FlLTQxOGUtODljNy04NjUxZTZhYWIzYzYifQ%2Ffhir&state=0hJc1S9O4oW54XuY&
      code_challenge=YPXe7B8ghKrj8PsT4L6ltupgI12NQJ5vblB07F4rGaw&
      code_challenge_method=S256


Receive authorization code when EHR redirects the browser back to (newlines added for clarity):

    https://sharp-lake-word.glitch.me/graph.html?
      code=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb250ZXh0Ijp7Im5lZWRfcGF0aWVudF9iYW5uZXIiOnRydWUsInNtYXJ0X3N0eWxlX3VybCI6Imh0dHBzOi8vc21hcnQuYXJnby5ydW4vL3NtYXJ0LXN0eWxlLmpzb24iLCJwYXRpZW50IjoiODdhMzM5ZDAtOGNhZS00MThlLTg5YzctODY1MWU2YWFiM2M2In0sImNsaWVudF9pZCI6ImRlbW9fYXBwX3doYXRldmVyIiwiY29kZV9jaGFsbGVuZ2VfbWV0aG9kIjoiUzI1NiIsImNvZGVfY2hhbGxlbmdlIjoiWVBYZTdCOGdoS3JqOFBzVDRMNmx0dXBnSTEyTlFKNXZibEIwN0Y0ckdhdyIsInNjb3BlIjoibGF1bmNoL3BhdGllbnQgcGF0aWVudC9PYnNlcnZhdGlvbi5ycyBwYXRpZW50L1BhdGllbnQucnMiLCJyZWRpcmVjdF91cmkiOiJodHRwczovL3NoYXJwLWxha2Utd29yZC5nbGl0Y2gubWUvZ3JhcGguaHRtbCIsImlhdCI6MTYzMzUzMjAxNCwiZXhwIjoxNjMzNTMyMzE0fQ.xilM68Bavtr9IpklYG-j96gTxAda9r4Z_boe2zv3A3E&
      state=0hJc1S9O4oW54XuY 

<a id="step-5-access-token"></a>

### Retrieve access token

Prepare a client authentication header by base64 encoding `demo_app_whatever:secret-key-1234567890`:

    Authorization: Basic ZGVtb19hcHBfd2hhdGV2ZXI6c2VjcmV0LWtleS0xMjM0NTY3ODkw

Prepare arguments for POST to token API (newlines added for clarity):

```
code=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb250ZXh0Ijp7Im5lZWRfcGF0aWVudF9iYW5uZXIiOnRydWUsInNtYXJ0X3N0eWxlX3VybCI6Imh0dHBzOi8vc21hcnQuYXJnby5ydW4vL3NtYXJ0LXN0eWxlLmpzb24iLCJwYXRpZW50IjoiODdhMzM5ZDAtOGNhZS00MThlLTg5YzctODY1MWU2YWFiM2M2In0sImNsaWVudF9pZCI6ImRlbW9fYXBwX3doYXRldmVyIiwiY29kZV9jaGFsbGVuZ2VfbWV0aG9kIjoiUzI1NiIsImNvZGVfY2hhbGxlbmdlIjoiWVBYZTdCOGdoS3JqOFBzVDRMNmx0dXBnSTEyTlFKNXZibEIwN0Y0ckdhdyIsInNjb3BlIjoibGF1bmNoL3BhdGllbnQgcGF0aWVudC9PYnNlcnZhdGlvbi5ycyBwYXRpZW50L1BhdGllbnQucnMiLCJyZWRpcmVjdF91cmkiOiJodHRwczovL3NoYXJwLWxha2Utd29yZC5nbGl0Y2gubWUvZ3JhcGguaHRtbCIsImlhdCI6MTYzMzUzMjAxNCwiZXhwIjoxNjMzNTMyMzE0fQ.xilM68Bavtr9IpklYG-j96gTxAda9r4Z_boe2zv3A3E&
grant_type=authorization_code&
redirect_uri=https%3A%2F%2Fsharp-lake-word.glitch.me%2Fgraph.html&
code_verifier=o28xyrYY7-lGYfnKwRjHEZWlFIPlzVnFPYMWbH-g_BsNnQNem-IAg9fDh92X0KtvHCPO5_C-RJd2QhApKQ-2cRp-S_W3qmTidTEPkeWyniKQSF9Q_k10Q5wMc8fGzoyF
```


Issue POST to the token endpoint:

```
curl 'https://smart.argo.run/v/r4/sim/eyJtIjoiMSIsImsiOiIxIiwiaSI6IjEiLCJqIjoiMSIsImIiOiI4N2EzMzlkMC04Y2FlLTQxOGUtODljNy04NjUxZTZhYWIzYzYifQ/auth/token' \
  -H 'accept: application/json' \
  -H 'content-type: application/x-www-form-urlencoded' \
  -H 'Authorization: Basic ZGVtb19hcHBfd2hhdGV2ZXI6c2VjcmV0LWtleS0xMjM0NTY3ODkw' \
  --data-raw 'code=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb250ZXh0Ijp7Im5lZWRfcGF0aWVudF9iYW5uZXIiOnRydWUsInNtYXJ0X3N0eWxlX3VybCI6Imh0dHBzOi8vc21hcnQuYXJnby5ydW4vL3NtYXJ0LXN0eWxlLmpzb24iLCJwYXRpZW50IjoiODdhMzM5ZDAtOGNhZS00MThlLTg5YzctODY1MWU2YWFiM2M2In0sImNsaWVudF9pZCI6ImRlbW9fYXBwX3doYXRldmVyIiwiY29kZV9jaGFsbGVuZ2VfbWV0aG9kIjoiUzI1NiIsImNvZGVfY2hhbGxlbmdlIjoiWVBYZTdCOGdoS3JqOFBzVDRMNmx0dXBnSTEyTlFKNXZibEIwN0Y0ckdhdyIsInNjb3BlIjoibGF1bmNoL3BhdGllbnQgcGF0aWVudC9PYnNlcnZhdGlvbi5ycyBwYXRpZW50L1BhdGllbnQucnMiLCJyZWRpcmVjdF91cmkiOiJodHRwczovL3NoYXJwLWxha2Utd29yZC5nbGl0Y2gubWUvZ3JhcGguaHRtbCIsImlhdCI6MTYzMzUzMjAxNCwiZXhwIjoxNjMzNTMyMzE0fQ.xilM68Bavtr9IpklYG-j96gTxAda9r4Z_boe2zv3A3E&grant_type=authorization_code&redirect_uri=https%3A%2F%2Fsharp-lake-word.glitch.me%2Fgraph.html&code_verifier=o28xyrYY7-lGYfnKwRjHEZWlFIPlzVnFPYMWbH-g_BsNnQNem-IAg9fDh92X0KtvHCPO5_C-RJd2QhApKQ-2cRp-S_W3qmTidTEPkeWyniKQSF9Q_k10Q5wMc8fGzoyF'


{
  "need_patient_banner": true,
  "smart_style_url": "https://smart.argo.run/smart-style.json",
  "patient": "87a339d0-8cae-418e-89c7-8651e6aab3c6",
  "token_type": "Bearer",
  "scope": "launch/patient patient/Observation.rs patient/Patient.rs",
  "expires_in": 3600,
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuZWVkX3BhdGllbnRfYmFubmVyIjp0cnVlLCJzbWFydF9zdHlsZV91cmwiOiJodHRwczovL3NtYXJ0LmFyZ28ucnVuLy9zbWFydC1zdHlsZS5qc29uIiwicGF0aWVudCI6Ijg3YTMzOWQwLThjYWUtNDE4ZS04OWM3LTg2NTFlNmFhYjNjNiIsInRva2VuX3R5cGUiOiJiZWFyZXIiLCJzY29wZSI6ImxhdW5jaC9wYXRpZW50IHBhdGllbnQvT2JzZXJ2YXRpb24ucnMgcGF0aWVudC9QYXRpZW50LnJzIiwiY2xpZW50X2lkIjoiZGVtb19hcHBfd2hhdGV2ZXIiLCJleHBpcmVzX2luIjozNjAwLCJpYXQiOjE2MzM1MzIwMTQsImV4cCI6MTYzMzUzNTYxNH0.PzNw23IZGtBfgpBtbIczthV2hGwanG_eyvthVS8mrG4",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb250ZXh0Ijp7Im5lZWRfcGF0aWVudF9iYW5uZXIiOnRydWUsInNtYXJ0X3N0eWxlX3VybCI6Imh0dHBzOi8vc21hcnQuYXJnby5ydW4vL3NtYXJ0LXN0eWxlLmpzb24iLCJwYXRpZW50IjoiODdhMzM5ZDAtOGNhZS00MThlLTg5YzctODY1MWU2YWFiM2M2In0sImNsaWVudF9pZCI6ImRlbW9fYXBwX3doYXRldmVyIiwic2NvcGUiOiJsYXVuY2gvcGF0aWVudCBwYXRpZW50L09ic2VydmF0aW9uLnJzIHBhdGllbnQvUGF0aWVudC5ycyBvZmZsaW5lX2FjY2VzcyIsImlhdCI6MTYzMzUzMzg1OSwiZXhwIjoxNjY1MDY5ODU5fQ.Q41QwZCEQlZ16M7YwvYuVbUP03mRFJoqRxL8SS8_ImM"
}
```

<a id="step-6-fhir-api"></a>

### Access FHIR API

```
curl 'https://smart.argo.run/v/r4/sim/eyJtIjoiMSIsImsiOiIxIiwiaSI6IjEiLCJqIjoiMSIsImIiOiI4N2EzMzlkMC04Y2FlLTQxOGUtODljNy04NjUxZTZhYWIzYzYifQ/fhir/Observation?code=4548-4&_sort%3Adesc=date&_count=10&patient=87a339d0-8cae-418e-89c7-8651e6aab3c6' \
  -H 'accept: application/json' \
  -H 'authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuZWVkX3BhdGllbnRfYmFubmVyIjp0cnVlLCJzbWFydF9zdHlsZV91cmwiOiJodHRwczovL3NtYXJ0LmFyZ28ucnVuLy9zbWFydC1zdHlsZS5qc29uIiwicGF0aWVudCI6Ijg3YTMzOWQwLThjYWUtNDE4ZS04OWM3LTg2NTFlNmFhYjNjNiIsInRva2VuX3R5cGUiOiJiZWFyZXIiLCJzY29wZSI6ImxhdW5jaC9wYXRpZW50IHBhdGllbnQvT2JzZXJ2YXRpb24ucnMgcGF0aWVudC9QYXRpZW50LnJzIiwiY2xpZW50X2lkIjoiZGVtb19hcHBfd2hhdGV2ZXIiLCJleHBpcmVzX2luIjozNjAwLCJpYXQiOjE2MzM1MzIwMTQsImV4cCI6MTYzMzUzNTYxNH0.PzNw23IZGtBfgpBtbIczthV2hGwanG_eyvthVS8mrG4'

{
  "resourceType": "Bundle",
  "id": "9e3ed23b-b62e-4a3d-9ac8-9b66a67f700d",
  "meta": {
    "lastUpdated": "2021-10-06T10:52:52.847-04:00"
  },
  "type": "searchset",
  "total": 11,
  "link": [
    {
      "relation": "self",
      "url": "https://smart.argo.run/v/r4/fhir/Observation?_count=10&_sort%3Adesc=date&code=4548-4&patient=87a339d0-8cae-418e-89c7-8651e6aab3c6"
    },
    {
      "relation": "next",
      "url": "https://smart.argo.run/v/r4/fhir?_getpages=9e3ed23b-b62e-4a3d-9ac8-9b66a67f700d&_getpagesoffset=10&_count=10&_pretty=true&_bundletype=searchset"
    }
  ],
  "entry": [
    {
<SNIPPED for brevity>
```

<a id="step-7-refresh"></a>

### Refresh access token

Generate a client authentication assertion and prepare arguments for POST to token API (newlines added for clarity)

```
grant_type=refresh_token&
refresh_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb250ZXh0Ijp7Im5lZWRfcGF0aWVudF9iYW5uZXIiOnRydWUsInNtYXJ0X3N0eWxlX3VybCI6Imh0dHBzOi8vc21hcnQuYXJnby5ydW4vL3NtYXJ0LXN0eWxlLmpzb24iLCJwYXRpZW50IjoiODdhMzM5ZDAtOGNhZS00MThlLTg5YzctODY1MWU2YWFiM2M2In0sImNsaWVudF9pZCI6ImRlbW9fYXBwX3doYXRldmVyIiwic2NvcGUiOiJsYXVuY2gvcGF0aWVudCBwYXRpZW50L09ic2VydmF0aW9uLnJzIHBhdGllbnQvUGF0aWVudC5ycyBvZmZsaW5lX2FjY2VzcyIsImlhdCI6MTYzMzUzMzg1OSwiZXhwIjoxNjY1MDY5ODU5fQ.Q41QwZCEQlZ16M7YwvYuVbUP03mRFJoqRxL8SS8_ImM&
```


```
curl 'https://smart.argo.run/v/r4/sim/eyJtIjoiMSIsImsiOiIxIiwiaSI6IjEiLCJqIjoiMSIsImIiOiI4N2EzMzlkMC04Y2FlLTQxOGUtODljNy04NjUxZTZhYWIzYzYifQ/auth/token' \
  -H 'accept: application/json' \
  -H 'content-type: application/x-www-form-urlencoded' \
  -H 'Authorization: Basic ZGVtb19hcHBfd2hhdGV2ZXI6c2VjcmV0LWtleS0xMjM0NTY3ODkw' \
  --data-raw 'code=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb250ZXh0Ijp7Im5lZWRfcGF0aWVudF9iYW5uZXIiOnRydWUsInNtYXJ0X3N0eWxlX3VybCI6Imh0dHBzOi8vc21hcnQuYXJnby5ydW4vL3NtYXJ0LXN0eWxlLmpzb24iLCJwYXRpZW50IjoiODdhMzM5ZDAtOGNhZS00MThlLTg5YzctODY1MWU2YWFiM2M2In0sImNsaWVudF9pZCI6ImRlbW9fYXBwX3doYXRldmVyIiwiY29kZV9jaGFsbGVuZ2VfbWV0aG9kIjoiUzI1NiIsImNvZGVfY2hhbGxlbmdlIjoieFFzdkN5c2FMbEZvVkU5ZV92MTFiWmNwUlR6RW5wVnIzY2c2VTJYeFpFbyIsInNjb3BlIjoibGF1bmNoL3BhdGllbnQgcGF0aWVudC9PYnNlcnZhdGlvbi5ycyBwYXRpZW50L1BhdGllbnQucnMiLCJyZWRpcmVjdF91cmkiOiJodHRwczovL3NoYXJwLWxha2Utd29yZC5nbGl0Y2gubWUvZ3JhcGguaHRtbCIsImlhdCI6MTYzMzUzMzY1NCwiZXhwIjoxNjMzNTMzOTU0fQ.ovs8WkW7ViCvoiTGJXxWb21OtiJfUmwgXwkt3a1gNRc&grant_type=authorization_code'

{
  "need_patient_banner": true,
  "smart_style_url": "https://smart.argo.run/smart-style.json",
  "patient": "87a339d0-8cae-418e-89c7-8651e6aab3c6",
  "token_type": "Bearer",
  "scope": "launch/patient patient/Observation.rs patient/Patient.rs offline_access",
  "expires_in": 3600,
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuZWVkX3BhdGllbnRfYmFubmVyIjp0cnVlLCJzbWFydF9zdHlsZV91cmwiOiJodHRwczovL3NtYXJ0LmFyZ28ucnVuLy9zbWFydC1zdHlsZS5qc29uIiwicGF0aWVudCI6Ijg3YTMzOWQwLThjYWUtNDE4ZS04OWM3LTg2NTFlNmFhYjNjNiIsInJlZnJlc2hfdG9rZW4iOiJleUpoYkdjaU9pSklVekkxTmlJc0luUjVjQ0k2SWtwWFZDSjkuZXlKamIyNTBaWGgwSWpwN0ltNWxaV1JmY0dGMGFXVnVkRjlpWVc1dVpYSWlPblJ5ZFdVc0luTnRZWEowWDNOMGVXeGxYM1Z5YkNJNkltaDBkSEJ6T2k4dmMyMWhjblF1WVhKbmJ5NXlkVzR2TDNOdFlYSjBMWE4wZVd4bExtcHpiMjRpTENKd1lYUnBaVzUwSWpvaU9EZGhNek01WkRBdE9HTmhaUzAwTVRobExUZzVZemN0T0RZMU1XVTJZV0ZpTTJNMkluMHNJbU5zYVdWdWRGOXBaQ0k2SW1SbGJXOWZZWEJ3WDNkb1lYUmxkbVZ5SWl3aWMyTnZjR1VpT2lKc1lYVnVZMmd2Y0dGMGFXVnVkQ0J3WVhScFpXNTBMMDlpYzJWeWRtRjBhVzl1TG5KeklIQmhkR2xsYm5RdlVHRjBhV1Z1ZEM1eWN5QnZabVpzYVc1bFgyRmpZMlZ6Y3lJc0ltbGhkQ0k2TVRZek16VXpNemcxT1N3aVpYaHdJam94TmpZMU1EWTVPRFU1ZlEuUTQxUXdaQ0VRbFoxNk03WXd2WXVWYlVQMDNtUkZKb3FSeEw4U1M4X0ltTSIsInRva2VuX3R5cGUiOiJiZWFyZXIiLCJzY29wZSI6ImxhdW5jaC9wYXRpZW50IHBhdGllbnQvT2JzZXJ2YXRpb24ucnMgcGF0aWVudC9QYXRpZW50LnJzIG9mZmxpbmVfYWNjZXNzIiwiY2xpZW50X2lkIjoiZGVtb19hcHBfd2hhdGV2ZXIiLCJleHBpcmVzX2luIjozNjAwLCJpYXQiOjE2MzM1MzM4NTksImV4cCI6MTYzMzUzNzQ1OX0.-4vtO6iADkH7HM6-IqoSchEMv2mVsztjHg-5RBkPXrc",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb250ZXh0Ijp7Im5lZWRfcGF0aWVudF9iYW5uZXIiOnRydWUsInNtYXJ0X3N0eWxlX3VybCI6Imh0dHBzOi8vc21hcnQuYXJnby5ydW4vL3NtYXJ0LXN0eWxlLmpzb24iLCJwYXRpZW50IjoiODdhMzM5ZDAtOGNhZS00MThlLTg5YzctODY1MWU2YWFiM2M2In0sImNsaWVudF9pZCI6ImRlbW9fYXBwX3doYXRldmVyIiwic2NvcGUiOiJsYXVuY2gvcGF0aWVudCBwYXRpZW50L09ic2VydmF0aW9uLnJzIHBhdGllbnQvUGF0aWVudC5ycyBvZmZsaW5lX2FjY2VzcyIsImlhdCI6MTYzMzUzMzg1OSwiZXhwIjoxNjY1MDY5ODU5fQ.Q41QwZCEQlZ16M7YwvYuVbUP03mRFJoqRxL8SS8_ImM"
}
```
