# SMART App Launch

1. The generated Toc will be an ordered list
{:toc}

## Overview

This implementation guide describes a set of foundational patterns based on OAuth 2.0 for client applications to authorize, authenticate, and integrate with FHIR-based data systems. The patterns defined in this specification are introduced in the sections below.

### [Discovery of Server Capabilities and Configuration](conformance.html)

SMART defines a discovery document available at `.well-known/smart-configuration` relative to a FHIR Server Base URL, allowing clients to learn the authorization endpoint URLs and features a server supports. This information helps client direct authorization requests to the right endpoint, and helps clients construct an authorization request that the server can support.

### SMART Defines Two Patterns For Client *Authorization*

#### [Authorization via **SMART App Launch**](app-launch.html)

Authorizes a user-facing client application ("App") to connect to a FHIR Server. This pattern allows for "launch context" such as *currently selected patient* to be shared with the app, based on a user's session inside an EHR or other health data software, or based on a user's selection at launch time. Authorization allows for delegation of a user's permissions to the app itself. 

#### [Authorization via **SMART Backend Services**](backend-services.html)

Authorizes a headless or automated client application ("Backend Service") to connect to a FHIR Server. This pattern allows for backend services to connect and interact with an EHR when there is no user directly involved in the launch process, or in other circumstances where permissions are assigned to the client out-of-band.

### SMART Defines Two Patterns For Client *Authentication*

When clients need to authenticate, this implementation guide defines two methods.

