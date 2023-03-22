{% capture SQUARE %}<span style="font-size:1em">&#9634;</span>{% endcapture %}

*The brands below are fabricated for the purpose of these examples.*

### Example 1: Lab with Thousands of Locations Nationwide

* One national brand
* Locations in thousands of cities

The configuration below establishes a single top-level Brand with a long list of ExampleHealth addresses. (The organization can also group  their locations into sub-brands such as "ExampleLabs Alaska")


<div class="bg-info" markdown="1">

<img src="Logo1.png" alt="ExampleLabs" width="40"/> **ExampleLabs** ([examplelabs.com](#))

|Source|API|Portal|
|--|--|--|
|**ExampleLabs Patient™ portal**|{{SQUARE}} Connect|{{SQUARE}} View |
{:.grid style="background-color: white"}

Nearest location: 1 mile (Madison)

</div><!-- info -->

The FHIR server's `.well-known/smart-configuration` file would include a link like

    "patientAccessBrands": "https://examplelabs.example.com/branding.json"
    
And the hosted` Patient Access Brands Bundle file would look like:

[Raw JSON](Bundle-example1.json)

~~~json
{% include_relative Bundle-example1.json %}
~~~


### Example 2: Regional Health System With Independently Branded Affiliates

* Regional health system ("ExampleHealth")
* Multiple locations in/around 12 cities
* Provides EHR for many affiliates (distinctly branded sites like "ExampleHealth Physicians of Madison" or "ExampleHealth Community Hospital")

The system displays the following cards to a user:

<div class="bg-info" markdown="1">
<img src="Logo2.png" alt="ExampleHealth" width="40"/>  **ExampleHealth** ([examplehealth.org](#))

|Source|API|Portal|
|--|--|--|
|**MyExampleHospital**| {{SQUARE}}  Connect|{{SQUARE}} View |
{:.grid style="background-color: white"}

Nearest location: 13 miles (Madison)
</div><!-- info -->

<div class="bg-info" markdown="1">
<img src="Logo8.png" alt="ExampleHealth Physicians of Madison" width="40"/> **ExampleHealth Physicians of Madison** ([ehpmadison.com](#))

|Source|API|Portal|
|--|--|--|
|**MyExampleHospital**| {{SQUARE}}  Connect|{{SQUARE}} View |
{:.grid style="background-color: white"}

Nearest location: 1 mile (Madison)
</div><!-- info -->

<div class="bg-info" markdown="1">
<img src="Logo5.svg" alt="ExampleHealth Community Hospital" width="40"/>  **ExampleHealth Community Hospital** ([ehchospital.org](#))

|Source|API|Portal|
|--|--|--|
|**MyExampleHospital**| {{SQUARE}}  Connect|{{SQUARE}} View |
{:.grid style="background-color: white"}

Nearest location: 120 miles (Lake City)
</div><!-- info -->

(And two more cards for other affiliated brands sharing the MyExampleHospital portal.)

[Raw JSON](Bundle-example2.json)

~~~json
{% include_relative Bundle-example2.json %}
~~~

### Example 3: Different EHRs for different sub-populations displayed in a unified card

*(Note: this is not an uncommon pattern. For example see, <https://www.tuftsmedicalcenter.org/myTuftsMedicalCenter>, <https://www.nuvancehealth.org/patients-and-visitors/patient-portals>, <https://www.ouhealth.com/ou-health-patients-families/patient-portals>, or run a search like <https://www.google.com/search?q=%22patient+portals%22+%22if+you%22>.)*

The ExampleHospital's patient portals below are split by audience:
* EHR1: "Patient Gateway" for adult patients to help them connect with providers, manage appointments and refill prescriptions.
* EHR2: "Pediatrics", a patient portal where parents can access their child's information.

Based on the definitions below, there would be top-level Brand cards for the two Hospital's, ExampleHospital1 and ExampleHospital2

<div class="bg-info" markdown="1">
<img src="Logo12.svg" alt="ExampleHospital1" width="40"/> **ExampleHospital1** ([examplehospital1.org](#))

|Source|API|Portal|
|--|--|--|
|**Patient Gateway**|{{SQUARE}} Connect |{{SQUARE}} View|
{:.grid style="background-color: white"}

Nearest location: 3 miles (Boston)
</div><!-- info -->

<div class="bg-info" markdown="1">
<img src="Logo7.svg" alt="ExampleHospital2" width="40"/> **ExampleHospital2** ([examplehospital2.org](#))


|Source|API|Portal|
|--|--|--|
|**Pediatrics**|{{SQUARE}} Connect |{{SQUARE}} View|
{:.grid style="background-color: white"}

Nearest location: 3 miles (Boston)
</div><!-- info -->

ExampleHospital3's patient portal is split by "Patient Gateway" and "Pediatrics".

Without a consistent identifier on both Organizations, ExampleHospital3 would have two cards:

<div class="bg-info" markdown="1">
<img src="Logo9.svg" alt="ExampleHospital3" width="40"/> **ExampleHospital3** ([examplehospital3.org](#))

|Source|API|Portal|
|--|--|--|
|**Patient Gateway**|{{SQUARE}}Connect|{{SQUARE}} View|
{:.grid style="background-color: white"}

Nearest location: 3 miles (Boston)
</div><!-- info -->

<div class="bg-info" markdown="1">
<img src="Logo9.svg" alt="ExampleHospital3" width="40"/> **ExampleHospital3** ([examplehospital3.org](#))

|Source|API|Portal|
|--|--|--|
|**Pediatrics**|{{SQUARE}} Connect |{{SQUARE}} View|
{:.grid style="background-color: white"}

Nearest location: 3 miles (Boston)
</div><!-- info -->


Although displaying 2 cards is correct, it may not reflect the organization's desired formatting.  Since the definitions below include a consistent identifier (system `urn:ietf:rfc:3986`, value `https://examplehospital3.org`), the system can combine the two ExampleHospital3 connection choices into a single card at display time. This results in a card more like this:

<div class="bg-info" markdown="1">
<img src="Logo9.svg" alt="ExampleHospital3" width="40"/> **ExampleHospital3** ([examplehospital3.org](#))

|Source|API|Portal|
|--|--|--|
|**Patient Gateway**| {{SQUARE}}  Connect|{{SQUARE}} View |
|**Pediatrics**|{{SQUARE}} Connect |{{SQUARE}} View|
{:.grid style="background-color: white"}

Nearest location: 3 miles (Boston)
</div><!-- info -->


#### EHR1 content for ExampleHospital1 (with ExampleHospital3 as `partOf`)


[Raw JSON](Bundle-example3.json)

~~~json
{% include_relative Bundle-example3.json %}
~~~


#### EHR2 Content for ExampleHospital2 (with ExampleHospital3 as `partOf`)



[Raw JSON](Bundle-example4.json)

~~~json
{% include_relative Bundle-example4.json %}
~~~



### Example 4: Two co-equal brands ("Brand1" + "Brand2")

##### Option 1: Combine both Brands as Affiliated with a Hidden Brand

* One endpoint with a parent brand
* Parent brand marked as "hidden"
* Child brands for Brand1 + Brand2, pointing up to "primary brand"

##### Option 2: Duplicate the Endpoint

* two endpoints with the same address
* Each endpoint points to its primary brand
* No brand hierarchy


##### Option 3: Replace Endpoint.managingOrganization with a Multi-cardinality Extension

* One endpoint with links to two primary brands
* No brand hierarchy

```javascript
{
  "resourceType": "Bundle",
  "type": "collection",
  "meta": {
    "lastUpdated": "2022-03-14T15:09:26.535Z"
  },
  "entry": [
    {
      "fullUrl": "https://epic.example.org/Endpoint/brand2",
      "resource": {
        "resourceType": "Endpoint",
        "id": "brand2",
        "address": "https://brand1.org/ProdFHIR/api/FHIR/R4",
        "name": "FHIR R4 Endpoint for Brand1/Brand2",
        "managingOrganization": {
          "reference": "Organization/brand2"
        },
        "extension": [
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/endpoint-fhir-version",
            "valueCode": "4.0.1"
          },
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/patient-access-developer-url",
            "valueUrl":  "https://open.epic.com"
          }
 
        ],
        "connectionType": {
          "system": "http://terminology.hl7.org/CodeSystem/endpoint-connection-type",
          "code": "hl7-fhir-rest"
        }
      }
    }, {
      "fullUrl": "https://epic.example.org/Endpoint/brand1",
      "resource": {
        "resourceType": "Endpoint",
        "id": "brand1",
        "address": "https://brand1.org/ProdFHIR/api/FHIR/R4",
        "name": "FHIR R4 Endpoint for Brand1/Brand2",
        "managingOrganization": {
          "reference": "Organization/brand1"
        },
        "extension": [
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/endpoint-fhir-version",
            "valueCode": "4.0.1"
          },
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/patient-access-developer-url",
            "valueUrl":  "https://open.epic.com"
          }
 
        ],
        "connectionType": {
          "system": "http://terminology.hl7.org/CodeSystem/endpoint-connection-type",
          "code": "hl7-fhir-rest"
        }
      }
    },{
      "fullUrl": "https://epic.example.org/Organization/brand1",
      "resource": {
        "resourceType": "Organization",
        "id": "brand1",
        "extension": [
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/brand-logo",
            "valueUrl": "https://examplehealth.org/logo/main.1024x102.png"
          },
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/patient-access-url",
            "valueUrl": "https://chart.brand1.org"
          }
        ],
        "name": "Brand1",
        "alias": [],
        "identifier": [],
        "telecom": [],
        "address": []
      }
    }, {
      "fullUrl": "https://epic.example.org/Organization/brand2",
      "resource": {
        "resourceType": "Organization",
        "id": "brand2",
        "extension": [
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/brand-logo",
            "valueUrl": "https://examplehealth.org/logo/main.1024x102.png"
          },
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/patient-access-url",
            "valueUrl": "https://chart.brand1.org"
          }
        ],
        "name": "Brand2",
        "alias": [],
        "identifier": [],
        "telecom": [],
        "address": []
      }
    }
  ]
}

```