### Introduction

This page documents the concept of API and 'Patient-access Brands', how healthcare providers can publish brands associated with their FHIR endpoints, and how apps can collect and present these brands to help patients connect to their health records. It discusses what information is included in a brand, such as primary name, logo, aliases, identifiers, categories, and patient access details. It provides information on creating an FHIR profile for an endpoint and organization, must-support definition and data absent reasons, caching and CORS, brand bundle, and metadata in `.well-known/smart-configuration`. Examples are also provided.

### Design Goals

* EHRs publish FHIR endpoints, meeting ONC requirements 
* Providers publish Brand details (name, logo, etc.) that patients will recognize
* Apps display Brands to create a "connect to my health records" UX

### Conceptual Model: Patient-Access Brands

*We describe a model UX where apps display a collection of cards or tiles, each representing a "Patient-access Brand" that patients can recognize and connect to.* (To be clear: we don't expect app developers to follow this model precisely; the model exists to keep our design grounded/tangible and to give us a shared vocabulary.)


### API Providers *Publish Brands* Associated with Endpoints

A healthcare provider, payer, or other organization exposing a FHIR patient access API can **decide which and how many brands to publish**  with their FHIR endpoints. Each Brand includes data describing the organization offering patient access (e.g., organization name and logo) together with details about their patient access offering (e.g., name and description of their patient portal) in terms that patients should recognize.

### Apps *Collect and Present Brands* to Users
An app can:

* **Display** the Brands it has collected (e.g., as cards or tiles in a UX)
* Allow users to **filter or search** Brands based on names, locations, or categories
* Allow users to **select and connect** to a Brand's API endpoint


### What Is In a Brand?
Each Brand includes the following information intended to support an app-based card or tile UX:

<!-- * `1..1` Primary name for the organization to display on a card (e.g., "Mass General Brigham")
* `1..1` Consumer-facing website for this Brand (note this is distinct from a patient portal, described under "Patient Access Details" below)
* `0..1` Logo to be displayed on a card, and link to logo use terms/agreements
  * {:.bg-warning}**TODO**: Specify formats/sizes (prefer PNG or SVG for transparency support), and perhaps support logos at multiple scales (https://developer.mozilla.org/en-US/docs/Web/Manifest/icons provides a take on this).
* `0..*` Aliases (e.g., former names like "Partners Healthcare") for filtering/search
* `0..*` Identifiers supporting cross-publisher references or links to external data sets such as the NPI Registry.
* `0..*` Locations (zip codes and street addresses) associated with the Brand
* `0..*` Categories (health system, hospital, clinic, pharmacy, lab, insurer) for filtering/search
* `1..1` Patient Access Details -- describes the portal this Brand offers to patients
    * `1..1` Name of a patient portal (e.g., "Patient Gateway" or "MyChildrens Portal")
    * `1..1` Portal URL where patients can manage accounts with this provider. 
    * `0..1` Patient-facing description, explaining the subset of patients eligible to connect, or the data available in a patient-friendly language
    * `0..1` "Patient access provided by" -- conveys that an affiliated Brand hosts this Brand's API technology and patient portal
    * `0..1` Portal logo to be displayed on a card for Brands that have a portal logo in addition to their brand logo -->


| Field | Description | Cardinality |
| --- | --- | --- |
| Name|Primary name for the organization to display on a card, e.g., "Mass General Brigham" | 1..1 |
| Consumer-facing website for this Brand | note this is distinct from a patient portal, described under "Patient Access Details" below | 1..1 |
| Logo |to be displayed on a card, and link to logo use terms/agreements  <span class="bg-warning" markdown="1">{**TODO**: Specify formats/sizes (prefer PNG or SVG for transparency support), and perhaps support logos at multiple scales (https://developer.mozilla.org/en-US/docs/Web/Manifest/icons provides a take on this).</span><!-- warning --> | 0..1 |
| Aliases | e.g., former names like "Partners Healthcare" for filtering/search | 0..* |
| Identifiers | supporting cross-publisher references or links to external data sets such as the NPI Registry. | 0..* |
| Locations | zip codes and street addresses associated with the Brand | 0..* |
| Categories | health system, hospital, clinic, pharmacy, lab, insurer for filtering/search | 0..* |
| Patient Access Details | describes the portal this Brand offers to patients | 1..1 |
| Name of a patient portal | e.g., "Patient Gateway" or "MyChildrens Portal" | 1..1 |
| Portal URL | where patients can manage accounts with this provider. | 1..1 |
| Patient-facing description | explaining the subset of patients eligible to connect, or the data available in a patient-friendly language | 0..1 |
| "Patient access provided by" | conveys that an affiliated Brand hosts this Brand's API technology and patient portal | 0..1 |
| Portal logo | to be displayed on a card for Brands that have a portal logo in addition to their brand logo | 0..1 |
{:.grid}

### Relationship Between Brands and Endpoints

Commonly, a single endpoint is associated with a single Brand. But the following cases are supported by this conceptual model:

* *An endpoint publishes one Brand*
    * For instance, a national lab might publish a Brand associated with their overall organization, including a complete list of zip codes where they operate.
* *An endpoint publishes multiple Brands*
    * For instance, a regional health system might publish a small collection of brands based on a specific hospital or clinic that their patients will recognize.
* *Multiple endpoints publish the same Brand*
    * For instance, a Hospital offering more than one patient portal for legacy purposes, or a patient portal hosting multiple FHIR API versions simultaneously


##### De-Duplicating Brands

If multiple endpoints independently publish the same Brand, apps can de-duplicate or merge as needed:

1. *A single EHR portal hosts multiple FHIR API endpoints advertising the same Brand* — for instance,  an EHR vendor hosting endpoints for FHIR DSTU2 alongside FHIR R4.
    * Publishers SHALL publish all "peer" endpoints in the same Bundle, and peer endpoints SHALL reference the same Brand. With these restrictions in place, this scenario does not require apps to perform any de-duplicate or merging.
2. *Different EHR portals advertise Brands that should merge into a single card at display time*. For instance, a hospital transitioning between EHRs offers two distinct patient portals for an interim period and would like to surface both in a single card.
    * To indicate that it's OK for apps to merge a Brand's card into another Brand's card, publishers SHALL populate the same `identifier` in both Brands. In addition, publishers SHOULD include a patient-facing description for any merged Brands. Finally, apps SHOULD merge Brands into a single target Brand's card by displaying the target Brand's title and logo. Each Brand displays a distinct "connect" button with a patient-facing description or name.

### FHIR Specification

An app assembles its collection of Brands (potentially as an offline, configuration-time process) by gathering  FHIR `PatientAccessEndpoint` (Endpoints) and `PatientAccessBrand` (Organizations) data from:

* <span class="bg-warning" markdown="1">[for each supported vendor]</span><!-- warning -->
    * Bundle consolidated by vendor
* <span class="bg-warning" markdown="1">[for each endpoint]</span><!-- warning -->
    * Bundle linked from `.well-known/smart-configuration`

For fine-grained organizational management, apps SHALL select the FHIR resources linked from `.well-known/smart-configuration` if they differ from the resources in a vendor-consolidated Brand Bundle.

#### Caching

Publishers SHOULD include a weak `ETag` header in all HTTP responses. Clients SHOULD cache responses by ETag and SHOULD consist of an `If-None-Match` header in all requests to avoid re-fetching data that have not changed. See https://www.hl7.org/fhir/http.html for background.

#### CORS

Publishers SHALL support [Cross-Origin Resource Sharing (CORS)](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Origin) for all GET requests to the artifacts described in this guide.



#### Metadata in `.well-known/smart-configuration`

FHIR servers supporting this IG SHOULD include the following property in the SMART configuration JSON response:

* `0..1` `patientAccessBrandBundle` URL of a Brand Bundle. The Bundle entries include any Brand and "peer endpoints" associated with this FHIR endpoint. In addition, FHIR servers SHOULD include any resource servers that an app might also be authorized to access.
* `0..1` `patientAccessPrimaryBrandIdentifier`: FHIR Identifier for this server's primary Brand within the Bundle. Publishers SHALL populate this property if the referenced Brand Bundle includes more than one Brand. When present, this identifier SHALL consist of a `value` and SHOULD have a `system`. 

The Brand Bundle SHALL include a Brand whose `Organization.identifier` matches the primary Brand identifier from SMART configuration JSON.

The Brand Bundle SHOULD include only the Brands and Endpoints associated with the SMART on FHIR server that links to the Bundle. However, the Brand Bundle MAY have additional Brands or Endpoints (e.g., supporting a publication pattern where endpoints from a given vendor might point to a comprehensive, centralized vendor-managed list). 

##### Example `.well-known/smart-configuration`

```javascript
{
  // details at http://hl7.org/fhir/smart-app-launch/conformance.html
  "patientAccessBrandBundle": "https://example.org/brands.json",
  "patientAccessPrimaryBrandIdentifier": {
      "value": "https://example.org"
  },
  ...
}
```

Dereferencing the `patientAccessBrandBundle` URL above would return a Brand Bundle.

#### Must-Support Definition (`MS`) and Data Absent Reasons
Below, "must support" means publishers must provide a way for Brands to populate value. For example, marking a Brand's "address" as `0..* MS` means that a publisher needs to give Brands a way to supply multiple addresses, even if some choose not to provide any.

The EHR that publishes a Brand Bundle may not have some required data elements (Brand Website, Portal Website, Portal Name). If the EHR has asked, but a Brand administrator has not supplied a value, the EHR MAY provide a [Data Absent Reason](extension-data-absent-reason.html) of `asked-declined` or `asked-unknown`. The EHR SHALL NOT use other Data Absent Reasons.


#### FHIR Patient Access Brands Endpoint Profile

{{site.data.structuredefinitions.patient-access-endpoint.description}}

[Formal Views of Profile Contents](StructureDefinition-patient-access-endpoint.html)
    
##### Example

```javascript

{% include_relative Endpoint-example.json %}

```

#### FHIR Patient Access Brands (Organization) Profile


* `1..1 MS` `name` Primary brand name to display on a card
* `1..1 MS` `telecom` with `system` of `url` and `value` conveying the primary public website for the Brand. Note this is distinct from the patient access portal website (described below)
* `0..* MS` `alias` Aliases (e.g., former names like "Partners Healthcare") for filtering/search
* `0..* MS` `identifier`(s) that apps can use to link this Brand across publishers or with external data sets. EHRs SHALL support customer-supplied identifiers (`system` and `value`).
    * It is RECOMMENDED that each Brand include an identifier where `system` is `urn:ietf:rfc:3986` (meaning the identifier is a URL) and `value` is the HTTPS URL for the Brand's primary web presence, omitting any "www." prefix from the domain and omitting any path component. For example, since the main web presence of Boston Children's Hospital is https://www.childrenshospital.org/, a recommended identifier would be:
        `{"system": "urn:ietf:rfc:3986", "value": "https://childrenshospital.org"}`
* `0..1 MS` `partOf` "Patient access provided by", to convey that an affiliated Brand hosts this Brand's API technology and patient portal. The hierarchy of "access provided by" links SHALL NOT exceed a depth of two (i.e., a Brand either includes portal details or links directly to a Brand that provides them).
* `0..* MS` `address` Locations (e.g., zip codes and/or street addresses) associated with the Brand. The following combinations are allowed:
  * State
  * City, state
  * City, state, zip code
  * Street address, city, state, zip code
  * zip code alone
* `0..*` `type` Categories for this organization (system: `http://fhir.org/argonaut/CodeSystem/patient-access-category`, code from: `clinical`, `lab`, `pharmacy`, `insurer`, `network`, `aggregator`)
* `extension's about the **Brand**
    * `0..* MS` Logo
        * `url` is `http://fhir.org/argonaut/StructureDefinition/brand-logo`
        * `valueUrl` SHOULD be optimized for display as a 1" square and formatted as SVG or 1024x1024 pixel PNG with transparent background. Multiple logos may be supplied. The URL can be an absolute URL  with the `https://` schema, or a [Data URL](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/Data_URLs) with the `data:` schema that directly embeds content.
    * `0..1 MS` Logo use agreement
        *  `url` is `http://fhir.org/argonaut/StructureDefinition/brand-logo-use-agreement`.
        *  `valueUrl` MAY include a link to terms for logo use by patient access apps.
    * `0..*` Brand flags
        * `url` is `http://fhir.org/argonaut/StructureDefinition/brand-flags`.
      * `valueCode` of `hidden` allows systems to designate Organizations as part of a hierarchy without necessarily being shown in a UX card or tile. This flag is intended to help app developers understand and debug the organizational relationships that underpin published Brands. Marking Brands `hidden` can also be used to associate many affiliated organizations with a parent Brand (e.g., each with its street address) without apps displaying redundant information to users.
* `extension`s about the Brand's **Patient Access** ("portal"). *Note: the extensions in this set represent the "Patient Access Details" described in the conceptual model above. These extensions are "**Inheritable**", meaning systems MAY be omit their values whenever correct values are inferrable by following the "Patient access provided by" links (`Organization.partOf`).*
    * `1..1 MS` Patient access name ("portal name")
        * `url` is `http://fhir.org/argonaut/StructureDefinition/patient-access-name`.
        * `valueString` indicates the name by which patients know the portal (e.g., "MyChildrens" or "Patient Gateway")
    * `1..1 MS` Patient access URL ("portal URL")8899
        * `url` is `http://fhir.org/argonaut/StructureDefinition/patient-access-url`.
        * `valueUrl` indicates the location of the patient portal associated with this Brand -- i.e., a URL where patients can go to see their data and manage access. 
   * `0..1 MS` Patient access description ("portal description")
        * `url` is  `http://fhir.org/argonaut/StructureDefinition/patient-access-description`.
        * `valueMarkdown` explains, if necessary (in patient-friendly language), the subset of patients eligible to connect and the data available. This capability supports (for example) a cancer center that uses one EHR for pediatric patients and another for adult patients. In this scenario, each EHR would publish a different `PatientAccessBrand`; apps would display the description to disambiguate the user's selection. For instance, one Brand might indicate "Access records for childhood cancer care" and another might indicate "Access records for adult cancer care".
    * `0..* MS` Patient access logo ("portal logo"). Used if the portal has its own logo in addition to the Brand's logo
        * `url` is `http://fhir.org/argonaut/StructureDefinition/patient-access-logo`
        * `valueUrl` See documentation for "brand logo"
    * `0..1 MS` Patient access logo use agreement
        *  `url` is `http://fhir.org/argonaut/StructureDefinition/patient-access-logo-use-agreement`.
        *  `valueUrl` See documentation for "brand logo use agreement".


[Formal Views of Profile Contents](StructureDefinition-patient-access-brand.html)

##### Example

```javascript

{% include_relative Organization-example.json %}

```
 
#### FHIR Patient Access Brands Bundle Profile

{{site.data.structuredefinitions.patient-access-brands-bundle.description}}

[Formal Views of Profile Contents](StructureDefinition-patient-access-brands-bundle.html)
  
  
##### Partial Patient-Access Brand Bundle Example

The following Bundle fragments in the example below illustrate how Brand data is compiled into a Bundle and how each Endpoint references a Brand (in other words, an Organization) within the same Bundle. 

```javascript
{
  "resourceType": "Bundle",
  "meta": {
    "lastUpdated": "2022-03-14T15:09:26.535Z"
  },
  "entry": [{
    "fullUrl": "https://pab.example.org/Endpoint/example",
    "resource": {
      "resourceType": "Endpoint",
      "managingOrganization": {
        "reference": "Organization/example"
      },
      ...
    }
  }, {
    "fullUrl": "https://pab.example.org/Organization/example",
    "resource": {
      "resourceType": "Organization",
      "name": "Example Hospital",
      "identifier": [{
        "value": "https://hospital.example.org"
      }],
      ...
    }
  }],
  ...
}
```

##### Complete Patient-Access Brand Bundle Examples

[Patient-Access Brand Examples](example-brands.html) shows complete examples representing: 

* A Lab with thousands of locations nationwide
* Regional health system with independently branded affiliated practices sharing a portal
* Cancer center affiliated with one provider's portal for adult patients and another provider's portal for pediatric patients


### Demonstration Brand Editor

The [SMART Patient Access: Brand Editor](https://brand-editor.argo.run/) is a demonstration brand editor with FHIR export.