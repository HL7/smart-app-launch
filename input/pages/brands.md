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

* National laboratory with many locations
* Regional health system with independently branded affiliated practices that share a patient portal
* Cancer center affiliated with one portal for adult patients and another portal for pediatric patients
* Clinical organization that has recently merged and still uses distinct brands

#### Guidelines For API Providers Publishing Brands Associated With Their FHIR Endpoints

A healthcare provider, payer, or other organization exposing a FHIR patient access API can **decide which brands to publish** in association with their FHIR endpoints. Each Brand includes data describing the organization (e.g., organization name and logo that a patient would recognize) together with details about their patient access portals (e.g., name, logo, an description in terms that patients should recognize) and the API endpoints associated with these portals.

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
| Portal Details | describes a portal this Brand offers to patients **See the table below**.| 1..* |
{:.grid}

#### Portal Details

The details of the Patient Access Brand communicated to the patient.

| Field | Description | Cardinality |
| --- | --- | --- |
| Portal name | e.g., "Patient Gateway" or "MyChildrens Portal" | 1..1 |
| Portal logo | to be displayed on a card for Brands that have a portal logo in addition to their brand logo | 0..1 |
| Portal URL | where patients can manage accounts with this provider. | 1..1 |
| Patient-facing description | explaining the subset of patients eligible to connect, or the data available in a patient-friendly language | 0..1 |
| API Endpoints| FHIR API Endpoints associated with the portal | 0..* |
{:.grid}


#### Understanding Relationships Among Brands, Portals, and Endpoints

Commonly, a single Brand is typically associated with a single patient Portal that offers a single FHIR Endpoint. But all of the following cases are supported by this conceptual model:

* *One Brand associated with multiple Portals*
    * e.g., a hospital may offer more than one patient portal for legacy purposes
    * e.g., a tertiary cancer center may offer one patient portal for adults and another for pediatric patients
    * Becaues Brand information may be published in multiple places, Organizations include the same `identifier` to facilitate matching, merging, and de-duplication. Apps can merge Brands into a single target Brand's card by displaying the target Brand's title and logo. Within the Brand's card, the app displays a distinct "connect" button for each set of Patient Access Details.
* *One Portal associated with multiple FHIR Endpoints*
    * e.g., a national lab's portal might have one Endpoint for FHIR R4 and another for FHIR R2
    * e.g., a national lab's portal might have one Endpoint for laboratory results and another for imaging results
* *Multiple Brands are associated with the same Portal*
    * e.g., a regional health system might publish a small collection of brands based associated with specific hospitals or clinics that their patients will recognize, each independently branded -- even though all these paths lead to the same portal and FHIR Endpoints.

### FHIR Profiles

#### Explanation of FHIR Profiles for Endpoint and Organization Resources

An app assembles its collection of Brands (typically as an offline, configuration-time process) by gathering FHIR `PatientAccessEndpoint` (Endpoints) and `PatientAccessBrand` (Organizations) resources from:

* Vendor-consolidated Brand Bundles that are openly published (e.g., in the context of a national EHR Certification program)
* Brand Bundles linked from `.well-known/smart-configuration` for known endpoints

For fine-grained organizational management, apps SHALL select the FHIR resources linked from `.well-known/smart-configuration` if they differ from the resources in a vendor-consolidated Brand Bundle.

#### FHIR Patient Access Brands (Organization) Profile

{{site.data.structuredefinitions.patient-access-brand.description}}

[Full Profile Details](StructureDefinition-patient-access-brand.html)

##### Example

[Organization Example](Organization-example.html)

```javascript

{% include_relative Organization-example.json %}

```

#### FHIR Patient Access Endpoint Profile

{{site.data.structuredefinitions.patient-access-endpoint.description}}

[Full Profile Details](StructureDefinition-patient-access-endpoint.html)
    
##### Example

[Endpoint Example](Endpoint-example.html)

 
#### FHIR Patient Access Brand Bundle Profile

{{site.data.structuredefinitions.patient-access-brands-bundle.description}}

[Full Profile Details](StructureDefinition-patient-access-brands-bundle.html)
  
  
##### Brand Bundle Examples

Brands and Endpoints are compiled together and published in a Brand Bundle. See the [Patient-Access Brand Examples](example-brands.html) for complete examples. 


#### Rules And Best Practices 

##### Consistent Identifiers for Organizations

Apps can use a Brand's `Organization.identifier` element to merge content published in multiple sources. To facilitate robust matching, EHRs SHALL support customer-supplied identifiers (`system` and `value`). It is RECOMMENDED that each Brand include an identifier where `system` is `urn:ietf:rfc: 3986` (meaning the identifier is a URL) and `value` is the HTTPS URL for the Brand's primary web presence, omitting any "www." prefix from the domain and omitting any path component. For example, since the main web presence of Boston Children's Hospital is https: //www.childrenshospital.org/, a recommended identifier would be:\n\n  `{"system": "urn:ietf:rfc:3986", "value": "https://childrenshospital.org"}`.

##### Managing Cross Origin Resource Sharing (CORS) For FHIR Resources

Publishers SHALL support [Cross-Origin Resource Sharing (CORS)](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Origin) for all GET requests to the artifacts described in this guide.

##### Caching Brand Bundles

Publishers SHOULD include a weak `ETag` header in all HTTP responses. Clients SHOULD cache responses by ETag and SHOULD provide an `If-None-Match` header in all requests to avoid re-fetching data that have not changed. See <https://www.hl7.org/fhir/http.html#cread> for background.

##### Metadata in `.well-known/smart-configuration`

FHIR servers supporting this IG SHOULD include the following property in the SMART configuration JSON response:

* `0..1` `patientAccessBrandBundle` URL of a Brand Bundle. The Bundle entries include any Brand and "peer endpoints" associated with this FHIR endpoint.
* `0..1` `patientAccessBrandIdentifier`: FHIR Identifier for this server's primary Brand within the Bundle. Publishers SHALL populate this property if the referenced Brand Bundle includes more than one Brand. When present, this identifier SHALL consist of a `value` and SHOULD have a `system`. 

The Brand Bundle SHALL include exactly one Brand with an `Organization.identifier` that matches the primary Brand identifier from SMART configuration JSON.

The Brand Bundle SHOULD include only the Brands and Endpoints associated with the SMART on FHIR server that links to the Bundle. However, the Brand Bundle MAY have additional Brands or Endpoints (e.g., supporting a publication pattern where endpoints from a given vendor might point to a comprehensive, centralized vendor-managed list). 

###### Example `.well-known/smart-configuration`

```javascript
{
  // details at http://hl7.org/fhir/smart-app-launch/conformance.html
  "patientAccessBrandBundle": "https://example.org/brands.json",
  "patientAccessBrandIdentifier": {
      "system": "urn:ietf:rfc:3986",
      "value": "https://example.org"
  },
  // ...
}
```

Dereferencing the `patientAccessBrandBundle` URL above would return a Brand Bundle.

##### Must-Support Definition (`MS`) and Data Absent Reasons

For this specification a profile element labeled as "must support" means publishers must provide a way for Brands to populate value. For example, marking a Brand's "address" as `0..* MS` means that a publisher needs to give Brands a way to supply multiple addresses, even if some choose not to provide any.

An EHR that publishes a Brand Bundle may not have some required data elements (Brand Website, Portal Website, Portal Name). If the EHR has asked, but a Brand administrator has not supplied a value, the EHR MAY provide a [Data Absent Reason](http://hl7.org/fhir/StructureDefinition/data-absent-reason) of `asked-declined` or `asked-unknown`. The EHR SHALL NOT use other Data Absent Reasons.
