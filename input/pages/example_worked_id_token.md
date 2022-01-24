
### Working with SMART on FHIR ID Tokens (examples)


```python
# !pip3 install python-jose
from Crypto.PublicKey import RSA
import json
import jose.jwk
import jose.jwt
import jose.constants
```

### Setup
To create self-contained example, we'll generate a new RSA Key for a fake
organization called "my-ehr.org", and we'll use that for the operations below.


```python
key = RSA.generate(2048)

private = key.exportKey('PEM').decode()
public = key.publickey().exportKey().decode()
print(public, "\n\n", private)
```

    -----BEGIN PUBLIC KEY-----
    MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqgr+Ee4zvGP+giYxCAJ1
    oI/ZIwhnUueEyVGqXgWJKqTUkliL9ccK0lsaPKDPUlGeIhyjJJQKjOfWWS5bMucs
    x3h9t4x98aZVkYUAdm7RSwjd3b59Fr6G60SsfrbtYhp4varKk2ZP2Ex2lB6ZHZoc
    3hFs/sMKibQNGqQT2bt+xpHvGtY994Tun/C3iOvjk3hvHMDp5Q+NY0aE/FURLEsa
    quBbOam0JTf9XVY8SBIsKb9sV0F6/lvWXos/acZflIFUyf22Z6eKniJKlH4FhrsQ
    c8YeILGR3iEKY3vauajCjHJkAyR+/fNKdRO0gQI12DxAL+piA8XtDxodNeTmIDXM
    rwIDAQAB
    -----END PUBLIC KEY-----

     -----BEGIN RSA PRIVATE KEY-----
    MIIEogIBAAKCAQEAqgr+Ee4zvGP+giYxCAJ1oI/ZIwhnUueEyVGqXgWJKqTUkliL
    9ccK0lsaPKDPUlGeIhyjJJQKjOfWWS5bMucsx3h9t4x98aZVkYUAdm7RSwjd3b59
    Fr6G60SsfrbtYhp4varKk2ZP2Ex2lB6ZHZoc3hFs/sMKibQNGqQT2bt+xpHvGtY9
    94Tun/C3iOvjk3hvHMDp5Q+NY0aE/FURLEsaquBbOam0JTf9XVY8SBIsKb9sV0F6
    /lvWXos/acZflIFUyf22Z6eKniJKlH4FhrsQc8YeILGR3iEKY3vauajCjHJkAyR+
    /fNKdRO0gQI12DxAL+piA8XtDxodNeTmIDXMrwIDAQABAoIBAAxVs8x1LQeTcVjb
    kF72XrYA+U1TRLt80+MOq38ag7K2Nj1PcwenIp/Tv/l56NAd34y16xeyLXm/L4tU
    k4UDw/nMQcJYzKIE4Nwne7sbms8Im5+EO+q0c3EJkEG430tohC2t//flShF0qn1g
    ItdE4KczOGbamx8WEoVGNbJrqWyZ9uuUx66UsUkXdEYnwPvfKeYmZP0MQYREsQ5C
    R98bdOrtz+wAc9zTu77GBxG7PzWtIQh8PF5/pfV3JOVHv+wGadLaLG4GD66ErYQh
    p8O/CPn3V34ol55NByFD1HiQoRwTkA/zmoI5axyaqBZbfWOSMYJp2ovR4NLQ1Z+n
    90umwOECgYEAt46acpTwiea2qxBSA5jcr2oYAFkwI+umgPQ2KkotlkG+u7xlvmDN
    wCyx+28xX6vWr0rJuptVgFnEYDnO5PFQj+emTnaRO5uVhmTA3sy1uQLDtP76kR0Q
    iK5aW5D5S9Z27pMKMyylqpnVbUHhl9+q8dulr2F639vIkER0bQeHAFcCgYEA7ScD
    StPAO+rWB9xvtA7ZCrF1lhwfPzicLMxiNOPf6YTg2agcAtZsJZOhB+MzPtF3E/t9
    oQHFlZvRn0yUcGsPtrUbq/8rU2T3mghdoMgWGomnwecDsk0lUrwv8Uxh1JYRNNhD
    82f6TSR9rPejYIaJflSEnoMJpM2PxtvQYaOA/2kCgYA/ZjXaVa8vMkztkNmC/I1c
    2RwpIqUKAx6jc7YxrSVJvLOQTGYn92+ZbNacra80CDpCmWZL2dMSXe8B/XWEhgT5
    b111xGYtXHOs06f6TGKH4HiQT3FkJdHMI8x5y/0PQKgbhxYCzuz5m+CnuBWfS1XT
    67Wyeczi/RqtGbfM4Mi0SQKBgEt+suacOEMaxB3mh8zbOS7VRWiO9UeL/vOn8M+D
    h2Fwgp/ni1s/5VelAotfQY4K4oyC8ABUbxDsdLPwjgSnoG36g5+icKlwp/3qEdxA
    NgEmtzfcEeot8ua+r8hyF2a0iy+2dRNEk4MBTdzFTMZKrfSAdWN8tZI4OkAE8/ZR
    NZyZAoGALvnLujCXip/onDmJJF1sD+t1NV3ldTDmof2/tsuZBQiHh8Q9nqsVl0t5
    1GxRmTsc1BLkPSFco0bcINiiyBid/p5xqHcV29XFLzls8BIHZg808/qWGar2UPkn
    /7nI+8QGrPH5JCgki8r9qlVHHE88Z0weOEUORyJj/w6Kv0WECUo=
    -----END RSA PRIVATE KEY-----


