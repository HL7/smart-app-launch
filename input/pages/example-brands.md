{% capture SQUARE %}<span style="font-size:1em">&#9634;</span>{% endcapture %}

*The brands below are fabricated for the purpose of these examples.*

### Example 1: Lab with Thousands of Locations Nationwide

* One national brand
* Locations in thousands of cities

The configuration below establishes a single top-level Brand with a long list of ExampleHealth addresses. (The organization can also group  their locations into sub-brands such as "ExampleLabs Alaska")


<div class="bg-info" markdown="1">

![](https://i.imgur.com/Kv5gq3Z.png) **ExampleLabs** ([examplelabs.com](https://example.org/examplelabs.com)

|Source|API|Portal|
|--|--|--|
|**RxampleLabs Patient™ portal**|{{SQUARE}} Connect|{{SQUARE}} View |
{:.grid style="background-color: white"}

Nearest location: 1 mile (Madison)

</div><!-- info -->

The FHIR server's `.well-known/smart-configuration` file would include a link like

    "patientAccessBrands": "https://examplelabs.example.com/branding.json"
    
And the hosted` Patient Access Brands Bundle file would look like:

[ExampleLabs Brands Bundle](Bundle-example1.html)

~~~json
{% include_relative Bundle-example1.json %}
~~~


### Example 2: Regional Health System With Independently Branded Affiliates

* Regional health system ("ExampleHealth")
* Multiple locations in/around 12 cities
* Provides EHR for many affiliates (distinctly branded sites like "ExampleHealth Physicians of Madison" or "ExampleHealth Community Hospital")

The system displays the following cards to a user:

<div class="bg-info" markdown="1">
![](https://i.imgur.com/dP83Tuq.png)  **ExampleHealth** ([examplehealth.org](https://www.examplehealth.org))

|Source|API|Portal|
|--|--|--|
|**MyExampleHospital**| {{SQUARE}}  Connect|{{SQUARE}} View |
{:.grid style="background-color: white"}

Nearest location: 13 miles (Madison)

</div><!-- info -->

<div class="bg-info" markdown="1">
![](https://i.imgur.com/1RbPNCv.png) **ExampleHealth Physicians of Madison** ([ehpmadison.com](https://www.ehpmadison.com/))

|Source|API|Portal|
|--|--|--|
|**MyExampleHospital**| {{SQUARE}}  Connect|{{SQUARE}} View |
{:.grid style="background-color: white"}

Nearest location: 1 mile (Madison)
</div><!-- info -->

<div class="bg-info" markdown="1">
![](https://i.imgur.com/GjS3s6U.png)  **ExampleHealth Community Hospital** ([ehchospital.org](https://www.ehchospital.org/))

|Source|API|Portal|
|--|--|--|
|**MyExampleHospital**| {{SQUARE}}  Connect|{{SQUARE}} View |
{:.grid style="background-color: white"}

Nearest location: 120 miles (Lake City)
</div><!-- info -->

(And two more cards for other affiliated brands sharing the MyExampleHospital portal.)

~~~json
{% include_relative Bundle-example2.json %}
~~~

### Example 3: Different EHRs for different sub-populations displayed in a unified card

*(Note: this is not an uncommon pattern. For example see https://info.chesapeakeregional.com/patient-portal, https://www.tuftsmedicalcenter.org/myTuftsMedicalCenter, https://www.nuvancehealth.org/patients-and-visitors/patient-portals, https://www.ouhealth.com/ou-health-patients-families/patient-portals, or run a search like https://www.google.com/search?q=%22patient+portals%22+%22if+you%22.)*

The ExampleHospital's patient portals below are split by audience:
* EHR1: "Patient Gateway" for adult patients to help them connect with providers, manage appointments and refill prescriptions.
* EHR2: "Pediatrics", a patient portal where parents can access their child's information.

Based on the definitions below, there would be top-level Brand cards for the two Hospital's, ExampleHospital1 and ExampleHospital2

<div class="bg-info" markdown="1">
![](https://i.imgur.com/IVuJArL.png) **ExampleHospital1** ([examplehospital1.org](https://www.example.org/hospital1/))

|Source|API|Portal|
|--|--|--|
|**Patient Gateway**|{{SQUARE}} Connect |{{SQUARE}} View|
{:.grid style="background-color: white"}

Nearest location: 3 miles (Boston)
</div><!-- info -->

<div class="bg-info" markdown="1">
![](https://i.imgur.com/K0A3NjL.png) **ExampleHospital2** ([examplehospital2.org](https://www.example.org/hospital2/))


|Source|API|Portal|
|--|--|--|
|**Pediatrics**|{{SQUARE}} Connect |{{SQUARE}} View|
{:.grid style="background-color: white"}

Nearest location: 3 miles (Boston)
</div><!-- info -->

ExampleHospital3's patient portal is split by audience:
* Patient Gateway for adult patients to help them connect with providers, manage appointments and refill prescriptions.
* Pediatrics, a patient portal where parents can access their child's information.

Without a consistent identifier on both Organizations, ExampleHospital3 would have two cards. This is accurate and works, but may not reflect the organization's desired formatting:

<div class="bg-info" markdown="1">
![](https://i.imgur.com/OjSDF1Z.png) **ExampleHospital3** ([examplehospital3.org](https://www.example.org/hospital3/))

|Source|API|Portal|
|--|--|--|
|**Patient Gateway** *Patient Gateway is an online tool to help adult patients connect with healthcare providers, manage appointments, and refill prescriptions.*|{{SQUARE}}Connect|{{SQUARE}} View|
{:.grid style="background-color: white"}

Nearest location: 3 miles (Boston)
</div><!-- info -->

<div class="bg-info" markdown="1">
![](https://i.imgur.com/OjSDF1Z.png) **ExampleHospital3** ([examplehospital3.org](https://www.example.org/hospital3/))

|Source|API|Portal|
|--|--|--|
|**Pediatrics**|{{SQUARE}} Connect |{{SQUARE}} View|
{:.grid style="background-color: white"}

Nearest location: 3 miles (Boston)
</div><!-- info -->


Since the definitions below include a consistent identifier (system `urn:ietf:rfc:3986`, value `https://examplehospital3.org`), the system can combine the two ExampleHospital3 connection choices into a single card at display time. This results in a card more like this:

<div class="bg-info" markdown="1">
![](https://i.imgur.com/OjSDF1Z.png) **ExampleHospital3** ([examplehospital3.org](https://www.example.org/hospital3/))

|Source|API|Portal|
|--|--|--|
|**Patient Gateway**| {{SQUARE}}  Connect|{{SQUARE}} View |
|**Pediatrics**|{{SQUARE}} Connect |{{SQUARE}} View|
{:.grid style="background-color: white"}

Nearest location: 3 miles (Boston)
</div><!-- info -->


#### EHR1 content for ExampleHospital1 (with ExampleHospital3 as `partOf`)
```javascript
{
  "resourceType": "Bundle",
  "type": "collection",
  "meta": {
    "lastUpdated": "2022-03-14T15:09:26.535Z"
  },
  "entry": [
    {
      "fullUrl": "https://epic.example.org/Endpoint/mgb-endpoint-r2",
      "resource": {
        "resourceType": "Endpoint",
        "id": "unity-point",
        "address": "https://ws-interconnect-fhir.partners.org/Interconnect-FHIR-MU-PRD/api/FHIR/DSTU2",
        "name": "FHIR DSTU2 Endpoint for Mass General Brigham Patient Gateway",
        "managingOrganization": {
          "reference": "Organization/mgb"
        },
        "extension": [
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/endpoint-fhir-version",
            "valueCode": "1.0.2"
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
    },
    {
      "fullUrl": "https://epic.example.org/Organization/mgb",
      "resource": {
        "resourceType": "Organization",
        "id": "mgb",
        "extension": [
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/brand-logo",
            "valueUrl": "https://www.example.org/hospital1.org
          /themes/custom/partners_mgb/logo.svg"
          },
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/patient-access-url", 
            "valueUrl": "https://patientgateway.examplehospital1.org
          /"
          },
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/patient-access-name",
            "valueString": "Mass General Brigham Patient Gateway"
          }
        ],
        "name": "Mass General Brigham",
        "alias": [
          "Partners Healthcare",
          "Brigham and Women's",
          "Newton-Wellesley Hospital"
        ],
        "identifier": [
          {
            "system": "urn:ietf:rfc:3986",
            "value": "https://examplehospital1.org
          "
          }
        ],
        "telecom": [
          {
            "system": "url",
            "value": "https://www.example.org/hospital1.org
          /"
          }
        ],
        "address": [
          {
            "city": "Boston",
            "state": "MA"
          },
          {
            "city": "Newton",
            "state": "MA"
          },
          {
            "city": "Walpole",
            "state": "MA"
          },
          {
            "city": "Waltham",
            "state": "MA"
          },
          {
            "city": "Newton",
            "state": "MA"
          }
        ]
      }
    },
    {
      "fullUrl": "https://epic.example.org/Organization/examplehospital3",
      "resource": {
        "resourceType": "Organization",
        "id": "data-farber",
        "partOf": {
          "reference": "Organization/mbg"
        },
        "extension": [
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/brand-logo",
            "valueUrl": "https://www.example.org/hospital3/ui/images/img-logo-2x-new.webp"
          },
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/patient-access-description",
            "valueMarkdown": "Patient Gateway is an online tool to help adult patients connect with health care providers, manage appointments, and refill prescriptions."
          }
        ],
        "name": "Dana-Farber Cancer Institute",
        "alias": [],
        "identifier": [
          {
            "system": "urn:ietf:rfc:3986",
            "value": "https://examplehospital3.org"
          }
        ],
        "telecom": [
          {
            "system": "url",
            "value": "https://www.example.org/hospital3/"
          }
        ],
        "address": [
          {
            "city": "Boston",
            "state": "MA"
          }
        ]
      }
    }
  ]
}
```

#### Cerner Content for Boston Children's Hospital (with Dana Farber as `partOf`)


```javascript
{
  "resourceType": "Bundle",
  "type": "collection",
  "meta": {
    "lastUpdated": "2022-03-14T15:09:26.535Z"
  },
  "entry": [
    {
      "fullUrl": "https://cerner.example.org/Endpoint/bch-r4",
      "resource": {
        "resourceType": "Endpoint",
        "id": "bch-r4",
        "address": "https://bch.cerner.examlpe.org/r4",
        "name": "FHIR R4 Endpoint for Boston Children's Hospital",
        "managingOrganization": {
          "reference": "Organization/bch"
        },
        "extension": [
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/endpoint-fhir-version",
            "valueCode": "4.0.1"
          },
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/patient-access-developer-url",
            "valueUrl": "https://code.cerner.com"
          }
        ],
        "connectionType": {
          "system": "http://terminology.hl7.org/CodeSystem/endpoint-connection-type",
          "code": "hl7-fhir-rest"
        }
      }
    },
    {
      "fullUrl": "https://cerner.example.org/Organization/bch",
      "resource": {
        "resourceType": "Organization",
        "id": "bch",
        "extension": [
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/brand-logo",
            "valueUrl": "https://www.example.org/hospital2/-/media/BCH-Global/Landing-Pages/National-Brand/BCHlogo.ashx?h=85&w=600&la=en&hash=AF50B39C3F246D61E4C012ED25A2D8CF4C3A1607"
          },
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/patient-access-url",
            "valueUrl": "https://apps.examplehospital2/mychildrens/index.html"
          },
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/patient-access-name",
            "valueString": "MyChildrens Patient Portal"
          }
        ],
        "name": "Boston Children's Hospital",
        "alias": [],
        "identifier": [
          {
            "system": "urn:ietf:rfc:3986",
            "value": "https://examplehospital2"
          }
        ],
        "telecom": [
          {
            "system": "url",
            "value": "https://www.example.org/hospital2/"
          }
        ],
        "address": [
          {
            "city": "Boston",
            "state": "MA"
          }
        ]
      }
    },
    {
      "fullUrl": "https://cerner.example.org/Organization/examplehospital3",
      "resource": {
        "resourceType": "Organization",
        "id": "data-farber",
        "partOf": {
          "reference": "Organization/bch"
        },
        "extension": [
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/brand-logo", 
            "valueUrl": "https://www.example.org/hospital3/ui/images/img-logo-2x-new.webp"
          },
          {
            "url": "http://fhir.org/argonaut/StructureDefinition/patient-access-description",  \\<<<Where is this extension defined >>>
            "valueMarkdown": "MyChildren's Patient Portal is a Web-based, easy-to-use, and secure way to access your child's information at your convenience."
          }
        ],
        "name": "Dana-Farber Cancer Institute",
        "alias": [],
        "identifier": [
          {
            "system": "urn:ietf:rfc:3986",
            "value": "https://examplehospital3.org"
          }
        ],
        "telecom": [
          {
            "system": "url",
            "value": "https://www.example.org/hospital3/"
          }
        ],
        "address": [
          {
            "city": "Boston",
            "state": "MA"
          }
        ]
      }
    }
  ]
}
```


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