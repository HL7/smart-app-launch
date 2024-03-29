### Introduction

The specification defines FHIR profiles for [Endpoint]({{site.data.fhir.path}}endpoint.html), [Organization]({{site.data.fhir.path}}organization.html), and [Bundle]({{site.data.fhir.path}}bundle.html) resources that help users connect their apps to health data providers. It outlines the process for data providers to publish FHIR Endpoint and Organization resources, where each Organization includes essential branding information such as the organization's name, logo, and user access details. Apps present branded Organizations to help users select the right data providers.

By following this specification, EHR systems, healthcare providers, payers, and app developers can ensure a consistent and recognizable user experience when connecting users to health records across various platforms and services.

The [User-Access Brand Examples](example-brands.html) illustrate how providers can represent diverse scenarios.

### Brands and Endpoints

This specification supports a model User Experience (UX) where apps display a collection of cards or tiles, each representing a "User-Access Brand" that users can recognize and connect to. App developers are not expected to follow this model UX precisely; the model exists to keep the design grounded and establish a shared vocabulary.

In this model, a healthcare **provider, payer, or other organization** exposing a user-facing FHIR API can **decide which brands to publish** in association with their FHIR endpoints. Each Brand includes data describing the organization (e.g., organization name and logo that a user would recognize) together with details about their user access portals (e.g., name, logo, and description in terms that users would recognize) as well as the API endpoints associated with these portals.

Using this model, an **app** can:

* **Display** the Brands it has collected (e.g., as cards or tiles in a UX).
* Allow users to **filter or search** Brands based on names, locations, or categories.
* Allow users to **select** Brands (and more specifically portals) where they have data available.
* Guide users to **connect** to FHIR endpoints for the selected portals.

### Design goals
- Health Data Providers can publish Brand details (name, logo, etc.) that users will recognize.
- Brands can be associated with one or more user access portals.
- Portals can be associated with one or more FHIR endpoints.
- Apps display Brands to create a "connect to my health records" UX.
- All details can be published in aggregate (e.g., by EHR vendor, by region, or globally).

### Brand Information

{% capture info_note %}
The overview tables and annotated examples on this page are intended for convenience and clarity. In case of any discrepancies, the formal profiles should be considered the definitive source of truth.
{% endcapture %}
{% include info-note.html content=info_note %}

#### Information Included In Each Brand

Each Brand includes the following information intended to support an app-based card or tile UX:

| Field | Description | Cardinality |
| --- | --- | --- |
| Name|Primary name for the organization to display on a card, e.g., "General Hospital" | 1..1 |
| User-facing website for this Brand | note this is distinct from an access portal, described under "Access Details" below | 1..1 |
| Logo |to be displayed on a card, and link to logo use terms/agreements | 0..1 |
| Aliases | e.g., former names like "General Health Associates" for filtering/search | 0..* |
| Identifiers | supporting cross-publisher references or links to external data sets such as the NPI Registry. | 0..* |
| Locations | Places associated with the Brand (e.g., states, cities, or street addresses) | 0..* |
| Categories | clinical, insurance, laboratory, imaging, pharmacy, network, aggregator --- for filtering/search | 0..* |
| Portal Details | describes a portal this Brand offers to users **See the table below**.| 0..* |
{:.grid}

#### Portal Details

The details of the User Access Brand communicated to the user.

| Field | Description | Cardinality |
| --- | --- | --- |
| Portal name | e.g., "Patient Gateway" or "MyChildrens Portal" | 0..1 |
| Portal logo | to be displayed on a card for Brands that have a portal logo in addition to their brand logo | 0..1 |
| Portal URL | where users can manage accounts with this provider. | 0..1 |
| User-facing description | explaining the subset of users eligible to connect, or the data available in a user-friendly language | 0..1 |
| API Endpoints| FHIR API Endpoints associated with the portal | 0..* |
{:.grid}

#### Relationships Among Brands, Portals, and Endpoints

Commonly, a single Brand is typically associated with a single Portal that offers a single FHIR Endpoint. But all of the following cases are supported by this conceptual model:

* *One Brand is associated with one Portal*
  * e.g., a primary care practice with a single EHR providing user access
