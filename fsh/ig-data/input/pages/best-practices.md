### Considerations for Scope Consent (Non-Normative)

In 3rd-party authorization scenarios (where the client and the resource server are not from the same organization), it is a common requirement for authorization servers to obtain the user's consent prior to granting the scopes requested by the client. In order to collect the required consent in a transparent manner, it is important that the authorization server presents a summary of the requested scopes in concise, plain language that the user understands.

The responsibility of supporting transparent consent falls on both the authorization server implementer as well as the client application developer.

*Client Application Considerations*
* In a complex authorization scenario involving user consent, the complexity of the authorization request presented to the user should be considered and balanced against the concept of least privilege. Make effective use of both wildcard and SMART 2.0 fine grained resource scopes to reduce the number and complexity of scopes requested. The goal is to request an appropriate level of access in a transparent manner that the user fully understands and agrees with.


*Authorization Server Considerations*
* For each requested scope- present the user with both a short and long description of the access requested. The long description may be available in a pop-up window or some similar display method. These descriptions should be in plain language, localized to the language set in the user's browser.
* Consider publishing consent design documentation for client developers- including user interface screenshots and full scope description metadata.  This will provide valuable transparency to client developers as they make decisions on what access to request at authorization time.
* Avoid industry jargon when describing a given scope to the user. For example, an average patient may not know what is meant if a client application is requesting for access to their "Encounters".
* If using the experimental query-based scopes, consider how the query will be represented in plain language. If the query cannot easily be explained in a single sentence, adjustment of the requested scope should be considered or proper documentation provided to educate the intended user population.

