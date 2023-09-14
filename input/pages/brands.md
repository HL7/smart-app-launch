### Introduction

This specification provides a standardized method for Electronic Health Record (EHR) systems to publish Fast Healthcare Interoperability Resources (FHIR) endpoints and associated branding information to create a seamless user experience connecting patients to their health records through various applications. The specification focuses on the concept of "Patient-access Brands," where apps display recognizable cards or tiles representing different healthcare providers, payers, or organizations offering patient access through their FHIR endpoints.

The specification defines FHIR profiles for [Endpoint]({{site.data.fhir.path}}endpoint.html), [Organization]({{site.data.fhir.path}}organization.html), and [Bundle]({{site.data.fhir.path}}bundle.html) resources. It outlines the process for API providers to publish Brands associated with their FHIR Endpoints and for apps to collect and present these Brands to users. Each Brand includes essential information such as the organization's name, logo, and patient access details, which apps can display in their user interface.

*EHR systems, healthcare providers, and app developers can ensure a consistent and recognizable user experience when connecting patients to their health records across various platforms and services by following this specification.*

### Brands and Endpoints

#### Definition Of Brands And Endpoints In The Context Of The Specification

This specification is designed to support a model UX where apps display a collection of cards or tiles, each representing a "Patient-access Brand" that patients can recognize and connect to. App developers are not expected to follow this model UX precisely; the model exists to keep the design grounded and establish a shared vocabulary.

Design goals:
- Providers can publish Brand details (name, logo, etc.) that patients will recognize
- Brand details can be published alongside endpoint details
- Brand and Endpoint details can be published in aggregate (e.g., by EHR vendor, by region, or globally)
- Apps display Brands to create a “connect to my health records” UX

##### Patient-Access Brand Bundle Examples

The [Patient-Access Brand Examples](example-brands.html) illustrate how providers can represent diverse scenarios including:

* National laboratory with thousands of locations
* Regional health system with independently branded affiliated practices that share a patient portal
* Cancer center affiliated with one portal for adult patients and another portal for pediatric patients
* Clinical organization that has recently merged and still uses distinct brands
* Aggregation publication of brands by EHR level
* Distributed publication of brands at the healthcare provider organization level

##### Demonstration Brand Editor

