This page reflects non-normative best practices established at the time of publication.  For up-to-date community discussion, see [SMART on FHIR Best Practices on the HL7 Confluence Site](https://confluence.hl7.org/display/FHIRI/SMART+on+FHIR+Best+Practices)

### Best practices for server developers include

* Remind users which apps have offline access (keeping in mind that too many reminders lead to alert fatigue)
* Mitigate threats of compromised refreshed tokens
* Expire an app's authorization if a refresh token is used more than once (see OAuth 2.1 [section 6.1](https://datatracker.ietf.org/doc/html/draft-ietf-oauth-v2-1-02#section-6.1))
* Consider offering clients a way to bind refresh tokens to asymmetric secrets managed in hardware
  * E.g., per-device dynamic client registration (see ongoing work on [UDAP specifications](https://www.udap.org/))
  * E.g., techniques like the [draft DPOP specification](https://datatracker.ietf.org/doc/html/draft-ietf-oauth-dpop-03)

### Best practices for app developers include

* Ensure that refresh tokens are never used more than once
* Take advantage of techniques to bind refresh tokens to asymmetric secrets managed in hardware, when available (see above)
* If an app only needs to connect to EHR when the user is present, maintain secrets with best-available protection (e.g., biometric unlock)
* Publicly document any code of conduct that an app adheres to (e.g., [CARIN Alliance code of conduct](https://www.carinalliance.com/our-work/trust-framework-and-code-of-conduct/))

### Considerations for Scope Consent

In 3rd-party authorization scenarios (where the client and the resource server are not from the same organization), it is a common requirement for authorization servers to obtain the user's consent prior to granting the scopes requested by the client. In order to collect the required consent in a transparent manner, it is important that the authorization server presents a summary of the requested scopes in concise, plain language that the user understands.

The responsibility of supporting transparent consent falls on both the authorization server implementer as well as the client application developer.

*Client Application Considerations*
* In a complex authorization scenario involving user consent, the complexity of the authorization request presented to the user should be considered and balanced against the concept of least privilege. Make effective use of both wildcard and SMART 2.0 fine grained resource scopes to reduce the number and complexity of scopes requested. The goal is to request an appropriate level of access in a transparent manner that the user fully understands and agrees with.

*Authorization Server Considerations*
* For each requested scope, present the user with both a short and long description of the access requested. The long description may be available in a pop-up window or some similar display method. These descriptions should be in plain language and localized to the user's browser language preference.
* Consider publishing consent design documentation for client developers including user interface screenshots and full scope description metadata.  This will provide valuable transparency to client developers as they make decisions on what access to request at authorization time.
* Avoid industry jargon when describing a given scope to the user. For example, an average patient may not know what is meant if a client application is requesting access to their "Encounters".
* If using the [experimental query-based scopes](scopes-and-launch-context.html#experimental-features-exp), consider how the query will be represented in plain language. If the query cannot easily be explained in a single sentence, adjustment of the requested scope should be considered or proper documentation provided to educate the intended user population.

### App and Server developers should consider trade-offs associated with confidential vs public app architectures

1. Persistent access is important for providing a seamless consumer experience, and Refresh Tokens are the mechanism SMART App Launch defines for enabling persistent access. If an app is ineligible for refresh tokens, the developer is likely to seek other means of achieving this (e.g., saving a user's password and simulating login; or moving to a cloud-based architecture even though there's no use case for managing data off-device).

1. Client architectures where data pass through or are stored in a secure backend server (e.g., many confidential clients) can offer more secure {refresh token :: client} binding, but are open to certain attacks that purely-on-device apps are not subject to (e.g., cloud server becomes compromised and tokens/secrets leak). A breach in this context can be widespread, across many users.

1. Client architectures where data are managed exclusively on end-user devices (e.g., many public clients including most native apps today, where an app is only registered once with a given EHR) are open to certain attacks that confidential clients can avoid (e.g., a malicious app on your device might steal tokens from a valid app, or might impersonate a valid app). A breach in this context is more likely to be isolated to a given user or device.

The choice of app architecture should be based on context. Apps that already need to manage data in the cloud should consider a confidential client architecture; apps that don't should consider a purely-on-device architecture. But this decision only works if refresh tokens are available in either case; otherwise, app developers will switch architectures just to be able to maintain persistent access, even if the overall security posture is diminished.
