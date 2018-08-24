---
layout: default
title: "Working with SMART on FHIR ID Tokens Example"
---

## Setup

To create self-contained example, we'll generate a new RSA Key for a fake organization called "my-ehr.org", and we'll use that for the operations below.

~~~ python
import jwt
from Crypto.PublicKey import RSA

key = RSA.generate(2048)
private = key.exportKey('PEM')
public = key.publickey().exportKey()
print public, "\n\n", private
~~~

Output:

~~~ string
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnvUyZCs7piYhhMjshljQ
+csrA2eYwoK4hmxXy+QfXFhB+ly3gk0LWVtDQAtOlTuex+G1mUt2e42E73pThNR2
mZo87tMFQKeElBWchjUifrOO4YbLmyorVlrP3+Oil0clMyZEZsbSmcc9R/0PFGox
FeU4B6eyavA8Eg23Cyj2kV9Ds5m9v35z3VsntcFoyt+ObRXDlIdo9K3YKAdP18zv
Ex+NhIt3c5NBLoX2cfZakihWDs3XDaekBG5YhhqWMlf4A8BAp2BTu6YHK/8ymjMo
tixDVSp8KgXKw3RnBgyacpl95oPdyiaQEzrNz17DPy1j12Y3vFMEFSc/VYHzm577
oQIDAQAB
-----END PUBLIC KEY-----
~~~
{:.print_out}

~~~string
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAnvUyZCs7piYhhMjshljQ+csrA2eYwoK4hmxXy+QfXFhB+ly3
gk0LWVtDQAtOlTuex+G1mUt2e42E73pThNR2mZo87tMFQKeElBWchjUifrOO4YbL
myorVlrP3+Oil0clMyZEZsbSmcc9R/0PFGoxFeU4B6eyavA8Eg23Cyj2kV9Ds5m9
v35z3VsntcFoyt+ObRXDlIdo9K3YKAdP18zvEx+NhIt3c5NBLoX2cfZakihWDs3X
DaekBG5YhhqWMlf4A8BAp2BTu6YHK/8ymjMotixDVSp8KgXKw3RnBgyacpl95oPd
yiaQEzrNz17DPy1j12Y3vFMEFSc/VYHzm577oQIDAQABAoIBAEa6oa5ykjsO0nFM
Gfp5gJr1bPE54n4CPmsJwFMn8VBcsRbetITVFUywUA8qONAsVC1qYCySqGi3gsQw
MQN0qkUUnTJDUR4Aq/xcVWZeNDgeW2A8Y1JqhBgLll1v44Pek03cJCl7JHBqd/kV
P+V8jtTIRpMZakktFf2OfrkHhBcQkZxEAVbthu8/fLl9LDGIFBJTZE80H48dWMiE
1QGdokJgX8k/lA6+Kr5/nMPiP/g1SkIEpsfmdGDB24pEAIRt9RfI0j72qMFY36mg
Uj6H68fkBN1vHyUGP8dIV1nZZ3aSHRehSYnEUJuM59O0diMrGcbpTkE9EouNZrwy
eM5qb7UCgYEAvMt18Cs1zkOvc2gWMesJKEzXz3gwRvIJNXdrGzjirQeN5luCw+Vo
P3QhIRhiatWYfe0fcVcE3odakpHXNJvwdnaAZxpY+k0YpWptuT+hPMME2+hNrAWq
UeRWIGh7eG0w0aLB8JlQnt1cPOkWMzehJwhpfcsnLwMuPRsMgA4QWVMCgYEA14q+
vFITKta90LiCH5PxJI2dFZjG2IU/MmIc85eGxLWgk1mIr38neS9Q9K1hcRs/jr8Y
dxK5UCYM6hP59zFfh8B7yGGgfXOPOa9g7ZrG7PYGv7OMyezhXC+3QCBSPQ0qEKut
npxefnIa+E8b8OzFLXjHN8F5DY5+CnUpQD3X1LsCgYBwkJMCHpFXKS4cDixlmPB9
0cs+zTdjpX3uHgSDV5h3eDCX72n5KPfOFYyHMgXEExR3yIDdz/d8QpGzIDeDC5ME
3sTSNHhmzL7sKZfAQvr8wn5MK6bb8QjLCOx9KC6t79SSuYsOzCqwfeU3//WXlgyE
vFRBh3YWZrwT/OOoGjqPNwKBgQC6dWYnF4FJT9eI1fSLSLoU+wTnB/EMochX15Rg
DbciOFUe4xdhakhFh28rG0nuRLoozJtndqUk9qW5YWqeMvIHR7ZNVFc37135cwQQ
yBJKL1MLR1IF5IvX6ddG/C7obZj0Lu/VBESiciduo1DyjIDOo2sDirUjyx6yAUSc
NGOfvQKBgCpWQkze+7MucceDyHBEy09+byPRmmzYcJDeFKokFpWJXW8lzMeJD3JH
odjMPdAaiF2fIUrj6/Ea3a8TiTROewChVPBNfiqVDJ8hp5CzPEV3XYkMM0lj/7Gn
bk1C6+SxZUGhhJxp1Pi6rl9vshxNv4g9qm046r2iZOBzjDhVTxkZ
-----END RSA PRIVATE KEY-----
~~~
{:.print_out}

