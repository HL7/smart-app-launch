This implementation guide describes a set of foundational patterns based on OAuth 2.0 for client applications to authorize, authenticate, and integrate with FHIR-based data systems. The patterns defined in this specification are introduced in the sections below.

### [Discovery of Server Capabilities and Configuration](conformance.html)

SMART defines a discovery document available at `.well-known/smart-configuration` relative to a FHIR Server Base URL, allowing clients to learn the authorization endpoint URLs and features a server supports. This information helps client direct authorization requests to the right endpoint, and helps clients construct an authorization request that the server can support.

### SMART Defines Three Patterns For Client *Authorization*

#### [Authorization via **SMART App Launch**](app-launch.html)

Authorizes a user-facing client application ("App") to connect to a FHIR Server. This pattern allows for "launch context" such as *currently selected patient* to be shared with the app, based on a user's session inside an EHR or other health data software, or based on a user's selection at launch time. Authorization allows for delegation of a user's permissions to the app itself. 

#### [Authorization via **SMART Backend Services**](backend-services.html)

Authorizes a headless or automated client application ("Backend Service") to connect to a FHIR Server. This pattern allows for backend services to connect and interact with an EHR when there is no user directly involved in the launch process, or in other circumstances where permissions are assigned to the client out-of-band.

#### [Authorization via **SMART Protected Dynamic Client Registration**](public-dynreg.html)

An extension to the SMART App Launch specification that allows apps without a trusted server component to request persistent access to APIs.


### SMART Defines Two Patterns For Client *Authentication*

When clients need to authenticate, this implementation guide defines two methods.

*Note that client authentication is not required in all authorization scenarios, and not all SMART clients are capable of authenticating (see discussion of ["Public Clients"](app-launch.html#support-for-public-and-confidential-apps) in the SMART App Launch overview).*

#### **[Asymmetric ("private key JWT") authentication](client-confidential-asymmetric.html)**

Authenticates a client using an asymmetric keypair. This is SMART's preferred authentication method because it avoids sending a shared secret over the wire.


#### **[Symmetric ("client secret") authentication](client-confidential-symmetric.html)**

Authenticate a client using a secret that has been pre-shared between the client and server


### [Scopes for Limiting Access](scopes-and-launch-context.html)

SMART uses a language of "scopes" to define specific access permissions that can be delegated to a client application. These scopes draw on FHIR API definitions for interactions, resource types, and search parameters to describe a permissions model. For example, an app might be granted scopes like `user/Encounter.rs`, allowing it to read and search for Encounters that are accessible to the user who has authorized the app. Similarly, a backend service might be granted scopes like `system/Encounter.rs`, allowing it to read and search for Encounters within the overall set of data it is configured to access. User-facing apps can also receive "launch context" to indicate details about the current patient or other aspects of a user's EHR session or a user's selections when launching the app.

*Note that the scope syntax has changed since SMARTv1. Details are at [Scopes for requesting clinical data](scopes-and-launch-context.html#scopes-for-requesting-clinical-data).*

### [Token Introspection](token-introspection.html)

SMART defines a Token Introspection API allowing Resource Servers or software components to understand the scopes, users, patients, and other context associated with access tokens. This pattern allows a looser coupling between Resource Servers and Authorization Servers.
