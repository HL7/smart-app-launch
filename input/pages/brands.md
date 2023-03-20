### Introduction

This specification provides a standardized method for Electronic Health Record (EHR) systems to publish Fast Healthcare Interoperability Resources (FHIR) endpoints and associated branding information to create a seamless user experience connecting patients to their health records through various applications. The specification focuses on the concept of "Patient-access Brands," where apps display recognizable cards or tiles representing different healthcare providers, payers, or organizations offering patient access through their FHIR endpoints.

The specification defines FHIR profiles for Endpoint, Organization, and Bundle resources. It outlines the process for API providers to publish Brands associated with their FHIR endpoints and for apps to collect and present these Brands to users. Each Brand includes essential information such as the organization's name, logo, and patient access details, which apps can display in their user interface. Additionally, the specification addresses the relationship between Brands and endpoints, supporting cases where an endpoint publishes one or multiple Brands or where multiple endpoints publish the same Brand. It also provides guidance on caching and CORS. 

EHR systems, healthcare providers, and app developers can ensure a consistent and recognizable user experience when connecting patients to their health records across various platforms and services by following this specification.


### Brands and Endpoints

#### Definition Of Brands And Endpoints In The Context Of The Specification

The Patient-access Brands API describe a model UX where apps display a collection of cards or tiles, each representing a "Patient-access Brand" that patients can recognize and connect to. App developers are not expected to follow this model precisely; the model exists to keep the design grounded/tangible and establish a shared vocabulary.

Design goals:
- EHRs publish FHIR endpoints, meeting ONC requirements
- Providers publish Brand details (name, logo, etc.) that patients will recognize
- Apps display Brands to create a “connect to my health records” UX

##### Patient-Access Brand Bundle Examples

The [Patient-Access Brand Examples](example-brands.html) illustrate the model for:

* A Lab with thousands of locations nationwide
* Regional health system with independently branded affiliated practices sharing a portal
* Cancer center affiliated with one provider's portal for adult patients and another provider's portal for pediatric patients

##### Demonstration Brand Editor