* *One Brand is associated with multiple Portals*
  * e.g., a hospital may offer more than one patient portal for legacy purposes
  * e.g., a tertiary cancer center may offer one patient portal for adults and another for pediatric patients
  * Because Brand information may be published in multiple places, Organizations include the same `identifier` to facilitate matching, merging, and de-duplication. Apps can merge Brands into a single target Brand's card by displaying the target Brand's title and logo. Within the Brand's card, the app displays a distinct "connect" button for each set of Portal Details.
* *One Portal is associated with one Endpoint*
  * e.g., an EHR-based portal that provides access to patient data through a single FHIR R4 endpoint 
* *One Portal is associated with multiple FHIR Endpoints*
  * e.g., a national lab's portal might have one Endpoint for FHIR R4 and another for FHIR R2.
  * e.g., a health system's portal might have one Endpoint for laboratory results and another for imaging results.
* *Multiple Brands are associated with the same Portal*
  * e.g., a regional health system that patients recognize under distinct brands associated with specific hospitals or clinics -- even though all these paths lead to the same portal and FHIR Endpoints.

### Conformance Overview
{% capture info_note %}
This conformance overview is intended for convenience and clarity. In case of any discrepancies, the formal profiles should be considered the definitive source of truth.
{% endcapture %}
{% include info-note.html content=info_note %}

* **Health Data Provider**. Any organization that offers SMART on FHIR access to its users and wishes to appear as a branded entity in user-facing apps. A Health Data Provider works with a Brand Bundle Publisher and SMART on FHIR Server to manage Organization and Endpoint details.
  * RECOMMENDED to define an Organization identifier where `system` is `urn:ietf:rfc:3986` and `value` is the HTTPS URL for the brand's primary web presence, omitting any "www." prefix from the domain and omitting any path component
* **Brand Bundle Publisher**. Any organization hosting or enabling management of a User Access Brand Bundle.
  * SHALL publish at least a "primary brand" that references each FHIR endpoint in the Brand Bundle
  * SHOULD support the publication of a more detailed Brand hierarchy
  * SHALL populate `Bundle.timestamp` to advertise the timestamp of the last change to the contents
  * SHOULD populate `Bundle.entry.resource.meta.lastUpdated` with a more detailed timestamp if the system tracks updates per Resource.
  * SHALL support Cross-Origin Resource Sharing (CORS) for all GET requests to the artifacts described in this guide.
  * SHOULD include a weak `ETag` header in all Brand Bundle HTTP responses
  * SHALL allow Health Data Providers to manage all data elements marked "Must-Support" in the "[User Access Brand](StructureDefinition-user-access-brand.html)" and "[User Access Endpoint](StructureDefinition-user-access-endpoint.html)" profiles
    * SHALL support customer-supplied Organization identifiers (`system` and `value`)
    * MAY provide a Data Absent Reason of `asked-declined` or `asked-unknown` in a Brand Bundle
    * SHALL NOT use Data Absent Reasons other than `asked-declined` or `asked-unknown` in a Brand Bundle
* **SMART on FHIR Server**. Any SMART on FHIR server that supports discovery of a User Access Brand Bundle.
  * SHOULD include `user_access_brand_bundle` and `user_access_brand_identifier` properties in the SMART configuration JSON response
  * When populating `user_access_brand_bundle`
      * SHOULD link to a Bundle that includes only Brands and Endpoints affiliated with the Health Data Provider responsible for this SMART on FHIR server
      * MAY link to a Bundle with Brands or Endpoints for additional Health Data Providers
      * SHALL populate `user_access_brand_identifier` in SMART configuration JSON response if the `user_access_brand_bundle` refers to a Bundle with multiple Brands.
  * When populating `user_access_brand_identifier` 
      * SHALL include a `value`
      * SHOULD include a `system`
      * SHALL ensure this identifier matches exactly one `Organization.identifier` in the referenced Brand Bundle
* **App**. Any SMART on FHIR app that leverages a User Access Brand Bundle.
  * SHOULD provide an `If-None-Match` header in all Brand Bundle requests to avoid re-fetching data that have not changed
  * SHOULD cache Brand Bundle responses by ETag
  * SHALL select FHIR resources linked from the `.well-known/smart-configuration` if they differ from the resources in a vendor-consolidated Brand Bundle