## Creating an ID Token (for servers)
Servers will create a signed JWT by following a process like this...

### Create a set of claims
These should include:

- sub: the user
- aud: the app for whom this ID Token is being produced
- iss: an identifier for this EHR system)
- profile: the absolute URL of the FHIR resource representing the current user

### Encode them in a JWT
Signing with the server's private key

~~~ python
claims = {
  "sub": "alice",
  "aud": ["growth-chart-app-123"],
  "iss": "https://my-ehr.org/fhir",
  "profile": "https://my-ehr.org/fhir/Practitioner/123"
}

id_token = jwt.encode(claims, key, 'RS512')
print id_token
~~~

Output:

<div class="scroll-me">

<code class="print_out">eyJhbGciOiJSUzUxMiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL215LWVoci5vcmcvZmhpciIsInByb2ZpbGUiOiJodHRwczovL215LWVoci5vcmcvZmhpci9QcmFjdGl0aW9uZXIvMTIzIiwic3ViIjoiYWxpY2UiLCJhdWQiOlsiZ3Jvd3RoLWNoYXJ0LWFwcC0xMjMiXX0.l_nSNfu9Sr3aeQA0C35bicRAMVu90UsQS61A7SPMGk2CQCgmXC87xgW_WR-D9CKk2sgGqom1qqYea_0A9LcncCYLXJL57MC5h7Kk3rjsBG_6Aib2jbOoGDlXbAogdXts7Jh5uGoIwZg6A4oTFB-9pWwrdtebBVdUjEfbDtAvmGZTvLxRMSv4ak1MorcUqLxwKMuj0PNr8AptKlf4ar0zDkua62y3nyM9xi-G6mD77HWG_lbtYaLVt8l-reSvuy7nFEODsvixtQ3yvIveKU8lAbItBf-FTSJi5m_pcfokBvwq8kTdX0fZHKj_bC1cGY0nv1qaoRwXpWefk-SRZbI2pg</code>

</div>
<br />

### Validating and using an ID Token (for clients)
A client obtains the ID Token as the result of an authorization operation. To validate the token, the client fetches the servers's public key, and then decodes the token. After decoding the token

~~~ python
jwt.decode(id_token, key=public)
~~~

Output:

~~~ string
{u'aud': [u'growth-chart-app-123'],
 u'iss': u'https://my-ehr.org/fhir',
 u'profile': u'https://my-ehr.org/fhir/Practitioner/123',
 u'sub': u'alice'}
~~~
{:.print_out}