The [SMART Patient Access: Brand Editor](https://brand-editor.argo.run/) is a demonstration brand editor with FHIR export that showcasing the capabilities of the API through a user interface. It allows users to edit and preview branding configurations for an example SMART on FHIR app.

#### Guidelines For API Providers Publishing Brands Associated With Their FHIR Endpoints

A healthcare provider, payer, or other organization exposing a FHIR patient access API can **decide which and how many brands to publish**  with their FHIR endpoints. Each Brand includes data describing the organization offering patient access (e.g., organization name and logo) together with details about their patient access offering (e.g., name and description of their patient portal) in terms that patients should recognize.

An app can:

* **Display** the Brands it has collected (e.g., as cards or tiles in a UX)
* Allow users to **filter or search** Brands based on names, locations, or categories
* Allow users to **select and connect** to a Brand's API endpoint

### Brand Information

#### Essential Information Included In Each Brand

Each Brand includes the following information intended to support an app-based card or tile UX:

| Field | Description | Cardinality |
| --- | --- | --- |
| Name|Primary name for the organization to display on a card, e.g., "Mass General Brigham" | 1..1 |
| Consumer-facing website for this Brand | note this is distinct from a patient portal, described under "Patient Access Details" below | 1..1 |
| Logo |to be displayed on a card, and link to logo use terms/agreements | 0..1 |
| Aliases | e.g., former names like "Partners Healthcare" for filtering/search | 0..* |
| Identifiers | supporting cross-publisher references or links to external data sets such as the NPI Registry. | 0..* |
| Locations | zip codes and street addresses associated with the Brand | 0..* |
| Categories | health system, hospital, clinic, pharmacy, lab, insurer for filtering/search | 0..* |
| Patient Access Details | describes the portal this Brand offers to patients **See the table below**.| 1..1 |
{:.grid}

#### Patient Access Details

The details of the Patient Access Brand communicated to the patient.

| Field | Description | Cardinality |
| --- | --- | --- |
| Name of a patient portal | e.g., "Patient Gateway" or "MyChildrens Portal" | 1..1 |
| Portal URL | where patients can manage accounts with this provider. | 1..1 |
| Patient-facing description | explaining the subset of patients eligible to connect, or the data available in a patient-friendly language | 0..1 |
| "Patient access provided by" | conveys that an affiliated Brand hosts this Brand's API technology and patient portal | 0..1 |
| Portal logo | to be displayed on a card for Brands that have a portal logo in addition to their brand logo | 0..1 |
{:.grid}



#### Explanation Of The Relationship Between Brands And Endpoints

Commonly, a single endpoint is associated with a single Brand. But the following cases are supported by this conceptual model:

* *An endpoint publishes one Brand*
    * For instance, a national lab might publish a Brand associated with their overall organization, including a complete list of zip codes where they operate.
* *An endpoint publishes multiple Brands*
    * For instance, a regional health system might publish a small collection of brands based on a specific hospital or clinic that their patients will recognize.
* *Multiple endpoints publish the same Brand*
    * For instance, a Hospital offering more than one patient portal for legacy purposes, or a patient portal hosting multiple FHIR API versions simultaneously
    * If multiple endpoints independently publish the same Brand, apps can de-duplicate or merge as needed:
      1. *A single EHR portal hosts multiple FHIR API endpoints advertising the same Brand* — for instance,  an EHR vendor hosting endpoints for FHIR DSTU2 alongside FHIR R4.
          * Publishers SHALL publish all "peer" endpoints in the same Bundle, and peer endpoints SHALL reference the same Brand. With these restrictions in place, this scenario does not require apps to perform any de-duplicate or merging.
      2. *Different EHR portals advertise Brands that should merge into a single card at display time*. For instance, a hospital transitioning between EHRs offers two distinct patient portals for an interim period and would like to surface both in a single card.
          * To indicate that it's OK for apps to merge a Brand's card into another Brand's card, publishers SHALL populate the same `identifier` in both Brands. In addition, publishers SHOULD include a patient-facing description for any merged Brands. Finally, apps SHOULD merge Brands into a single target Brand's card by displaying the target Brand's title and logo. Each Brand displays a distinct "connect" button with a patient-facing description or name.


### Caching and CORS

#### Guidelines For Caching And Managing Cross Origin Resource Sharing (CORS) For FHIR Resources

Publishers SHOULD include a weak `ETag` header in all HTTP responses. Clients SHOULD cache responses by ETag and SHOULD consist of an `If-None-Match` header in all requests to avoid re-fetching data that have not changed. See <https://www.hl7.org/fhir/http.html> for background.

Publishers SHALL support [Cross-Origin Resource Sharing (CORS)](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Origin) for all GET requests to the artifacts described in this guide.

### FHIR Profiles

#### Explanation Of FHIR Profiles For Endpoint And Organization Resources

An app assembles its collection of Brands (potentially as an offline, configuration-time process) by gathering  FHIR `PatientAccessEndpoint` (Endpoints) and `PatientAccessBrand` (Organizations) data from:

* Vendor-consolidated Brand Bundles
* FHIR resources linked from `.well-known/smart-configuration` for each endpoint

which are defined below. For fine-grained organizational management, apps SHALL select the FHIR resources linked from `.well-known/smart-configuration` if they differ from the resources in a vendor-consolidated Brand Bundle.

#### Rules And Best Practices For Creating And Implementing FHIR Profiles

##### Metadata in `.well-known/smart-configuration`

FHIR servers supporting this IG SHOULD include the following property in the SMART configuration JSON response:

* `0..1` `patientAccessBrandBundle` URL of a Brand Bundle. The Bundle entries include any Brand and "peer endpoints" associated with this FHIR endpoint. In addition, FHIR servers SHOULD include any resource servers that an app might also be authorized to access.
* `0..1` `patientAccessPrimaryBrandIdentifier`: FHIR Identifier for this server's primary Brand within the Bundle. Publishers SHALL populate this property if the referenced Brand Bundle includes more than one Brand. When present, this identifier SHALL consist of a `value` and SHOULD have a `system`. 

The Brand Bundle SHALL include a Brand whose `Organization.identifier` matches the primary Brand identifier from SMART configuration JSON.

The Brand Bundle SHOULD include only the Brands and Endpoints associated with the SMART on FHIR server that links to the Bundle. However, the Brand Bundle MAY have additional Brands or Endpoints (e.g., supporting a publication pattern where endpoints from a given vendor might point to a comprehensive, centralized vendor-managed list). 

###### Example `.well-known/smart-configuration`

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

##### Must-Support Definition (`MS`) and Data Absent Reasons
For this specification a profile element labeled as "must support" means publishers must provide a way for Brands to populate value. For example, marking a Brand's "address" as `0..* MS` means that a publisher needs to give Brands a way to supply multiple addresses, even if some choose not to provide any.

The EHR that publishes a Brand Bundle may not have some required data elements (Brand Website, Portal Website, Portal Name). If the EHR has asked, but a Brand administrator has not supplied a value, the EHR MAY provide a [Data Absent Reason](extension-data-absent-reason.html) of `asked-declined` or `asked-unknown`. The EHR SHALL NOT use other Data Absent Reasons.

#### FHIR Patient Access Endpoint Profile

<!-- * `1..1 MS` `address` FHIR base URL for server supporting patient access
* `1..1 MS` `connectionType` -- fixed Coding for `hl7-fhir-rest`
* `0..1` `name` fallback or default name describing the endpoint and the organization offering Patient API access at this endpoint. This value MAY contain technical details like FHIR API Version designations, and apps SHOULD preferentially use names from an associated `PatientAccessBrand`, rather than displaying this value to users.
* `1..* MS` `contact` website where developers can to configure access to this endpoint
    * `system` is `url`
    * `value` is an `https://` URL for app developers
* `1..1 MS` `managingOrganization` references a [`PatientAccessBrand` Organization](#FHIR-Profile-for-Organization-PatientAccessBrand). This property associates a single "primary brand" with the endpoint. Additional affiliated Brands or parent brands can be associated via "Patient access provided by" links (`Organization.partOf`). EHR vendors SHALL support integrated publication of Organizations in the same JSON Bundle, as well as external customer-managed publication:
  * `0..1 MS`  `reference` containing a relative URL to a Brand within this Bundle
   * `0..1 MS` `identifier` with a customer-supplied identifier for the primary Brand
   * `0..* MS` `extension` with
       * `url` `http://fhir.org/argonaut/StructureDefinition/brand-bundle`
       * `valueUrl` URL for a customer-managed Patient Access Brands Bundle that defines the identified Brand and related Brands (the Bundle SHALL contain exactly one entry matching the specified identifier).
* `extension`
    * `1..* MS` `http://fhir.org/argonaut/StructureDefinition/endpoint-fhir-version` to convey the endpoint's FHIR Version. This element is a denormalization to help clients focus on supported endpoints. The `valueCode` is any version from http://hl7.org/fhir/valueset-FHIR-version.html. (As of this publication, `4.0.1` is expected for ONC-certified EHRs). -->

{{site.data.structuredefinitions.patient-access-endpoint.description}}

[Formal Views of Profile Contents](StructureDefinition-patient-access-endpoint.html)
    
##### Example

[Endpoint Example](Endpoint-example.html)

```javascript

{% include_relative Endpoint-example.json %}

```

#### FHIR Patient Access Brands (Organization) Profile


{{site.data.structuredefinitions.patient-access-brand.description}}


[Formal Views of Profile Contents](StructureDefinition-patient-access-brand.html)

##### Example

[Organization Example](Organization-example.html)

```javascript

{% include_relative Organization-example.json %}

```
 
#### FHIR Brands Bundle Profile

{{site.data.structuredefinitions.patient-access-brands-bundle.description}}

[Formal Views of Profile Contents](StructureDefinition-patient-access-brands-bundle.html)
  
  
##### Partial View Of Brands Bundle Example

The following Bundle fragments in the example below illustrate how Brand data is compiled into a Bundle and how each Endpoint references a Brand (in other words, an Organization) within the same Bundle. See the[Patient-Access Brand Examples](example-brands.html) for complete examples. 

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