### FHIR Profiles

An app assembles its collection of Brands (typically as an offline, configuration-time process) by gathering FHIR `UserAccessEndpoint` (Endpoints) and `UserAccessBrand` (Organizations) resources from:

* Vendor-consolidated Brand Bundles that are openly published (e.g., in the context of a national EHR Certification program)
* Brand Bundles linked from `.well-known/smart-configuration` for known endpoints

For fine-grained organizational management, apps SHALL select the FHIR resources linked from `.well-known/smart-configuration` if they differ from the resources in a vendor-consolidated Brand Bundle.

#### Brand Profile (Organization)

See [Formal Profile](StructureDefinition-user-access-brand.html).

This annotated example illustrates how a Brand is represented as a FHIR Organization.

```js
{
  // A Brand is represented as a FHIR Organization
  "resourceType" : "Organization",
  "id" : "good-health",
  // The primary name by which users recognize this brand
  "name" : "Good Health",
  // Additional names or former names that users may recognize
  "alias" : ["Goodie Bag Health"],
  // Any valid status is allowed, but publishers should consider filtering 
  // their published list to only include active brands.
  "active" : true,
  // This guide provides a vocabulary for loosely categorizing the type of
  // data available at user access API endpoints. Multiple categories
  // can be included here.
  "type" : [{
    "coding" : [{
      "system" : "http://terminology.hl7.org/CodeSystem/organization-type",
      "code" : "prov",
      "display" : "Healthcare Provider"
    }]
  }],
  "extension" : [{
    // (0..1) `organization-brand` extension conveys branding details that
    // are not part of FHIR's core data model
    "url" : "http://hl7.org/fhir/StructureDefinition/organization-brand",
    "extension" : [{
      // (0..*) Link to the logo (uses `https:` or  `data:` schme for inline)
      // * optimized for display as a 1 in / 2.54 cm square
      // * formatted as SVG or 1024x1024 pixel PNG with transparent background
      // * legible at small sizes
      "url" : "brandLogo",
      "valueUrl" : "https://goodhealth.example.org/images/logo.svg"
    },{
      // (0..*) Link to the license agreement for the logo, if applicable.
      // Developers must review and agree to the linked logo license terms
      // prior to using the logo in their applications.
      "url" : "brandLogoLicense",
      "valueUrl" : "https://goodhealth.example.org/license.html"
    }, {
      // (0..*) Link to a Brand Bundle where additional information about
      // this Brand may be available.
      "url" : "brandBundle",
      "valueUrl" : "https://goodhealth.example.org/branding.json"
    }]
  },
  {
    // (0..*) `organization-portal` extension conveys details about a
    // portal associated with this brand. This extension repeats when
    // more than one portal is associated with this brand.
    "url" : "http://hl7.org/fhir/StructureDefinition/organization-portal",
    "extension" : [{
      // (0..1) Name of the portal as shown to users
      "url" : "portalName",
      "valueString" : "GoodHealthCentral"
    },
    {
      // (0..1) Describes the portal and its intended audience. May be used to help
      // users select the right portal if multiple options are available.
      "url" : "portalDescription",
      "valueMarkdown" : "GoodHealthCentral is available for our primary care patients."
    },
    {
      // (0..1) Link to the portal website.
      "url" : "portalUrl",
      "valueUrl" : "https://goodhealthcentral.example.org"
    },
    {
      // (0..1) Logo for the portal (see descriptions for brandLogo above)
      "url" : "portalLogo",
      "valueUrl" : "https://goodhealthcentral.example.org/logo.png"
    },{
      // (0..1) License for the portal logo (see description for brandLogoLicense above)
      "url" : "portalLogoLicense",
      "valueUrl" : "https://goodhealthcentral.example.org/logo-license.html"
    },
    {
      // (0..*) Endpoint associated with this portal. This extension repeat
      // when more than one endpoint is associated with this portal.
      // (The `reference` is to an Endpoint that appears in the same
      // Brand Bundle as this Organization) 
      "url" : "portalEndpoint",
      "valueReference" : {
        "reference" : "Endpoint/goodhealth-r4"
      }
    },{
      "url" : "portalEndpoint",
      "valueReference" : {
        "reference" : "Endpoint/goodhealth-r2"
      }
    }]
  }],
  // Apps can use a Brand’s Organization.identifier to merge content published
  // in multiple sources. To facilitate robust matching, EHRs SHALL support
  // customer-supplied identifiers (system and value). It is RECOMMENDED that
  // each Brand include an identifier where system is `urn:ietf:rfc: 3986` 
  // (meaning the identifier is a URL) and value is the HTTPS URL for the
  // Brand’s primary web presence, omitting any "www." prefix and any path.
  // Of course, additional Identifiers may be included as well.
  "identifier" : [{
    "system" : "urn:ietf:rfc:3986",
    "value" : "https://examplelabs.org"
  }],
  // telecom with value conveying the primary public website for the Brand.
  // Note this is distinct from the user access portal website.
  "telecom" : [{
    "system" : "url",
    "value" : "https://brand.example.com"
  }],
  // Locations (e.g., zip codes and/or street addresses) associated with the Brand.
  // The following combinations are allowed, and as a best practice to ensure
  // consistent worldwide adoption, the Address.country data element SHOULD be
  // populated inside any of these with an ISO 3166-1 alpha-2 country code.
:
  // * State
  // * City, state
  // * City, state, zip code
  // * Street address, city, state, zip code
  // * Zip code alone
  "address" : [{
    "city" : "Boston",
    "state" : "MA",
    "postalCode" : "02111",
    "country": "US"
  }, {
    "postalCode" : "02139",
    "country": "US"
  }],
  // These endpoints are already listed above in association with their portal.
  // They are repeated here as a convenience for clients that do not know how
  // to interpret User Access Brands.
  "endpoint": [{
    "reference" : "Endpoint/goodhealth-r2"
  }, {
    "reference" : "Endpoint/goodhealth-r4"
  }]
}
```