The [SMART Patient Access: Brand Editor](https://brand-editor.argo.run/) is a demonstration brand editor with FHIR export that showcasing the capabilities of the API through a user interface. It allows users to edit and preview branding configurations for an example SMART on FHIR app.

#### Guidelines For API Providers Publishing Brands Associated With Their FHIR Endpoints

A healthcare provider, payer, or other organization exposing a FHIR patient access API can **decide which brands to publish**  with their FHIR endpoints. Each Brand includes data describing the organization offering patient access (e.g., organization name and logo) together with details about their patient access offering (e.g., name and description of their patient portal) in terms that patients should recognize.

An app can:

* **Display** the Brands it has collected (e.g., as cards or tiles in a UX)
* Allow users to **filter or search** Brands based on names, locations, or categories
* Allow users to **select and connect** to a Brand's API endpoint

### Brand Information

#### Essential Information Included In Each Brand

Each Brand includes the following information intended to support an app-based card or tile UX:

| Field | Description | Cardinality |
| --- | --- | --- |
| Name|Primary name for the organization to display on a card, e.g., "General Hospital" | 1..1 |
| Consumer-facing website for this Brand | note this is distinct from a patient portal, described under "Patient Access Details" below | 1..1 |
| Logo |to be displayed on a card, and link to logo use terms/agreements | 0..1 |
| Aliases | e.g., former names like "General Health Associates" for filtering/search | 0..* |
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

Commonly, a single Brand is typically associated with a single Endpoint. But the following cases are supported by this conceptual model:

* *One Brand is associated with one Endpoint*
    * For instance, a national lab might publish a Brand associated with their overall organization, including a complete list of zip codes where they operate.
* *Multiple Brands are associated with one Endpoint*
    * For instance, a regional health system might publish a small collection of brands based on a specific hospital or clinic that their patients will recognize.
* *One Brand is associated with  multiple Endpoints*
    * For instance, a Hospital offering more than one patient portal for legacy purposes, or a patient portal hosting multiple FHIR API versions simultaneously
    * Becaues Brand information may be published in multiple place, Organizations include the same `identifier` to facilitate matching, merging, and de-duplication. Apps can merge Brands into a single target Brand's card by displaying the target Brand's title and logo. Within the Brand's card, the app displays a distinct "connect" button for each set of Patient Access Details.

### FHIR Profiles

#### Explanation Of FHIR Profiles For Endpoint And Organization Resources

An app assembles its collection of Brands (potentially as an offline, configuration-time process) by gathering  FHIR `PatientAccessEndpoint` (Endpoints) and `PatientAccessBrand` (Organizations) data from:

* Vendor-consolidated Brand Bundles
* FHIR resources linked from `.well-known/smart-configuration` for each endpoint

which are defined below. For fine-grained organizational management, apps SHALL select the FHIR resources linked from `.well-known/smart-configuration` if they differ from the resources in a vendor-consolidated Brand Bundle.

#### FHIR Patient Access Endpoint Profile

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
 
#### FHIR Patient Access Brand Bundle Profile

{{site.data.structuredefinitions.patient-access-brands-bundle.description}}

[Formal Views of Profile Contents](StructureDefinition-patient-access-brands-bundle.html)
  
  
##### Partial View Of Brand Bundle Example

The following Bundle fragments in the example below illustrate how Brand data is compiled into a Bundle and how 
a Brand (in other words, an Organization) references an Endpoint within the same Bundle. See the [Patient-Access Brand Examples](example-brands.html) for complete examples. 

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
      "id": "examplelabs",
      // ...
    }
  }, {
    "fullUrl": "https://pab.example.org/Organization/example",
    "resource": {
      "resourceType": "Organization",
      "name": "Example Hospital",
      /// ...
      "endpoint": [{
         "reference": "Endpoint/examplelabs",
         "display": "FHIR R4 Endpoint for ExampleLabs Brand"
      }]
    }
  }],
  // ...
}
```



#### Rules And Best Practices For Creating And Using Patient Access Profiles

##### Guidelines For Caching And Managing Cross Origin Resource Sharing (CORS) For FHIR Resources

Publishers SHALL support [Cross-Origin Resource Sharing (CORS)](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Origin) for all GET requests to the artifacts described in this guide.

Publishers SHOULD include a weak `ETag` header in all HTTP responses. Clients SHOULD cache responses by ETag and SHOULD consist of an `If-None-Match` header in all requests to avoid re-fetching data that have not changed. See <https://www.hl7.org/fhir/http.html> for background.

##### Metadata in `.well-known/smart-configuration`

FHIR servers supporting this IG SHOULD include the following property in the SMART configuration JSON response:

* `0..1` `patientAccessBrandBundle` URL of a Brand Bundle. The Bundle entries include any Brand and "peer endpoints" associated with this FHIR endpoint.
* `0..1` `patientAccessPrimaryBrandIdentifier`: FHIR Identifier for this server's primary Brand within the Bundle. Publishers SHALL populate this property if the referenced Brand Bundle includes more than one Brand. When present, this identifier SHALL consist of a `value` and SHOULD have a `system`. 

The Brand Bundle SHALL include a Brand whose `Organization.identifier` matches the primary Brand identifier from SMART configuration JSON.

The Brand Bundle SHOULD include only the Brands and Endpoints associated with the SMART on FHIR server that links to the Bundle. However, the Brand Bundle MAY have additional Brands or Endpoints (e.g., supporting a publication pattern where endpoints from a given vendor might point to a comprehensive, centralized vendor-managed list). 

###### Example `.well-known/smart-configuration`

```javascript
{
  // details at http://hl7.org/fhir/smart-app-launch/conformance.html
  "patientAccessBrandBundle": "https://example.org/brands.json",
  "patientAccessPrimaryBrandIdentifier": {
      "system": "urn:ietf:rfc:3986",
      "value": "https://example.org"
  },
  // ...
}
```

Dereferencing the `patientAccessBrandBundle` URL above would return a Brand Bundle.

##### Must-Support Definition (`MS`) and Data Absent Reasons
For this specification a profile element labeled as "must support" means publishers must provide a way for Brands to populate value. For example, marking a Brand's "address" as `0..* MS` means that a publisher needs to give Brands a way to supply multiple addresses, even if some choose not to provide any.

The EHR that publishes a Brand Bundle may not have some required data elements (Brand Website, Portal Website, Portal Name). If the EHR has asked, but a Brand administrator has not supplied a value, the EHR MAY provide a [Data Absent Reason](http://hl7.org/fhir/StructureDefinition/data-absent-reason) of `asked-declined` or `asked-unknown`. The EHR SHALL NOT use other Data Absent Reasons.
