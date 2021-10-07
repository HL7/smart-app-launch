### Profile Audience and Scope

This profile desribes SMART's
[`client-confidential-symmetric`](conformance.html) authentication mechanism.  It is intended for
for [SMART App Launch](app-launch.html) clients that can maintain a secret but cannot manage asymmetric keypairs. For client that can manage asymmetric keypairs, [Asymmetric Authentication](client-confidential-asymmetric.html) is preferred. This profile is not intended for [SMART Backend Services](backend-services.html) clients.

### Authentication using a `client_secret`

If a client has registered for Client Password authentication (i.e.,
it possesses a `client_secret` that is also known to the EHR), the client
authenticates by supplying an `Authorization` header with HTTP Basic authentication,
where the username is the app's `client_id` and the password is the app's
`client_secret`.

#### Example

If the `client_id` is "my-app" and the `client_secret` is "my-app-secret-123",
then the header uses the value B64Encode("my-app:my-app-secret-123"), which
converts to `bXktYXBwOm15LWFwcC1zZWNyZXQtMTIz`. This gives the app the Authorization
token for "Basic Auth".

GET header:

```
Authorization: Basic bXktYXBwOm15LWFwcC1zZWNyZXQtMTIz
```