#### Endpoint Profile

See [Formal Profile](StructureDefinition-user-access-endpoint.html).

This annotated example illustrates how an Endpoint is represented.

```js
{
  "resourceType": "Endpoint",
  "id": "goodhealth-r4",
  // FHIR Base URL for the User Access Endpoint
  "address": "https://fhir.goodhealth.example.org/r4",
  // Any valid status is allowed, but publishers should consider filtering 
  // their published list to only include active endpoints.
  "status": "active",
  // Name for the User Access Endpoint. This value may contain
  // technical details like FHIR API Version designations, so apps should prefer
  // displaying the `Organization.name` from an associated UserAccessBrand, 
  // rather than displaying this value to users.
  "name": "FHIR R4 Endpoint for GoodHealth",
  // Fixed value indicating FHIR API Endpoint
  "connectionType": {
    "code": "hl7-fhir-rest",
    "system": "http://terminology.hl7.org/CodeSystem/endpoint-connection-type"
  },
  "extension": [
    {
      // (1..*) The User Access Endpoint's FHIR Version. This Extension
      // is a denormalization to help clients focus on supported endpoints.
      "url": "http://hl7.org/fhir/StructureDefinition/endpoint-fhir-version",
      "valueCode": "4.0.1"
    }
  ],
  // Contact information for the endpoint. This will include at least one
  // URL for a website where developers can configure access to this endpoint.
  "contact": [
    {
      "system": "url",
      "value": "https://dev-portal.goodhealth.example.org"
    }
  ],
  // Some `payloadType` is required by FHIR R4. It can be populated with a 
  // placeholder value like the one shown here.
  "payloadType" : [
    {
      "coding" : [
        {
          "system" : "http://terminology.hl7.org/CodeSystem/endpoint-payload-type",
          "code" : "none"
        }
      ]
    }
  ]
}

```


#### Brand Bundle Profile

{{site.data.structuredefinitions.user-access-brands-bundle.description}}

```js
{
  "resourceType": "Bundle",
  "id": "example",
  // Brand Bundles are always published as "collection"
  "type": "collection",
  // Brand Bundles always include a timestamp that apps can use to recognize
  // if contents have changed since the last time they fetched the bundle.
  "timestamp": "2023-09-05T20:00:43.241070-07:00",
  "entry": [ /* Organizations and Endpoints here */ ]
} 
```

