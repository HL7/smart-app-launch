```python
# To create a markdown of this notebook, run: jupyter nbconvert --to markdown example-authorization-jwks-and-signatures.ipynb
# !pip3 install python-jose

import json
import jose.jwk
import jose.jwt
import jose.constants

def get_signing_key(filename):
    with open(filename) as private_key_file:
        signing_keyset = json.load(private_key_file)
        signing_key = [k for k in signing_keyset["keys"] if "sign" in k["key_ops"]][0]
        return signing_key
    
jwt_claims = {
  "iss": "https://bili-monitor.example.com",
  "sub": "https://bili-monitor.example.com",
  "aud": "https://authorize.smarthealthit.org/token",
  "exp": 1422568860,
  "jti": "random-non-reusable-jwt-id-123"
}
```


    Traceback (most recent call last):


      File ~\AppData\Roaming\Python\Python38\site-packages\IPython\core\interactiveshell.py:3251 in run_code
        exec(code_obj, self.user_global_ns, self.user_ns)


      Input In [5] in <module>
        import jose.jwk


      File C:\Python38\lib\site-packages\jose.py:546
        print decrypt(deserialize_compact(jwt), {'k':key},
              ^
    SyntaxError: invalid syntax




```python
print("### Encoded JWT with RS384 Signature")
rsa_signing_jwk = get_signing_key("RS384.private.json")
jose.jwt.encode(
    jwt_claims,
    rsa_signing_jwk,
    algorithm='RS384',
    headers={"kid": rsa_signing_jwk["kid"]})
```

    ### Encoded JWT with RS384 Signature



    ---------------------------------------------------------------------------

    NameError                                 Traceback (most recent call last)

    Input In [1], in <module>
          1 print("### Encoded JWT with RS384 Signature")
    ----> 2 rsa_signing_jwk = get_signing_key("RS384.private.json")
          3 jose.jwt.encode(
          4     jwt_claims,
          5     rsa_signing_jwk,
          6     algorithm='RS384',
          7     headers={"kid": rsa_signing_jwk["kid"]})


    NameError: name 'get_signing_key' is not defined



```python
print("### Encoded JWT with ES384 Signature")
ec_signing_jwk  = get_signing_key("ES384.private.json")
jose.jwt.encode(
    jwt_claims,
    ec_signing_jwk,
    algorithm='ES384',
    headers={"kid": ec_signing_jwk["kid"]})
```

    # Encoded JWT with ES384 Signature





    'eyJhbGciOiJFUzM4NCIsImtpZCI6ImNkNTIwMjExZTU2NjFkYmJhMjI1NmY2N2Y2ZDUzZjk3IiwidHlwIjoiSldUIn0.eyJpc3MiOiJodHRwczovL2JpbGktbW9uaXRvci5leGFtcGxlLmNvbSIsInN1YiI6Imh0dHBzOi8vYmlsaS1tb25pdG9yLmV4YW1wbGUuY29tIiwiYXVkIjoiaHR0cHM6Ly9hdXRob3JpemUuc21hcnRoZWFsdGhpdC5vcmcvdG9rZW4iLCJleHAiOjE0MjI1Njg4NjAsImp0aSI6InJhbmRvbS1ub24tcmV1c2FibGUtand0LWlkLTEyMyJ9.ddl5N8dt5PYI_7syKg_dm1wj1LR3dYVztFlTODs6pU1vKH1Zv3d9NctbnAsZ4aZ1K7HE83_fA_hIAL0JsU1GoB7roLmrpj8zfygG9Q1ZBAmKNoR60pyONPZsGTihoR29'