*Note that client authentication is not required in all authorization scenarios, and not all SMART clients are capable of authenticating (see discussion of ["Public Clients"](app-launch.html#support-for-public-and-confidential-apps) in the SMART App Launch overview).*

#### **[Asymmetric ("private key JWT") authentication](client-confidential-asymmetric.html)**

Authenticates a client using an asymmetric keypair. This is SMART's preferred authentication method because it avoids sending a shared secret over the wire.


#### **[Symmetric ("client secret") authentication](client-confidential-symmetric.html)**

Authenticate a client using a secret that has been pre-shared between the client and server


### [Scopes for Limiting Access](scopes-and-launch-context.html)

SMART uses a language of "scopes" to define specific access permissions that can be delegated to a client application. These scopes draw on FHIR API definitions for interactions, resource types, and search parameters to describe a permissions model. For example, an app might be granted scopes like `user/Encounter.rs`, allowing it to read and search for Encounters that are accessible to the user who has authorized the app. Similarly, a backend service might be granted scopes like `system/Encounter.rs`, allowing it to read and search for Encounters within the overall set of data it is configured to access. User-facing apps can also receive "launch context" to indicate details about the current patient or other aspects of a user's EHR session or a user's selections when launching the app.

*Note that the scope syntax has changed since SMARTv1. Details are in section [Scopes for requesting clinical data](scopes-and-launch-context.html#scopes-for-requesting-clinical-data).*

### [Token Introspection](token-introspection.html)

SMART defines a Token Introspection API allowing Resource Servers or software components to understand the scopes, users, patients, and other context associated with access tokens. This pattern allows a looser coupling between Resource Servers and Authorization Servers.


### FHIR Publication Details

#### Intellectual Property Statements

{% include ip-statements.xhtml %}

#### Cross Version Analysis

{% include cross-version-analysis.xhtml %}

#### Package Dependencies

{% include dependency-table.xhtml %}

#### Global Profile Definitions

{% include globals-table.xhtml %}
## 'App Launch: Launch and Authorization'

The SMART App Launch Framework connects third-party applications to Electronic
Health Record data, allowing apps to launch from inside or outside the user
interface of an EHR system. The framework supports apps for use by clinicians,
patients, and others via a PHR or Patient Portal or any FHIR system where a user can launch an app. It provides a reliable, secure authorization protocol for
a variety of app architectures, including apps that run on an end-user's device
as well as apps that run on a secure server.
The Launch Framework supports four key use cases:

1. Patients apps that launch standalone
2. Patient apps that launch from a portal
3. Provider apps that launch standalone
4. Provider apps that launch from a portal

These use cases support apps that perform data visualization, data collection,
clinical decision support, data sharing, case reporting, and many other
functions.

### Profile audience and scope

This profile is intended to be used by developers of apps that need to access user identity information or other FHIR resources by requesting authorization from OAuth 2.0 compliant authorization servers. It is compatible with FHIR R2 (DSTU2) and later; this publication includes explicit definitions for FHIR R4.

OAuth 2.0 authorization servers are configured to mediate access based on
a set of rules configured to enforce institutional policy, which may
include requesting end-user authorization.  This profile
does not dictate the institutional policies that are implemented in the
authorization server.

The profile defines a method through which an app requests
authorization to access a FHIR resource, and then uses that authorization
to retrieve the resource.  Synchronization of patient context is not addressed;
for use cases that require context synchronization (e.g., learning about when
the in-context patient changes within an EHR session) see
[FHIRcast](https://fhircast.org).  In other words, if the patient chart is
changed during the session, the application will not inherently be updated.

Security mechanisms such as those mandated by HIPAA in the US (end-user
authentication, session time-out, security auditing, and accounting of
disclosures) are outside the scope of this profile.

This profile provides a mechanism to *delegate* an entity's permissions (e.g., a user's permissions) to a 3rd-party app. The profile includes mechanisms to delegate a limited subset of an entity's permissions (e.g., only sharing access to certain data types). However, this profile does not model the permissions that the entity has in the first place (e.g., it provides no mechanism to specify that a given entity should or should not be able to access specific records in an EHR). Hence, this profile is designed to work on top of an EHR's existing user and permissions management system, enabling a standardized mechanism for delegation.


### Security and Privacy Considerations

#### App protection

The app is responsible for protecting itself from potential misbehaving or
malicious values passed to its redirect URL (e.g., values injected with
executable code, such as SQL) and for protecting authorization codes, access
tokens, and refresh tokens from unauthorized access and use.  The app
developer must be aware of potential threats, such as malicious apps running
on the same platform, counterfeit authorization servers, and counterfeit
resource servers, and implement countermeasures to help protect both the app
itself and any sensitive information it may hold. For background, see the
[OAuth 2.0 Threat Model and Security
Considerations](https://tools.ietf.org/html/rfc6819).

Specific requirements are:

* Apps SHALL ensure that sensitive information (authentication secrets,
authorization codes, tokens) is transmitted ONLY to authenticated servers,
over TLS-secured channels.

* Apps SHALL generate an unpredictable `state` parameter for each user
session; SHALL include `state` with all authorization requests; and SHALL
validate the `state` value for any request sent to its redirect URL.

* An app SHALL NOT execute untrusted user-supplied inputs as code.

* An app SHALL NOT forward values passed back to its redirect URL to any
other arbitrary or user-provided URL (a practice known as an “open
redirector”).

* An app SHALL NOT store bearer tokens in cookies that are transmitted
as clear text.

* Apps SHOULD persist tokens and other sensitive data in app-specific
storage locations only, and SHOULD NOT persist them in
system-wide-discoverable locations.

#### Support for "public" and "confidential" apps

Within this profile we differentiate between the two types of apps defined in the [OAuth 2.0 specification: confidential and public](https://tools.ietf.org/html/rfc6749#section-2.1). The differentiation is based upon whether the execution environment within which the app runs
enables the app to protect secrets.   Pure client-side apps
(for example, HTML5/JS browser-based apps, iOS mobile
apps, or Windows desktop apps) can provide adequate security, but they may be unable to "keep a secret" in the OAuth2 sense.  In other words, any "secret" key, code, or
string that is statically embedded in the app can potentially be extracted by an end-user
or attacker. Hence security for these apps cannot depend on secrets embedded at
install-time.

For strategies and best practices to protecting a client secret refer to:

- OAuth 2.0 Threat Model and Security Considerations: [4.1.1. Threat: Obtaining Client Secrets](https://tools.ietf.org/html/rfc6819#section-4.1.1)
- OAuth 2.0 for Native Apps: [8.5. Client Authentication](https://tools.ietf.org/html/draft-ietf-oauth-native-apps-12#section-8.5)
- [OAuth 2.0 Dynamic Client Registration Protocol](https://tools.ietf.org/html/rfc7591)

##### Use the <span class="label label-primary">confidential app</span>  profile if your app is *able* to protect a secret

for example:

- App runs on a trusted server with only server-side access to the secret
- App is a native app that uses additional technology (such as dynamic client registration and universal `redirect_uris`) to protect the secret


##### Use the <span class="label label-primary">public app</span> profile if your app is *unable* to protect a secret

for example:

- App is an HTML5 or JS in-browser app (including single-page applications) that would expose the secret in user space
- App is a native app that can only distribute a secret statically

#### Considerations for PKCE Support
All SMART apps SHALL support Proof Key for Code Exchange (PKCE).  PKCE is a standardized, cross-platform technique for clients to mitigate the threat of authorization code interception or injection. PKCE is described in [IETF RFC 7636](https://tools.ietf.org/html/rfc7636). SMART servers SHALL support the `S256` `code_challenge_method` and SHALL NOT support the `plain` method.

#### Considerations for Cross-Origin Resource Sharing (CORS) support
Servers that support purely browser-based apps SHALL enable [Cross-Origin Resource Sharing (CORS)](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS) as follows:

1. For requests from any origin, CORS configuration permits access to the public discovery endpoints (`.well-known/smart-configuration` and `metadata`)
2. For requests from a client's registered origin(s), CORS configuration permits access to the token endpoint and to FHIR REST API endpoints 

#### Related reading

Implementers can review the [OAuth Security Topics](https://tools.ietf.org/html/draft-ietf-oauth-security-topics-16) guidance from IETF as a collection of Best Current Practices.

Some resources shared with apps following this IG may be considered [Patient Sensitive](http://hl7.org/fhir/security.html#Patient); implementers should review the Core FHIR Specification's [Security Page](http://hl7.org/fhir/security.html) for additional security and privacy considerations.

### SMART authorization & FHIR access: overview

An app can launch from within an existing EHR or Patient Portal session; this is known as an EHR launch.  Alternatively, it can launch as a standalone app.

In an <span class="label label-primary">EHR launch</span>, an opaque handle to
the EHR context is passed along to the app as part of the launch URL.  The app
later will include this handle as a request parameter when it requests
authorization to access resources. The server will provide the application with
EHR context based on this handle. Note that the complete URLs of
all apps approved for use by users of this EHR will have been registered with
the EHR authorization server.

In a <span class="label label-primary">standalone launch</span>, when the app
launches from outside an EHR session, the app can request context from the EHR
authorization server. The context will then be determined during the
authorization process as described below.

Once an app receives a launch request, it requests authorization to access FHIR resources by
instructing the browser to navigate to the EHR's authorization endpoint. Based
on pre-defined rules and possibly end-user authorization, the EHR authorization
server either grants the request by returning an authorization code to the app’s
redirect URL or denies the request. The app then exchanges the authorization
code for an access token. The app presents the access token to the EHR’s resource server to
access requested FHIR resources. If a refresh token is returned along with the
access token, the app may use it to request a new access token with the same
scope, once the old access token expires.

###  Top-level steps for SMART App Launch

The top-level steps for Smart App Launch are:

1. [Register App with EHR](#step-1-register) (*one-time step*, can be out-of-band)
2. Launch App:  [Standalone Launch](#step-2-launch-standalone) or [EHR Launch](#step-2-launch-ehr)
3. [Retrieve .well-known/smart-configuration](#step-3-discovery)
4. [Obtain authorization code](#step-4-authorization-code)
5. [Obtain access token](#step-5-access-token)
6. [Access FHIR API](#step-6-fhir-api)
7. [Refresh access token](#step-7-refresh)

"The actors involved in each step and the order in which steps are used is illustrated in the figure below.
"
<div>{% include overview-app-launch.svg %}</div>
<br clear="all"/>


More detail on each of these steps is provided in the sections below.

<a id="step-1-register"></a>

### Register App with EHR

Before a SMART app can run against an EHR, the app must be registered with that
EHR's authorization service.  SMART does not specify a standards-based registration process, but we
encourage EHR implementers to consider the [OAuth 2.0 Dynamic Client
Registration Protocol](https://tools.ietf.org/html/rfc7591)
for an out-of-the-box solution.

*Note that this is a one-time setup step, and can occur out-of-band*.

#### Request

No matter how an app registers with an EHR's authorization service, at registration time **every SMART app SHALL**:

* Register zero or more fixed, fully-specified launch URL with the EHR's authorization server
* Register one or more fixed, fully-specified `redirect_uri`s with the EHR's authorization server. 

For confidential clients, additional registration-time requirements are defined based on the client authentication method.

* For asymmetric client authentication: a [JSON Web Key Set or JWSK URL](client-confidential-asymmetric.html#registering-a-client-communicating-public-keys) is established
* For symmetric client authentication: a [client secret](client-confidential-symmetric.html) is established

#### Response

The EHR confirms the app's registration parameters and communicates a `client_id` to the app.

<a id="step-2-launch"></a>
<a id="step-2-launch-standalone"></a>

### Launch App: Standalone Launch

In SMART's <span class="label label-primary">standalone
launch</span> flow, a user selects an app from outside the EHR
(for example, by tapping an app icon on a mobile phone home screen).  


#### Request
There is no explicit request associated with this step of the SMART App Launch process.  

#### Response
The app proceeds to the [next step](#step-3-discovery) of the SMART App Launch flow.

#### Examples

* [Public client](example-app-launch-public.html#step-2-launch)
* [Confidential client, asymmetric authentication](example-app-launch-asymmetric-auth.html#step-2-launch)
* [Confidential client, symmetric authentication](example-app-launch-symmetric-auth.html#step-2-launch)

<a id="step-2-launch-ehr"></a>

### Launch App: EHR Launch

In SMART's <span class="label label-primary">EHR launch</span> flow,
a user has established an EHR session and then decides to launch an app. This
could be a single-patient app that runs in the context of a patient record, or
a user-level app (like an appointment manager or a population dashboard).

#### Request
The EHR initiates a "launch sequence" by opening a new browser instance (or `iframe`)
pointing to the app's registered launch URL and passing some context.

The following parameters are included:

<table class="table">
  <thead>
    <th colspan="3">Parameters</th>
  </thead>
  <tbody>
    <tr>
      <td><code>iss</code></td>
      <td><span class="label label-success">required</span></td>
      <td>

Identifies the EHR's FHIR endpoint, which the app can use to obtain
additional details about the EHR including its authorization URL.

      </td>
    </tr>
    <tr>
      <td><code>launch</code></td>
      <td><span class="label label-success">required</span></td>
      <td>

      Opaque identifier for this specific launch and any EHR context associated
with it. This parameter must be communicated back to the EHR  at authorization
time by passing along a <code>launch</code> parameter (see example below).

      </td>
    </tr>
  </tbody>
</table>


##### *For example*
A launch might cause the browser to navigate to:

    Location: https://app/launch?iss=https%3A%2F%2Fehr%2Ffhir&launch=xyz123

Later, when the app prepares its [authorization request](#step-4-authorization-code), it includes
`launch` as a requested scope and includes a `launch={launch id}` URL
parameter echoing the value it received from the EHR in this
notification.

#### Response
The app proceeds to the [next step](#step-3-discovery) of the SMART App Launch flow.


<a id="step-3-discovery"></a>

### Retrieve `.well-known/smart-configuration`

In order to obtain launch context and request authorization to access FHIR
resources, the app discovers the EHR FHIR server's SMART configuration metadata,
including OAuth `authorization_endpoint` and `token_endpoint` URLs.

#### Request

The discovery URL is constructed by appending `.well-known/smart-configuration` to the FHIR Base URL.  The app issues an HTTP GET to the discovery URL with an `Accept` header supporting `application/json`.

#### Response
The EHR responds with a SMART configuration JSON document as described in the [Conformance](conformance.html) section.

#### Examples

* [Example request and response](conformance.html#example-request)


<a id="step-4-authorization-code"></a>

### Obtain authorization code

To proceed with a launch, the app constructs a request for an authorization code.

#### Request
The app supplies the following parameters to the EHR’s "authorize" endpoint.

*Note on PKCE Support: the EHR SHALL ensure that the `code_verifier` is present and valid when the code is exchanged for an access token.*

<table class="table">
  <thead>
    <th colspan="3">Parameters</th>
  </thead>
  <tbody>
    <tr>
      <td><code>response_type</code></td>
      <td><span class="label label-success">required</span></td>
      <td>Fixed value: <code>code</code>. </td>
    </tr>
    <tr>
      <td><code>client_id</code></td>
      <td><span class="label label-success">required</span></td>
      <td>The client's identifier. </td>
    </tr>
    <tr>
      <td><code>redirect_uri</code></td>
      <td><span class="label label-success">required</span></td>
      <td>Must match one of the client's pre-registered redirect URIs.</td>
    </tr>
    <tr>
      <td><code>launch</code></td>
      <td><span class="label label-info">conditional</span></td>
      <td>When using the <span class="label label-primary">EHR Launch</span> flow, this must match the launch value received from the EHR. Omitted when using the <span class="label label-primary">Standalone Launch</span>.</td>
    </tr>
    <tr>
      <td><code>scope</code></td>
      <td><span class="label label-success">required</span></td>
      <td>

Must describe the access that the app needs, including scopes like
<code>patient/*.rs</code>, <code>openid</code> and <code>fhirUser</code> (if app
needs authenticated patient identity) and either:

<ul>
<li> a <code>launch</code> value indicating that the app wants to receive already-established launch context details from the EHR </li>
<li> a set of launch context requirements in the form <code>launch/patient</code>, which asks the EHR to establish context on your behalf.</li>
</ul>

See section <a href="scopes-and-launch-context.html">SMART on FHIR Access
Scopes</a> for details.

      </td>
    </tr>
    <tr>
      <td><code>state</code></td>
      <td><span class="label label-success">required</span></td>
      <td>

An opaque value used by the client to maintain state between the request and
callback. The authorization server includes this value when redirecting the
user-agent back to the client. The parameter SHALL be used for preventing
cross-site request forgery or session fixation attacks.  The app SHALL use
an unpredictable value for the state parameter with at least 122 bits of
entropy (e.g., a properly configured random uuid is suitable).

      </td>
    </tr>
     <tr>
      <td><code>aud</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
URL of the EHR resource server from which the app wishes to retrieve FHIR data.
This parameter prevents leaking a genuine bearer token to a counterfeit
resource server. (Note that in the case of an <span class="label label-primary">EHR launch</span>
flow, this <code>aud</code> value is the same as the launch's <code>iss</code> value.)

Note that the <code>aud</code> parameter is semantically equivalent to the
<code>resource</code> parameter defined in <a href="https://datatracker.ietf.org/doc/rfc8707">RFC8707</a>.
SMART's <code>aud</code> parameter predates RFC8707 and we have decided not to
rename it for reasons of backwards compatibility. We might consider renaming
SMART's <code>aud</code> parameter in the future if implementer feedback
indicates that alignment would be valuable.  For the current release, servers
SHALL support the <code>aud</code> parameter and MAY support a <code>resource</code>
parameter as a synonym for <code>aud</code>.

      </td>
    </tr>

    <tr>
      <td><code>code_challenge</code></td>
      <td><span class="label label-info">required</span></td>
      <td>This parameter is generated by the app and used for the code challenge, as specified by <a href="https://tools.ietf.org/html/rfc7636">PKCE</a>.  For example, when <code>code_challenge_method</code> is <code>'S256'</code>, this is the S256 hashed version of the <code>code_verifier</code> parameter.  See section <a href="#considerations-for-pkce-support">considerations-for-pkce-support</a>.</td>
    </tr>


    <tr>
      <td><code>code_challenge_method</code></td>
      <td><span class="label label-info">required</span></td>
      <td>Method used for the <code>code_challenge</code> parameter.  Example value: <code>S256</code>.  See <a href="#considerations-for-pkce-support">considerations-for-pkce-support</a>.</td>
    </tr>

  </tbody>
</table>

The app SHOULD limit its requested scopes to the minimum necessary (i.e.,
minimizing the requested data categories and the requested duration of access).

If the app needs to authenticate the identity of or retrieve information about
the end-user, it should include two OpenID Connect scopes:  `openid` and
`fhirUser`.   When these scopes are requested and the request is granted, the
app will receive an id_token along with the access token.  For full details,
see [SMART launch context parameters](scopes-and-launch-context.html).

The following requirements are adopted from [OpenID Connect Core 1.0 Specification section 3.1.2.1](https://openid.net/specs/openid-connect-core-1_0.html#AuthRequest):

* Authorization Servers SHALL support the use of the HTTP GET and POST methods at the Authorization Endpoint.
* Clients SHALL use either the HTTP GET or the HTTP POST method to send the Authorization Request to the Authorization Server.  If using the HTTP GET method, the request parameters are serialized using URI Query String Serialization.  If using the HTTP POST method, the request parameters are serialized using Form Serialization and the application/x-www-form-urlencoded content type.

###### *For example*
If an app needs demographics and observations for a single
patient and wants information about the current logged-in user, the app  can request:

* `patient/Patient.r`
* `patient/Observation.rs`
* `openid fhirUser`

If the app was launched from an EHR, the app adds a `launch` scope and a
`launch={launch id}` URL parameter echoing the value it received from the EHR
to be associated with the EHR context of this launch notification.

*Apps using the <span class="label label-primary">standalone launch</span> flow
won't have a `launch` id at this point.  These apps can declare launch context
requirements by adding specific scopes to the authorization request: for
example, `launch/patient` to indicate that the app needs a patient ID, or
`launch/encounter` to indicate it needs an encounter.  The EHR's "authorize"
endpoint will take care of acquiring the context it needs (making it available to the app).  
For example, if your app needs patient context, the EHR may
provide the end-user with a patient selection widget.  For full details, see <a
href="scopes-and-launch-context.html">SMART launch
context parameters</a>.*


The app then instructs the browser to navigate the browser to the EHR's **authorization URL** as
determined above. For example to cause the browser to issue a `GET`:


```
Location: https://ehr/authorize?
            response_type=code&
            client_id=app-client-id&
            redirect_uri=https%3A%2F%2Fapp%2Fafter-auth&
            launch=xyz123&
            scope=launch+patient%2FObservation.rs+patient%2FPatient.rs+openid+fhirUser&
            state=98wrghuwuogerg97&
            aud=https://ehr/fhir
```

Alternatively, the following example shows one way for a client app to cause the browser to issue a `POST` using HTML and javascript:


```
<html>
  <body onload="javascript:document.forms[0].submit()">
    <form method="post" action="https://ehr/authorize">
      <input type="hidden" name="response_type" value="code"/>
      <input type="hidden" name="client_id" value="app-client-id"/>
      <input type="hidden" name="redirect_uri" value="https://app/after-auth"/>
      <input type="hidden" name="launch" value="xyz123"/>
      <input type="hidden" name="scope" value="launch patient/Observation.rs patient/Patient.rs openid fhirUser"/>
      <input type="hidden" name="state" value="98wrghuwuogerg97"/>
      <input type="hidden" name="aud" value="https://ehr/fhir"/>
    </form>
  </body>
</html>
```

#### Response

The authorization decision is up to the EHR authorization server which may request authorization from the end-user. The EHR authorization
server will enforce access rules based on local policies and optionally direct
end-user input.

The EHR decides whether to grant or deny access.  This decision is
communicated to the app when the EHR authorization server returns an
authorization code or, if denying access, an error response.  Authorization codes are short-lived, usually expiring
within around one minute.  The code is sent when the EHR authorization server
causes the browser to navigate to the app's <code>redirect_uri</code> with the
following URL parameters:

<table class="table">
  <thead>
    <th colspan="3">Parameters</th>
  </thead>
  <tbody>
    <tr>
      <td><code>code</code></td>
      <td><span class="label label-success">required</span></td>

      <td>

The authorization code generated by the authorization server. The
authorization code *must* expire shortly after it is issued to mitigate the
risk of leaks.

      </td>
    </tr>
    <tr>
      <td><code>state</code></td>
      <td><span class="label label-success">required</span></td>
      <td>The exact value received from the client.</td>
    </tr>
  </tbody>
</table>

The app SHALL validate the value of the state parameter upon return to the
redirect URL and SHALL ensure that the state value is securely tied to the
user’s current session (e.g., by relating the state value to a session
identifier issued by the app).

###### *For example*

Based on the `client_id`, current EHR user, configured policy, and perhaps
direct user input, the EHR makes a decision to approve or deny access.  This
decision is communicated to the app by instructing the browser to navigate to the app's registered
`redirect_uri`. For example:

```
Location: https://app/after-auth?
  code=123abc&
  state=98wrghuwuogerg97
```

#### Examples

* [Public client](example-app-launch-public.html#step-4-authorization-code)
* [Confidential client, asymmetric authentication](example-app-launch-asymmetric-auth.html#step-4-authorization-code)
* [Confidential client, symmetric authentication](example-app-launch-symmetric-auth.html#step-4-authorization-code)



<a id="step-5-access-token"></a>

### Obtain access token

After obtaining an authorization code, the app trades the code for an access
token.

#### Request
The app issues an HTTP `POST` to the EHR authorization server's token endpoint URL using content-type `application/x-www-form-urlencoded` as described in
section 4.1.3 of [RFC6749](https://tools.ietf.org/html/rfc6749#section-4.1.3).

For <span class="label label-primary">public apps</span>, authentication not required because a client with no secret cannot prove its
identity when it issues a call. (The end-to-end system can still be secure
because the client comes from a known, https protected endpoint specified and
enforced by the redirect uri.)  For <span class="label label-primary">confidential
apps</span>, authentication is required. Confidential clients SHOULD use
[Asymmetric Authentication](client-confidential-asymmetric.html) if available, and
MAY use [Symmetric Authentication](client-confidential-symmetric.html).

<table class="table">
  <thead>
    <th colspan="3">Parameters</th>
  </thead>
  <tbody>
    <tr>
      <td><code>grant_type</code></td>
      <td><span class="label label-success">required</span></td>
      <td>Fixed value: <code>authorization_code</code></td>
    </tr>
    <tr>
      <td><code>code</code></td>
      <td><span class="label label-success">required</span></td>
      <td>Code that the app received from the authorization server</td>
    </tr>
    <tr>
      <td><code>redirect_uri</code></td>
      <td><span class="label label-success">required</span></td>
      <td>The same redirect_uri used in the initial authorization request</td>
    </tr>
    <tr>
      <td><code>code_verifier</code></td>
      <td><span class="label label-warning">required</span></td>
      <td>This parameter is used to verify against the <code>code_challenge</code> parameter previously provided in the authorize request.</td>
    </tr>
    <tr>
      <td><code>client_id</code></td>
      <td><span class="label label-warning">conditional</span></td>
      <td>Required for <span class="label label-primary">public apps</span>. Omit for <span class="label label-primary">confidential apps</span>.</td>
    </tr>
  </tbody>
</table>

#### Response

The EHR authorization server SHALL return a JSON object that includes an access token
or a message indicating that the authorization request has been denied. The JSON structure
includes the following parameters:

<table class="table">
  <thead>
    <th colspan="3">Parameters</th>
  </thead>
  <tbody>
    <tr>
      <td><code>access_token</code></td>
      <td><span class="label label-success">required</span></td>
      <td>The access token issued by the authorization server</td>
    </tr>
    <tr>
      <td><code>token_type</code></td>
      <td><span class="label label-success">required</span></td>
      <td>Fixed value: <code>Bearer</code></td>
    </tr>
    <tr>
      <td><code>expires_in</code></td>
      <td><span class="label label-info">recommended</span></td>
      <td>Lifetime in seconds of the access token, after which the token SHALL NOT be accepted by the resource server</td>
    </tr>
    <tr>
      <td><code>scope</code></td>
      <td><span class="label label-success">required</span></td>
      <td>Scope of access authorized. Note that this can be different from the scopes requested by the app.</td>
    </tr>
    <tr>
      <td><code>id_token</code></td>
      <td><span class="label label-info">optional</span></td>
      <td>Authenticated user identity and user details, if requested</td>
    </tr>
      <tr>
      <td><code>refresh_token</code></td>
      <td><span class="label label-info">optional</span></td>
      <td>Token that can be used to obtain a new access token, using the same or a subset of the original authorization grants</td>
    </tr>
  </tbody>
</table>

In addition, if the app was launched from within a patient context,
parameters to communicate the context values MAY BE included. For example,
a parameter like `"patient": "123"` would indicate the FHIR resource
https://[fhir-base]/Patient/123. Other context parameters may also
be available. For full details see the [SMART launch context parameters](scopes-and-launch-context.html) section.

The parameters are included in the entity-body of the HTTP response, as
described in section 5.1 of [RFC6749](https://tools.ietf.org/html/rfc6749).

The access token is a string of characters as defined in
[RFC6749](https://tools.ietf.org/html/rfc6749) and
[RFC6750](http://tools.ietf.org/html/rfc6750).  The token is essentially
a private message that the authorization server
passes to the FHIR Resource Server telling the FHIR server that the
"message bearer" has been authorized to access the specified resources.  
Defining the format and content of the access token is left up to the
organization that issues the access token and holds the requested resource.

The authorization server's response SHALL
include the HTTP "Cache-Control" response header field with a value
of "no-store," as well as the "Pragma" response header field with a
value of "no-cache."

The EHR authorization server decides what `expires_in` value to assign to an
access token and whether to issue a refresh token, as defined in section 1.5
of [RFC6749](https://tools.ietf.org/html/rfc6749#page-10), along with the
access token.  If the app receives a refresh token along with the access
token, it can exchange this refresh token for a new access token when the
current access token expires (see step 5 below).

Apps SHOULD store tokens in app-specific storage locations only, and not in
system-wide-discoverable locations.  Access tokens SHOULD have a valid
lifetime no greater than one hour.  Confidential
clients may be issued longer-lived tokens than public clients.

*A large range of threats to access tokens can be mitigated by digitally
signing the token as specified in [RFC7515](https://tools.ietf.org/html/rfc7515)
or by using a Message Authentication Code (MAC) instead.  Alternatively,
an access token can contain a reference to authorization information,
rather than encoding the information directly into the token itself.  
To be effective, such references must be infeasible for an attacker to
guess.  Using a reference may require an extra interaction between the
resource server and the authorization server; the mechanics of such an
interaction are not defined by this specification.*

At this point, **the authorization flow is complete**.


#### Examples

* [Public client](example-app-launch-public.html#step-5-access-token)
* [Confidential client, asymmetric authentication](example-app-launch-asymmetric-auth.html#step-5-access-token)
* [Confidential client, symmetric authentication](example-app-launch-symmetric-auth.html#step-5-access-token)

<a id="step-6-fhir-api"></a>

### Access FHIR API

With a valid access token, the app can access protected EHR data by issuing a
FHIR API call to the FHIR endpoint on the EHR's resource server.

#### Request

From the access token response, an app has received an OAuth2 bearer-type access token (`access_token` property) that can be used to fetch clinical data.  The app issues a request that includes an
`Authorization` header that presents the `access_token` as a "Bearer" token:

{% raw %}
    Authorization: Bearer {{access_token}}
{% endraw %}

(Note that in a real request, `{% raw %}{{access_token}}{% endraw %}`{:.language-text} is replaced
with the actual token value.)

#### Response

The resource server SHALL validate the access token and ensure that it has not expired and that its scope covers the requested resource.  The
resource server also validates that the `aud` parameter associated with the
authorization (see section <a href="#step-4-authorization-code">Obtain authorization code</a>) matches the resource server's own FHIR
endpoint.  The method used by the EHR to validate the access token is beyond
the scope of this specification but generally involves an interaction or
coordination between the EHR’s resource server and the authorization server.

On occasion, an app may receive a FHIR resource that contains a “reference” to
a resource hosted on a different resource server.  The app SHOULD NOT blindly
follow such references and send along its access_token, as the token may be
subject to potential theft.   The app SHOULD either ignore the reference, or
initiate a new request for access to that resource.


#### Example Request and Response

**Example**
``` text
GET https://ehr/fhir/Patient/123
Authorization: Bearer i8hweunweunweofiwweoijewiwe
```

**Response**
```
{
  "resourceType": "Patient",
  "birthTime": ...
}
```


<a id="step-7-refresh"></a>

### Refresh access token

Refresh tokens are issued to enable sessions to last longer than the validity period of an access token.  The app can use the `expires_in` field from the token response (see section <a href="#step-5-access-token">Obtain access token</a>) to determine when its access token will expire.  EHR implementers are also encouraged to consider using the [OAuth 2.0 Token Introspection Protocol](https://tools.ietf.org/html/rfc7662) to provide an introspection endpoint that clients can use to examine the validity and meaning of tokens. An app with "online access" can continue to get new access tokens as long as the end-user remains online.  Apps with "offline access" can continue to get new access tokens without the user being interactively engaged for cases where an application should have long-term access extending beyond the time when a user is still interacting with the client.

The app requests a refresh token in its authorization request via the `online_access` or `offline_access` scope (see section <a href="scopes-and-launch-context.html">SMART on FHIR Access Scopes</a> for details).  A server can decide which client types (public or confidential) are eligible for offline access and able to receive a refresh token.  If granted, the EHR supplies a refresh_token in the token response.  A refresh token SHALL be bound to the same `client_id` and SHALL contain the same or a subset of the claims authorized for the access token with which it is associated. After an access token expires, the app requests a new access token by providing its refresh token to the EHR's token endpoint.


#### Request

An HTTP `POST` transaction is made to the EHR authorization server's token URL, with content-type `application/x-www-form-urlencoded`. The decision about how long the refresh token lasts is determined by a mechanism that the server chooses.  For clients with online access, the goal is to ensure that the user is still online.

- For <span class="label label-primary">public apps</span>, authentication is not possible (and thus not required). For <span class="label label-primary">confidential apps</span>, see authentication considerations in
<a href="#step-5-access-token">step 5</a>.

The following request parameters are defined:

<table class="table">
  <thead>
    <th colspan="3">Parameters</th>
  </thead>
  <tbody>

    <tr>
      <td><code>grant_type</code></td>
      <td><span class="label label-success">required</span></td>
      <td>Fixed value: <code>refresh_token</code>. </td>
    </tr>
    <tr>
      <td><code>refresh_token</code></td>
      <td><span class="label label-success">required</span></td>
      <td>The refresh token from a prior authorization response</td>
    </tr>
    <tr>
      <td><code>scope</code></td>
      <td><span class="label label-info">optional</span></td>
      <td>
The scopes of access requested. If present, this value must be a strict sub-set
of the scopes granted in the original launch (no new permissions can be
obtained at refresh time). A missing value indicates a request for the same
scopes granted in the original launch.
      </td>
    </tr>
  </tbody>
</table>

#### Response

The response is a JSON object containing a new access token, with the following claims:

<table class="table">
  <thead>
    <th colspan="3">JSON Object property name</th>
  </thead>
  <tbody>
    <tr>
      <td><code>access_token</code></td>
      <td><span class="label label-success">required</span></td>
      <td>New access token issued by the authorization server.</td>
    </tr>
    <tr>
      <td><code>token_type</code></td>
      <td><span class="label label-success">required</span></td>
      <td>Fixed value: bearer</td>
    </tr>
    <tr>
      <td><code>expires_in</code></td>
      <td><span class="label label-success">required</span></td>
      <td>The lifetime in seconds of the access token. For example, the value 3600 denotes that the access token will expire in one hour from the time the response was generated.</td>
    </tr>
    <tr>
      <td><code>scope</code></td>
      <td><span class="label label-success">required</span></td>
      <td>Scope of access authorized. Note that this will be the same as the scope of the original access token, and it can be different from the scopes requested by the app.</td>
    </tr>
    <tr>
      <td><code>refresh_token</code></td>
      <td><span class="label label-info">optional</span></td>
      <td>The refresh token issued by the authorization server. If present, the app should discard any previous <code>refresh_token</code> associated with this launch and replace it with this new value.</td>
    </tr>
  </tbody>
</table>

In addition, if the app was launched from within a patient context,
parameters to communicate the context values MAY BE included. For example,
a parameter like `"patient": "123"` would indicate the FHIR resource
https://[fhir-base]/Patient/123. Other context parameters may also
be available. For full details see [SMART launch context parameters](scopes-and-launch-context.html).

#### Examples

* [Public client](example-app-launch-public.html#step-7-refresh)
* [Confidential client, asymmetric authentication](example-app-launch-asymmetric-auth.html#step-7-refresh)
* [Confidential client, symmetric authentication](example-app-launch-symmetric-auth.html#step-7-refresh)


[.well-known/smart-configuration]: conformance.html#using-well-known
## Backend Services

### Profile Audience and Scope

This profile is intended to be used by developers of backend services (clients)
that autonomously (or semi-autonomously) need to access resources from FHIR
servers that have pre-authorized defined scopes of access.  This specification
handles use cases complementary to the [SMART App Launch
protocol](app-launch.html).  Specifically, this
profile describes the runtime process by which the client acquires an access
token that can be used to retrieve FHIR resources.  This specification is
designed to work with [FHIR Bulk Data Access](http://hl7.org/fhir/uv/bulkdata/),
but is not restricted to use for retrieving bulk data; it may be used to connect
to any FHIR API endpoint, including both synchronous and asynchronous access.

#### Use this profile when the following conditions apply:

* The target FHIR authorization server can register the client and pre-authorize access to a
defined set of FHIR resources.
* The client may run autonomously, or with user interaction that does not
include access authorization.
* The client supports [`client-confidential-asymmetric` authentication](client-confidential-asymmetric.html)
* No compelling need exists for a user to authorize the access at runtime.

Note that the FHIR specification includes a set of [security considerations](http://hl7.org/fhir/security.html) including security, privacy, and access control. These considerations apply to diverse use cases and provide general guidance for choosing among security specifications for particular use cases.

#### Examples

* An analytics platform or data warehouse that periodically performs a bulk data
import from an electronic health record system for analysis of
a population of patients.

* A lab monitoring service that determines which patients are currently
admitted to the hospital, reviews incoming laboratory results, and generates
clinical alerts when specific trigger conditions are met.  Note that in this
example, the monitoring service may be a backend client to multiple servers.

* A data integration service that periodically queries the EHR for newly
registered patients and synchronizes these with an external database

* A utilization tracking system that queries an EHR every minute for
bed and room usage and displays statistics on a wall monitor.

* Public health surveillance studies that do not require real-time exchange of data.

### Underlying Standards

* [HL7 FHIR RESTful API](http://www.hl7.org/fhir/http.html)
* [RFC5246, The Transport Layer Security Protocol, V1.2](https://tools.ietf.org/html/rfc5246)
* [RFC6749, The OAuth 2.0 Authorization Framework](https://tools.ietf.org/html/rfc6749)
* [RFC7515, JSON Web Signature](https://tools.ietf.org/html/rfc7515)
* [RFC7517, JSON Web Key](https://www.rfc-editor.org/rfc/rfc7517.txt)
* [RFC7518, JSON Web Algorithms](https://tools.ietf.org/html/rfc7518)
* [RFC7519, JSON Web Token (JWT)](https://tools.ietf.org/html/rfc7519)
* [RFC7521, Assertion Framework for OAuth 2.0 Client Authentication and Authorization Grants](https://tools.ietf.org/html/rfc7521)
* [RFC7523, JSON Web Token (JWT) Profile for OAuth 2.0 Client Authentication and Authorization Grants](https://tools.ietf.org/html/rfc7523)
* [RFC7591, OAuth 2.0 Dynamic Client Registration Protocol](https://tools.ietf.org/html/rfc7591)

### Conformance Language
This specification uses the conformance verbs SHALL, SHOULD, and MAY as defined
in [RFC2119](https://www.ietf.org/rfc/rfc2119.txt). Unlike RFC 2119, however,
this specification allows that different applications may not be able to
interoperate because of how they use optional features. In particular:

1.  SHALL: an absolute requirement for all implementations
2.  SHALL NOT: an absolute prohibition against inclusion for all implementations
3.  SHOULD/SHOULD NOT: A best practice or recommendation to be considered by
implementers within the context of their particular implementation; there may
be valid reasons to ignore an item, but the full implications must be understood
and carefully weighed before choosing a different course
4.  MAY: This is truly optional language for an implementation; can be included or omitted as the implementer decides with no implications


### Top-level steps for Backend Services Authorization

<div>{% include overview-backend-services.svg %}</div>
<br clear="all"/>

1. [Register Backend Service](#step-1-register) (*one-time step*, can be out-of-band)
2. [Retrieve .well-known/smart-configuration](#step-2-discovery)
3. [Obtain access token](#step-3-access-token)
4. [Access FHIR API](#step-4-fhir-api)


<a id="step-1-register"></a>

### Register SMART Backend Service (communicating public keys)

Before a SMART client can run against a FHIR server, the client SHALL register
with the server by following the [registration steps described in `client-confidential-asymmetric` authentication](client-confidential-asymmetric.html#registering-a-client-communicating-public-keys).

<a id="step-2-discovery"></a>

### Retrieve `.well-known/smart-configuration`

In order to request authorization to access FHIR resources, the app discovers the EHR FHIR server's SMART configuration metadata, including OAuth `token` endpoint URL.

#### Request
The app issues an HTTP GET with an `Accept` header supporting `application/json` to retrieve the SMART configuration file.

#### Response

Servers respond with a discovery response that meets [discovery requirements described in `client-confidential-asymmetric` authentication](client-confidential-asymmetric.html#discovery-requirements).

#### Example Request and Response

For a full example, see [example request and response](example-backend-services.html#step-2-discovery).

<a id="step-3-access-token"></a>

### Obtain access token

By the time a client has been registered with the FHIR authorization server, the key
elements of organizational trust will have been established. That is, the
client will be considered "pre-authorized" to access FHIR resources.
Then, at runtime, the client will need to obtain an access token in
order to retrieve FHIR resources as pre-authorized. Such access tokens are
issued by the FHIR authorization server, in accordance with the [OAuth 2.0
Authorization Framework, RFC6749](https://tools.ietf.org/html/rfc6749).  

Because the authorization scope is limited to protected resources previously
arranged with the FHIR authorization server, the client credentials grant flow,
as defined in [Section 4.4 of RFC6749](https://tools.ietf.org/html/rfc6749#page-40),
may be used to request authorization.  Use of the client credentials grant type
requires that the client SHALL be a "confidential" client capable of
protecting its authentication credential.  

This specification describes requirements for requesting an access token
through the use of an OAuth 2.0 client credentials flow, with a [JWT
assertion](https://tools.ietf.org/html/rfc7523) as the
client's authentication mechanism. The exchange, as depicted above, allows the
client to authenticate itself to the FHIR authorization server and to request a short-lived
access token in a single exchange.


#### Request

To begin the exchange, the client SHALL use the [Transport Layer Security
(TLS) Protocol Version 1.2 (RFC5246)](https://tools.ietf.org/html/rfc5246) or a more recent version of TLS to
authenticate the identity of the FHIR authorization server and to establish an encrypted,
integrity-protected link for securing all exchanges between the client
and the FHIR authorization server's token endpoint.  All exchanges described herein between the client
and the FHIR server SHALL be secured using TLS V1.2 or a more recent version of TLS .


Before a client can request an access token, it generates a one-time-use
authentication JWT [as described in `client-confidential-symmetric`
authentication](client-confidential-asymmetric.html#authenticating-to-the-token-endpoint).
After generating this authentication JWT, the client
requests an access token via HTTP `POST` to the FHIR authorization server's
token endpoint URL, using content-type `application/x-www-form-urlencoded` with
the following parameters:

<table class="table">
  <thead>
    <th colspan="3">Parameters</th>
  </thead>
  <tbody>
    <tr>
      <td><code>scope</code></td>
      <td><span class="label label-success">required</span></td>
      <td>The scope of access requested. See note about scopes below</td>
    </tr>
    <tr>
      <td><code>grant_type</code></td>
      <td><span class="label label-success">required</span></td>
      <td>Fixed value: <code>client_credentials</code></td>
    </tr>
    <tr>
      <td><code>client_assertion_type</code></td>
      <td><span class="label label-success">required</span></td>
      <td>Fixed value: <code>urn:ietf:params:oauth:client-assertion-type:jwt-bearer</code></td>
    </tr>
    <tr>
      <td><code>client_assertion</code></td>
      <td><span class="label label-success">required</span></td>
      <td>Signed authentication JWT value (see above)</td>
    </tr>
  </tbody>
</table>

##### Scopes

The client is pre-authorized by the server: at registration time or out of band,
it is given the authority to access certain data. The client then includes a set
of scopes in the access token request, which causes the server to apply
additional access restrictions following the [SMART Scopes
syntax](scopes-and-launch-context.html).  For Backend Services, requested scopes
will be `system/` scopes (for example `system/Observation.rs`, which requests an
access token capable of reading all Observations that the client has been
pre-authorized to access).


#### Response

##### Enforce Authorization

There are several cases where a client might ask for data that the server cannot or will not return:
* Client explicitly asks for data that it is not authorized to see (e.g., a client asks for Observation resources but has scopes that only permit access to Patient resources). In this case a server SHOULD respond with a failure to the initial request.
* Client explicitly asks for data that the server does not support (e.g., a client asks for Practitioner resources but the server does not support FHIR access to Practitioner data). In this case a server SHOULD respond with a failure to the initial request.
* Client explicitly asks for data that the server supports and that appears consistent with its access scopes -- but some additional out-of-band rules/policies/restrictions prevents the client from being authorized to see these data. In this case, the server MAY withhold certain results from the response, and MAY indicate to the client that results were withheld by including OperationOutcome information in the "error" array for the response as a partial success.

Rules regarding circumstances under which a client is required to obtain and present an access token along with a request are based on risk-management decisions that each FHIR resource service needs to make, considering the workflows involved, perceived risks, and the organization’s risk-management policies.  Refresh tokens SHOULD NOT be issued.

##### Validate Authentication JWS

The FHIR authorization server validates a client's authentication JWT according to the `client-confidential-asymmetric` authentication profile. [See JWT validation rules](client-confidential-asymmetric.html#signature-verification).


##### Evaluate Requested Access

Once the client has been authenticated, the FHIR authorization server SHALL
mediate the request to assure that the scope requested is within the scope pre-authorized
to the client.

##### Issue Access Token

If an error is encountered during the authorization process, the FHIR authorization server SHALL
respond with the appropriate error message defined in [Section 5.2 of the OAuth 2.0 specification](https://tools.ietf.org/html/rfc6749#page-45).  The FHIR authorization server SHOULD include an `error_uri` or `error_description` as defined in OAuth 2.0.

If the access token request is valid and authorized, the FHIR authorization server
SHALL issue an access token in response.  The access token response SHALL be a JSON object with
the following properties:

<table class="table">
  <thead>
    <th colspan="3">Access token response: property names</th>
  </thead>
  <tbody>
    <tr>
      <td><code>access_token</code></td>
      <td><span class="label label-success">required</span></td>
      <td>The access token issued by the FHIR authorization server.</td>
    </tr>
    <tr>
      <td><code>token_type</code></td>
      <td><span class="label label-success">required</span></td>
      <td>Fixed value: <code>bearer</code>.</td>
    </tr>
    <tr>
      <td><code>expires_in</code></td>
      <td><span class="label label-success">required</span></td>
      <td>The lifetime in seconds of the access token. The recommended value is <code>300</code>, for a five-minute token lifetime.</td>
    </tr>
    <tr>
      <td><code>scope</code></td>
      <td><span class="label label-success">required</span></td>
      <td>Scope of access authorized. Note that this can be different from the scopes requested by the app.</td>
    </tr>
  </tbody>
</table>

To minimize risks associated with token redirection, the scope of each access token SHOULD encompass, and be limited to, the resources requested. Access tokens issued under this profile SHALL be short-lived; the `expires_in`
value SHOULD NOT exceed `300`, which represents an expiration-time of five minutes.

#### Example Token Request and Response

For a full example, see [example token request and response](example-backend-services.html#step-3-access-token).

<a id="step-4-fhir-api"></a>

### Access FHIR API

With a valid access token, the app can access protected FHIR data by issuing a
FHIR API call to the FHIR endpoint on the FHIR resource server.

#### Request

From the access token response, an app has received an OAuth2 bearer-type access token (`access_token` property) that can be used to fetch clinical data.  The app issues a request that includes an
`Authorization` header that presents the `access_token` as a "Bearer" token:

{% raw %}
    Authorization: Bearer {{access_token}}
{% endraw %}

(Note that in a real request, `{% raw %}{{access_token}}{% endraw %}`{:.language-text} is replaced
with the actual token value.)

#### Response

The resource server SHALL validate the access token and ensure that it has not expired and that its scope covers the requested resource. The method used by the EHR to validate the access token is beyond the scope of this specification but generally involves an interaction or coordination between the EHR’s resource server and the authorization server.

On occasion, an Backend Service may receive a FHIR resource that contains a “reference” to a resource hosted on a different resource server.  The Backend Service SHOULD NOT blindly follow such references and send along its access_token, as the token may be subject to potential theft.   The Backend Service SHOULD either ignore the reference, or initiate a new request for access to that resource.

#### Example Request and Response

For a full example, see [example FHIR API request and response](example-backend-services.html#step-4-fhir-api).
## 'App Launch: Scopes and Launch Context'

<!-- # SMART App Launch: Scopes and Launch Context-->

SMART on FHIR's authorization scheme uses OAuth scopes to communicate (and
negotiate) access requirements. Providing apps with access to broad data sets is consistent with current common practices (e.g., interface engines also provide access to broad data sets); access is also limited based on the privileges of the user in context.  In general, we use scopes for three kinds of data:

1. [Clinical data](#scopes-for-requesting-clinical-data)
1. [Contextual data](#scopes-for-requesting-context-data)
1. [Identity data](#scopes-for-requesting-identity-data)

Launch context is a negotiation where a client asks for specific launch context
parameters (e.g., `launch/patient`). A server can decide which launch context
parameters to provide, using the client's request as an input into the decision
process.  See ["scopes for requesting context data"](#scopes-for-requesting-context-data) for details.

### Quick Start

Here is a quick overview of the most commonly used scopes. The complete details are provided in the following sections.

Scope | Grants
------|--------
`patient/*.rs`    | Permission to read and search any resource for the current patient (see notes on wildcard scopes below).
`user/*.cruds`    | Permission to read and write all resources that the current user can access (see notes on wildcard scopes below).
`openid fhirUser` | Permission to retrieve information about the current logged-in user.
`launch`          | Permission to obtain launch context when app is launched from an EHR.
`launch/patient`  | When launching outside the EHR, ask for a patient to be selected at launch time.
`offline_access`  | Request a `refresh_token` that can be used to obtain a new access token to replace an expired one, even after the end-user no longer is online after the access token expires.
`online_access`   | Request a `refresh_token` that can be used to obtain a new access token to replace an expired one, and that will be usable for as long as the end-user remains online.
{:.grid}

#### SMART's scopes are used to delegate access

SMART's scopes allow a client to request the delegation of a specific set of
access rights; such rights are always limited by underlying system policies and
permissions.

For example:

* If a client uses SMART App Launch to request `user/*.cruds` and is granted these scopes by a user, these scopes convey "full access" relative to the user's underlying permissions.  If the underlying user has limited permissions, the client will face these same limitations.
* If a client uses SMART Backend Services to request `system/*.cruds`, these scopes convey "full access" relative to a server's pre-configured client-specific policy.  If the pre-configured policy imposes limited permissions, the client will face these same limitations.

Neither SMART on FHIR nor the FHIR Core specification provide a way to model
the "underlying" permissions at play here; this is a lower-level responsibility
in the access control stack.  As such, clients can attempt to perform FHIR
operations based on the scopes they are granted — but depending on the details
of the underlying permission system (e.g., the permissions of the approving
user and/or permissions assigned in a client-specific policy) these requests
may be rejected, or results may be omitted from responses.

For instance, a client may receive:

* `200 OK` response to a search interaction that appears to be allowed by the granted scopes, but where results have been omitted from the response Bundle.
* `403 Forbidden` response to a write interaction that appears to be allowed by the granted scopes.

Applications reading may receive results that have been filtered or redacted
based on the underlying permissions of the delegating authority, or may be
refused access (see guidance at [https://hl7.org/fhir/security.html#AccessDenied](https://hl7.org/fhir/security.html#AccessDenied)).

### Scopes for requesting clinical data

SMART on FHIR defines OAuth2 access scopes that correspond directly to FHIR resource types. These scopes impact the access an application may have to FHIR resources (and actions). We define permissions to support the following FHIR REST API interactions:

* `c` for `create`
  * Type level [create](http://hl7.org/fhir/http.html#create)
* `r` for `read`
  * Instance level [read](http://hl7.org/fhir/http.html#read)
  * Instance level [vread](http://hl7.org/fhir/http.html#vread)
  * Instance level [history](http://hl7.org/fhir/http.html#history)
* `u` for `update`
  * Instance level [update](http://hl7.org/fhir/http.html#update)
    Note that some servers allow for an [update operation to create a new instance](http://hl7.org/fhir/http.html#upsert), and this is allowed by the update scope
  * Instance level [patch](http://hl7.org/fhir/http.html#patch)
* `d` for `delete`
  * Instance level [delete](http://hl7.org/fhir/http.html#delete)
* `s` for `search`
  * Type level [search](http://hl7.org/fhir/http.html#search)
  * Type level [history](http://hl7.org/fhir/http.html#history)
  * System level [search](http://hl7.org/fhir/http.html#search)
  * System level [history](http://hl7.org/fhir/http.html#history)


Valid suffixes are a subset of the in-order string `.cruds`. For example, to convey support for creating and updating observations, use scope `patient/Observation.cu`. To convey support for reading and searching observations, use scope `patient/Observation.rs`. For backwards compatibility with scopes defined in the SMART App Launch 1.0 specification, servers SHOULD advertise the `permission-v1` capability in their `.well-known/smart-configuration` discovery document, SHOULD return v1 scopes when v1 scopes are requested and granted, and SHOULD process v1 scopes with the following semantics in v2:

* v1 `.read` ⇒ v2 `.rs`
* v1 `.write` ⇒ v2 `.cud`
* v1 `.*` ⇒ v2 `.cruds`

Scope requests with undefined or out of order interactions MAY be ignored, replaced with server default scopes, or rejected. For example, a request of `.dus` is not a defined scope request. This policy is to prevent misinterpretation of scopes with other conventions (e.g., interpreting `.read` as `.rd` and granting extraneous delete permissions).

#### Batches and Transactions

SMART 2.0 does not define specific scopes for [batch or transaction](http://hl7.org/fhir/http.html#transaction) interactions. These system-level interactions are simply convenience wrappers for other interactions. As such, batch and transaction requests should be validated based on the actual requests within them.

#### Scope Equivalence

Multiple scopes compounded or expanded are equivalent to each other.  E.g., `Observation.rs` is interchangeable with `Observation.r Observation.s`. In order to reduce token size, it is recommended that scopes be factored to their shortest form.

#### Finer-grained resource constraints using search parameters

In SMART 1.0, scopes were based entirely on FHIR Resource types, as in `patient/Observation.read` (for Observations) or `patient.Immunization.read` (for Immunizations). In SMART 2.0, we provide more detailed constraints based on FHIR REST API search parameter syntax. To apply these constraints, add a query string suffix to existing scopes, starting with `?` and followed by a series of `param=value` items separated by `&`. For example, to request read and search access to laboratory observations but not other observations, the scope `patient/Observation.rs?category=http://terminology.hl7.org/CodeSystem/observation-category|laboratory`.

#### Requirements for support

We’re seeking community consensus on a small common core of search parameters
for broad support; we reserve the right to make some search parameters
mandatory in the future.

#### Experimental features

Because the search parameter based syntax here is quite general, it opens up the possibility of using many features that servers may have trouble supporting in a consistent and performant fashion. Given the current level of implementation experience, the following features should be considered experimental, even if they are supported by a server:

* Use of search modifiers such as `Observation.rs?code:in=http://valueset.example.org/ValueSet/diabetes-codes`
* Use of search parameter chaining such as `Observation.rs?patient.birthdate=1990`
* Use of [FHIR's `_filter` capabilities](https://www.hl7.org/fhir/search_filter.html)


#### Scope size over the wire

Scope strings appear over the wire at several points in an OAuth flow. Implementers should be aware that fine-grained controls can lead to a proliferation of scopes, increasing in the length of the `scope` string for app authorizations. As such, implementers should take care to avoid putting arbitrarily large scope strings in places where they might not "fit". The following considerations apply, presented in the sequential order of a SMART App Launch:

* When initiating an authorization request, app developers should prefer POST-based authorization requests to GET-based requests, since this avoids URL length limits that might apply to GET-based authorization requests. (For example, some current-generation browsers have a 32kB length limit for values displayed in the URL bar.)
* In the authorization code redirect response, no scopes are included, so these considerations do not apply.
* In the access token response, no specific limits apply, since this payload comes in response to a client-initiated POST.
* In the token introspection response, no specific limits apply, since this payload comes in response to a client-initiated POST.
* In the access token itself, implementation-specific considerations may apply. SMART leaves access token formats out of scope, so formally there are no restrictions. But since access tokens are included in HTTP headers, servers should take care to ensure they do not get too large. For example, some current-generation HTTP servers have an 8kB limit on header length. To remain under this limit, authorization servers that use structured token formats like JWT might consider embedding handles or pointers to scopes, rather than embedding literal scopes in an access token. Alternatively, authorization servers might establish an internal convention mapping shorter scope names into longer scopes (or common combinations of longer scopes).


#### Clinical Scope Syntax

Expressed as a railroad diagram, the scope language is:


<svg class="railroad-diagram" width="1094" height="131" viewBox="0 0 1094 131" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
<!--
https://github.com/tabatkins/railroad-diagrams
Diagram(
  Choice(0, 'patient', 'user', 'system'),
  Choice(0, '/'),
  Choice(0, 'FHIR Resource Type', '*'),
  Choice(0, '.'),
  OptionalSequence('c', 'r', 'u', 'd', 's'),
  Optional(
    Sequence('?', OneOrMore('param=value&')))
)
-->

<g transform="translate(.5 .5)">
<g>
<path d="M20 30v20m10 -20v20m-10 -10h20"></path>
</g>
<g>
<path d="M40 40h0"></path>
<path d="M159.5 40h0"></path>
<path d="M40 40h20"></path>
<g class="terminal ">
<path d="M60 40h0"></path>
<path d="M139.5 40h0"></path>
<rect x="60" y="29" width="79.5" height="22" rx="10" ry="10"></rect>
<text x="99.75" y="44">patient</text>
</g>
<path d="M139.5 40h20"></path>
<path d="M40 40a10 10 0 0 1 10 10v10a10 10 0 0 0 10 10"></path>
<g class="terminal ">
<path d="M60 70h12.75"></path>
<path d="M126.75 70h12.75"></path>
<rect x="72.75" y="59" width="54" height="22" rx="10" ry="10"></rect>
<text x="99.75" y="74">user</text>
</g>
<path d="M139.5 70a10 10 0 0 0 10 -10v-10a10 10 0 0 1 10 -10"></path>
<path d="M40 40a10 10 0 0 1 10 10v40a10 10 0 0 0 10 10"></path>
<g class="terminal ">
<path d="M60 100h4.25"></path>
<path d="M135.25 100h4.25"></path>
<rect x="64.25" y="89" width="71" height="22" rx="10" ry="10"></rect>
<text x="99.75" y="104">system</text>
</g>
<path d="M139.5 100a10 10 0 0 0 10 -10v-40a10 10 0 0 1 10 -10"></path>
</g>
<g>
<path d="M159.5 40h0"></path>
<path d="M228 40h0"></path>
<path d="M159.5 40h20"></path>
<g class="terminal ">
<path d="M179.5 40h0"></path>
<path d="M208 40h0"></path>
<rect x="179.5" y="29" width="28.5" height="22" rx="10" ry="10"></rect>
<text x="193.75" y="44">/</text>
</g>
<path d="M208 40h20"></path>
</g>
<g>
<path d="M228 40h0"></path>
<path d="M441 40h0"></path>
<path d="M228 40h20"></path>
<g class="terminal ">
<path d="M248 40h0"></path>
<path d="M421 40h0"></path>
<rect x="248" y="29" width="173" height="22" rx="10" ry="10"></rect>
<text x="334.5" y="44">FHIR Resource Type</text>
</g>
<path d="M421 40h20"></path>
<path d="M228 40a10 10 0 0 1 10 10v10a10 10 0 0 0 10 10"></path>
<g class="terminal ">
<path d="M248 70h72.25"></path>
<path d="M348.75 70h72.25"></path>
<rect x="320.25" y="59" width="28.5" height="22" rx="10" ry="10"></rect>
<text x="334.5" y="74">&#42;</text>
</g>
<path d="M421 70a10 10 0 0 0 10 -10v-10a10 10 0 0 1 10 -10"></path>
</g>
<g>
<path d="M441 40h0"></path>
<path d="M509.5 40h0"></path>
<path d="M441 40h20"></path>
<g class="terminal ">
<path d="M461 40h0"></path>
<path d="M489.5 40h0"></path>
<rect x="461" y="29" width="28.5" height="22" rx="10" ry="10"></rect>
<text x="475.25" y="44">.</text>
</g>
<path d="M489.5 40h20"></path>
</g>
<g>
<path d="M509.5 40h0"></path>
<path d="M832 40h0"></path>
<path d="M509.5 40a10 10 0 0 0 10 -10v0a10 10 0 0 1 10 -10h28.5a10 10 0 0 1 10 10v0a10 10 0 0 0 10 10"></path>
<path d="M509.5 40h20"></path>
<g class="terminal ">
<path d="M529.5 40h0"></path>
<path d="M558 40h0"></path>
<rect x="529.5" y="29" width="28.5" height="22" rx="10" ry="10"></rect>
<text x="543.75" y="44">c</text>
</g>
<path d="M558 20h68.5a10 10 0 0 1 10 10v0a10 10 0 0 0 10 10"></path>
<path d="M558 40h20"></path>
<g class="terminal ">
<path d="M578 40h0"></path>
<path d="M606.5 40h0"></path>
<rect x="578" y="29" width="28.5" height="22" rx="10" ry="10"></rect>
<text x="592.25" y="44">r</text>
</g>
<path d="M606.5 40h20"></path>
<path d="M558 40a10 10 0 0 1 10 10v0a10 10 0 0 0 10 10h28.5a10 10 0 0 0 10 -10v0a10 10 0 0 1 10 -10"></path>
<path d="M626.5 20h68.5a10 10 0 0 1 10 10v0a10 10 0 0 0 10 10"></path>
<path d="M626.5 40h20"></path>
<g class="terminal ">
<path d="M646.5 40h0"></path>
<path d="M675 40h0"></path>
<rect x="646.5" y="29" width="28.5" height="22" rx="10" ry="10"></rect>
<text x="660.75" y="44">u</text>
</g>
<path d="M675 40h20"></path>
<path d="M626.5 40a10 10 0 0 1 10 10v0a10 10 0 0 0 10 10h28.5a10 10 0 0 0 10 -10v0a10 10 0 0 1 10 -10"></path>
<path d="M695 20h68.5a10 10 0 0 1 10 10v0a10 10 0 0 0 10 10"></path>
<path d="M695 40h20"></path>
<g class="terminal ">
<path d="M715 40h0"></path>
<path d="M743.5 40h0"></path>
<rect x="715" y="29" width="28.5" height="22" rx="10" ry="10"></rect>
<text x="729.25" y="44">d</text>
</g>
<path d="M743.5 40h20"></path>
<path d="M695 40a10 10 0 0 1 10 10v0a10 10 0 0 0 10 10h28.5a10 10 0 0 0 10 -10v0a10 10 0 0 1 10 -10"></path>
<path d="M763.5 40h20"></path>
<g class="terminal ">
<path d="M783.5 40h0"></path>
<path d="M812 40h0"></path>
<rect x="783.5" y="29" width="28.5" height="22" rx="10" ry="10"></rect>
<text x="797.75" y="44">s</text>
</g>
<path d="M812 40h20"></path>
<path d="M763.5 40a10 10 0 0 1 10 10v0a10 10 0 0 0 10 10h28.5a10 10 0 0 0 10 -10v0a10 10 0 0 1 10 -10"></path>
</g>
<g>
<path d="M832 40h0"></path>
<path d="M1054 40h0"></path>
<path d="M832 40a10 10 0 0 0 10 -10v0a10 10 0 0 1 10 -10"></path>
<g>
<path d="M852 20h182"></path>
</g>
<path d="M1034 20a10 10 0 0 1 10 10v0a10 10 0 0 0 10 10"></path>
<path d="M832 40h20"></path>
<g>
<path d="M852 40h0"></path>
<path d="M1034 40h0"></path>
<g class="terminal ">
<path d="M852 40h0"></path>
<path d="M880.5 40h0"></path>
<rect x="852" y="29" width="28.5" height="22" rx="10" ry="10"></rect>
<text x="866.25" y="44">?</text>
</g>
<path d="M880.5 40h10"></path>
<path d="M890.5 40h10"></path>
<g>
<path d="M900.5 40h0"></path>
<path d="M1034 40h0"></path>
<path d="M900.5 40h10"></path>
<g class="terminal ">
<path d="M910.5 40h0"></path>
<path d="M1024 40h0"></path>
<rect x="910.5" y="29" width="113.5" height="22" rx="10" ry="10"></rect>
<text x="967.25" y="44">param=value&</text>
</g>
<path d="M1024 40h10"></path>
<path d="M910.5 40a10 10 0 0 0 -10 10v0a10 10 0 0 0 10 10"></path>
<g>
<path d="M910.5 60h113.5"></path>
</g>
<path d="M1024 60a10 10 0 0 0 10 -10v0a10 10 0 0 0 -10 -10"></path>
</g>
</g>
<path d="M1034 40h20"></path>
</g>
<path d="M 1054 40 h 20 m -10 -10 v 20 m 10 -20 v 20"></path>
</g>
<style>
	svg {
		background-color: hsl(30,20%,95%);
	}
	path {
		stroke-width: 3;
		stroke: black;
		fill: rgba(0,0,0,0);
	}
	text {
		font: bold 14px monospace;
		text-anchor: middle;
		white-space: pre;
	}
	text.diagram-text {
		font-size: 12px;
	}
	text.diagram-arrow {
		font-size: 16px;
	}
	text.label {
		text-anchor: start;
	}
	text.comment {
		font: italic 12px monospace;
	}
	g.non-terminal text {
		/&#42;font-style: italic;&#42;/
	}
	rect {
		stroke-width: 3;
		stroke: black;
		fill: hsl(120,100%,90%);
	}
	rect.group-box {
		stroke: gray;
		stroke-dasharray: 10 5;
		fill: none;
	}
	path.diagram-text {
		stroke-width: 3;
		stroke: black;
		fill: white;
		cursor: help;
	}
	g.diagram-text:hover path.diagram-text {
		fill: #eee;
	}</style>
</svg>

#### Patient-specific scopes

Patient-specific scopes allow access to specific data about a single patient.
*Which* patient is not specified here: clinical data
scopes are all about *what* and not *who* which is handled in the next section.
Patient-specific scopes start with `patient/`.
Note that some EHRs may not enable access to all related resources (for
example, Practitioners linked to/from Patient-specific resources).
Note that if a FHIR server supports linking one Patient record with another
via `Patient.link`, the server documentation SHALL describe its authorization
behavior.

Several examples are shown below:

Goal | Scope | Notes
-----|-------|-------
Read and search for all observations about a patient         | `patient/Observation.rs` |
Read demographics about a patient             | `patient/Patient.r`      | Note the difference in capitalization between "patient" the permission type and "Patient" the resource.
Add new blood pressure readings for a patient | `patient/Observation.c`  | Note that the permission is broader than the goal: with this scope, an app can add not only blood pressures, but other observations as well. Note also that write access does not imply read access.
Read all available data about a patient       | `patient/*.cruds`        | See notes on wildcard scopes below.
{:.grid}

#### User-level scopes

User-level scopes allow access to specific data that a user can access. Note
that this isn't just data *about* the user; it's data *available to* that user.
User-level scopes start with  `user/`.

Several examples are shown below:

Goal | Scope | Notes
-----|-------|-------
Read a feed of all new lab observations across a patient population | `user/Observation.rs`    |
Manage all appointments to which the authorizing user has access    | `user/Appointment.cruds` | Individual attributes such as `d` for delete could be removed if not required.
Manage all resources on behalf of the authorizing user              | `user/*.cruds`           |
Select a patient                                                    | `user/Patient.rs`        | Allows the client app to select a patient.
{:.grid}

#### System-level scopes
System-level scopes describe data that a client system is directly authorized
to access; these scopes are useful in cases where there is no user in the loop,
such as a data monitoring or reporting service.  System-level scopes start with
`system/`.

Several examples are shown below:

Goal | Scope | Notes
-----|-------|-------
Alert engine to monitor all lab observations in a health system          | `system/Observation.rs` | Read-only access to observations.
Perform bulk data export across all available data within a FHIR server  | `system/*.rs`           | Full read/search for all resources.
System-level bridge, turning a V2 ADT feed into FHIR Encounter resources | `system/Encounter.cud`  | Write access to Encounters.
{:.grid}

#### Wildcard scopes

As noted previously, clients can request clinical scopes that contain a wildcard (`*`) for the FHIR resource. When a wildcard is requested for the FHIR resource, the client is asking for all data for all available FHIR resources, both now _and in the future_. This is an important distinction to understand, especially for the entity responsible for granting authorization requests from clients.

For instance, imagine a FHIR server that today just exposes the Patient resource. The authorization server asking a patient to authorize a SMART app requesting `patient/*.cruds` should inform the user that they are being asked to grant this SMART app access to not just the currently accessible data about them (patient demographics), but also any additional data the FHIR server may be enhanced to expose in the future (e.g., genetics).

As with any requested scope, the scopes ultimately granted by the authorization server may differ from the scopes requested by the client! This is often true when dealing with wildcard clinical scope requests.

As a best practice, clients should examine the granted scopes by the authorization server and respond accordingly. Failure to do so may lead to situations where the client receives an authorization failure by the FHIR server because it attempted to access FHIR resources beyond the granted scopes.

For example, consider a client with the goal of obtaining read and write access to a patient's allergies. If this client requests the clinical scope of `patient/AllergyIntolerance.cruds`, the authorization server may respond in a variety of ways with respect to the scopes that are ultimately granted. The following table outlines several, but not an exhaustive list of scenarios for this example:

Granted Scope | Notes
--------------|-------
`patient/AllergyIntolerance.cruds` | The client was granted exactly what it requested: patient-level read and write access to allergies via the same requested wildcard scope.
`patient/AllergyIntolerance.rs`<br />`patient/AllergyIntolerance.cud` | The client was granted exactly what it requested: patient-level CRUDS access to allergies. However, note that this was communicated via two explicit scopes rather than a single scope.
`patient/AllergyIntolerance.rs`    | The client was granted just patient-level read access to allergies.
`patient/AllergyIntolerance.cud`   | The client was granted just patient-level write access to allergies.
`patient/*.rs`                     | The client was granted read access to all data on the patient.
`patient/*.cruds`                  | The client was granted its requested scopes as well as read/write access to all other data on the patient.
`patient/Observation.rs`           | The client was granted an entirely different scope: patient-level read access to the patient's observations.  While this behavior is unlikely for a production quality authorization server, this scenario is technically possible.
`""` (empty scope string – no scopes granted) | The authorization server chose to not grant any of the requested scopes.
{:.grid}

As a best practice, clients are encouraged to request only the scopes and permissions they need to function and avoid the use of wildcard scopes purely for the sake of convenience. For instance, if your allergy management app requires patient-level read and write access to allergies, requesting the `patient/AllergyIntolerance.cruds` scope is acceptable. However, if your app only requires access to read allergies, requesting a scope of `patient/AllergyIntolerance.rs` would be more appropriate.

### Scopes for requesting context data

These scopes affect what context parameters will be provided in the access token response. Many apps rely on contextual data from the EHR to answer questions like:

* Which patient record is currently "open" in the EHR?
* Which encounter is currently "open" in the EHR?
* At which clinic, hospital ward, or patient room is the end-user currently working?

To request access to such details, an app asks for "launch context" scopes in
addition to whatever clinical access scopes it needs. Launch context scopes are
easy to tell apart from clinical data scopes, because they always begin with
`launch`.

There are two general approaches to asking for launch context data depending
on the details of how your app is launched.

#### Apps that launch from the EHR

Apps that launch from the EHR will be passed an explicit URL parameter called
`launch`, whose value must associate the app's
authorization request with the current EHR session.  For example, If an app receives the URL
parameter `launch=abc123`, then it requests the scope `launch` and provides an
additional URL parameter of `launch=abc123`.

The application could choose to also provide `launch/patient` and/or `launch/encounter` as "hints" regarding which contexts the app would like the EHR to gather. The EHR MAY ignore these hints (for example, if the user is in a workflow where these contexts do not exist).

If an application requests a clinical scope which is restricted to a single patient (e.g., `patient/*.rs`), and the authorization results in the EHR is granting that scope, the EHR SHALL establish a patient in context. The EHR MAY refuse authorization requests including `patient/` that do not also include a valid `launch`, or it MAY infer the `launch/patient` scope.

#### Standalone apps

Standalone apps that launch outside the EHR do not have any EHR context at the outset. These apps must explicitly request EHR context. The EHR SHOULD provide the requested context if requested by the following scopes, unless otherwise noted.

Requested Scope | Meaning
----------------|---------
`launch/patient`   | Need patient context at launch time (FHIR Patient resource). See note below.
`launch/encounter` | Need encounter context at launch time (FHIR Encounter resource).
(Others)           | This list can be extended by any SMART EHR to support additional context.  When specifying resource types, convert the type names to *all lowercase* (e.g., `launch/diagnosticreport`).
{:.grid}

Note on `launch/patient`: If an application requests a clinical scope which is restricted to a single patient (e.g., `patient/*.rs`), and the authorization results in the EHR granting that scope, the EHR SHALL establish a patient in context. The EHR MAY refuse authorization requests including `patient/` that do not also include a valid `launch/patient` scope, or it MAY infer the `launch/patient` scope.

#### Launch context arrives with your `access_token`

Once an app is authorized, the token response will include any context data the
app requested and any (potentially) unsolicited context data the EHR may
decide to communicate. For example, EHRs may use launch context to communicate
UX and UI expectations to the app (see `need_patient_banner` below).

Launch context parameters come alongside the access token. They will appear as JSON
parameters:

```js
{
  "access_token": "secret-xyz",
  "patient": "123",
  "fhirContext": [{"reference": "DiagnosticReport/123"}, {"reference": "Organization/789"}],
//...
}
```
Some common launch context parameters are shown below. The following sections provides further details:

Launch context parameter | Example value | Meaning
-------------------------|---------------|---------
`patient`             | `"123"`                                  | String value with a patient id, indicating that the app was launched in the context of FHIR Patient 123. If the app has any patient-level scopes, they will be scoped to Patient 123.
`encounter`           | `"123"`                                  | String value with an encounter id, indicating that the app was launched in the context of FHIR Encounter 123.
`fhirContext`         | `[{"reference": "Appointment/123"}]`                    | Array of objects referring to any resource type other than "Patient" or "Encounter". See [details below](#fhir-context).
`need_patient_banner` | `true` or `false` (boolean)              | Boolean value indicating whether the app was launched in a UX context where a patient banner is required (when `true`) or not required (when `false`). An app receiving a value of `false` should not take up screen real estate displaying a patient banner.
`intent`              | `"reconcile-medications"`                | String value describing the intent of the application launch (see notes [below](#launch-intent))
`smart_style_url`     | `"https://ehr/styles/smart_v1.json"`     | String URL where the EHR's style parameters can be retrieved (for apps that support [styling](#styling))
`tenant`              | `"2ddd6c3a-8e9a-44c6-a305-52111ad302a2"` | String conveying an opaque identifier for the healthcare organization that is launching the app. This parameter is intended primarily to support EHR Launch scenarios.
{:.grid}

<h5 id="fhir-context"><code>fhirContext</code></h5>

To allow application flexibility, maintain backwards compatibility, and keep a
predictable JSON structure, any contextual resource types that were requested
by a launch scope will appear in the `fhirContext` array. The Patient and
Encounter resource types will *not be deprecated from top-level parameters*,
and they will *not be permitted* within the `fhirContext` array unless they
include a `role` other than `"launch"`.

Each object in the `fhirContext` array SHALL have a  `reference` property with
a string value containing a relative reference to a FHIR resource. Note that
there MAY be more than one Reference to a given *type* of resource

Each object in the `fhirContext` array MAY have a  `role` property with a
string value containing a URI identifying the role. The `role` property is
OPTIONAL; it MAY be omitted and SHALL NOT be the empty string. Relative URIs
can only be used if they are defined in this specification; other roles require
the use of absolute URIs. The absence of a role property is semantically
equivalent to a role of `"launch"`, indicating to a client that the app launch
was performed in the context of the referenced resource. More granular role
URIs can be adopted in use-case-specific ways. Note that `role` need not be
unique; multiple entries in `fhirContext` may have the same role.

<h5 id="launch-intent"><b>App Launch Intent</b> (optional)</h5>
`intent`: Some SMART apps might offer more than one context or user interface
that can be accessed during the SMART launch. The optional `intent` parameter
in the launch context provides a mechanism for the SMART EHR to communicate to
the client app which specific context should be displayed as the outcome of the
launch. This allows for closer integration between the EHR and client, so that
different launch points in the EHR UI can target specific displays within the
client app.

For example, a patient timeline app might provide three specific UI contexts,
and inform the SMART EHR (out of band, at app configuration time)  of the
`intent` values that can be used to launch the app directly into one of the
three contexts. The app might respond to `intent` values like:

* `summary-timeline-view` - A default UI context, showing a data summary
* `recent-history-timeline` - A history display, showing a list of entries
* `encounter-focused-timeline` - A timeline focused on the currently in-context encounter

If a SMART EHR provides a value that the client does not recognize, or does
not provide a value, the client app SHOULD display a default application UI
context.

Note that *SMART makes no effort to standardize `intent` values*.  Intents simply
provide a mechanism for tighter custom integration between an app and a SMART
EHR. The meaning of intent values must be negotiated between the app and the EHR.

##### SMART App Styling (experimental[^1])
{: #styling}
`smart_style_url`: In order to mimic the style of the SMART EHR more closely,
SMART apps can check for the existence of this launch context parameter and,  if provided,
download the JSON file referenced by the URL value.

The URL SHOULD serve a "SMART Style" JSON object with one or more of the following properties:

``` text
{
  color_background: "#edeae3",
  color_error: "#9e2d2d",
  color_highlight: "#69b5ce",
  color_modal_backdrop: "",
  color_success: "#498e49",
  color_text: "#303030",
  dim_border_radius: "6px",
  dim_font_size: "13px",
  dim_spacing_size: "20px",
  font_family_body: "Georgia, Times, 'Times New Roman', serif",
  font_family_heading: "'HelveticaNeue-Light', Helvetica, Arial, 'Lucida Grande', sans-serif;"
}
```

The URL value itself is to be considered a version key for the contents of the SMART Style JSON:
EHRs SHALL return a new URL value in the `smart_style_url` launch context parameter if the contents
of this JSON is changed.

Style Property | Description
---------------|-------------
`color_background`     | The color used as the background of the app.
`color_error`          | The color used when UI elements need to indicate an area or item of concern or dangerous action, such as a button to be used to delete an item, or a display an error message.
`color_highlight`      | The color used when UI elements need to indicate an area or item of focus, such as a button used to submit a form, or a loading indicator.
`color_modal_backdrop` | The color used when displaying a backdrop behind a modal dialog or window.
`color_success`        | The color used when UI elements need to indicate a positive outcome, such as a notice that an action was completed successfully.
`color_text`           | The color used for body text in the app.
`dim_border_radius`    | The base corner radius used for UI element borders (0px results in square corners).
`dim_font_size`        | The base size of body text displayed in the app.
`dim_spacing_size`     | The base dimension used to space UI elements.
`font_family_body`     | The list of typefaces to use for body text and elements.
`font_family_heading`  | The list of typefaces to use for content heading text and elements.
{:.grid}

SMART client apps that can adjust their styles should incorporate the above
property values into their stylesheets, but are not required to do so.

Optionally, if the client app detects a new version of the SMART Style object
(i.e. a new URL is returned the `smart_style_url` parameter), the client can
store the new property values and request approval to use the new values from
a client app stakeholder. This allows for safeguarding against poor usability
that might occur from the immediate use of these values in the client app UI.

### Scopes for requesting identity data

Some apps need to authenticate the end-user.  This can be accomplished by
requesting the scope `openid`.  When the `openid` scope is requested, apps can
also request the `fhirUser` scope to obtain a FHIR resource representation of
the current user.

When these scopes are requested (and the request is granted), the app will
receive an [`id_token`](http://openid.net/specs/openid-connect-core-1_0.html#CodeIDToken)
that comes alongside the access token.

This token must be [validated according to the OIDC specification](http://openid.net/specs/openid-connect-core-1_0.html#IDTokenValidation).
To learn more about the user, the app should treat the `fhirUser` claim as the
URL of a FHIR resource representing the current user.  This URL MAY be absolute
(e.g., `https://ehr.example.org/Practitioner/123`), or it MAY be relative to
the FHIR server base URL associated with the current authorization request
(e.g., `Practitioner/123`).  This will be a resource of type `Patient`,
`Practitioner`, `PractitionerRole`, `RelatedPerson`, or `Person`.
Note that the FHIR server base URL is the same as the URL represented in the
`aud` parameter passed in to the authorization request.
Note that `Person` is only used if the other resource types do not apply to the
current user, for example, the "authorized representative" for >1 patients.

The [OpenID Connect Core specification](http://openid.net/specs/openid-connect-core-1_0.html)
describes a wide surface area with many optional capabilities. To be considered compatible
with the SMART's `sso-openid-connect` capability, the following requirements apply:

 * Response types: The EHR SHALL support the Authorization Code Flow, with the request parameters as defined in [SMART App Launch](app-launch.html). Support is not required for parameters that OIDC lists as optional (e.g., `id_token_hint`, `acr_value`), but EHRs are encouraged to review these optional parameters.

 * Public Keys Published as Bare JWK Keys: The EHR SHALL publish public keys as bare JWK keys (which MAY also be accompanied by X.509 representations of those keys).

 * Claims: The EHR SHALL support the inclusion of SMART's `fhirUser` claim within the `id_token` issued for any requests that grant the `openid` and `fhirUser` scopes.

* Signed ID Token: The EHR SHALL support Signing ID Tokens with RSA SHA-256.

* A SMART app SHALL NOT pass the `auth_time` claim or `max_age` parameter to a server that does not support receiving them.

Servers MAY include support for the following features:

 * `claims` parameters on the authorization request
 * Request Objects on the authorization request
 * UserInfo endpoint with claims exposed to clients

### Scopes for requesting a refresh token

To request a `refresh_token` that can be used to obtain a new access token
after the current access token expires, add one of the following scopes:

Scope | Grants
------|--------
`online_access`    | Request a `refresh_token` that can be used to obtain a new access token to replace an expired one, and that will be usable for as long as the end-user remains online.
`offline_access`   | Request a `refresh_token` that can be used to obtain a new access token to replace an expired token, and that will remain usable for as long as the authorization server and end-user will allow, regardless of whether the end-user is online.
{:.grid}

### Extensibility

In addition to conveying FHIR Resource references with the `fhirContext` array, additional context parameters and scopes can be used as extensions using the following namespace conventions:

- use a *full URI* that you control (e.g., http://example.com/scope-name)
- use any string starting with `__` (two underscores)

#### Example: Extra context - `fhirContext` for FHIR Resource References

##### EHR Launch

If a SMART on FHIR server supports additional launch context during an EHR
Launch, it could communicate the ID of an `ImagingStudy` that is open in the
EHR at the time of app launch.  The server could return an access token response
where the `fhirContext` array includes a value such as `{"reference": "ImagingStudy/123"}`.

##### Standalone Launch

If a SMART on FHIR server supports additional launch context during a
Standalone Launch, it could provide an ability for the user to select an
`ImagingStudy` during the launch.  A client could request this behavior by
requesting a `launch/imagingstudy` scope (note that launch requests scopes are
always lower case); then after allowing the user to select an `ImagingStudy`,
the server could return an access token response where the `fhirContext` array
includes a value such as  `{"reference": "ImagingStudy/123"}`.

If a medication reconciliation app expects distinct contextual inputs
representing an at-home medication list and an in-hospital medication list, the
EHR might supply `fhirContext` like:

```json
{
  // other properties omitted for brevity
  "patient": "123",
  "fhirContext": [{
	"reference": "List/123",
	"role": "https://example.org/med-list-at-home"
  }, {
	"reference": "List/456",
	"role": "https://example.org/med-list-at-hospital"
  }]
}
```


#### Example: Extra context - extensions for non-FHIR context

If a SMART on FHIR server wishes to communicate additional context (such
as a custom "dark mode" flag to provide clients a hint about whether they
should render a UI suitable for use in low-light environments), it could
accomplish this by returning an access token response where an extension
property is present.  The server could choose an extension property as a full URL
(e.g., `{..., "https://ehr.example.org/props/dark-mode": true}`) or by using a
`"__"` prefix (e.g., `{..., "__darkMode": true}`).

#### Example: Extra scopes - extensions for non-FHIR APIs

If a SMART on FHIR server supports a custom behavior like allowing users
to choose their own profile photos through a custom non-FHIR API, it
can designate a custom scope using a full URL (e.g.,
`https://ehr.example.org/scopes/profilePhoto.manage`) or by using a `"__"`
prefix (e.g., `__profilePhoto.manage`).  The server could advertise this scope in its developer-facing
documentation, and also in the `scopes_supported` array of its
`.well-known/smart-configuration` file.  Clients requesting authorization could
include this scope alongside other standardized scopes, so the `scope`
parameter of the authorization request might look like:
`launch/patient patient/*.rs __profilePhoto.manage`.  If the user grants these
scopes, the access token response would then include a `scope` value that
matches the original request.

### Steps for using an ID token

 1. Examine the ID token for its "issuer" property
 2. Perform a `GET {issuer}/.well-known/openid-configuration`
 3. Fetch the server's JSON Web Key by following the "jwks_uri" property
 4. Validate the token's signature against the public key from step #3
 5. Extract the `fhirUser` claim and treat it as the URL of a FHIR resource

### Worked examples

- Worked Python example: [rendered](worked_example_id_token.html)

### Appendix: URI representation of scopes

In some circumstances, scopes must be represented as URIs. For example, when exchanging what scopes users are allowed to have, or sharing what scopes a user has chosen. When URI representations are required, the SMART scopes SHALL be prefixed with `http://smarthealthit.org/fhir/scopes/`, so that a `patient/*.r` scope would be `http://smarthealthit.org/fhir/scopes/patient/*.r`.

openID scopes the URI prefix of http://openid.net/specs/openid-connect-core-1_0# SHALL be used.

---

<br />

[^1]: Section is marked as "experimental" to indicate that there may be future backwards-incompatible changes to the style document pointed to by the `smart_style_url`.
## Client Authentication

Two different types:

1. [Assymetric (public key)](client-confidential-asymmetric.html) 
2. [Symmetric (shared secret)](client-confidential-symmetric.html) 
## 'Client Authentication: Asymmetric (public key)'

### Profile Audience and Scope

This profile describes SMART's
[`client-confidential-asymmetric`](conformance.html) authentication mechanism.  It is intended
for SMART clients that can manage and sign assertions with asymmetric keys.
Specifically, this profile describes the registration-time metadata required for
a client using asymmetric keys, and the runtime process by which a client can
authenticate to an OAuth server's token endpoint. This profile can be
implemented by user-facing SMART apps in the context of the [SMART App Launch](app-launch.html)
flow or by [SMART Backend Services](backend-services.html) that
establish a connection with no user-facing authorization step.

#### Use this profile when the following conditions apply:

* The target FHIR authorization server supports SMART's `client-confidential-asymmetric` capability
* The client can manage asymmetric keys for authentication
* The client is able to protect a private key

*Note*: The FHIR specification includes a set of [security
considerations](http://hl7.org/fhir/security.html) including security, privacy,
and access control. These considerations apply to diverse use cases and provide
general guidance for choosing among security specifications for particular use
cases.

### Underlying Standards

* [HL7 FHIR RESTful API](http://www.hl7.org/fhir/http.html)
* [RFC5246, The Transport Layer Security Protocol, V1.2](https://tools.ietf.org/html/rfc5246)
* [RFC6749, The OAuth 2.0 Authorization Framework](https://tools.ietf.org/html/rfc6749)
* [RFC7515, JSON Web Signature](https://tools.ietf.org/html/rfc7515)
* [RFC7517, JSON Web Key](https://www.rfc-editor.org/rfc/rfc7517.txt)
* [RFC7518, JSON Web Algorithms](https://tools.ietf.org/html/rfc7518)
* [RFC7519, JSON Web Token (JWT)](https://tools.ietf.org/html/rfc7519)
* [RFC7521, Assertion Framework for OAuth 2.0 Client Authentication and Authorization Grants](https://tools.ietf.org/html/rfc7521)
* [RFC7523, JSON Web Token (JWT) Profile for OAuth 2.0 Client Authentication and Authorization Grants](https://tools.ietf.org/html/rfc7523)
* [RFC7591, OAuth 2.0 Dynamic Client Registration Protocol](https://tools.ietf.org/html/rfc7591)

<a id="discovery-requirements"></a>

### Advertising server support for this profile
As described in the [Conformance section](conformance.html), a server advertises its support for SMART Confidential Clients with Asymmetric Keys by including the `client-confidential-asymmetric` capability at is `.well-known/smart-configuration` endpoint; configuration properties include `token_endpoint`, `scopes_supported`, `token_endpoint_auth_methods_supported` (with values that include `private_key_jwt`), and `token_endpoint_auth_signing_alg_values_supported` (with values that include at least one of `RS384`, `ES384`).

#### Example `.well-known/smart-configuration` Response
```
HTTP/1.1 200 OK
Content-Type: application/json

{
  "token_endpoint": "https://ehr.example.com/auth/token",
  "token_endpoint_auth_methods_supported": ["private_key_jwt"],
  "token_endpoint_auth_signing_alg_values_supported": ["RS384", "ES384"],
  "scopes_supported": ["system/*.rs"]
}
```

### Registering a client (communicating public keys)

Before a SMART client can run against a FHIR server, the client SHALL generate
or obtain an asymmetric key pair and SHALL register its public key set with that
FHIR server’s authorization service (referred to below as the "FHIR authorization server").
SMART does not require a
standards-based registration process, but we encourage FHIR service implementers to
consider using the [OAuth 2.0 Dynamic Client Registration
Protocol](https://tools.ietf.org/html/draft-ietf-oauth-dyn-reg).

No matter how a client registers with a FHIR authorization server, the
client SHALL register the **public key** that the
client will use to authenticate itself to the FHIR authorization server.  The public key SHALL
be conveyed to the FHIR authorization server in a JSON Web Key (JWK) structure presented within
a JWK Set, as defined in
[JSON Web Key Set (JWKS)](https://tools.ietf.org/html/rfc7517).  The client SHALL
protect the associated private key from unauthorized disclosure
and corruption.

For consistency in implementation, FHIR authorization servers SHALL support registration of client JWKs using both of the following techniques (clients SHALL choose a server-supported method at registration time):

  1. URL to JWK Set (strongly preferred). This URL communicates the TLS-protected
  endpoint where the client's public JWK Set can be found.
  This endpoint SHALL be accessible via TLS without client authentication or authorization. Advantages
  of this approach are that
  it allows a client to rotate its own keys by updating the hosted content at the
  JWK Set URL, assures that the public key used by the FHIR authorization server is current, and avoids the
  need for the FHIR authorization server to maintain and protect the JWK Set. The client SHOULD return a “Cache-Control” header in its JWKS response

  2. JWK Set directly (strongly discouraged). If a client cannot host the JWK
  Set at a TLS-protected URL, it MAY supply the JWK Set directly to the FHIR authorization server at
  registration time.  In this case, the FHIR authorization server SHALL protect the JWK Set from corruption,
  and SHOULD remind the client to send an update whenever the key set changes.  Conveying
  the JWK Set directly carries the limitation that it does not enable the client to
  rotate its keys in-band.  Including both the current and successor keys within the JWK Set
  helps counter this limitation.  However, this approach places increased responsibility
  on the FHIR authorization server for protecting the integrity of the key(s) over time, and denies the FHIR authorization server the
  opportunity to validate the currency and integrity of the key at the time it is used.  

The client SHALL be capable of generating a JSON Web Signature in accordance with [RFC7515](https://tools.ietf.org/html/rfc7515). The client SHALL support both `RS384` and `ES384` for the JSON Web Algorithm (JWA) header parameter as defined in [RFC7518](https://tools.ietf.org/html/rfc7518).
The FHIR authorization server SHALL be capable of validating signatures with at least one of `RS384` or `ES384`.
Over time, best practices for asymmetric signatures are likely to evolve. While this specification mandates a baseline of support clients and servers MAY support and use additional algorithms for signature validation.
As a reference, the signature algorithm discovery protocol `token_endpoint_auth_signing_alg_values_supported` property is defined in OpenID Connect as part of the [OAuth2 server metadata](https://tools.ietf.org/html/rfc8414).

No matter how a JWK Set is communicated to the FHIR authorization server, each JWK SHALL represent an
asymmetric key by including `kty` and `kid` properties, with content conveyed using
"bare key" properties (i.e., direct base64 encoding of key material as integer values).
This means that:

* For RSA public keys, each JWK SHALL include `n` and `e` values (modulus and exponent)
* For ECDSA public keys, each JWK SHALL include `crv`, `x`, and `y` values (curve,
x-coordinate, and y-coordinate, for EC keys)

Upon registration, the client SHALL be assigned a `client_id`, which the client SHALL use when
requesting an access token.


### Authenticating to the Token endpoint

This specification describes how a client authenticates using an asymmetric key, e.g., when requesting an access token during: [SMART App Launch](app-launch.html#step-5-access-token) or [SMART Backend Services](backend-services.html#step-3-access-token), authentication is based on the OAuth 2.0 client credentials flow, with a [JWT
assertion](https://tools.ietf.org/html/rfc7523) as the client's authentication mechanism.

To begin the exchange, the client SHALL use the [Transport Layer Security
(TLS) Protocol Version 1.2 (RFC5246)](https://tools.ietf.org/html/rfc5246) or a more recent version of TLS to
authenticate the identity of the FHIR authorization server and to establish an encrypted,
integrity-protected link for securing all exchanges between the client
and the FHIR authorization server's token endpoint.  All exchanges described herein between the client
and the FHIR server SHALL be secured using TLS V1.2 or a more recent version of TLS .

#### Request

Before a client can request an access token, it SHALL generate a
one-time-use JSON Web Token (JWT) that will be used to authenticate the client to
the FHIR authorization server. The authentication JWT SHALL include the
following claims, and SHALL be signed with the client's private
key (which SHOULD be an `RS384` or `ES384` signature). For a practical reference on JWT, as well as debugging
tools and client libraries, see [https://jwt.io](https://jwt.io).

<table class="table">
  <thead>
    <th colspan="3">Authentication JWT Header Values</th>
  </thead>
  <tbody>
    <tr>
      <td><code>alg</code></td>
      <td><span class="label label-success">required</span></td>
      <td>The JWA algorithm (e.g., <code>RS384</code>, <code>ES384</code>) used for signing the authentication JWT.
      </td>
    </tr>
    <tr>
      <td><code>kid</code></td>
      <td><span class="label label-success">required</span></td>
      <td>The identifier of the key-pair used to sign this JWT. This identifier SHALL
          be unique within the client's JWK Set.</td>
    </tr>
    <tr>
      <td><code>typ</code></td>
      <td><span class="label label-success">required</span></td>
      <td>Fixed value: <code>JWT</code>.</td>
    </tr>
    <tr>
      <td><code>jku</code></td>
      <td><span class="label label-info">optional</span></td>
      <td>The TLS-protected URL to the JWK Set containing the public key(s) accessible without authentication or authorization. When present, this SHALL match the JWKS URL value that the client supplied to the FHIR authorization server at client registration time. When absent, the FHIR authorization server SHOULD fall back on the JWK Set URL or the JWK Set supplied at registration time. See section <a href="#signature-verification">Signature Verification</a> for details.</td>
    </tr>
  </tbody>
</table>


<table class="table">
  <thead>
    <th colspan="3">Authentication JWT Claims</th>
  </thead>
  <tbody>
    <tr>
      <td><code>iss</code></td>
      <td><span class="label label-success">required</span></td>
      <td>Issuer of the JWT -- the client's <code>client_id</code>, as determined during registration with the FHIR authorization server
        (note that this is the same as the value for the <code>sub</code> claim)</td>
    </tr>
    <tr>
      <td><code>sub</code></td>
      <td><span class="label label-success">required</span></td>
      <td>The client's <code>client_id</code>, as determined during registration with the FHIR authorization server
      (note that this is the same as the value for the <code>iss</code> claim)</td>
    </tr>
    <tr>
      <td><code>aud</code></td>
      <td><span class="label label-success">required</span></td>
      <td>The FHIR authorization server's "token URL" (the same URL to which this authentication JWT will be posted -- see below)</td>
    </tr>
    <tr>
      <td><code>exp</code></td>
      <td><span class="label label-success">required</span></td>
      <td>Expiration time integer for this authentication JWT, expressed in seconds since the "Epoch" (1970-01-01T00:00:00Z UTC). This time SHALL be no more than five minutes in the future.</td>
    </tr>
    <tr>
      <td><code>jti</code></td>
      <td><span class="label label-success">required</span></td>
      <td>A nonce string value that uniquely identifies this authentication JWT.</td>
    </tr>
  </tbody>
</table>

After generating an authentication JWT, the client requests an access token following either the [SMART App Launch](app-launch.html#step-5-access-token) or the [SMART Backend Services](backend-services.html#step-3-access-token) specification.  Authentication details are conveyed using the following additional properties on the token request:

<table class="table">
  <thead>
    <th colspan="3">Parameters</th>
  </thead>
  <tbody>
    <tr>
      <td><code>client_assertion_type</code></td>
      <td><span class="label label-success">required</span></td>
      <td>Fixed value: <code>urn:ietf:params:oauth:client-assertion-type:jwt-bearer</code></td>
    </tr>
    <tr>
      <td><code>client_assertion</code></td>
      <td><span class="label label-success">required</span></td>
      <td>Signed authentication JWT value (see above)</td>
    </tr>
  </tbody>
</table>

#### Response

##### Signature Verification

The FHIR authorization server SHALL validate the JWT according to the
processing requirements defined in [Section 3 of RFC7523](https://tools.ietf.org/html/rfc7523#section-3) including validation of the signature on the JWT.

In addition, the authentication server SHALL:
* check that the `jti` value has not been previously encountered for the given `iss` within the maximum allowed authentication JWT lifetime (e.g., 5 minutes). This check prevents replay attacks.
* ensure that the `client_id` provided is known and matches the JWT's `iss` claim.

To resolve a key to verify signatures, a FHIR authorization server SHALL follow this algorithm:

<ol>
  <li>If the <code>jku</code> header is present, verify that the <code>jku</code> is whitelisted (i.e., that it
    matches the JWKS URL value supplied at registration time for the specified <code>client_id</code>).
    <ol type="a">
      <li>If the <code>jku</code> header is not whitelisted, the signature verification fails.</li>
      <li>If the <code>jku</code> header is whitelisted, create a set of potential keys by dereferencing the <code>jku</code> URL. Proceed to step 3.</li>
    </ol>
  </li>
  <li>If the <code>jku</code> header is absent, create a set of potential key sources consisting of all keys found in the registration-time JWKS or found by dereferencing the registration-time JWK Set URL. Proceed to step 3.</li>
  <li>Identify a set of candidate keys by filtering the potential keys to identify the single key where the <code>kid</code> matches the value supplied in the client's JWT header, and the <code>kty</code> is consistent with the signature algorithm supplied in the client's JWT header (e.g., <code>RSA</code> for a JWT using an RSA-based signature, or <code>EC</code> for a JWT using an EC-based signature). If no keys match, or more than one key matches, the verification fails.</li>
  <li>Attempt to verify the JWK using the key identified in step 3.</li>
</ol>

To retrieve the keys from a JWKS URL in step 1 or step 2, a FHIR authorization server issues a HTTP GET request that URL to obtain a JWKS response. For example, if a client has registered a JWKS URL of https://client.example.com/path/to/jwks.json, the server retrieves the client's JWKS with a GET request for that URL, including a header of `Accept: application/json`.

If an error is encountered during the authentication process, the server SHALL
respond with an `invalid_client` error as defined by
the [OAuth 2.0 specification](https://tools.ietf.org/html/rfc6749#section-5.2).

* The FHIR authorization server SHALL NOT cache a JWKS for longer than the client's cache-control header indicates.
* The FHIR authorization server SHOULD cache a client's JWK Set according to the client's cache-control header; it doesn't need to retrieve it anew every time. 

Processing of the access token request proceeds according to either the [SMART App Launch](app-launch.html#step-5-access-token) or the [SMART Backend Services](backend-services.html#step-3-access-token) specification.

### Worked example

Assume that a "bilirubin result monitoring service" client has registered with a FHIR authorization server whose token endpoint is at "https://authorize.smarthealthit.org/token", establishing the following

 * JWT "issuer" URL: `https://bili-monitor.example.com`
 * OAuth2 `client_id`: `https://bili-monitor.example.com`
 * JWK identifier: `kid` value (see [example JWK](RS384.public.json))

The client protects its private key from unauthorized access, use, and modification.  

At runtime, when the bilirubin monitoring service needs to authenticate to the token endpoint, it generates a one-time-use authentication JWT.

**JWT Headers:**

```
{
  "typ": "JWT",
  "alg": "RS384",
  "kid": "eee9f17a3b598fd86417a980b591fbe6"
}
```

**JWT Payload:**

```
{
  "iss": "https://bili-monitor.example.com",
  "sub": "https://bili-monitor.example.com",
  "aud": "https://authorize.smarthealthit.org/token",
  "exp": 1422568860,
  "jti": "random-non-reusable-jwt-id-123"
}
```

Using the client's RSA private key, with SHA-384 hashing (as specified for
an `RS384` algorithm (`alg`) parameter value in RFC7518), the signed token
value is:

```
eyJhbGciOiJSUzM4NCIsImtpZCI6ImVlZTlmMTdhM2I1OThmZDg2NDE3YTk4MGI1OTFmYmU2IiwidHlwIjoiSldUIn0.eyJpc3MiOiJodHRwczovL2JpbGktbW9uaXRvci5leGFtcGxlLmNvbSIsInN1YiI6Imh0dHBzOi8vYmlsaS1tb25pdG9yLmV4YW1wbGUuY29tIiwiYXVkIjoiaHR0cHM6Ly9hdXRob3JpemUuc21hcnRoZWFsdGhpdC5vcmcvdG9rZW4iLCJleHAiOjE0MjI1Njg4NjAsImp0aSI6InJhbmRvbS1ub24tcmV1c2FibGUtand0LWlkLTEyMyJ9.D5kAqNJwaftCqsRdVVQDq6dMBxuGFOF5svQJuXbcYp-oEyg5qOwK9ZE5cGLTHxqwfpUPNzRKgVdIGuhawAA-8g0s1nKQae8CuKs33hhKh4J34xSEwW3MYs1gwI4GHTtR_g3kYSX6QCi14Ed3GIAvYFgqRqt-gD7sewMUXL4SB8I8cXcDbCqVizm7uPVhjw6QaeKZygJJ_AVLhM4Xs9LTy4HAhdCHpN0FrNmCerUIYJvHDpcod7A0jDmxdoeW1KIBYlhdhQNwjtsTvT1ce4qacN_3KIv_fIzCKLIgDv9eWxkjAtxOmIm8aW5gX9xX7X0nbd0QglIyiic_bZVNNEh0kg
```

Note: to inspect this example JWT, you can visit https://jwt.io. Paste the signed
JWT value above into the "Encoded"  field, and paste the [sample public signing key](RS384.public.json) (starting with the `{"kty": "RSA"` JSON object, and excluding the `{ "keys": [` JWK Set wrapping array) into the "Public Key" box.
The plaintext JWT will be displayed in the "Decoded:Payload"  field, and a "Signature Verified" message will appear.

For a complete code example demonstrating how to generate this assertion, see: [rendered Jupyter Notebook](authorization-example-jwks-and-signatures.html), [source .ipynb file](authorization-example-jwks-and-signatures.ipynb).


#### Requesting an Access Token

A `client_assertion` generated in this fashion can be used to request an access token as part of a SMART App Launch authorization flow, or as part of a SMART Backend Services authorization flow. See complete example:

* SMART App Launch: [specification](app-launch.html); [full example](example-app-launch-asymmetric-auth.html#step-5-access-token)
* SMART Backend Services: [specification](backend-services.html); [full example](example-backend-services.html#step-3-access-token)
## 'Client Authentication: Symmetric (shared secret)'

### Profile Audience and Scope

This profile describes SMART's
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
## Token Introspection

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
## Conformance

The SMART's App Launch specification enables apps to launch and securely interact with EHRs.
The specification can be described as a set of capabilities and a given SMART on FHIR server implementation
may implement a subset of these.  The methods of declaring a server's SMART authorization endpoints and launch capabilities are described in the sections below.

### SMART on FHIR OAuth authorization Endpoints and Capabilities

The server SHALL convey the FHIR OAuth authorization endpoints and any *optional* SMART Capabilities it supports using a [Well-Known Uniform Resource Identifiers (URIs)](#using-well-known) JSON file. (In previous versions of SMART, some of these details were also conveyed in a server's CapabilityStatement; this mechanism is now deprecated.)


#### Capability Sets

A *Capability Set* combines individual capabilities to enable a specific use-case. A SMART on FHIR server SHOULD support one or more *Capability Set*s. Unless otherwise noted, each capability listed is required to satisfy a *Capability Set*. Any individual SMART server will publish a granular list of its capabilities; from this list a client can determine which of these Capability Sets are supported:

External implementation guides MAY define additional capabilities to be discovered through this same mechanism. IGs published by HL7 MAY use simple strings to represent additional capabilities (e.g., `example-new-capability`); IGs published by other organizations SHALL use full URIs to represent additional capabilities (e.g., `http://sdo.example.org/example-new-capability`).

##### Patient Access for Standalone Apps
1. `launch-standalone`
1. At least one of `client-public` or `client-confidential-symmetric`; and MAY support `client-confidential-asymmetric`
1. `context-standalone-patient`
1. `permission-patient`

#####  Patient Access for EHR Launch (i.e. from Portal)
1. `launch-ehr`
1. At least one of `client-public` or `client-confidential-symmetric`; and MAY support `client-confidential-asymmetric`
1. `context-ehr-patient`
1. `permission-patient`

#####  Clinician Access for Standalone
1. `launch-standalone`
1. At least one of `client-public` or `client-confidential-symmetric`; and MAY support `client-confidential-asymmetric`
1. `permission-user`
1. `permission-patient`

#####  Clinician Access for EHR Launch
1. `launch-ehr`
1. At least one of `client-public` or `client-confidential-symmetric`; and MAY support `client-confidential-asymmetric`
1. `context-ehr-patient` support
1. `context-ehr-encounter` support
1. `permission-user`
1. `permission-patient`

#### Capabilities

To promote interoperability, the following SMART on FHIR *Capabilities* have been defined. A given set of these capabilities is combined to support a specific use, a *Capability Set*.

##### Launch Modes

* `launch-ehr`: support for SMART's EHR Launch mode  
* `launch-standalone`: support for SMART's Standalone Launch mode

##### Authorization Methods

* `authorize-post`: support for POST-based authorization

##### Client Types

* `client-public`: support for SMART's public client profile (no client authentication)  
* `client-confidential-symmetric`: support for SMART's symmetric confidential client profile ("client secret" authentication). See [Client Authentication: Symmetric](client-confidential-symmetric.html).
* `client-confidential-asymmetric`: support for SMART's asymmetric confidential client profile ("JWT authentication"). See [Client Authentication: Asymmetric](client-confidential-asymmetric.html).

##### Single Sign-on

* `sso-openid-connect`: support for SMART's OpenID Connect profile

##### Launch Context

The following capabilities convey that a SMART on FHIR server is capable of providing context
to an app at launch time.

###### Launch Context for UI Integration

These capabilities only apply during an EHR Launch, and `context-style` only for an embedded EHR Launch.

* `context-banner`: support for "need patient banner" launch context (conveyed via `need_patient_banner` token parameter)
* `context-style`: support for "SMART style URL" launch context (conveyed via `smart_style_url` token parameter). This capability is deemed *experimental*.

###### Launch Context for EHR Launch

When a SMART on FHIR server supports the launch of an app from _within_ an
existing user session ("EHR Launch"), the server has an opportunity to pass
existing, already-established context (such as the current patient ID) through
to the launching app. Using the following capabilities, a server declares its
ability to pass context through to an app at launch time:

* `context-ehr-patient`: support for patient-level launch context (requested by `launch/patient` scope, conveyed via `patient` token parameter)
* `context-ehr-encounter`: support for encounter-level launch context (requested by `launch/encounter` scope, conveyed via `encounter` token parameter)

###### Launch Context for Standalone Launch

When a SMART on FHIR server supports the launch of an app from _outside_ an
existing user session ("Standalone Launch"), the server may be able to
proactively resolve new context to help establish the details required for an
app launch. For example, an external app may request that the SMART on FHIR
server should work with the end-user to establish a patient context before
completing the launch.

* `context-standalone-patient`: support for patient-level launch context (requested by `launch/patient` scope, conveyed via `patient` token parameter)
* `context-standalone-encounter`: support for encounter-level launch context (requested by `launch/encounter` scope, conveyed via `encounter` token parameter)

##### Permissions

* `permission-offline`: support for refresh tokens (requested by `offline_access` scope)
* `permission-online`: support for refresh tokens (requested by `online_access` scope)
* `permission-patient`: support for patient-level scopes (e.g., `patient/Observation.rs`)
* `permission-user`: support for user-level scopes (e.g., `user/Appointment.rs`)
* `permission-v1`: support for SMARTv1 scope syntax (e.g., `patient/Observation.read`)
* `permission-v2`: support for SMARTv2 granular scope syntax (e.g., `patient/Observation.rs?category=http://terminology.hl7.org/CodeSystem/observation-category|vital-signs`)

##### App State (Experimental)

* `smart-app-state`: support for managing [SMART App State](./app-state.html)

<br />


### FHIR Authorization Endpoint and Capabilities Discovery using a Well-Known Uniform Resource Identifiers (URIs)
{: #using-well-known}

The authorization endpoints accepted by a FHIR resource server are exposed as a Well-Known Uniform Resource Identifiers (URIs) [(RFC5785)](https://datatracker.ietf.org/doc/html/rfc5785) JSON document.

FHIR endpoints requiring authorization SHALL serve a JSON document at the location formed by appending `/.well-known/smart-configuration` to their base URL.
Contrary to RFC5785 Appendix B.4, the `.well-known` path component may be appended even if the FHIR endpoint already contains a path component.

Responses for `/.well-known/smart-configuration` requests SHALL be JSON, regardless of `Accept` headers provided in the request.

* clients MAY omit an `Accept` header
* servers MAY ignore any client-supplied `Accept` headers
* servers SHALL respond with `application/json`

All endpoint URLs in the response document SHALL be absolute URLs. Clients
encountering relative endpoint URLs (e.g., in the context of legacy or
non-conformant servers) SHOULD evaluate them relative to the FHIR Server Base
URL following [RFC1808](https://datatracker.ietf.org/doc/html/rfc1808#section-4).
For example, in a browser context the absolute URL could be determined via 
`new URL(relativeUrl, fhirBaseUrl).toString()` .


<a id="example-request">

#### Sample Request

Sample requests:

##### Base URL "fhir.ehr.example.com"

```
GET /.well-known/smart-configuration HTTP/1.1
Host: fhir.ehr.example.com
```

##### Base URL "www.ehr.example.com/apis/fhir"

```
GET /apis/fhir/.well-known/smart-configuration HTTP/1.1
Host: www.ehr.example.com
```

#### Response

A JSON document must be returned using the `application/json` mime type.

##### Metadata
- `issuer`: **CONDITIONAL**, String conveying this system's OpenID Connect Issuer URL. Required if the server's capabilities include `sso-openid-connect`; otherwise, omitted.
- `jwks_uri`: **CONDITIONAL**, String conveying this system's JSON Web Key Set URL. Required if the server's capabilities include `sso-openid-connect`; otherwise, optional.
- `authorization_endpoint`: **REQUIRED**, URL to the OAuth2 authorization endpoint.
- `grant_types_supported`: **REQUIRED**, Array of grant types supported at the token endpoint. The options are "authorization_code" (when SMART App Launch is supported) and "client_credentials" (when SMART Backend Services is supported).
- `token_endpoint`: **REQUIRED**, URL to the OAuth2 token endpoint.
- `token_endpoint_auth_methods_supported`: **OPTIONAL**, array of client authentication methods supported by the token endpoint. The options are "client_secret_post", "client_secret_basic", and "private_key_jwt".
- `registration_endpoint`: **OPTIONAL**, If available, URL to the OAuth2 dynamic registration endpoint for this FHIR server.
- `smart_app_state_endpoint`: **CONDITIONAL**, URL to the EHR's app state endpoint. SHALL be present when the EHR supports the `smart-app-state` capability and the endpoint is distinct from the EHR's primary endpoint.
- `scopes_supported`: **RECOMMENDED**, Array of scopes a client may request. See [scopes and launch context](scopes-and-launch-context.html#quick-start). The server SHALL support all scopes listed here; additional scopes MAY be supported (so clients should not consider this an exhaustive list).
- `response_types_supported`: **RECOMMENDED**, Array of OAuth2 `response_type` values that are supported.  Implementers can refer to `response_type`s defined in OAuth 2.0 ([RFC 6749](https://datatracker.ietf.org/doc/html/rfc6749)) and in [OIDC Core](https://openid.net/specs/openid-connect-core-1_0.html#Authentication).
- `management_endpoint`: **RECOMMENDED**, URL where an end-user can view which applications currently have access to data and can make adjustments to these access rights.
- `introspection_endpoint` :  **RECOMMENDED**, URL to a server's introspection endpoint that can be used to validate a token.
- `revocation_endpoint` :  **RECOMMENDED**, URL to a server's revoke endpoint that can be used to revoke a token.
- `capabilities`: **REQUIRED**, Array of strings representing SMART capabilities (e.g., `sso-openid-connect` or `launch-standalone`) that the server supports.
- `code_challenge_methods_supported`: **REQUIRED**, Array of PKCE code challenge methods supported. The `S256` method SHALL be included in this list, and the `plain` method SHALL NOT be included in this list.


<a id="example-response">

#### Sample Response

```
HTTP/1.1 200 OK
Content-Type: application/json

{
  "issuer": "https://ehr.example.com",
  "jwks_uri": "https://ehr.example.com/.well-known/jwks.json",
  "authorization_endpoint": "https://ehr.example.com/auth/authorize",
  "token_endpoint": "https://ehr.example.com/auth/token",
  "token_endpoint_auth_methods_supported": [
    "client_secret_basic",
    "private_key_jwt"
  ],
  "grant_types_supported": [
    "authorization_code",
    "client_credentials"
  ],
  "registration_endpoint": "https://ehr.example.com/auth/register",
  "scopes_supported": ["openid", "profile", "launch", "launch/patient", "patient/*.rs", "user/*.rs", "offline_access"],
  "response_types_supported": ["code"],
  "management_endpoint": "https://ehr.example.com/user/manage",
  "introspection_endpoint": "https://ehr.example.com/user/introspect",
  "revocation_endpoint": "https://ehr.example.com/user/revoke",
  "code_challenge_methods_supported": ["S256"],
  "capabilities": [
    "launch-ehr",
    "permission-patient",
    "permission-v2",
    "client-public",
    "client-confidential-symmetric",
    "context-ehr-patient",
    "sso-openid-connect"
  ]
}
```

## Best Practices

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
* If using the [experimental query-based scopes](scopes-and-launch-context.html#experimental-features), consider how the query will be represented in plain language. If the query cannot easily be explained in a single sentence, adjustment of the requested scope should be considered or proper documentation provided to educate the intended user population.

### App and Server developers should consider trade-offs associated with confidential vs public app architectures

1. Persistent access is important for providing a seamless consumer experience, and Refresh Tokens are the mechanism SMART App Launch defines for enabling persistent access. If an app is ineligible for refresh tokens, the developer is likely to seek other means of achieving this (e.g., saving a user's password and simulating login; or moving to a cloud-based architecture even though there's no use case for managing data off-device).

1. Client architectures where data pass through or are stored in a secure backend server (e.g., many confidential clients) can offer more secure {refresh token :: client} binding, but are open to certain attacks that purely-on-device apps are not subject to (e.g., cloud server becomes compromised and tokens/secrets leak). A breach in this context can be widespread, across many users.

1. Client architectures where data are managed exclusively on end-user devices (e.g., many public clients including most native apps today, where an app is only registered once with a given EHR) are open to certain attacks that confidential clients can avoid (e.g., a malicious app on your device might steal tokens from a valid app, or might impersonate a valid app). A breach in this context is more likely to be isolated to a given user or device.

The choice of app architecture should be based on context. Apps that already need to manage data in the cloud should consider a confidential client architecture; apps that don't should consider a purely-on-device architecture. But this decision only works if refresh tokens are available in either case; otherwise, app developers will switch architectures just to be able to maintain persistent access, even if the overall security posture is diminished.
## Extensions

This chapter contains the following extensions on SMART on FHIR.

* [Persisting App State](app-state.html)
* [Task profile requesting a SMART launch](task-launch.html)
## 'Persisting App State (Experimental)'

### `smart-app-state` capability

This experimental capability allows apps to persist a small amount of
configuration data to an EHR's FHIR server. Conformance requirements described
below apply only to software that implements support for this capability.
Example use cases include:

* App with no backend storage persists user preferences such as default
  screens, shortcuts, or color preferences. Such apps can save preferences to
  the EHR and retrieve them on subsequent launches.

* App maintains encrypted external data sets. Such apps can persist access keys
  to the EHR and retrieve them on subsequent launches, allowing in-app
  decryption and display of external data sets.

**Apps SHALL NOT use `smart-app-state` when data being persisted could be
managed directly using FHIR domain models.** For example, an app would never
persist clinical diagnoses or observations using `smart-app-state`. Such usage
is prohibited because the standard FHIR API provides safer and more
interoperable mechanisms for clinical data sharing.

**Apps SHALL NOT expect the EHR to use or interpret data stored via
`smart-app-state`**  unless specific agreements are made outside the scope of
this capability.

<a id="at-most-one-subject"></a>
Note that while state can be associated with a user account or with a patient
record, this capability does not enable state associated with (user, patient)
pairs. For instance, there is no defined mechanism to save information like
"Practitioner A prefers her diabetes management app to start with the 'recent
labs' screen for Patient A, and the 'in-range glucose time' screen for Patient
B."

### Formal definitions

The narrative documentation below provides formal requirements, usage notes, and examples.

In addition, the following conformance resources can support automated processing in FHIR R4:

* [CapabilityStatement/smart-app-state-server](CapabilityStatement-smart-app-state-server.html)
* [StructureDefinition/smart-app-state-basic](StructureDefinition-smart-app-state-basic.html)

### Discovery

EHRs supporting this capability SHALL advertise support by including
`"smart-app-state"` in the capabilities array of their FHIR server's
`.well-known/smart-configuration` file (see section [Conformance](conformance.html)).

EHRs supporting this capability MAY include a `smart_app_state_endpoint`
property if they want to maintain App State management functionality at a
location distinct form the core EHR's FHIR endpoint (see section [Design
Notes](#design-notes)).

The EHR's "App State FHIR endpoint" is defined as:

1. The value in `smart_app_state_endpoint`, if present
2. The EHR's primary FHIR endpoint, otherwise


#### Example discovery document

Consider a FHIR server with base URL `https://ehr.example.org/fhir`.

The discovery document at
`https://ehr.example.org/fhir/.well-known/smart-configuration` might include:

```js
{
  "capabilities": [
    "smart-app-state",
    // <other capabilities snipped>
  ],
  "smart_app_state_endpoint": "https://ehr.example.org/appstate"
  // <other properties snipped>
}
```

### App State Interactions

The EHR's App State FHIR endpoint SHALL provide support for:

2. `POST /Basic` requiring the presence of `If-Match` to prevent contention
2. `PUT /Basic/[id]` requiring the presence of `If-Match` to prevent contention
2. `DELETE /Basic/[id]` requiring the presence of `If-Match` to prevent contention
1. `GET /Basic?code={}&subject={}`
1. `GET /Basic?code={}&subject:missing=true` // for global app config

### Managing app state (CRUDS)

App State data can include details like encryption keys. EHRs SHALL evaluate
storage requirements and MAY store App State data separately from their routine
FHIR Resource storage space. 

App State is always associated with a "state code" (`Basic.code.coding`) and
optionally associated with a subject (`Basic.subject`).

EHRs SHALL allow at least one `smart-app-state` resource per state code, and at
least one `smart-app-state` resource per (state code, subject) tuple. EHRs
SHOULD describe applicable limits in their developer documentation.

EHRs SHOULD retain app state data for as long as the originating app remains
actively registered with the EHR. EHRs MAY establish additional retention
policies in their developer documentation.

##### Create

To create app state, an app submits to the EHR's App State endpoint:

    POST /Basic

The request body is a `Basic` resource where:

1. Total resource size as serialized in the POST body SHALL NOT exceed 256KB unless the EHR's documentation establishes a higher limit
2. `Basic.id` SHALL NOT be included
2. `Basic.meta.versionId` SHALL NOT be included
3. `Basic.subject.reference` is optional, associating App State with <a href="#at-most-one-subject">at most one subject</a>. When omitted, global configuration can be stored in App State. When present, this SHALL be an absolute reference to a resource in the EHR's primary FHIR server. The EHR SHALL support at least Patient, Practitioner, PractitionerRole, RelatedPerson, Person. The EHR's documentation MAY establish support for a broader set of resources.
5. `Basic.code.coding[]`  SHALL include exactly one app-specified Coding
6. `Basic.extension` MAY include non-complex extensions. Extensions SHALL be limited to the `valueString` type unless the EHR's documentation establishes a broader set of allowed extension types

If the EHR accepts the request, the EHR SHALL persist the submitted resource including:

* a newly generated server-side unique value in populated in `Basic.id`
* a value populated in `Basic.meta.versionId`
* the Reference present in `Basic.subject`, if any
* the Coding present in `Basic.code.coding`
* all top-level extensions present in the request

If the EHR cannot meet all of these obligations, it SHALL reject the request.

The response headers include an `ETag` header following [FHIR Core "Managing Resource
Contention"](https://hl7.org/fhir/http.html#concurrency).

The response body is a `Basic` resource representing the state persisted by the EHR.

##### Updates

To update app state, an app submits to the EHR's App State endpoint:

    PUT /Basic/[id]

The request SHALL include an `If-Match` header with an ETag to prevent
contention as defined in [FHIR Core "Managing Resource
Contention"](https://hl7.org/fhir/http.html#concurrency).

The payload is a `Basic` resource where:

1. `Basic.id` SHALL be present, matching the `[id]` in the request URL
3. `Basic.subject` and `Basic.code` SHALL NOT change from the previously-persisted values

EHR servers SHALL return a `412 Precondition Failed` response if the version
specified in `If-Match` header's ETag does not reflect the most recent version
stored in the server, or if the `Basic.subject` or `Basic.code` does not match
previously-persisted value.

The successful response headers include an `ETag` header following [FHIR Core "Managing Resource
Contention"](https://hl7.org/fhir/http.html#concurrency).

The response body is a `Basic` resource representing the state persisted by the EHR.

##### Deletes

To delete app state, an app submits to the EHR's App State endpoint:

    DELETE /Basic/[id]

The request SHALL include an `If-Match` header with an ETag to prevent
contention as defined in [FHIR Core "Managing Resource
Contention"](https://hl7.org/fhir/http.html#concurrency).

EHR servers SHALL return a `412 Precondition Failed` response if the version
specified in `If-Match` header's ETag does not reflect the most recent version
stored in the server.

After successfully deleting state, an app SHALL NOT submit subsequent requests
to modify the same state by `Basic.id`. Servers SHALL process any subsequent
requests about this `Basic.id` as a failed precondition.


#### Querying app state

An app SHALL query for state by supplying a state type code and optionally a
subject:

* `GET /Basic?code={}&subject={}` for state associated with a specific subject
* `GET /Basic?code={}&subject:missing=true` for global state associated with the app overall

The EHR SHALL support the following query parameters:

* `?code` , restricted to fixed state codes that exactly match `Basic.code.coding[0]` (i.e., `${system}` + `|` + `${code}`)
* `?subject`, restricted to absolute references that exactly match `Basic.subject.reference`, with support for the `:missing=true` modifier to find global state

The response body is a FHIR Bundle where each entry is a `Basic` resource as persisted by the EHR.

### API Examples

#### Example 1: App-specific User Preferences

The following example `POST` body shows how an app might persist a user's app-specific preferences:

```
POST /Basic

Authorization: Bearer <snipped>
```
```js
{
  "resourceType": "Basic",
  "subject": {"reference": "https://ehr.example.org/fhir/Practitioner/123"},
  "code": {
    "coding": [
      // app-specific designation; the EHR does not need to understand
      // the meaning of this concept, but SHALL persist it and MAY
      // use it for access control (e.g., using SMART on FHIR scopes
      // or other controls; see below)
      { 
        "system": "https://myapp.example.org",
        "code": "display-preferences"
      }
    ]
  },
  "extension": [
    // app-managed state; the EHR does not need to understand
    // the meaning of these values, but SHALL persist them
    {
      "url": "https://myapp.example.org/display-preferences-v2.0.1",
      "valueString": "{\"defaultView\":\"problem-list\",\"colorblindMode\":\"D\",\"resultsPerPage\":150}"
    }
  ]
}
```

The API response populates `id` and `meta.versionId`, like:

```
Location: https://ehr.example.org/appstate/Basic/1000
ETag: W/"a"
```

```js
{
  "resourceType": "Basic",
  "id": "1000",
  "meta": {"versionId": "a"},
  "subject": {"reference": "https://ehr.example.org/fhir/Practitioner/123"},
  ...<snipped for brevity>
```

To query for these data, an app could invoke the following operation (newlines added for clarity):

```
GET /Basic
  subject=https://ehr.example.org/fhir/Practitioner/123&
  code=https://myapp.example.org|display-preferences

Authorization: Bearer <snipped>
```

... which returns a Bundle including the "Example 1" payload.

#### Example 2: Access Keys to an external data set

The following `POST` body shows how an app might persist access keys for an externally managed encrypted data set:

```
POST /Basic

Authorization: Bearer <snipped>
```

```js
{
  "resourceType": "Basic",
  "subject": {"reference": "https://ehr.example.org/fhir/Patient/123"},
  "code": {
    "coding": [
      // app-specific designation; the EHR does not need to understand
      // the meaning of this concept, but SHALL persist it and MAY
      // use it for access control (e.g., using SMART on FHIR scopes
      // or other controls; see below)
      { 
        "system": "https://myapp.example.org",
        "code": "encrypted-phr-access-keys"
      }
    ]
  },
  "extension": [
    // app-managed state; the EHR does not need to understand
    // the meaning of these values, but SHALL persist them
    {
      "url": "https://myapp.example.org/encrypted-phr-access-keys",
      "valueString": "eyJhbGciOiJSU0EtT0FFUCIsImVuYyI6IkEyNTZH...<snipped>"
    }
  ]
}
```

The EHR responds with a Basic resource representing the new SMART App State
object as it has been persisted. The API response populates `id` and
`meta.versionId`, like:

```
Location: https://ehr.example.org/appstate/Basic/1001
ETag: W/"a"
```

```js
{
  "resourceType": "Basic",
  "id": "1001",
  "meta": {"versionId": "a"},
  "subject": {"reference": "https://ehr.example.org/fhir/Practitioner/123"},
  ...<snipped for brevity>
```

#### Example 3: Updating the Access Keys from Example 2

The following `POST` body shows how an app might update persisted access keys for an externally managed encrypted data set, based on the response to Example 2.


```
PUT /Basic/1001

Authorization: Bearer <snipped>
If-Match: W/"a"
```

```js
{
  "resourceType": "Basic",
  "id": "1001",
  "subject": {"reference": "https://ehr.example.org/fhir/Patient/123"},
  "code": {
    "coding": [
      { 
        "system": "https://myapp.example.org",
        "code": "encrypted-phr-access-keys"
      }
    ]
  },
  "extension": [
    {
      "url": "https://myapp.example.org/encrypted-phr-access-keys",
      "valueString": "eyJhbGc<updated value, snipped>"
    }
  ]
}
```

The EHR responds with a Basic resource representing the updated SMART App State object as it has been persisted. The API response includes an updated `meta.versionId`, like:

```js
{
  "resourceType": "Basic",
  "id": "1001",
  "meta": {"versionId": "b"},
  ...<snipped for brevity>
```


#### Example 4: Deleting the Access Keys from Example 3

The following `POST` body shows how an app might delete persisted access keys for an externally managed encrypted data set, based on the response to Example 3.


```
DELETE /Basic/1001

Authorization: Bearer <snipped>
If-Match: W/"b"
```

```js
{
  "resourceType": "Basic",
  "id": "1001",
  "subject": {"reference": "Patient/123"},
  "code": {
    "coding": [
      { 
        "system": "https://myapp.example.org",
        "code": "encrypted-phr-access-keys"
      }
    ]
  }
}
```

The EHR responds with a `200 OK` or `204 No Content` message to indicate a successful deletion.

### Security and Access controls


Apps SHALL NOT use data from `Extension.valueString` without validating or
sanitizing the data first. In other words, app developers need to consider a
threat model where App State values have been populated with arbitrary content.
(Note that EHRs are expected to simply store and return such data unmodified,
without "using" the data.)

The EHR SHALL enforce access controls to ensure that only authorized apps are
able to perform the FHIR interactions described above. From the app's
perspective, these operations are invoked using a SMART on FHIR access token in
an Authorization header. Every App State request SHALL include an Authorization
header with an access token issued by the EHR's authorization server. 

This means the EHR tracks (e.g., in some internal, implementation-specific
format) sets of `Coding`s representing the SMART App State types (i.e.,
`Basic.code.coding`) that the app is allowed to

  * query, when the subject is the in-context patient
  * modify, when the subject is the in-context patient
  * query, when the subject is the in-context app user
  * modify, when the subject is the in-context app user
  * query, with `subject:missing=true` (for global app config)
  * modify, with `subject:missing=true` (for global app config)

EHRs SHALL only associate state codes with an app if the app is trusted to access
those data. These decisions can be made out-of-band during or after the app
registration process. A recommended default is to allow apps to register only
state codes where the `system` matches the app's verified origin. For instance,
if the EHR has verified that the app developer manages the origin
`https://app.example.org`, the app could be associated with SMART App State
types like `https://app.example.org|user-preferences` or
`https://app.exmample.org|phr-keys`. If an app requires access to other App
State types, these could be reviewed through an out-of-band process. This
situation is expected when one developer supplies a patient-facing app and
another developer supplies a provider-facing "companion app" that needs to
query state written by the patient-facing app.

Further consideration is required when granting an app the ability to modify
global app state (i.e., where `Basic.subject` is absent). Such permissions
should be limited to administrative apps. See section [global app
configuration](#global-app-configuration).

Where appropriate, the EHR MAY expose these controls using SMART scopes as follows.

#### Granting access at the user level

An app writing user-specific state (e.g., user preferences) or writing patient-specific state on behalf of an authorized user can request SMART scopes like:

    user/Basic.cuds // query and modify state

This scope would allow the app to manage any app state that the user is permitted to manage. Note that without further refinement, this scope could allow an app to see and manage app state from *other apps* in addition to its own. This can be a useful behavior in scenarios where sets of apps have a mutual understanding of certain state values (e.g. a suite of apps offered by a single developer). 

#### Granting access at the patient level

An app writing patient-specific state (e.g., access keys for an externally managed encrypted data set) can request a SMART scope like:

    patient/Basic.cuds // query and modify state

This scope would allow the app to manage any app state that the user is
permitted to manage on the in-context patient record. Note that without further
refinement, this scope could allow an app to see and manage app state written
by *other apps*. This can be a useful behavior in scenarios where sets of apps
have a mutual understanding of certain state values (e.g., a patient-facing
mobile app that creates an encrypted data payload and a provider-facing
"companion app" that decrypts and displays the data set within the EHR). 

For the scenario of a patient-facing mobile app that works in tandem with
provider-facing "companion app" in the EHR, scopes can be narrowed to better
reflect minimum necessary access (note the use of more specific codes).

##### Patient-facing mobile app

    patient/Basic.cuds?code=https://myapp.example.org|encrypted-phr-access-keys

##### Provider-facing "companion app" in the EHR

    patient/Basic.s?code=https://myapp.example.org|encrypted-phr-access-keys

#### Global app configuration

Some apps might leverage "global" (i.e., hospital-wide) state stored in the
EHR. Such access could be requested for an administrative end-user with scopes
of the form:

    user/Basic.cuds // query and modify global app state
    user/Basic.s // query global app state

For example, a family of apps could be deployed with read access to a
"configuration" state type, with a management app authorized to modify this
state type. Using this pattern, a local site administrator could establish
settings across the family of apps.

A management app might create such hospital-defined configuration with:

    user/Basic.cuds?code=https://myapp.example.org|hospital-config

And the related family of apps installed at a hospital might access such
hospital-defined configuration with:

    user/Basic.s?code=https://myapp.example.org|hospital-config

#### Explaining access controls to end users

In the case of user-facing authorization interactions (e.g., for a
patient-facing SMART App), it's important to ensure that such scopes can be
explained in plain language. For example, it is important to explain to users
that any information their app submits to the EHR may be considered part of the
health record and may be accessible to their healthcare provider team. To
support authorization, EHRs may need to gather additional information from app
developers at registration time with explanations, or may apply additional
protections to facilitate access control decisions. 

#### Implementation considerations for EHRs

EHRs can implement support for `smart-app-state` using their internal resource
server infrastructure, or can deploy a decoupled resource server that
communicates with the EHR authorization server using [SMART on FHIR Token
Introspection](token-introspection.html), signed tokens, or some other
mechanism. While some access control decisions can be made directly based on
standardized scopes, other decisions may require additional policy information.
See ["scopes are used to delegate
access"](scopes-and-launch-context.html#smarts-scopes-are-used-to-delegate-access)
for background on this point.

Consider the following examples:

* a token granting `patient/Basic.s?code=https://app|1` with a context of
  `"patient": "a"` would be authorized to query
  `Basic?subject=Patient/a&code=https://app|1`

* a token granting `user/Basic.s?code=https://app|1` with a context of
  `"fhirUser": "Practitioner/b"` would be authorized to query
  `Basic?subject=Practitioner/b&code=https://app|1`

* a token granting `user/Basic.s?code=https://app|1` with no patient context
  and a user context of `"fhirUser": "Practitioner/b"` would require additional
  policy information to decide whether to allow
  `Basic?subject=Patient/a&code=https://app|1`. A server MAY simply reject
  queries like this as unauthorized, while still supporting many use cases. To
  properly authorize this request, a resource server would need to determine
  whether EHR policy allows Practitioner B to access Patient A's records. Such
  policy information could be static (e.g., a simple system could maintain a
  policy like "all Practitioner users can access all patient records") or
  dynamically available in EHR-specific ways such as FHIR Groups, CareTeams,
  PractitionerRoles, or non-FHIR APIs such as
  [SCIM](https://www.simplecloud.info/) or others. Such policy details are
  beyond the scope of SMART on FHIR.

### Design Notes

Implementers may wonder why the SMART App State capability defines a FHIR Base
URL that might be distinct from the EHR's main FHIR base URL. During the design
and prototype phase, implementers identified requirements that led to this
design:

* Ensure that EHRs can identify App State requests via path-based HTTP request
  evaluation. This allows EHRs to route App State requests to a purpose-built
  underlying service. Such identification is not possible when the only path
  information is `/Basic` (e.g., for `POST /Basic` on the EHR's main FHIR
  endpoint), since non-App-State CRUD operations on `Basic` would use this same
  path. Providing the option for a distinct FHIR base URL allows EHRs to
  establish predictable and distinct paths when this is desirable.

* Ensure that App State can be persisted separately from other `Basic`
  resources managed by the EHR. This stems from the fact that App State is
  essentially opaque to the EHR and should not be returned in general-purpose
  queries for `Basic` content (which may be used to surface first-class EHR
  concepts).
## 'Task profile for requesting SMART launch (Experimental)'

This section defines a set of profiles of the FHIR Task resource that requests launch of a SMART application. These tasks could be used to recommend an application for staff to launch, e.g. as a result of a Clinical Reasoning deployment.

Two profiles are defined:

* [task-ehr-launch](StructureDefinition-task-ehr-launch.html), requests an EHR launch with optional appContext.
* [task-standalone-launch](StructureDefinition-task-standalone-launch.html), requests a standalone launch.

### Requesting an EHR launch

A Task with the profile [task-ehr-launch](StructureDefinition-task-ehr-launch.html), requests an EHR launch with optional `appContext`.

The `Task.for` field, if present indicates the Patient resource to be used in the launch context.

the `Task.encounter` field, if present indicates the Encounter resource to be used in the launch context.
 
The input field contains:

* the url of the application to be launched
* optional appContext to be included in the token response as is specified in a [CDShooks Link](https://cds-hooks.org/specification/current/#link)

An example of such Task is presented below: 

```js
{
  "resourceType": "Task",
  "id": "task-for-ehr-launch",
  "status": "requested",
  "intent": "proposal",
  "code": {
    "coding": [{
      "system": "http://hl7.org/fhir/smart-app-launch/CodeSystem/smart-codes",
      "code": "launch-app-ehr",
      "display": "Launch application using the SMART EHR launch"
    }]
  },
  "for": {"reference": "https://example.org/fhir/Patient/123"},
  "encounter": {"reference": "https://example.org/fhir/Encounter/456"},
  "input": [
  {
    "type": {
        "coding":[{
          "system": "http://hl7.org/fhir/smart-app-launch/CodeSystem/smart-codes",
          "code": "smartonfhir-application",
          "display": "SMART on FHIR application URL."
        }]
    },
    "valueUrl": "https://www.example.org/myapplication"
  },
  {
    "type": {
        "coding":[{
          "system": "http://hl7.org/fhir/smart-app-launch/CodeSystem/smart-codes",
          "code": "smartonfhir-appcontext",
          "display": "Application context related to this launch."
        }]
    },
    "valueString": "{\"field1\":\"value\"}"
  }
```

### Requesting an standalone launch

A Task according to the profile [task-standalone-launch](StructureDefinition-task-standalone-launch.html), requests an standalone launch.

The input field contains:

* the url of the application to be launched

An example of such Task is presented below: 

```js
{
  "resourceType": "Task",
  "id": "task-for-standalone-launch",
  "status": "requested",
  "intent": "proposal",
  "code": 
  {
    "coding": [{
      "system": "http://hl7.org/fhir/smart-app-launch/CodeSystem/smart-codes",
      "code": "launch-app-standalone",
      "display": "Launch application using the SMART standalone launch"
    }]
  },
  "for": {"reference": "https://example.org/fhir/Patient/123"},
  "encounter": {"reference": "https://example.org/fhir/Encounter/456"},
  "input": [
  {
    "type": {
        "coding":[{
          "system": "http://hl7.org/fhir/smart-app-launch/CodeSystem/smart-codes",
          "code": "smartonfhir-application",
          "display": "SMART on FHIR application URL."
        }]
    },
    "valueUrl": "https://www.example.org/myapplication"
  }]
}
```
## Examples

These examples demonstrate various aspects of SMART on FHIR.

* [Launch a Public client](example-app-launch-public.html)
* [Launch a Confidential client using asymmetric authentication](example-app-launch-asymmetric-auth.html)
* [Launch a Confidential client using symmetric authentication](example-app-launch-symmetric-auth.html)
* [Backend Services](example-backend-services.html)
* [Id Token](worked_example_id_token.html)
* [JWS generation for Asymmetric Client Auth](authorization-example-jwks-and-signatures.html)
## Example App Launch for Public Client

<a id="step-2-launch"></a>

### Launch App
This is a user-driven step triggering the subsequent workflow.

In this example, the launch is initiated against a FHIR server with a base URL of:

    https://smart.argo.run/v/r4/sim/eyJtIjoiMSIsImsiOiIxIiwiaSI6IjEiLCJqIjoiMSIsImIiOiI4N2EzMzlkMC04Y2FlLTQxOGUtODljNy04NjUxZTZhYWIzYzYifQ/fhir

... and the app's redirect URL has been registered as:

    https://sharp-lake-word.glitch.me/graph.html

... and the app has been registered as a public client, assigned a `client_id` of:

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

Prepare arguments for POST to token API (newlines added for clarity):

```
client_id=demo_app_whatever&
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
  --data-raw 'client_id=demo_app_whatever&code=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb250ZXh0Ijp7Im5lZWRfcGF0aWVudF9iYW5uZXIiOnRydWUsInNtYXJ0X3N0eWxlX3VybCI6Imh0dHBzOi8vc21hcnQuYXJnby5ydW4vL3NtYXJ0LXN0eWxlLmpzb24iLCJwYXRpZW50IjoiODdhMzM5ZDAtOGNhZS00MThlLTg5YzctODY1MWU2YWFiM2M2In0sImNsaWVudF9pZCI6ImRlbW9fYXBwX3doYXRldmVyIiwiY29kZV9jaGFsbGVuZ2VfbWV0aG9kIjoiUzI1NiIsImNvZGVfY2hhbGxlbmdlIjoiWVBYZTdCOGdoS3JqOFBzVDRMNmx0dXBnSTEyTlFKNXZibEIwN0Y0ckdhdyIsInNjb3BlIjoibGF1bmNoL3BhdGllbnQgcGF0aWVudC9PYnNlcnZhdGlvbi5ycyBwYXRpZW50L1BhdGllbnQucnMiLCJyZWRpcmVjdF91cmkiOiJodHRwczovL3NoYXJwLWxha2Utd29yZC5nbGl0Y2gubWUvZ3JhcGguaHRtbCIsImlhdCI6MTYzMzUzMjAxNCwiZXhwIjoxNjMzNTMyMzE0fQ.xilM68Bavtr9IpklYG-j96gTxAda9r4Z_boe2zv3A3E&grant_type=authorization_code&redirect_uri=https%3A%2F%2Fsharp-lake-word.glitch.me%2Fgraph.html&code_verifier=o28xyrYY7-lGYfnKwRjHEZWlFIPlzVnFPYMWbH-g_BsNnQNem-IAg9fDh92X0KtvHCPO5_C-RJd2QhApKQ-2cRp-S_W3qmTidTEPkeWyniKQSF9Q_k10Q5wMc8fGzoyF'


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

Prepare arguments for POST to token API (newlines added for clarity)

```
client_id=demo_app_whatever&
grant_type=refresh_token&
refresh_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb250ZXh0Ijp7Im5lZWRfcGF0aWVudF9iYW5uZXIiOnRydWUsInNtYXJ0X3N0eWxlX3VybCI6Imh0dHBzOi8vc21hcnQuYXJnby5ydW4vL3NtYXJ0LXN0eWxlLmpzb24iLCJwYXRpZW50IjoiODdhMzM5ZDAtOGNhZS00MThlLTg5YzctODY1MWU2YWFiM2M2In0sImNsaWVudF9pZCI6ImRlbW9fYXBwX3doYXRldmVyIiwic2NvcGUiOiJsYXVuY2gvcGF0aWVudCBwYXRpZW50L09ic2VydmF0aW9uLnJzIHBhdGllbnQvUGF0aWVudC5ycyBvZmZsaW5lX2FjY2VzcyIsImlhdCI6MTYzMzUzMzg1OSwiZXhwIjoxNjY1MDY5ODU5fQ.Q41QwZCEQlZ16M7YwvYuVbUP03mRFJoqRxL8SS8_ImM&
```


```
curl 'https://smart.argo.run/v/r4/sim/eyJtIjoiMSIsImsiOiIxIiwiaSI6IjEiLCJqIjoiMSIsImIiOiI4N2EzMzlkMC04Y2FlLTQxOGUtODljNy04NjUxZTZhYWIzYzYifQ/auth/token' \
  -H 'accept: application/json' \
  -H 'content-type: application/x-www-form-urlencoded' \
  --data-raw 'client_id=demo_app_whatever&code=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb250ZXh0Ijp7Im5lZWRfcGF0aWVudF9iYW5uZXIiOnRydWUsInNtYXJ0X3N0eWxlX3VybCI6Imh0dHBzOi8vc21hcnQuYXJnby5ydW4vL3NtYXJ0LXN0eWxlLmpzb24iLCJwYXRpZW50IjoiODdhMzM5ZDAtOGNhZS00MThlLTg5YzctODY1MWU2YWFiM2M2In0sImNsaWVudF9pZCI6ImRlbW9fYXBwX3doYXRldmVyIiwiY29kZV9jaGFsbGVuZ2VfbWV0aG9kIjoiUzI1NiIsImNvZGVfY2hhbGxlbmdlIjoieFFzdkN5c2FMbEZvVkU5ZV92MTFiWmNwUlR6RW5wVnIzY2c2VTJYeFpFbyIsInNjb3BlIjoibGF1bmNoL3BhdGllbnQgcGF0aWVudC9PYnNlcnZhdGlvbi5ycyBwYXRpZW50L1BhdGllbnQucnMiLCJyZWRpcmVjdF91cmkiOiJodHRwczovL3NoYXJwLWxha2Utd29yZC5nbGl0Y2gubWUvZ3JhcGguaHRtbCIsImlhdCI6MTYzMzUzMzY1NCwiZXhwIjoxNjMzNTMzOTU0fQ.ovs8WkW7ViCvoiTGJXxWb21OtiJfUmwgXwkt3a1gNRc&grant_type=authorization_code'

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
## Example App Launch for Asymmetric Client Auth

<a id="step-2-launch"></a>

### Launch App
This is a user-driven step triggering the subsequent workflow.

In this example, the launch is initiated against a FHIR server with a base URL of:

    https://smart.argo.run/v/r4/sim/eyJtIjoiMSIsImsiOiIxIiwiaSI6IjEiLCJqIjoiMSIsImIiOiI4N2EzMzlkMC04Y2FlLTQxOGUtODljNy04NjUxZTZhYWIzYzYifQ/fhir

... and the app's redirect URL has been registered as:

    https://sharp-lake-word.glitch.me/graph.html

... and the app's public key has been registered as:
```
{
  "kty": "EC",
  "crv": "P-384",
  "x": "wcE8O55ro6aOuTf5Ty1k_IG4mTcuLiVercHouge1G5Ri-leevhev4uJzlHpi3U8r",
  "y": "mLRgz8Giu6XA_AqG8bywqbygShmd8jowflrdx0KQtM5X4s4aqDeCRfcpexykp3aI",
  "kid": "afb27c284f2d93959c18fa0320e32060",
  "alg": "ES384",
}
```

(For reproducibility: the corresponding private key parameter `"d"` is `"WcrTiYk8jbI-Sd1sKNpqGmELWGG08bf_y9SSlnC4cpAl5GRdHHN9gKYlPvMFqiJ5"`. This would not be shared in a real-world registration scenario.)

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

Generate a client authentication assertion and prepare arguments for POST to token API (newlines added for clarity):

```
code=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb250ZXh0Ijp7Im5lZWRfcGF0aWVudF9iYW5uZXIiOnRydWUsInNtYXJ0X3N0eWxlX3VybCI6Imh0dHBzOi8vc21hcnQuYXJnby5ydW4vL3NtYXJ0LXN0eWxlLmpzb24iLCJwYXRpZW50IjoiODdhMzM5ZDAtOGNhZS00MThlLTg5YzctODY1MWU2YWFiM2M2In0sImNsaWVudF9pZCI6ImRlbW9fYXBwX3doYXRldmVyIiwiY29kZV9jaGFsbGVuZ2VfbWV0aG9kIjoiUzI1NiIsImNvZGVfY2hhbGxlbmdlIjoiWVBYZTdCOGdoS3JqOFBzVDRMNmx0dXBnSTEyTlFKNXZibEIwN0Y0ckdhdyIsInNjb3BlIjoibGF1bmNoL3BhdGllbnQgcGF0aWVudC9PYnNlcnZhdGlvbi5ycyBwYXRpZW50L1BhdGllbnQucnMiLCJyZWRpcmVjdF91cmkiOiJodHRwczovL3NoYXJwLWxha2Utd29yZC5nbGl0Y2gubWUvZ3JhcGguaHRtbCIsImlhdCI6MTYzMzUzMjAxNCwiZXhwIjoxNjMzNTMyMzE0fQ.xilM68Bavtr9IpklYG-j96gTxAda9r4Z_boe2zv3A3E&
grant_type=authorization_code&
redirect_uri=https%3A%2F%2Fsharp-lake-word.glitch.me%2Fgraph.html&
client_assertion_type=urn%3Aietf%3Aparams%3Aoauth%3Aclient-assertion-type%3Ajwt-bearer&
client_assertion=eyJ0eXAiOiJKV1QiLCJraWQiOiJhZmIyN2MyODRmMmQ5Mzk1OWMxOGZhMDMyMGUzMjA2MCIsImFsZyI6IkVTMzg0In0.eyJpc3MiOiJkZW1vX2FwcF93aGF0ZXZlciIsInN1YiI6ImRlbW9fYXBwX3doYXRldmVyIiwiYXVkIjoiaHR0cHM6Ly9zbWFydC5hcmdvLnJ1bi92L3I0L3NpbS9leUp0SWpvaU1TSXNJbXNpT2lJeElpd2lhU0k2SWpFaUxDSnFJam9pTVNJc0ltSWlPaUk0TjJFek16bGtNQzA0WTJGbExUUXhPR1V0T0Rsak55MDROalV4WlRaaFlXSXpZellpZlEvYXV0aC90b2tlbiIsImp0aSI6ImQ4MDJiZDcyY2ZlYTA2MzVhM2EyN2IwODE3YjgxZTQxZTBmNzQzMzE4MTg4OTM4YjAxMmMyMDM2NmJkZmU4YTEiLCJleHAiOjE2MzM1MzIxMzR9.eHUtXmppOLIMAfBM4mFpcgJ90bDNYWQpkm7--yRS2LY5HoXwr3FpqHMTrjhK60r5kgYGFg6v9IQaUFKFpn1N2Eyty62JWxvGXRlgEDbdX9wAAr8TeWnsAT_2orfpn6wz&
code_verifier=o28xyrYY7-lGYfnKwRjHEZWlFIPlzVnFPYMWbH-g_BsNnQNem-IAg9fDh92X0KtvHCPO5_C-RJd2QhApKQ-2cRp-S_W3qmTidTEPkeWyniKQSF9Q_k10Q5wMc8fGzoyF
```


Issue POST to the token endpoint:

```
curl 'https://smart.argo.run/v/r4/sim/eyJtIjoiMSIsImsiOiIxIiwiaSI6IjEiLCJqIjoiMSIsImIiOiI4N2EzMzlkMC04Y2FlLTQxOGUtODljNy04NjUxZTZhYWIzYzYifQ/auth/token' \
  -H 'accept: application/json' \
  -H 'content-type: application/x-www-form-urlencoded' \
  --data-raw 'code=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb250ZXh0Ijp7Im5lZWRfcGF0aWVudF9iYW5uZXIiOnRydWUsInNtYXJ0X3N0eWxlX3VybCI6Imh0dHBzOi8vc21hcnQuYXJnby5ydW4vL3NtYXJ0LXN0eWxlLmpzb24iLCJwYXRpZW50IjoiODdhMzM5ZDAtOGNhZS00MThlLTg5YzctODY1MWU2YWFiM2M2In0sImNsaWVudF9pZCI6ImRlbW9fYXBwX3doYXRldmVyIiwiY29kZV9jaGFsbGVuZ2VfbWV0aG9kIjoiUzI1NiIsImNvZGVfY2hhbGxlbmdlIjoiWVBYZTdCOGdoS3JqOFBzVDRMNmx0dXBnSTEyTlFKNXZibEIwN0Y0ckdhdyIsInNjb3BlIjoibGF1bmNoL3BhdGllbnQgcGF0aWVudC9PYnNlcnZhdGlvbi5ycyBwYXRpZW50L1BhdGllbnQucnMiLCJyZWRpcmVjdF91cmkiOiJodHRwczovL3NoYXJwLWxha2Utd29yZC5nbGl0Y2gubWUvZ3JhcGguaHRtbCIsImlhdCI6MTYzMzUzMjAxNCwiZXhwIjoxNjMzNTMyMzE0fQ.xilM68Bavtr9IpklYG-j96gTxAda9r4Z_boe2zv3A3E&grant_type=authorization_code&redirect_uri=https%3A%2F%2Fsharp-lake-word.glitch.me%2Fgraph.html&client_assertion_type=urn%3Aietf%3Aparams%3Aoauth%3Aclient-assertion-type%3Ajwt-bearer&client_assertion=eyJ0eXAiOiJKV1QiLCJraWQiOiJhZmIyN2MyODRmMmQ5Mzk1OWMxOGZhMDMyMGUzMjA2MCIsImFsZyI6IkVTMzg0In0.eyJpc3MiOiJkZW1vX2FwcF93aGF0ZXZlciIsInN1YiI6ImRlbW9fYXBwX3doYXRldmVyIiwiYXVkIjoiaHR0cHM6Ly9zbWFydC5hcmdvLnJ1bi92L3I0L3NpbS9leUp0SWpvaU1TSXNJbXNpT2lJeElpd2lhU0k2SWpFaUxDSnFJam9pTVNJc0ltSWlPaUk0TjJFek16bGtNQzA0WTJGbExUUXhPR1V0T0Rsak55MDROalV4WlRaaFlXSXpZellpZlEvYXV0aC90b2tlbiIsImp0aSI6ImQ4MDJiZDcyY2ZlYTA2MzVhM2EyN2IwODE3YjgxZTQxZTBmNzQzMzE4MTg4OTM4YjAxMmMyMDM2NmJkZmU4YTEiLCJleHAiOjE2MzM1MzIxMzR9.eHUtXmppOLIMAfBM4mFpcgJ90bDNYWQpkm7--yRS2LY5HoXwr3FpqHMTrjhK60r5kgYGFg6v9IQaUFKFpn1N2Eyty62JWxvGXRlgEDbdX9wAAr8TeWnsAT_2orfpn6wz&code_verifier=o28xyrYY7-lGYfnKwRjHEZWlFIPlzVnFPYMWbH-g_BsNnQNem-IAg9fDh92X0KtvHCPO5_C-RJd2QhApKQ-2cRp-S_W3qmTidTEPkeWyniKQSF9Q_k10Q5wMc8fGzoyF'


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
client_assertion_type=urn%3Aietf%3Aparams%3Aoauth%3Aclient-assertion-type%3Ajwt-bearer&
client_assertion=eyJ0eXAiOiJKV1QiLCJraWQiOiJhZmIyN2MyODRmMmQ5Mzk1OWMxOGZhMDMyMGUzMjA2MCIsImFsZyI6IkVTMzg0In0.eyJpc3MiOiJkZW1vX2FwcF93aGF0ZXZlciIsInN1YiI6ImRlbW9fYXBwX3doYXRldmVyIiwiYXVkIjoiaHR0cHM6Ly9zbWFydC5hcmdvLnJ1bi92L3I0L3NpbS9leUp0SWpvaU1TSXNJbXNpT2lJeElpd2lhU0k2SWpFaUxDSnFJam9pTVNJc0ltSWlPaUk0TjJFek16bGtNQzA0WTJGbExUUXhPR1V0T0Rsak55MDROalV4WlRaaFlXSXpZellpZlEvYXV0aC90b2tlbiIsImp0aSI6IjJmZjBhNzlmNzVkN2FiZmVhMDdkYTg2ZWZkOGQ2NWM5NGVmY2M5YzQ2MDNiNmExZGQwODMwOGExYjEyMWVmZTAiLCJleHAiOjE2MzM1MzM3NzV9.MGw_W9EMJ1dYjmXZ6piel5-mHMusBUtZ6E5aLAZeXJXG-3PF5Ruqpq90NKXM4JP2R9t0AhCna2gGTX2XFGZT0HtxUXt08xprcWbRzz4EIu2sZsXspVf8Y5JDqtwQh3MU
```


```
curl 'https://smart.argo.run/v/r4/sim/eyJtIjoiMSIsImsiOiIxIiwiaSI6IjEiLCJqIjoiMSIsImIiOiI4N2EzMzlkMC04Y2FlLTQxOGUtODljNy04NjUxZTZhYWIzYzYifQ/auth/token' \
  -H 'accept: application/json' \
  -H 'content-type: application/x-www-form-urlencoded' \
  --data-raw 'code=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb250ZXh0Ijp7Im5lZWRfcGF0aWVudF9iYW5uZXIiOnRydWUsInNtYXJ0X3N0eWxlX3VybCI6Imh0dHBzOi8vc21hcnQuYXJnby5ydW4vL3NtYXJ0LXN0eWxlLmpzb24iLCJwYXRpZW50IjoiODdhMzM5ZDAtOGNhZS00MThlLTg5YzctODY1MWU2YWFiM2M2In0sImNsaWVudF9pZCI6ImRlbW9fYXBwX3doYXRldmVyIiwiY29kZV9jaGFsbGVuZ2VfbWV0aG9kIjoiUzI1NiIsImNvZGVfY2hhbGxlbmdlIjoieFFzdkN5c2FMbEZvVkU5ZV92MTFiWmNwUlR6RW5wVnIzY2c2VTJYeFpFbyIsInNjb3BlIjoibGF1bmNoL3BhdGllbnQgcGF0aWVudC9PYnNlcnZhdGlvbi5ycyBwYXRpZW50L1BhdGllbnQucnMiLCJyZWRpcmVjdF91cmkiOiJodHRwczovL3NoYXJwLWxha2Utd29yZC5nbGl0Y2gubWUvZ3JhcGguaHRtbCIsImlhdCI6MTYzMzUzMzY1NCwiZXhwIjoxNjMzNTMzOTU0fQ.ovs8WkW7ViCvoiTGJXxWb21OtiJfUmwgXwkt3a1gNRc&grant_type=authorization_code&client_assertion_type=urn%3Aietf%3Aparams%3Aoauth%3Aclient-assertion-type%3Ajwt-bearer&client_assertion=eyJ0eXAiOiJKV1QiLCJraWQiOiJhZmIyN2MyODRmMmQ5Mzk1OWMxOGZhMDMyMGUzMjA2MCIsImFsZyI6IkVTMzg0In0.eyJpc3MiOiJkZW1vX2FwcF93aGF0ZXZlciIsInN1YiI6ImRlbW9fYXBwX3doYXRldmVyIiwiYXVkIjoiaHR0cHM6Ly9zbWFydC5hcmdvLnJ1bi92L3I0L3NpbS9leUp0SWpvaU1TSXNJbXNpT2lJeElpd2lhU0k2SWpFaUxDSnFJam9pTVNJc0ltSWlPaUk0TjJFek16bGtNQzA0WTJGbExUUXhPR1V0T0Rsak55MDROalV4WlRaaFlXSXpZellpZlEvYXV0aC90b2tlbiIsImp0aSI6IjJmZjBhNzlmNzVkN2FiZmVhMDdkYTg2ZWZkOGQ2NWM5NGVmY2M5YzQ2MDNiNmExZGQwODMwOGExYjEyMWVmZTAiLCJleHAiOjE2MzM1MzM3NzV9.MGw_W9EMJ1dYjmXZ6piel5-mHMusBUtZ6E5aLAZeXJXG-3PF5Ruqpq90NKXM4JP2R9t0AhCna2gGTX2XFGZT0HtxUXt08xprcWbRzz4EIu2sZsXspVf8Y5JDqtwQh3MU'

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
## Example App Launch for Symmetric Client Auth

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
## Example Backend Services Flow

<a id="step-2-discovery"></a>

### Retrieve .well-known/smart-configuration

```sh
curl -s 'https://smart.argo.run/v/r4/sim/eyJtIjoiMSIsImsiOiIxIiwiaSI6IjEiLCJqIjoiMSIsImIiOiI4N2EzMzlkMC04Y2FlLTQxOGUtODljNy04NjUxZTZhYWIzYzYifQ/fhir/.well-known/smart-configuration' \
  -H 'accept: application/json'

{
  "token_endpoint": "https://smart.argo.run/v/r4/sim/eyJtIjoiMSIsImsiOiIxIiwiaSI6IjEiLCJqIjoiMSIsImIiOiI4N2EzMzlkMC04Y2FlLTQxOGUtODljNy04NjUxZTZhYWIzYzYifQ/auth/token",
  "grant_types_supported": [
    "client_credentials"
  ],
  "token_endpoint_auth_methods_supported": [
    "private_key_jwt",
  ],
  "token_endpoint_auth_signing_alg_values_supported": [
    "RS384",
    "ES384"
  ],
  "scopes_supported": [
    "system/*.rs"
  ],
  "capabilities": [
    "client-confidential-asymmetric",
    "permission-v2",
  ]
}
```


<a id="step-3-access-token"></a>

### Retrieve access token

Generate a client authentication assertion and prepare arguments for POST to token API (newlines added for clarity):

```
grant_type=client_credentials&
scope=system%2F*.rs&
client_assertion_type=urn%3Aietf%3Aparams%3Aoauth%3Aclient-assertion-type%3Ajwt-bearer&
client_assertion=eyJ0eXAiOiJKV1QiLCJraWQiOiJhZmIyN2MyODRmMmQ5Mzk1OWMxOGZhMDMyMGUzMjA2MCIsImFsZyI6IkVTMzg0In0.eyJpc3MiOiJkZW1vX2FwcF93aGF0ZXZlciIsInN1YiI6ImRlbW9fYXBwX3doYXRldmVyIiwiYXVkIjoiaHR0cHM6Ly9zbWFydC5hcmdvLnJ1bi92L3I0L3NpbS9leUp0SWpvaU1TSXNJbXNpT2lJeElpd2lhU0k2SWpFaUxDSnFJam9pTVNJc0ltSWlPaUk0TjJFek16bGtNQzA0WTJGbExUUXhPR1V0T0Rsak55MDROalV4WlRaaFlXSXpZellpZlEvYXV0aC90b2tlbiIsImp0aSI6ImQ4MDJiZDcyY2ZlYTA2MzVhM2EyN2IwODE3YjgxZTQxZTBmNzQzMzE4MTg4OTM4YjAxMmMyMDM2NmJkZmU4YTEiLCJleHAiOjE2MzM1MzIxMzR9.eHUtXmppOLIMAfBM4mFpcgJ90bDNYWQpkm7--yRS2LY5HoXwr3FpqHMTrjhK60r5kgYGFg6v9IQaUFKFpn1N2Eyty62JWxvGXRlgEDbdX9wAAr8TeWnsAT_2orfpn6wz
```


Issue POST to the token endpoint:

```
curl 'https://smart.argo.run/v/r4/sim/eyJtIjoiMSIsImsiOiIxIiwiaSI6IjEiLCJqIjoiMSIsImIiOiI4N2EzMzlkMC04Y2FlLTQxOGUtODljNy04NjUxZTZhYWIzYzYifQ/auth/token' \
  -H 'accept: application/json' \
  -H 'content-type: application/x-www-form-urlencoded' \
  --data-raw 'grant_type=client_credentials&scope=system%2F*.rs&client_assertion_type=urn%3Aietf%3Aparams%3Aoauth%3Aclient-assertion-type%3Ajwt-bearer&client_assertion=eyJ0eXAiOiJKV1QiLCJraWQiOiJhZmIyN2MyODRmMmQ5Mzk1OWMxOGZhMDMyMGUzMjA2MCIsImFsZyI6IkVTMzg0In0.eyJpc3MiOiJkZW1vX2FwcF93aGF0ZXZlciIsInN1YiI6ImRlbW9fYXBwX3doYXRldmVyIiwiYXVkIjoiaHR0cHM6Ly9zbWFydC5hcmdvLnJ1bi92L3I0L3NpbS9leUp0SWpvaU1TSXNJbXNpT2lJeElpd2lhU0k2SWpFaUxDSnFJam9pTVNJc0ltSWlPaUk0TjJFek16bGtNQzA0WTJGbExUUXhPR1V0T0Rsak55MDROalV4WlRaaFlXSXpZellpZlEvYXV0aC90b2tlbiIsImp0aSI6ImQ4MDJiZDcyY2ZlYTA2MzVhM2EyN2IwODE3YjgxZTQxZTBmNzQzMzE4MTg4OTM4YjAxMmMyMDM2NmJkZmU4YTEiLCJleHAiOjE2MzM1MzIxMzR9.eHUtXmppOLIMAfBM4mFpcgJ90bDNYWQpkm7--yRS2LY5HoXwr3FpqHMTrjhK60r5kgYGFg6v9IQaUFKFpn1N2Eyty62JWxvGXRlgEDbdX9wAAr8TeWnsAT_2orfpn6wz'


{
  "token_type": "Bearer",
  "scope": "system/*.rs",
  "expires_in": 3600,
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuZWVkX3BhdGllbnRfYmFubmVyIjp0cnVlLCJzbWFydF9zdHlsZV91cmwiOiJodHRwczovL3NtYXJ0LmFyZ28ucnVuLy9zbWFydC1zdHlsZS5qc29uIiwicGF0aWVudCI6Ijg3YTMzOWQwLThjYWUtNDE4ZS04OWM3LTg2NTFlNmFhYjNjNiIsInRva2VuX3R5cGUiOiJiZWFyZXIiLCJzY29wZSI6ImxhdW5jaC9wYXRpZW50IHBhdGllbnQvT2JzZXJ2YXRpb24ucnMgcGF0aWVudC9QYXRpZW50LnJzIiwiY2xpZW50X2lkIjoiZGVtb19hcHBfd2hhdGV2ZXIiLCJleHBpcmVzX2luIjozNjAwLCJpYXQiOjE2MzM1MzIwMTQsImV4cCI6MTYzMzUzNTYxNH0.PzNw23IZGtBfgpBtbIczthV2hGwanG_eyvthVS8mrG4"
}
```

<a id="step-4-fhir-api"></a>

### Access FHIR API

```
curl 'https://smart.argo.run/v/r4/sim/eyJtIjoiMSIsImsiOiIxIiwiaSI6IjEiLCJqIjoiMSIsImIiOiI4N2EzMzlkMC04Y2FlLTQxOGUtODljNy04NjUxZTZhYWIzYzYifQ/fhir/Observation?code=4548-4&_sort%3Adesc=date&_count=10' \
  -H 'accept: application/json' \
  -H 'authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuZWVkX3BhdGllbnRfYmFubmVyIjp0cnVlLCJzbWFydF9zdHlsZV91cmwiOiJodHRwczovL3NtYXJ0LmFyZ28ucnVuLy9zbWFydC1zdHlsZS5qc29uIiwicGF0aWVudCI6Ijg3YTMzOWQwLThjYWUtNDE4ZS04OWM3LTg2NTFlNmFhYjNjNiIsInRva2VuX3R5cGUiOiJiZWFyZXIiLCJzY29wZSI6ImxhdW5jaC9wYXRpZW50IHBhdGllbnQvT2JzZXJ2YXRpb24ucnMgcGF0aWVudC9QYXRpZW50LnJzIiwiY2xpZW50X2lkIjoiZGVtb19hcHBfd2hhdGV2ZXIiLCJleHBpcmVzX2luIjozNjAwLCJpYXQiOjE2MzM1MzIwMTQsImV4cCI6MTYzMzUzNTYxNH0.PzNw23IZGtBfgpBtbIczthV2hGwanG_eyvthVS8mrG4'

{
  "resourceType": "Bundle",
  "id": "9e3ed23b-b62e-4a3d-9ac8-9b66a67f700d",
  "meta": {
    "lastUpdated": "2021-10-06T10:52:52.847-04:00"
  },
  "type": "searchset",
  "total": 1100,
<SNIPPED for brevity>
```## Example Id Token

This example demonstrates the creation and validation of an Id Token.

### Setup

#### Python

```python
# !pip3 install python-jose
from Crypto.PublicKey import RSA
import json
import jose.jwk
import jose.jwt
import jose.constants
```

#### Create RSA key

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
## Example JWS generation for Asymmetric Client Auth

### Python

```python
# To create a markdown of this notebook, run: jupyter nbconvert --to markdown authorization-example-jwks-and-signatures.ipynb
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


```python
print("# Encoded JWT with RS384 Signature")
rsa_signing_jwk = get_signing_key("RS384.private.json")
jose.jwt.encode(
    jwt_claims,
    rsa_signing_jwk,
    algorithm='RS384',
    headers={"kid": rsa_signing_jwk["kid"]})
```

### Encoded JWT with RS384 Signature

    eyJhbGciOiJSUzM4NCIsImtpZCI6ImVlZTlmMTdhM2I1OThmZDg2NDE3YTk4MGI1OTFmYmU2IiwidHlwIjoiSldUIn0.eyJpc3MiOiJodHRwczovL2JpbGktbW9uaXRvci5leGFtcGxlLmNvbSIsInN1YiI6Imh0dHBzOi8vYmlsaS1tb25pdG9yLmV4YW1wbGUuY29tIiwiYXVkIjoiaHR0cHM6Ly9hdXRob3JpemUuc21hcnRoZWFsdGhpdC5vcmcvdG9rZW4iLCJleHAiOjE0MjI1Njg4NjAsImp0aSI6InJhbmRvbS1ub24tcmV1c2FibGUtand0LWlkLTEyMyJ9.D5kAqNJwaftCqsRdVVQDq6dMBxuGFOF5svQJuXbcYp-oEyg5qOwK9ZE5cGLTHxqwfpUPNzRKgVdIGuhawAA-8g0s1nKQae8CuKs33hhKh4J34xSEwW3MYs1gwI4GHTtR_g3kYSX6QCi14Ed3GIAvYFgqRqt-gD7sewMUXL4SB8I8cXcDbCqVizm7uPVhjw6QaeKZygJJ_AVLhM4Xs9LTy4HAhdCHpN0FrNmCerUIYJvHDpcod7A0jDmxdoeW1KIBYlhdhQNwjtsTvT1ce4qacN_3KIv_fIzCKLIgDv9eWxkjAtxOmIm8aW5gX9xX7X0nbd0QglIyiic_bZVNNEh0kg




```python
print("# Encoded JWT with ES384 Signature")
ec_signing_jwk  = get_signing_key("ES384.private.json")
jose.jwt.encode(
    jwt_claims,
    ec_signing_jwk,
    algorithm='ES384',
    headers={"kid": ec_signing_jwk["kid"]})
```

### Encoded JWT with ES384 Signature

    eyJhbGciOiJFUzM4NCIsImtpZCI6ImNkNTIwMjExZTU2NjFkYmJhMjI1NmY2N2Y2ZDUzZjk3IiwidHlwIjoiSldUIn0.eyJpc3MiOiJodHRwczovL2JpbGktbW9uaXRvci5leGFtcGxlLmNvbSIsInN1YiI6Imh0dHBzOi8vYmlsaS1tb25pdG9yLmV4YW1wbGUuY29tIiwiYXVkIjoiaHR0cHM6Ly9hdXRob3JpemUuc21hcnRoZWFsdGhpdC5vcmcvdG9rZW4iLCJleHAiOjE0MjI1Njg4NjAsImp0aSI6InJhbmRvbS1ub24tcmV1c2FibGUtand0LWlkLTEyMyJ9.ddl5N8dt5PYI_7syKg_dm1wj1LR3dYVztFlTODs6pU1vKH1Zv3d9NctbnAsZ4aZ1K7HE83_fA_hIAL0JsU1GoB7roLmrpj8zfygG9Q1ZBAmKNoR60pyONPZsGTihoR29