[Formal Profile](StructureDefinition-user-access-brands-bundle.html)
  
##### Brand Bundle Examples

Brands and Endpoints are compiled together and published in a Brand Bundle.

The [User-Access Brand Examples](example-brands.html) illustrate how providers can represent diverse scenarios including:

* National laboratory with many locations
* Regional health system with independently branded affiliated practices that share a patient portal
* Cancer center affiliated with one portal for adult patients and another portal for pediatric patients
* Clinical organization that has recently merged and still uses distinct brands

### Rules And Best Practices 

#### Consistent Identifiers for Organizations

Apps can use a Brand's `Organization.identifier` element to merge content published in multiple sources. To facilitate robust matching, EHRs SHALL support customer-supplied identifiers (`system` and `value`). It is RECOMMENDED that each Brand include an identifier where `system` is `urn:ietf:rfc: 3986` (meaning the identifier is a URL) and `value` is the HTTPS URL for the Brand's primary web presence, omitting any "www." prefix from the domain and omitting any path component. For example, since the main web presence of Boston Children's Hospital is https://www.childrenshospital.org/, a recommended identifier would be

    {"system": "urn:ietf:rfc:3986", "value": "https://childrenshospital.org"}

#### Managing Cross Origin Resource Sharing (CORS) For FHIR Resources

Publishers SHALL support [Cross-Origin Resource Sharing (CORS)](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Origin) for all GET requests to the artifacts described in this guide.

#### Caching Brand Bundles

Publishers SHOULD include a weak `ETag` header in all HTTP responses. Clients SHOULD cache responses by ETag and SHOULD provide an `If-None-Match` header in all requests to avoid re-fetching data that have not changed. See <https://www.hl7.org/fhir/http.html#cread> for background.

#### Metadata in `.well-known/smart-configuration`

To ensure that SMART apps can discover Brand information directly from a FHIR endpoint's base URL, FHIR servers supporting this IG SHOULD include the following properties in the SMART configuration JSON response:

* `user_access_brand_bundle` URL of a Brand Bundle. The Bundle entries include any Brand and "peer endpoints" associated with this FHIR endpoint.
* `user_access_brand_identifier`: FHIR Identifier for this server's primary Brand within the Bundle. Publishers SHALL populate this property if the referenced Brand Bundle includes more than one Brand. When present, this identifier SHALL consist of a `value` and SHOULD have a `system`. 

The Brand Bundle SHALL include exactly one Brand with an `Organization.identifier` that matches the primary Brand identifier from SMART configuration JSON.

The Brand Bundle SHOULD include only the Brands and Endpoints associated with the SMART on FHIR server that links to the Bundle. However, the Brand Bundle MAY have additional Brands or Endpoints (e.g., supporting a publication pattern where endpoints from a given vendor might point to a comprehensive, centralized vendor-managed list).

Note that the presence of an Endpoint in the Brand Bundle does not provide an implicit authorization to access the Endpoint. Clients that require access to the data provided by the FHIR Endpoints in the Brand Bundle can use SMART Configuration metadata to determine authorization requirements.

##### Example `.well-known/smart-configuration`

```javascript
{
  // details at http://hl7.org/fhir/smart-app-launch/conformance.html
  "user_access_brand_bundle": "https://example.org/brands.json",
  "user_access_brand_identifier": {
    "system": "urn:ietf:rfc:3986",
    "value": "https://example.org"
  },
  // ...
}
```

Dereferencing the `user_access_brand_bundle` URL above would return a Brand Bundle.

#### Must-Support Definition (`MS`) and Data Absent Reasons

User Access Brand profile elements labeled as "must support" mean publishers must provide a way for Brands to populate the value. For example, marking a Brand's "address" as `0..* MS` means that a publisher needs to give Brands a way to supply multiple addresses, even if some choose not to provide any.

An EHR that publishes a Brand Bundle may not have some required data elements (Brand Website, Portal Website, Portal Name). If the EHR has asked, but a Brand administrator has not supplied a value, the EHR MAY provide a [Data Absent Reason](http://hl7.org/fhir/StructureDefinition/data-absent-reason) of `asked-declined` or `asked-unknown`. The EHR SHALL NOT use other Data Absent Reasons.