### Creating an ID Token (for servers)
Servers will create a signed JWT by following a process like this.

#### Create a set of claims
These should include:
 * `sub`: the user
 * `aud`: the app for whom this ID Token is being produced
 * `iss`: an identifier for this EHR system)
 * `profile`: the absolute URL of the FHIR resource representing the current user

#### Encode them in a JWT
Signing with the server's private key


```python
claims = {
  "sub": "alice",
  "aud": "growth-chart-app-123",
  "iss": "https://my-ehr.org/fhir",
  "fhirUser": "https://my-ehr.org/fhir/Practitioner/123"
}


id_token = jose.jwt.encode(
    claims,
    key,
    algorithm='RS384')

print(id_token)
```

    eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzM4NCJ9.eyJzdWIiOiJhbGljZSIsImF1ZCI6Imdyb3d0aC1jaGFydC1hcHAtMTIzIiwiaXNzIjoiaHR0cHM6Ly9teS1laHIub3JnL2ZoaXIiLCJmaGlyVXNlciI6Imh0dHBzOi8vbXktZWhyLm9yZy9maGlyL1ByYWN0aXRpb25lci8xMjMifQ.BuivDG9lOu0mI5ESm2Cl4EoGTW0BFA3N5oPcEX30Q77vxBuMspRd9N6kKLgTj8TsAFAutXKlTztdbbyDsTVcjYRZervUMgfS5gv2ERmTTy6wnWRxcsxA8oCmwJ8nqIz9VztCd73IZ8zvCebnaIwTjqt3r5a1aWNqRftncUa5pA2nN3DezMPrWaQ6U_S-QcyVrS_NznqRzI_2JFXlnLn6xSD6CXAfSHRy-1M2VZA4b6m6K3LXM2Pe_WF8HJ1GCLKLMqvYM0oQGLgy4tpDrDr8T8kxd4nLisIjQoXVjx5kASSaSiEuPYMG5E0h9eeSUZFVG-FvYtkgXF3vKaBJjX40BA


### Validating and using an ID Token (for clients)
A client obtains the ID Token as the result of an authorization operation. To validate the token, the client fetches the servers's public key, and then decodes the token. While decoding the token, the client must verify that the audience ('aud') matches its own client_id




```python
jose.jwt.decode(id_token, public, audience='growth-chart-app-123')
```




    {'sub': 'alice',
     'aud': 'growth-chart-app-123',
     'iss': 'https://my-ehr.org/fhir',
     'fhirUser': 'https://my-ehr.org/fhir/Practitioner/123'}
